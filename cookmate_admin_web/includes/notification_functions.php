<?php
/**
 * Food CHART - Notification Functions & Reusable Service Layer
 * Implements relational notification management, the strict 24-hour read retention query rule,
 * idempotent read timestamp handling, and automatic event dispatching.
 */

require_once __DIR__ . '/../config/db.php';

/**
 * Automatically ensures notification database tables exist and are properly structured.
 * Self-healing schema for both local development and live production hosting (InfinityFree).
 */
function ensure_notifications_tables_exist(PDO $pdo): void {
    static $alreadyRun = false;
    if ($alreadyRun) return;

    try {
        // 1. Ensure users table exists
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                display_name VARCHAR(100) NOT NULL,
                email VARCHAR(150) NULL,
                auth_token VARCHAR(255) NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ");

        // 2. Ensure notifications catalog table exists
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS notifications (
                id INT AUTO_INCREMENT PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                message TEXT NOT NULL,
                type VARCHAR(50) NOT NULL DEFAULT 'general',
                target_type VARCHAR(32) NOT NULL DEFAULT 'all',
                target_user_id INT NULL,
                related_type VARCHAR(50) NULL,
                related_id VARCHAR(100) NULL,
                image VARCHAR(500) NULL,
                action_label VARCHAR(100) NULL,
                status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
                created_by_admin_id INT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                expires_at DATETIME NULL,
                INDEX idx_notif_status (status),
                INDEX idx_notif_created_at (created_at),
                INDEX idx_notif_target (target_type, target_user_id),
                INDEX idx_notif_related (related_type, related_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ");

        // Ensure action_label column exists on notifications table
        try {
            $notifCols = $pdo->query("SHOW COLUMNS FROM notifications")->fetchAll(PDO::FETCH_COLUMN);
            if (!in_array('action_label', $notifCols)) {
                $pdo->exec("ALTER TABLE notifications ADD COLUMN action_label VARCHAR(100) NULL AFTER image");
            }
        } catch (Exception $e) {}

        // 3. Inspect user_notifications table schema
        $needRecreateUn = false;
        try {
            $unCols = $pdo->query("SHOW COLUMNS FROM user_notifications")->fetchAll(PDO::FETCH_COLUMN);
            if (empty($unCols)) {
                $needRecreateUn = true;
            } elseif (!in_array('notification_id', $unCols) || !in_array('read_at', $unCols)) {
                // Table has old schema from previous migrations! Drop legacy and recreate relational table
                $pdo->exec("DROP TABLE IF EXISTS user_notifications");
                $needRecreateUn = true;
            }
        } catch (Exception $e) {
            $needRecreateUn = true;
        }

        if ($needRecreateUn) {
            $pdo->exec("
                CREATE TABLE IF NOT EXISTS user_notifications (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    notification_id INT NOT NULL,
                    user_id INT NOT NULL,
                    is_read TINYINT(1) NOT NULL DEFAULT 0,
                    read_at DATETIME NULL,
                    is_dismissed TINYINT(1) NOT NULL DEFAULT 0,
                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    UNIQUE KEY uq_notif_user (notification_id, user_id),
                    INDEX idx_un_user (user_id),
                    INDEX idx_un_notification (notification_id),
                    INDEX idx_un_read_status (is_read),
                    INDEX idx_un_read_at (read_at),
                    INDEX idx_un_user_read (user_id, is_read, read_at)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            ");
        }

        // 4. Seed initial default users if none exist
        $userCount = (int)$pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
        if ($userCount === 0) {
            $pdo->exec("
                INSERT INTO users (id, display_name, email, auth_token) VALUES 
                (1, 'Admin Chef', 'admin@foodchart.app', 'tok_admin_001'),
                (6, 'Abhishek', 'abhishek@example.com', 'tok_abhishek_6a9a773109227'),
                (7, 'Priya', 'priya@example.com', 'tok_priya_6a9a773109890')
            ");
        }

        // 5. Seed initial notifications if catalog is empty
        $notifCount = (int)$pdo->query("SELECT COUNT(*) FROM notifications")->fetchColumn();
        if ($notifCount === 0) {
            $pdo->exec("
                INSERT INTO notifications (title, message, type, target_type, related_type, related_id, action_label, status, created_at) VALUES 
                ('New Recipe Added 🍲', 'Chicken Ghee Roast is now available on Food CHART. Explore this authentic coastal delicacy!', 'new_recipe', 'all', 'recipe', 'rec_chicken_ghee_roast', 'View Recipe', 'active', NOW()),
                ('✨ Recipe Updated', 'Masala Dosa recipe has brand new step-by-step cooking instructions and crispiness tips.', 'recipe_updated', 'all', 'recipe', 'rec_masala_dosa', 'Check Recipe', 'active', NOW()),
                ('📢 Food CHART Community Update', 'Welcome to the Food CHART notification center! Stay updated with community recipes and chef tips.', 'admin_announcement', 'all', NULL, NULL, 'Tap to Explore', 'active', NOW()),
                ('🚀 New Feature: Trending Hashtags', 'Discover authentic regional specialties by tapping trending hashtags like #MalnadSpecial.', 'new_feature', 'all', 'feature', 'hashtags', 'Try Hashtags', 'active', NOW())
            ");
        }

        $alreadyRun = true;
    } catch (Exception $ex) {
        error_log('ensure_notifications_tables_exist error: ' . $ex->getMessage());
    }
}

/**
 * Creates a notification in the main catalog table.
 *
 * @param PDO $pdo
 * @param array $data [title, message, type, target_type, target_user_id, related_type, related_id, image, status, created_by_admin_id, expires_at]
 * @return int The created notification ID
 */
function create_system_notification(PDO $pdo, array $data): int {
    ensure_notifications_tables_exist($pdo);
    $stmt = $pdo->prepare("
        INSERT INTO notifications (
            title,
            message,
            type,
            target_type,
            target_user_id,
            related_type,
            related_id,
            image,
            action_label,
            status,
            created_by_admin_id,
            expires_at,
            created_at
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW()
        )
    ");

    $targetType = in_array($data['target_type'] ?? '', ['all', 'specific_user', 'all_except_user', 'selected_users']) ? $data['target_type'] : 'all';
    $status = in_array($data['status'] ?? '', ['active', 'inactive']) ? $data['status'] : 'active';

    $stmt->execute([
        trim($data['title'] ?? ''),
        trim($data['message'] ?? ''),
        trim($data['type'] ?? 'general'),
        $targetType,
        !empty($data['target_user_id']) ? (int)$data['target_user_id'] : null,
        !empty($data['related_type']) ? trim($data['related_type']) : null,
        !empty($data['related_id']) ? trim($data['related_id']) : null,
        !empty($data['image']) ? trim($data['image']) : null,
        !empty($data['action_label']) ? trim($data['action_label']) : null,
        $status,
        !empty($data['created_by_admin_id']) ? (int)$data['created_by_admin_id'] : 1,
        !empty($data['expires_at']) ? $data['expires_at'] : null,
    ]);

    return (int)$pdo->lastInsertId();
}

/**
 * Automatically purges notifications that have exceeded the strict 24-hour expiration rule:
 * - Purges notifications created > 24 hours ago
 * - Purges related user_notifications records
 * - Ensures mobile and admin only display fresh within-24-hour notifications
 */
function auto_purge_expired_notifications(PDO $pdo): int {
    try {
        $stmt1 = $pdo->prepare("
            DELETE FROM user_notifications 
            WHERE notification_id IN (
                SELECT id FROM notifications 
                WHERE created_at < NOW() - INTERVAL 24 HOUR
                   OR (expires_at IS NOT NULL AND expires_at < NOW())
            )
        ");
        $stmt1->execute();

        $stmt2 = $pdo->prepare("
            DELETE FROM notifications 
            WHERE created_at < NOW() - INTERVAL 24 HOUR
               OR (expires_at IS NOT NULL AND expires_at < NOW())
        ");
        $stmt2->execute();
        return (int)$stmt2->rowCount();
    } catch (Exception $e) {
        return 0;
    }
}

/**
 * Returns notifications for an authenticated user following the exact 24-hour rule:
 * - Only notifications created within the last 24 hours are returned (strict 24-hour retention).
 * - Read notifications > 24 hours or older notifications are automatically purged/hidden.
 *
 * @param PDO $pdo
 * @param int $userId
 * @param int $page
 * @param int $limit
 * @param string|null $filter 'all', 'unread', or null
 * @return array
 */
function get_user_notifications(PDO $pdo, int $userId, int $page = 1, int $limit = 20, ?string $filter = null): array {
    ensure_notifications_tables_exist($pdo);
    auto_purge_expired_notifications($pdo);

    $page = max(1, $page);
    $limit = max(1, min(100, $limit));
    $offset = ($page - 1) * $limit;

    $filterClause = '';
    if ($filter === 'unread') {
        $filterClause = " AND (un.is_read IS NULL OR un.is_read = 0) ";
    }

    $sql = "
        SELECT 
            n.id,
            n.title,
            n.message,
            n.type,
            n.target_type,
            n.target_user_id,
            n.related_type,
            n.related_id,
            n.image,
            n.action_label,
            n.status,
            n.created_at,
            COALESCE(un.is_read, 0) AS is_read,
            un.read_at
        FROM notifications n
        LEFT JOIN user_notifications un 
               ON un.notification_id = n.id AND un.user_id = ?
        WHERE n.status = 'active'
          AND n.created_at >= NOW() - INTERVAL 24 HOUR
          AND (
               n.target_type = 'all' 
               OR (n.target_type = 'specific_user' AND n.target_user_id = ?)
               OR (n.target_type = 'all_except_user' AND (n.target_user_id IS NULL OR n.target_user_id != ?))
          )
          AND (n.expires_at IS NULL OR n.expires_at > NOW())
          AND (un.is_dismissed IS NULL OR un.is_dismissed = 0)
          AND (
               un.is_read IS NULL 
               OR un.is_read = 0 
               OR (un.is_read = 1 AND un.read_at > NOW() - INTERVAL 24 HOUR)
          )
          {$filterClause}
        ORDER BY n.created_at DESC
        LIMIT ? OFFSET ?
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(1, $userId, PDO::PARAM_INT);
    $stmt->bindValue(2, $userId, PDO::PARAM_INT);
    $stmt->bindValue(3, $userId, PDO::PARAM_INT);
    $stmt->bindValue(4, $limit, PDO::PARAM_INT);
    $stmt->bindValue(5, $offset, PDO::PARAM_INT);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    return array_map(function($r) {
        $rawCreated = $r['created_at'];
        $isoUtc = gmdate('Y-m-d\TH:i:s\Z', strtotime($rawCreated));
        $readAtUtc = !empty($r['read_at']) ? gmdate('Y-m-d\TH:i:s\Z', strtotime($r['read_at'])) : null;

        return [
            'id'           => (int)$r['id'],
            'title'        => $r['title'],
            'message'      => $r['message'],
            'type'         => $r['type'],
            'target_type'  => $r['target_type'],
            'related_type' => $r['related_type'],
            'related_id'   => $r['related_id'],
            'image'        => $r['image'],
            'action_label' => $r['action_label'] ?? null,
            'is_read'      => (bool)$r['is_read'],
            'read_at'      => $readAtUtc,
            'created_at'   => $isoUtc,
        ];
    }, $rows);
}

/**
 * Returns the exact count of unread notifications for a given user within 24 hours.
 *
 * @param PDO $pdo
 * @param int $userId
 * @return int
 */
function get_user_unread_count(PDO $pdo, int $userId): int {
    ensure_notifications_tables_exist($pdo);
    auto_purge_expired_notifications($pdo);

    $stmt = $pdo->prepare("
        SELECT COUNT(*)
        FROM notifications n
        LEFT JOIN user_notifications un 
               ON un.notification_id = n.id AND un.user_id = ?
        WHERE n.status = 'active'
          AND n.created_at >= NOW() - INTERVAL 24 HOUR
          AND (
               n.target_type = 'all' 
               OR (n.target_type = 'specific_user' AND n.target_user_id = ?)
               OR (n.target_type = 'all_except_user' AND (n.target_user_id IS NULL OR n.target_user_id != ?))
          )
          AND (n.expires_at IS NULL OR n.expires_at > NOW())
          AND (un.is_dismissed IS NULL OR un.is_dismissed = 0)
          AND (un.is_read IS NULL OR un.is_read = 0)
    ");
    $stmt->execute([$userId, $userId, $userId]);
    return (int)$stmt->fetchColumn();
}


/**
 * Marks a single notification as read.
 * Strict idempotency rule: If already read, does NOT change read_at!
 *
 * @param PDO $pdo
 * @param int $notificationId
 * @param int $userId
 * @return bool
 */
function mark_notification_as_read(PDO $pdo, int $notificationId, int $userId): bool {
    $stmt = $pdo->prepare("
        INSERT INTO user_notifications (
            notification_id,
            user_id,
            is_read,
            read_at,
            created_at,
            updated_at
        ) VALUES (
            ?,
            ?,
            1,
            NOW(),
            NOW(),
            NOW()
        )
        ON DUPLICATE KEY UPDATE
            is_read = 1,
            read_at = IF(read_at IS NULL, NOW(), read_at),
            updated_at = NOW()
    ");

    return $stmt->execute([$notificationId, $userId]);
}

/**
 * Marks all currently unread notifications as read for a given user.
 * Existing read notifications preserve their original read_at.
 *
 * @param PDO $pdo
 * @param int $userId
 * @return int Number of newly marked notifications
 */
function mark_all_notifications_as_read(PDO $pdo, int $userId): int {
    // 1. Fetch all unread notification IDs applicable to this user
    $stmt = $pdo->prepare("
        SELECT n.id 
        FROM notifications n
        LEFT JOIN user_notifications un 
               ON un.notification_id = n.id AND un.user_id = ?
        WHERE n.status = 'active'
          AND (
               n.target_type = 'all' 
               OR (n.target_type = 'specific_user' AND n.target_user_id = ?)
               OR (n.target_type = 'all_except_user' AND (n.target_user_id IS NULL OR n.target_user_id != ?))
          )
          AND (n.expires_at IS NULL OR n.expires_at > NOW())
          AND (un.is_dismissed IS NULL OR un.is_dismissed = 0)
          AND (un.is_read IS NULL OR un.is_read = 0)
    ");
    $stmt->execute([$userId, $userId, $userId]);
    $unreadIds = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (empty($unreadIds)) {
        return 0;
    }

    $upsert = $pdo->prepare("
        INSERT INTO user_notifications (
            notification_id,
            user_id,
            is_read,
            read_at,
            created_at,
            updated_at
        ) VALUES (
            ?,
            ?,
            1,
            NOW(),
            NOW(),
            NOW()
        )
        ON DUPLICATE KEY UPDATE
            is_read = 1,
            read_at = IF(read_at IS NULL, NOW(), read_at),
            updated_at = NOW()
    ");

    $count = 0;
    foreach ($unreadIds as $nId) {
        $upsert->execute([(int)$nId, $userId]);
        $count++;
    }

    return $count;
}

/**
 * Marks a notification as unread (Section 15 optional).
 *
 * @param PDO $pdo
 * @param int $notificationId
 * @param int $userId
 * @return bool
 */
function mark_notification_as_unread(PDO $pdo, int $notificationId, int $userId): bool {
    $stmt = $pdo->prepare("
        INSERT INTO user_notifications (
            notification_id,
            user_id,
            is_read,
            read_at,
            created_at,
            updated_at
        ) VALUES (
            ?,
            ?,
            0,
            NULL,
            NOW(),
            NOW()
        )
        ON DUPLICATE KEY UPDATE
            is_read = 0,
            read_at = NULL,
            updated_at = NOW()
    ");

    return $stmt->execute([$notificationId, $userId]);
}

/**
 * Dismisses / deletes a notification for a user so it no longer appears in their list.
 *
 * @param PDO $pdo
 * @param int $notificationId
 * @param int $userId
 * @return bool
 */
function dismiss_user_notification(PDO $pdo, int $notificationId, int $userId): bool {
    $stmt = $pdo->prepare("
        INSERT INTO user_notifications (
            notification_id,
            user_id,
            is_read,
            read_at,
            is_dismissed,
            created_at,
            updated_at
        ) VALUES (
            ?,
            ?,
            1,
            NOW(),
            1,
            NOW(),
            NOW()
        )
        ON DUPLICATE KEY UPDATE
            is_dismissed = 1,
            is_read = 1,
            read_at = IF(read_at IS NULL, NOW(), read_at),
            updated_at = NOW()
    ");

    return $stmt->execute([$notificationId, $userId]);
}

/**
 * Dismisses / clears all visible notifications for a user.
 *
 * @param PDO $pdo
 * @param int $userId
 * @return int Number of dismissed notifications
 */
function dismiss_all_user_notifications(PDO $pdo, int $userId): int {
    $stmt = $pdo->prepare("
        SELECT n.id 
        FROM notifications n
        LEFT JOIN user_notifications un 
               ON un.notification_id = n.id AND un.user_id = ?
        WHERE n.status = 'active'
          AND (
               n.target_type = 'all' 
               OR (n.target_type = 'specific_user' AND n.target_user_id = ?)
               OR (n.target_type = 'all_except_user' AND (n.target_user_id IS NULL OR n.target_user_id != ?))
          )
          AND (n.expires_at IS NULL OR n.expires_at > NOW())
          AND (un.is_dismissed IS NULL OR un.is_dismissed = 0)
    ");
    $stmt->execute([$userId, $userId, $userId]);
    $ids = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (empty($ids)) {
        return 0;
    }

    $upsert = $pdo->prepare("
        INSERT INTO user_notifications (
            notification_id,
            user_id,
            is_read,
            read_at,
            is_dismissed,
            created_at,
            updated_at
        ) VALUES (
            ?,
            ?,
            1,
            NOW(),
            1,
            NOW(),
            NOW()
        )
        ON DUPLICATE KEY UPDATE
            is_dismissed = 1,
            is_read = 1,
            read_at = IF(read_at IS NULL, NOW(), read_at),
            updated_at = NOW()
    ");

    $count = 0;
    foreach ($ids as $nId) {
        $upsert->execute([(int)$nId, $userId]);
        $count++;
    }

    return $count;
}

/**
 * Retrieves high-level notification statistics for Admin dashboard.
 *
 * @param PDO $pdo
 * @return array
 */
function get_admin_notification_stats(PDO $pdo): array {
    try {
        $total = (int)$pdo->query("SELECT COUNT(*) FROM notifications")->fetchColumn();
        $active = (int)$pdo->query("SELECT COUNT(*) FROM notifications WHERE status = 'active'")->fetchColumn();
        $today = (int)$pdo->query("SELECT COUNT(*) FROM notifications WHERE DATE(created_at) = CURDATE()")->fetchColumn();
        $readCount = (int)$pdo->query("SELECT COUNT(*) FROM user_notifications WHERE is_read = 1")->fetchColumn();
        $unreadCount = (int)$pdo->query("SELECT COUNT(*) FROM user_notifications WHERE is_read = 0")->fetchColumn();

        return [
            'total'        => $total,
            'active'       => $active,
            'sent_today'   => $today,
            'read_count'   => $readCount,
            'unread_count' => $unreadCount,
        ];
    } catch (Exception $e) {
        return [
            'total'        => 0,
            'active'       => 0,
            'sent_today'   => 0,
            'read_count'   => 0,
            'unread_count' => 0,
        ];
    }
}
