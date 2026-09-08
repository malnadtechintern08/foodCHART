<?php
/**
 * Food CHART Web Admin - Complete In-App Notification Center & Mobile App Access Hub
 * Features:
 * 1. Mobile App Simulator & In-App Live Preview with real-time bell badge & animations
 * 2. User Perspective Switcher (View app experience as Abhishek, Priya, Chef Bharath, etc.)
 * 3. 1-Click "Push to Mobile App Now" test dispatches with instant database persistence
 * 4. In-App Read/Unread simulation with 24-hour expiration countdown
 * 5. App REST API Gateway & Live Endpoint Inspector
 * 6. Full notification management (CRUD, active toggle, filtering, search, and live preview modal)
 */

require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/includes/notification_functions.php';

$pdo = get_db_connection();
ensure_notifications_tables_exist($pdo);

// Auto-purge retired weekend challenge notifications
try {
    $weekendIds = $pdo->query("SELECT id FROM notifications WHERE title LIKE '%Weekend Culinary Challenge%' OR title LIKE '%Food CHART Weekend%' OR title LIKE '%Food CHART Weekend%'")->fetchAll(PDO::FETCH_COLUMN);
    if (!empty($weekendIds)) {
        $inClause = implode(',', array_map('intval', $weekendIds));
        $pdo->exec("DELETE FROM user_notifications WHERE notification_id IN ($inClause)");
        $pdo->exec("DELETE FROM notifications WHERE id IN ($inClause)");
    }
} catch (Exception $e) {}

$pageTitle = 'App Notifications Hub';
$currentPage = 'notifications.php';

// Handle Action: Quick Push to App
if (isset($_POST['action']) && $_POST['action'] === 'quick_push') {
    $pushTemplate = $_POST['template'] ?? '';
    $targetUserId = !empty($_POST['target_user_id']) ? (int)$_POST['target_user_id'] : 6;

    $payload = null;
    switch ($pushTemplate) {
        case 'new_recipe':
            $payload = [
                'title'               => '🍲 Fresh Recipe: Hyderabadi Chicken Biryani',
                'message'             => 'A royal delicacy with aromatic basmati rice, saffron, and tender marinated chicken is now live!',
                'type'                => 'new_recipe',
                'target_type'         => 'all',
                'action_label'        => 'View Recipe',
                'related_type'        => 'recipe',
                'related_id'          => 'rec_chicken_biryani',
                'status'              => 'active',
                'created_by_admin_id' => 1
            ];
            break;

        case 'announcement':
            $payload = [
                'title'               => '📢 Food CHART Community Culinary Update',
                'message'             => 'Explore newly featured heritage recipes and authentic chef tips from our vibrant cooking community!',
                'type'                => 'admin_announcement',
                'target_type'         => 'all',
                'action_label'        => 'Explore Community',
                'related_type'        => 'feature',
                'related_id'          => 'search',
                'status'              => 'active',
                'created_by_admin_id' => 1
            ];
            break;

        case 'recipe_approved':
            $payload = [
                'title'               => '🎉 Your Recipe Was Approved & Published!',
                'message'             => 'Congratulations! Your submission has been verified by the Food CHART culinary team and is now live.',
                'type'                => 'recipe_approved',
                'target_type'         => 'specific_user',
                'target_user_id'      => $targetUserId,
                'action_label'        => 'View Live Recipe',
                'related_type'        => 'recipe',
                'related_id'          => '201',
                'status'              => 'active',
                'created_by_admin_id' => 1
            ];
            break;

        case 'changes_requested':
            $payload = [
                'title'               => '📝 Changes Requested for Submission',
                'message'             => 'Please add precise ingredient cooking measurements and specify marination time.',
                'type'                => 'changes_requested',
                'target_type'         => 'specific_user',
                'target_user_id'      => $targetUserId,
                'action_label'        => 'Edit Submission',
                'related_type'        => 'recipe_submission',
                'related_id'          => '1',
                'status'              => 'active',
                'created_by_admin_id' => 1
            ];
            break;

        case 'new_feature':
            $payload = [
                'title'               => '🚀 Food CHART Voice Cooking Timer',
                'message'             => 'You can now run hands-free cooking timers directly from recipe detail steps!',
                'type'                => 'new_feature',
                'target_type'         => 'all',
                'action_label'        => 'Try Feature',
                'related_type'        => 'feature',
                'related_id'          => 'voice_timer',
                'status'              => 'active',
                'created_by_admin_id' => 1
            ];
            break;
    }

    if ($payload) {
        try {
            $newId = create_system_notification($pdo, $payload);
            set_flash_message('success', "🚀 Notification #$newId successfully pushed to Food CHART mobile app!");
        } catch (Exception $e) {
            set_flash_message('danger', "Failed to push notification: " . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/notifications.php?user_id=' . $targetUserId);
    exit;
}

// Handle Action: Toggle In-App Read Status (for App Simulation testing)
if (isset($_GET['action']) && $_GET['action'] === 'toggle_user_read') {
    $notifId = (int)($_GET['id'] ?? 0);
    $targetUserId = (int)($_GET['user_id'] ?? 6);
    $markAs = (int)($_GET['is_read'] ?? 1);

    if ($notifId > 0 && $targetUserId > 0) {
        try {
            if ($markAs === 1) {
                mark_notification_as_read($pdo, $notifId, $targetUserId);
                set_flash_message('success', "In-App read status updated: Notification #$notifId marked as read for User #$targetUserId.");
            } else {
                $stmt = $pdo->prepare("UPDATE user_notifications SET is_read = 0, read_at = NULL, updated_at = NOW() WHERE notification_id = ? AND user_id = ?");
                $stmt->execute([$notifId, $targetUserId]);
                set_flash_message('success', "In-App read status updated: Notification #$notifId marked as unread for User #$targetUserId.");
            }
        } catch (Exception $e) {
            set_flash_message('danger', "Error updating in-app status: " . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/notifications.php?user_id=' . $targetUserId);
    exit;
}

// Handle Action: Delete Notification
if (isset($_GET['action']) && $_GET['action'] === 'delete') {
    $delId = (int)($_GET['id'] ?? 0);
    if ($delId > 0) {
        try {
            $pdo->prepare("DELETE FROM user_notifications WHERE notification_id = ?")->execute([$delId]);
            $stmt = $pdo->prepare("DELETE FROM notifications WHERE id = ?");
            $stmt->execute([$delId]);
            set_flash_message('success', "Notification #$delId was permanently deleted.");
        } catch (Exception $e) {
            set_flash_message('danger', "Error deleting notification: " . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/notifications.php');
    exit;
}

// Handle Action: Toggle Status (Active / Inactive)
if (isset($_GET['action']) && $_GET['action'] === 'toggle') {
    $toggleId = (int)($_GET['id'] ?? 0);
    if ($toggleId > 0) {
        try {
            $stmt = $pdo->prepare("SELECT status, title FROM notifications WHERE id = ?");
            $stmt->execute([$toggleId]);
            $notif = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($notif) {
                $newStatus = ($notif['status'] === 'active') ? 'inactive' : 'active';
                $up = $pdo->prepare("UPDATE notifications SET status = ?, updated_at = NOW() WHERE id = ?");
                $up->execute([$newStatus, $toggleId]);
                set_flash_message('success', "Notification \"{$notif['title']}\" status set to <strong>$newStatus</strong>.");
            }
        } catch (Exception $e) {
            set_flash_message('danger', "Error toggling status: " . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/notifications.php');
    exit;
}

// Handle Add / Edit Notification Modal Form Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !isset($_POST['action'])) {
    $notifId     = (int)($_POST['id'] ?? 0);
    $title       = trim($_POST['title'] ?? '');
    $message     = trim($_POST['message'] ?? '');
    $type        = trim($_POST['type'] ?? 'general');
    $targetType  = in_array($_POST['target_type'] ?? '', ['all', 'specific_user', 'all_except_user']) ? $_POST['target_type'] : 'all';
    $targetUser  = (!empty($_POST['target_user_id']) && in_array($targetType, ['specific_user', 'all_except_user'])) ? (int)$_POST['target_user_id'] : null;
    $relatedType = trim($_POST['related_type'] ?? '');
    $relatedId   = trim($_POST['related_id'] ?? '');
    $image       = trim($_POST['image'] ?? '');
    $actionLabel = trim($_POST['action_label'] ?? '');
    $status      = in_array($_POST['status'] ?? '', ['active', 'inactive']) ? $_POST['status'] : 'active';
    $expiresAt   = !empty($_POST['expires_at']) ? trim($_POST['expires_at']) : null;

    if (empty($title) || empty($message)) {
        set_flash_message('danger', 'Both Notification Title and Message are required.');
    } else {
        try {
            if ($notifId > 0) {
                $up = $pdo->prepare("
                    UPDATE notifications SET
                        title = ?,
                        message = ?,
                        type = ?,
                        target_type = ?,
                        target_user_id = ?,
                        related_type = ?,
                        related_id = ?,
                        image = ?,
                        action_label = ?,
                        status = ?,
                        expires_at = ?,
                        updated_at = NOW()
                    WHERE id = ?
                ");
                $up->execute([
                    $title, $message, $type, $targetType, $targetUser,
                    !empty($relatedType) ? $relatedType : null,
                    !empty($relatedId) ? $relatedId : null,
                    !empty($image) ? $image : null,
                    !empty($actionLabel) ? $actionLabel : null,
                    $status, $expiresAt, $notifId
                ]);
                set_flash_message('success', "Notification #$notifId updated successfully.");
            } else {
                $newId = create_system_notification($pdo, [
                    'title'               => $title,
                    'message'             => $message,
                    'type'                => $type,
                    'target_type'         => $targetType,
                    'target_user_id'      => $targetUser,
                    'related_type'        => !empty($relatedType) ? $relatedType : null,
                    'related_id'          => !empty($relatedId) ? $relatedId : null,
                    'image'               => !empty($image) ? $image : null,
                    'action_label'        => !empty($actionLabel) ? $actionLabel : null,
                    'status'              => $status,
                    'created_by_admin_id' => 1,
                    'expires_at'          => $expiresAt
                ]);
                set_flash_message('success', "New notification created successfully (ID: #$newId).");
            }
        } catch (Exception $e) {
            set_flash_message('danger', "Database error: " . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/notifications.php');
    exit;
}

// Fetch users for target user picker & app perspective switcher
$usersList = $pdo->query("SELECT id, display_name, email FROM users ORDER BY id ASC LIMIT 250")->fetchAll(PDO::FETCH_ASSOC);

// User Perspective Switcher for Mobile App Live Simulator
$selectedUserId = isset($_GET['user_id']) ? (int)$_GET['user_id'] : 6;
// Default to first user if selected user doesn't exist
$validUserIds = array_column($usersList, 'id');
if (!in_array($selectedUserId, $validUserIds) && !empty($validUserIds)) {
    $selectedUserId = $validUserIds[0];
}

$selectedUser = null;
foreach ($usersList as $u) {
    if ((int)$u['id'] === $selectedUserId) {
        $selectedUser = $u;
        break;
    }
}
$selectedUserName = $selectedUser ? $selectedUser['display_name'] : "User #$selectedUserId";

// Fetch In-App notifications for this selected user
$appUserNotifs = get_user_notifications($pdo, $selectedUserId);
$appUserUnreadCount = get_user_unread_count($pdo, $selectedUserId);

// Fetch admin global stats
$stats = get_admin_notification_stats($pdo);
$totalSent = $stats['total'];
$activeCount = $stats['active'];
$sentToday = $stats['sent_today'];
$readCount = $stats['read_count'];
$unreadCount = $stats['unread_count'];

// Filter & search parameters for management table
$searchQ = trim($_GET['q'] ?? '');
$typeFilter = trim($_GET['type'] ?? '');
$statusFilter = trim($_GET['status'] ?? '');
$targetFilter = trim($_GET['target'] ?? '');

$where = ['1=1'];
$params = [];

if (!empty($searchQ)) {
    $where[] = '(n.title LIKE ? OR n.message LIKE ?)';
    $params[] = "%$searchQ%";
    $params[] = "%$searchQ%";
}
if (!empty($typeFilter)) {
    $where[] = 'n.type = ?';
    $params[] = $typeFilter;
}
if (!empty($statusFilter)) {
    $where[] = 'n.status = ?';
    $params[] = $statusFilter;
}
if (!empty($targetFilter)) {
    $where[] = 'n.target_type = ?';
    $params[] = $targetFilter;
}

$whereClause = implode(' AND ', $where);

$stmt = $pdo->prepare("
    SELECT 
        n.*,
        (SELECT COUNT(*) FROM user_notifications un WHERE un.notification_id = n.id AND un.is_read = 1) AS read_count,
        (SELECT COUNT(*) FROM user_notifications un WHERE un.notification_id = n.id) AS delivery_count,
        u.display_name AS target_user_name
    FROM notifications n
    LEFT JOIN users u ON u.id = n.target_user_id
    WHERE {$whereClause}
    ORDER BY n.created_at DESC
");
$stmt->execute($params);
$notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);

require_once __DIR__ . '/includes/header.php';
?>

<style>
/* Phone Simulator & Notification Hub Styles */
.app-simulator-wrapper {
    background: linear-gradient(145deg, #181818, #111111);
    border: 1px solid var(--cm-border);
    border-radius: var(--cm-radius-lg);
    padding: 24px;
    margin-bottom: 30px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
}

.phone-frame {
    width: 380px;
    max-width: 100%;
    margin: 0 auto;
    background: #0E0E0E;
    border: 10px solid #282828;
    border-radius: 46px;
    overflow: hidden;
    box-shadow: 0 25px 60px rgba(0, 0, 0, 0.8), 0 0 0 1px rgba(255, 255, 255, 0.08);
    position: relative;
    display: flex;
    flex-direction: column;
    min-height: 640px;
    max-height: 720px;
}

.phone-notch {
    height: 28px;
    background: #0E0E0E;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    z-index: 10;
}
.dynamic-island {
    width: 110px;
    height: 18px;
    background: #000;
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: space-around;
    padding: 0 8px;
}
.camera-lens {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #111;
    border: 1px solid #222;
}

.phone-status-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 2px 20px 6px;
    font-size: 11px;
    font-weight: 600;
    color: #FFF;
}

.phone-app-bar {
    background: #141414;
    border-bottom: 1px solid #222;
    padding: 10px 18px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.bell-icon-container {
    position: relative;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 38px;
    height: 38px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.06);
    transition: background 0.2s ease, transform 0.2s ease;
}
.bell-icon-container:hover {
    background: rgba(229, 9, 21, 0.15);
    transform: scale(1.05);
}

.bell-shake-animation {
    animation: bellHarmonicShake 3s infinite ease-in-out;
    transform-origin: top center;
}

@keyframes bellHarmonicShake {
    0%, 65%, 100% { transform: rotate(0deg); }
    70% { transform: rotate(14deg); }
    75% { transform: rotate(-12deg); }
    80% { transform: rotate(10deg); }
    85% { transform: rotate(-6deg); }
    90% { transform: rotate(2deg); }
}

.bell-badge-bubble {
    position: absolute;
    top: -2px;
    right: -2px;
    background: #E50915;
    color: #FFF;
    font-size: 10px;
    font-weight: 900;
    min-width: 18px;
    height: 18px;
    border-radius: 9px;
    padding: 0 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 6px rgba(229, 9, 21, 0.6);
    border: 2px solid #141414;
}

.phone-content-scroll {
    flex: 1;
    overflow-y: auto;
    padding: 14px;
    background: #0E0E0E;
}

.sim-notif-card {
    background: #181818;
    border: 1px solid #262626;
    border-radius: 12px;
    padding: 12px;
    margin-bottom: 10px;
    display: flex;
    gap: 12px;
    position: relative;
    transition: transform 0.15s ease, border-color 0.15s ease;
}
.sim-notif-card.unread {
    border-left: 3.5px solid #E50915;
    background: #1C1C1C;
}
.sim-notif-card:hover {
    border-color: #383838;
}

.quick-push-btn {
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid var(--cm-border);
    border-radius: 10px;
    padding: 12px 14px;
    color: #FFF;
    font-size: 13px;
    font-weight: 600;
    text-align: left;
    display: flex;
    align-items: center;
    gap: 12px;
    width: 100%;
    cursor: pointer;
    transition: all 0.2s ease;
}
.quick-push-btn:hover {
    background: rgba(229, 9, 21, 0.12);
    border-color: var(--cm-primary);
    transform: translateY(-2px);
}
</style>

<!-- Top Title & Navigation Bar -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
    <div>
        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 4px;">
            <span style="background: rgba(229, 9, 21, 0.15); color: var(--cm-primary); border: 1px solid var(--cm-primary); padding: 4px 10px; border-radius: 8px; font-size: 12px; font-weight: 800; text-transform: uppercase;">
                <i class="fa-solid fa-mobile-screen"></i> In-App Notification Hub
            </span>
            <span style="color: var(--cm-text-muted); font-size: 13px;">Food CHART Mobile Flutter Client Sync</span>
        </div>
        <h2 style="font-size: 28px; font-weight: 800; margin: 0; color: #FFF;">
            App Notifications & Push Control Center
        </h2>
    </div>

    <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
        <a href="<?= BASE_URL ?>/api/notifications/index.php?user_id=<?= $selectedUserId ?>" target="_blank" class="btn btn-secondary" title="View live JSON response consumed by Flutter app">
            <i class="fa-solid fa-code" style="color: #29B6F6;"></i> Inspect App API JSON
        </a>
        <button type="button" class="btn btn-primary" onclick="openCreateModal()">
            <i class="fa-solid fa-plus"></i> Compose Notification
        </button>
    </div>
</div>

<!-- ========================================================================= -->
<!-- SECTION 1: FOOD CHART MOBILE APP LIVE EXPERIENCE & PUSH CONTROL CONSOLE   -->
<!-- ========================================================================= -->
<div class="app-simulator-wrapper">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 16px; border-bottom: 1px solid var(--cm-border); padding-bottom: 16px;">
        <div style="display: flex; align-items: center; gap: 12px;">
            <div style="width: 44px; height: 44px; border-radius: 12px; background: rgba(229, 9, 21, 0.15); color: #E50915; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                <i class="fa-solid fa-mobile-screen-button"></i>
            </div>
            <div>
                <h3 style="font-size: 18px; margin: 0; font-weight: 800; color: #FFF;">
                    Food CHART Mobile App Simulator
                </h3>
                <span style="font-size: 13px; color: var(--cm-text-secondary);">
                    Real-time in-app experience preview with live animated notification bell & unread counter
                </span>
            </div>
        </div>

        <!-- User Perspective Switcher -->
        <div style="display: flex; align-items: center; gap: 10px; background: rgba(0, 0, 0, 0.35); padding: 6px 14px; border-radius: 12px; border: 1px solid var(--cm-border);">
            <label for="app_perspective_select" style="font-size: 12.5px; font-weight: 700; color: var(--cm-text-secondary); margin: 0;">
                <i class="fa-solid fa-user-gear" style="color: #FFB300; margin-right: 4px;"></i> View App As:
            </label>
            <select id="app_perspective_select" class="form-control" style="width: auto; padding: 4px 10px; height: auto; font-size: 13px; font-weight: 700; background: #222; border-color: #333;" onchange="switchUserPerspective(this.value)">
                <?php foreach ($usersList as $u): ?>
                    <?php
                    $uUnread = get_user_unread_count($pdo, (int)$u['id']);
                    ?>
                    <option value="<?= $u['id'] ?>" <?= (int)$u['id'] === $selectedUserId ? 'selected' : '' ?>>
                        <?= htmlspecialchars($u['display_name']) ?> (ID #<?= $u['id'] ?>) - <?= $uUnread ?> unread
                    </option>
                <?php endforeach; ?>
            </select>
        </div>
    </div>

    <!-- Simulator Layout: Left Phone, Right 1-Click Push Dispatcher & API status -->
    <div style="display: grid; grid-template-columns: 420px 1fr; gap: 28px; align-items: start;">
        
        <!-- Left: Interactive Mobile Phone Simulator -->
        <div style="display: flex; flex-direction: column; align-items: center;">
            <div class="phone-frame">
                <!-- Phone Notch & Dynamic Island -->
                <div class="phone-notch">
                    <div class="dynamic-island">
                        <div class="camera-lens"></div>
                        <span style="width: 6px; height: 6px; border-radius: 50%; background: #00E676; display: inline-block;"></span>
                    </div>
                </div>

                <!-- Phone Status Bar -->
                <div class="phone-status-bar">
                    <span>9:41</span>
                    <div style="display: flex; gap: 6px; align-items: center; font-size: 10px;">
                        <i class="fa-solid fa-signal"></i>
                        <i class="fa-solid fa-wifi"></i>
                        <i class="fa-solid fa-battery-full" style="color: #4CAF50;"></i>
                    </div>
                </div>

                <!-- Food CHART App Top Bar -->
                <div class="phone-app-bar">
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <div style="width: 28px; height: 28px; border-radius: 8px; background: #E50915; display: flex; align-items: center; justify-content: center; color: #FFF; font-size: 14px; font-weight: 900;">
                            🔥
                        </div>
                        <span style="font-family: 'Outfit', sans-serif; font-size: 17px; font-weight: 800; letter-spacing: -0.5px; color: #FFF;">
                            Food <span style="color: #E50915;">CHART</span>
                        </span>
                    </div>

                    <div style="display: flex; align-items: center; gap: 10px;">
                        <div style="color: #888; font-size: 14px; cursor: pointer;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </div>
                        
                        <!-- Interactive Notification Bell in Phone Preview -->
                        <div class="bell-icon-container" onclick="togglePhoneView()" title="Click to toggle App Home / In-App Notifications Feed">
                            <i class="fa-solid fa-bell <?= $appUserUnreadCount > 0 ? 'bell-shake-animation' : '' ?>" style="color: <?= $appUserUnreadCount > 0 ? '#FFF' : '#888' ?>; font-size: 16px;"></i>
                            <?php if ($appUserUnreadCount > 0): ?>
                                <span class="bell-badge-bubble">
                                    <?= $appUserUnreadCount > 99 ? '99+' : $appUserUnreadCount ?>
                                </span>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>

                <!-- Simulator Navigation Toggle Bar -->
                <div style="background: #181818; padding: 6px 14px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #222;">
                    <div style="font-size: 11px; font-weight: 700; color: #AAA;">
                        <span id="phoneViewModeLabel"><i class="fa-solid fa-bell" style="color: #E50915;"></i> In-App Notifications</span>
                    </div>
                    <button type="button" onclick="togglePhoneView()" style="background: rgba(255,255,255,0.08); border: 1px solid #333; color: #FFF; font-size: 10px; font-weight: 700; border-radius: 6px; padding: 2px 8px; cursor: pointer;">
                        Toggle Screen &rarr;
                    </button>
                </div>

                <!-- Phone Scrollable Content: View 1 (Notifications Feed) -->
                <div id="phoneNotificationsFeed" class="phone-content-scroll">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; padding: 0 4px;">
                        <span style="font-size: 13px; font-weight: 800; color: #FFF;">
                            Activity & Alerts
                        </span>
                        <span style="font-size: 11px; color: var(--cm-primary); font-weight: 700;">
                            <?= count($appUserNotifs) ?> total • <?= $appUserUnreadCount ?> unread
                        </span>
                    </div>

                    <?php if (empty($appUserNotifs)): ?>
                        <div style="text-align: center; padding: 60px 16px; color: #666;">
                            <i class="fa-solid fa-bell-slash" style="font-size: 36px; margin-bottom: 12px; color: #444; display: block;"></i>
                            <h5 style="color: #FFF; font-size: 14px; margin-bottom: 6px;">No Notifications Yet</h5>
                            <p style="font-size: 12px; color: #777;">You're completely caught up! New recipe alerts and admin messages will appear here.</p>
                        </div>
                    <?php else: ?>
                        <?php foreach ($appUserNotifs as $notif): ?>
                            <?php
                            $isUnread = !(bool)$notif['is_read'];
                            $typeIcon = 'fa-bell';
                            $iconColor = '#FFA726';
                            $iconBg = 'rgba(255, 167, 38, 0.15)';

                            switch ($notif['type']) {
                                case 'new_recipe':
                                    $typeIcon = 'fa-utensils';
                                    $iconColor = '#E50915';
                                    $iconBg = 'rgba(229, 9, 21, 0.15)';
                                    break;
                                case 'recipe_approved':
                                    $typeIcon = 'fa-circle-check';
                                    $iconColor = '#4CAF50';
                                    $iconBg = 'rgba(76, 175, 80, 0.15)';
                                    break;
                                case 'changes_requested':
                                    $typeIcon = 'fa-pen-to-square';
                                    $iconColor = '#FF9800';
                                    $iconBg = 'rgba(255, 152, 0, 0.15)';
                                    break;
                                case 'admin_announcement':
                                    $typeIcon = 'fa-bullhorn';
                                    $iconColor = '#29B6F6';
                                    $iconBg = 'rgba(41, 182, 246, 0.15)';
                                    break;
                                case 'new_feature':
                                    $typeIcon = 'fa-rocket';
                                    $iconColor = '#AB47BC';
                                    $iconBg = 'rgba(171, 71, 188, 0.15)';
                                    break;
                            }
                            ?>
                            <div class="sim-notif-card <?= $isUnread ? 'unread' : '' ?>">
                                <div style="width: 36px; height: 36px; border-radius: 10px; background: <?= $iconBg ?>; color: <?= $iconColor ?>; display: flex; align-items: center; justify-content: center; font-size: 15px; flex-shrink: 0;">
                                    <i class="fa-solid <?= $typeIcon ?>"></i>
                                </div>
                                <div style="flex: 1; min-width: 0;">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 6px;">
                                        <h6 style="color: #FFF; font-size: 12.5px; font-weight: 700; margin: 0; line-height: 1.3;">
                                            <?= htmlspecialchars($notif['title']) ?>
                                        </h6>
                                        <?php if ($isUnread): ?>
                                            <span style="width: 7px; height: 7px; border-radius: 50%; background: #E50915; flex-shrink: 0; margin-top: 3px;" title="Unread indicator"></span>
                                        <?php endif; ?>
                                    </div>
                                    <p style="color: #AAA; font-size: 11.5px; margin: 3px 0 6px; line-height: 1.35;">
                                        <?= htmlspecialchars($notif['message']) ?>
                                    </p>
                                    
                                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 4px;">
                                        <?php if (!empty($notif['action_label'])): ?>
                                            <span style="font-size: 10.5px; font-weight: 700; color: #FFA726; background: rgba(255, 167, 38, 0.12); padding: 2px 6px; border-radius: 4px;">
                                                <?= htmlspecialchars($notif['action_label']) ?> &rarr;
                                            </span>
                                        <?php else: ?>
                                            <span></span>
                                        <?php endif; ?>

                                        <!-- Interactive Toggle Read button for simulator testing -->
                                        <a href="<?= BASE_URL ?>/notifications.php?action=toggle_user_read&id=<?= $notif['id'] ?>&user_id=<?= $selectedUserId ?>&is_read=<?= $isUnread ? '1' : '0' ?>" 
                                           style="font-size: 10px; color: <?= $isUnread ? '#4CAF50' : '#888' ?>; text-decoration: underline;" 
                                           title="Simulate user marking this notification">
                                            <?= $isUnread ? 'Simulate Mark Read' : 'Simulate Mark Unread' ?>
                                        </a>
                                    </div>

                                    <?php if (!$isUnread): ?>
                                        <div style="margin-top: 4px; font-size: 9.5px; color: #666; display: flex; align-items: center; gap: 4px;">
                                            <i class="fa-solid fa-clock-rotate-left"></i> Disappears in 24h of read
                                        </div>
                                    <?php endif; ?>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>

                <!-- Phone Scrollable Content: View 2 (Food CHART Home Feed Simulation) -->
                <div id="phoneHomeScreenFeed" class="phone-content-scroll" style="display: none;">
                    <div style="padding: 10px 4px 16px;">
                        <h4 style="font-size: 15px; color: #FFF; margin: 0 0 4px; font-weight: 800;">
                            Hello, <?= htmlspecialchars($selectedUserName) ?>! 👋
                        </h4>
                        <p style="font-size: 12px; color: #888; margin: 0 0 14px;">
                            What authentic recipe are we cooking today?
                        </p>

                        <!-- Mock Search Bar -->
                        <div style="background: #1C1C1C; border: 1px solid #282828; border-radius: 10px; padding: 8px 12px; display: flex; align-items: center; gap: 8px; color: #666; font-size: 12px; margin-bottom: 16px;">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <span>Search recipes, ingredients...</span>
                        </div>

                        <!-- Active In-App Notification Banner on Home -->
                        <?php if ($appUserUnreadCount > 0): ?>
                            <div onclick="togglePhoneView()" style="background: linear-gradient(135deg, rgba(229,9,21,0.2), rgba(229,9,21,0.05)); border: 1px solid #E50915; border-radius: 12px; padding: 12px; margin-bottom: 16px; cursor: pointer;">
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <div style="width: 32px; height: 32px; border-radius: 50%; background: #E50915; display: flex; align-items: center; justify-content: center; color: #FFF; font-size: 14px;">
                                        <i class="fa-solid fa-bell bell-shake-animation"></i>
                                    </div>
                                    <div style="flex: 1;">
                                        <strong style="color: #FFF; font-size: 12.5px; display: block;">
                                            You have <?= $appUserUnreadCount ?> unread notification<?= $appUserUnreadCount > 1 ? 's' : '' ?>!
                                        </strong>
                                        <span style="font-size: 11px; color: #FF8A80;">Tap to view latest announcements &rarr;</span>
                                    </div>
                                </div>
                            </div>
                        <?php endif; ?>

                        <!-- Sample Trending Recipe Cards -->
                        <div style="font-size: 13px; font-weight: 800; color: #FFF; margin-bottom: 10px;">
                            🔥 Trending in Malnad & South India
                        </div>

                        <div style="background: #181818; border: 1px solid #262626; border-radius: 12px; overflow: hidden; margin-bottom: 12px;">
                            <div style="height: 100px; background: linear-gradient(45deg, #3E2723, #D84315); display: flex; align-items: center; justify-content: center; font-size: 36px;">
                                🍗
                            </div>
                            <div style="padding: 10px;">
                                <span style="font-size: 10px; font-weight: 800; color: #E50915; text-transform: uppercase;">Non-Veg • 45 Mins</span>
                                <h6 style="color: #FFF; font-size: 13px; margin: 2px 0 4px; font-weight: 700;">Chicken Ghee Roast</h6>
                                <span style="color: #888; font-size: 11px;">Spicy Kundapur style roasted chicken in pure ghee</span>
                            </div>
                        </div>

                        <div style="background: #181818; border: 1px solid #262626; border-radius: 12px; overflow: hidden;">
                            <div style="height: 100px; background: linear-gradient(45deg, #1B5E20, #4CAF50); display: flex; align-items: center; justify-content: center; font-size: 36px;">
                                🍲
                            </div>
                            <div style="padding: 10px;">
                                <span style="font-size: 10px; font-weight: 800; color: #4CAF50; text-transform: uppercase;">Veg • 30 Mins</span>
                                <h6 style="color: #FFF; font-size: 13px; margin: 2px 0 4px; font-weight: 700;">Malnad Bisi Bele Bath</h6>
                                <span style="color: #888; font-size: 11px;">Authentic spiced rice with lentils and homegrown vegetables</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Phone Bottom Bar Simulation -->
                <div style="background: #141414; border-top: 1px solid #222; padding: 10px 24px; display: flex; justify-content: space-around; align-items: center; color: #666; font-size: 16px;">
                    <i class="fa-solid fa-house" style="color: var(--cm-primary);" onclick="togglePhoneView()"></i>
                    <i class="fa-solid fa-compass"></i>
                    <i class="fa-solid fa-bookmark"></i>
                    <i class="fa-solid fa-user"></i>
                </div>
            </div>

            <div style="margin-top: 12px; font-size: 12px; color: var(--cm-text-muted); text-align: center;">
                <i class="fa-solid fa-circle-info"></i> Tapping the notification bell in the phone toggles between App Home & Notification feed.
            </div>
        </div>

        <!-- Right: 1-Click "Push to Mobile App Now" Dispatcher & API Sync Panel -->
        <div>
            <!-- Quick Dispatch Card -->
            <div class="card" style="padding: 20px; margin-bottom: 20px;">
                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px;">
                    <h4 style="font-size: 16px; margin: 0; font-weight: 800; color: #FFF;">
                        <i class="fa-solid fa-paper-plane" style="color: var(--cm-primary); margin-right: 6px;"></i> 1-Click "Push to App Now" Quick Actions
                    </h4>
                    <span style="font-size: 11px; background: rgba(76, 175, 80, 0.15); color: #4CAF50; padding: 2px 8px; border-radius: 6px; font-weight: 700;">
                        Live MySQL Sync
                    </span>
                </div>
                <p style="font-size: 13px; color: var(--cm-text-secondary); margin-bottom: 16px;">
                    Trigger high-priority in-app alerts directly into the Food CHART database. The phone simulator and user device refresh instantly.
                </p>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                    <!-- Push 1: New Recipe Alert -->
                    <form method="POST" action="<?= BASE_URL ?>/notifications.php">
                        <input type="hidden" name="action" value="quick_push">
                        <input type="hidden" name="template" value="new_recipe">
                        <input type="hidden" name="target_user_id" value="<?= $selectedUserId ?>">
                        <button type="submit" class="quick-push-btn">
                            <span style="font-size: 22px;">🍲</span>
                            <div>
                                <strong style="display: block; color: #FFF;">Push New Recipe Alert</strong>
                                <span style="font-size: 11px; color: var(--cm-text-muted);">Broadcast: Hyderabadi Biryani</span>
                            </div>
                        </button>
                    </form>

                    <!-- Push 2: Community Announcement -->
                    <form method="POST" action="<?= BASE_URL ?>/notifications.php">
                        <input type="hidden" name="action" value="quick_push">
                        <input type="hidden" name="template" value="announcement">
                        <input type="hidden" name="target_user_id" value="<?= $selectedUserId ?>">
                        <button type="submit" class="quick-push-btn">
                            <span style="font-size: 22px;">📢</span>
                            <div>
                                <strong style="display: block; color: #FFF;">Push Announcement</strong>
                                <span style="font-size: 11px; color: var(--cm-text-muted);">Community Chef Update</span>
                            </div>
                        </button>
                    </form>

                    <!-- Push 3: Recipe Approved (Personal) -->
                    <form method="POST" action="<?= BASE_URL ?>/notifications.php">
                        <input type="hidden" name="action" value="quick_push">
                        <input type="hidden" name="template" value="recipe_approved">
                        <input type="hidden" name="target_user_id" value="<?= $selectedUserId ?>">
                        <button type="submit" class="quick-push-btn">
                            <span style="font-size: 22px;">🎉</span>
                            <div>
                                <strong style="display: block; color: #FFF;">Push Recipe Approved</strong>
                                <span style="font-size: 11px; color: #4CAF50;">Target: <?= htmlspecialchars($selectedUserName) ?></span>
                            </div>
                        </button>
                    </form>

                    <!-- Push 4: Changes Requested (Personal) -->
                    <form method="POST" action="<?= BASE_URL ?>/notifications.php">
                        <input type="hidden" name="action" value="quick_push">
                        <input type="hidden" name="template" value="changes_requested">
                        <input type="hidden" name="target_user_id" value="<?= $selectedUserId ?>">
                        <button type="submit" class="quick-push-btn">
                            <span style="font-size: 22px;">📝</span>
                            <div>
                                <strong style="display: block; color: #FFF;">Push Changes Requested</strong>
                                <span style="font-size: 11px; color: #FFA000;">Target: <?= htmlspecialchars($selectedUserName) ?></span>
                            </div>
                        </button>
                    </form>
                </div>
            </div>

            <!-- App API Gateway & Deep-Link Route Status -->
            <div class="card" style="padding: 20px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                    <h4 style="font-size: 16px; margin: 0; font-weight: 800; color: #FFF;">
                        <i class="fa-solid fa-network-wired" style="color: #29B6F6; margin-right: 6px;"></i> Mobile App Connectivity & Deep Links
                    </h4>
                    <span style="font-size: 11px; color: #4CAF50; font-weight: 700;">
                        <i class="fa-solid fa-circle-check"></i> REST API Active
                    </span>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 16px;">
                    <div style="background: rgba(0,0,0,0.3); border: 1px solid var(--cm-border); border-radius: 8px; padding: 10px 12px;">
                        <div style="font-size: 11px; font-weight: 700; color: var(--cm-text-muted); text-transform: uppercase;">Active Mobile Client Route</div>
                        <div style="font-family: monospace; font-size: 12px; color: #29B6F6; margin-top: 4px;">
                            /notifications
                        </div>
                    </div>
                    <div style="background: rgba(0,0,0,0.3); border: 1px solid var(--cm-border); border-radius: 8px; padding: 10px 12px;">
                        <div style="font-size: 11px; font-weight: 700; color: var(--cm-text-muted); text-transform: uppercase;">Target Database</div>
                        <div style="font-family: monospace; font-size: 12px; color: #4CAF50; margin-top: 4px;">
                            MySQL (Food CHART DB)
                        </div>
                    </div>
                </div>

                <!-- API Endpoints Quick Reference Table -->
                <div style="font-size: 12.5px; color: #DDD;">
                    <div style="display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #222;">
                        <span><code style="color: #FFA726;">GET</code> /api/notifications/?user_id=<?= $selectedUserId ?></span>
                        <a href="<?= BASE_URL ?>/api/notifications/index.php?user_id=<?= $selectedUserId ?>" target="_blank" style="color: #29B6F6; font-size: 11px;">Test &rarr;</a>
                    </div>
                    <div style="display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #222;">
                        <span><code style="color: #FFA726;">GET</code> /api/notifications/unread-count.php?user_id=<?= $selectedUserId ?></span>
                        <a href="<?= BASE_URL ?>/api/notifications/unread-count.php?user_id=<?= $selectedUserId ?>" target="_blank" style="color: #29B6F6; font-size: 11px;">Test &rarr;</a>
                    </div>
                    <div style="display: flex; justify-content: space-between; padding: 6px 0;">
                        <span><code style="color: #4CAF50;">POST</code> /api/notifications/mark-read.php</span>
                        <span style="color: #888; font-size: 11px;">Body: notification_id, user_id</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ========================================================================= -->
<!-- SECTION 2: GLOBAL NOTIFICATION METRICS & ARCHIVE                          -->
<!-- ========================================================================= -->
<div class="stats-grid" style="margin-bottom: 24px; display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px;">
    <div class="stat-card">
        <div class="stat-icon red">
            <i class="fa-solid fa-bell"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Total Notifications</span>
            <span class="stat-value"><?= number_format($totalSent) ?></span>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon green">
            <i class="fa-solid fa-circle-check"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Active Broadcasts</span>
            <span class="stat-value"><?= number_format($activeCount) ?></span>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon" style="background: rgba(255, 179, 0, 0.15); color: #FFB300;">
            <i class="fa-solid fa-calendar-day"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Sent Today</span>
            <span class="stat-value"><?= number_format($sentToday) ?></span>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon" style="background: rgba(41, 182, 246, 0.15); color: #29B6F6;">
            <i class="fa-solid fa-envelope-open-text"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Total Reads</span>
            <span class="stat-value"><?= number_format($readCount) ?></span>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon orange">
            <i class="fa-solid fa-clock"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Pending Unread</span>
            <span class="stat-value"><?= number_format($unreadCount) ?></span>
        </div>
    </div>
</div>

<!-- Filters & Search Toolbar -->
<div class="card" style="padding: 16px 20px; margin-bottom: 24px;">
    <form method="GET" action="<?= BASE_URL ?>/notifications.php" style="display: flex; gap: 12px; flex-wrap: wrap; align-items: center;">
        <input type="hidden" name="user_id" value="<?= $selectedUserId ?>">

        <div style="flex: 2; min-width: 220px;">
            <input type="text" name="q" class="form-control" placeholder="Search notification title or message..." value="<?= htmlspecialchars($searchQ) ?>">
        </div>
        
        <div style="min-width: 160px;">
            <select name="type" class="form-control">
                <option value="">All Types</option>
                <option value="new_recipe" <?= $typeFilter === 'new_recipe' ? 'selected' : '' ?>>🍲 New Recipe</option>
                <option value="recipe_updated" <?= $typeFilter === 'recipe_updated' ? 'selected' : '' ?>>✨ Recipe Updated</option>
                <option value="admin_announcement" <?= $typeFilter === 'admin_announcement' ? 'selected' : '' ?>>📢 Announcement</option>
                <option value="new_feature" <?= $typeFilter === 'new_feature' ? 'selected' : '' ?>>🚀 New Feature</option>
                <option value="recipe_approved" <?= $typeFilter === 'recipe_approved' ? 'selected' : '' ?>>✅ Recipe Approved</option>
                <option value="recipe_rejected" <?= $typeFilter === 'recipe_rejected' ? 'selected' : '' ?>>❌ Recipe Rejected</option>
                <option value="changes_requested" <?= $typeFilter === 'changes_requested' ? 'selected' : '' ?>>📝 Changes Requested</option>
                <option value="general" <?= $typeFilter === 'general' ? 'selected' : '' ?>>🔔 General</option>
            </select>
        </div>

        <div style="min-width: 140px;">
            <select name="target" class="form-control">
                <option value="">All Audiences</option>
                <option value="all" <?= $targetFilter === 'all' ? 'selected' : '' ?>>🌐 Broadcast (All)</option>
                <option value="specific_user" <?= $targetFilter === 'specific_user' ? 'selected' : '' ?>>👤 Specific User</option>
                <option value="all_except_user" <?= $targetFilter === 'all_except_user' ? 'selected' : '' ?>>👥 All Except User</option>
            </select>
        </div>

        <div style="min-width: 130px;">
            <select name="status" class="form-control">
                <option value="">All Statuses</option>
                <option value="active" <?= $statusFilter === 'active' ? 'selected' : '' ?>>Active</option>
                <option value="inactive" <?= $statusFilter === 'inactive' ? 'selected' : '' ?>>Inactive</option>
            </select>
        </div>

        <button type="submit" class="btn btn-secondary">
            <i class="fa-solid fa-filter"></i> Filter
        </button>

        <?php if (!empty($searchQ) || !empty($typeFilter) || !empty($statusFilter) || !empty($targetFilter)): ?>
            <a href="<?= BASE_URL ?>/notifications.php?user_id=<?= $selectedUserId ?>" class="btn btn-secondary" title="Clear Filters">
                <i class="fa-solid fa-xmark"></i>
            </a>
        <?php endif; ?>
    </form>
</div>

<!-- Complete Notifications Management Data Table -->
<div class="card" style="padding: 0; overflow: hidden; margin-bottom: 40px;">
    <div style="padding: 16px 20px; border-bottom: 1px solid var(--cm-border); display: flex; justify-content: space-between; align-items: center;">
        <h3 style="font-size: 16px; margin: 0; font-weight: 700;">
            All Sent Notifications (<?= count($notifications) ?>)
        </h3>
        <span style="font-size: 12px; color: var(--cm-text-muted);">
            24-hour read disappearance retention rule active
        </span>
    </div>

    <?php if (empty($notifications)): ?>
        <div style="text-align: center; padding: 50px 20px; color: var(--cm-text-secondary);">
            <i class="fa-solid fa-bell-slash" style="font-size: 42px; color: var(--cm-text-muted); margin-bottom: 16px; display: block;"></i>
            <h4 style="color: #FFF; margin-bottom: 8px;">No notifications found</h4>
            <p style="font-size: 14px; margin-bottom: 16px;">Try adjusting your search criteria or create a new announcement.</p>
            <button type="button" class="btn btn-primary btn-sm" onclick="openCreateModal()">Create Notification</button>
        </div>
    <?php else: ?>
        <div class="table-responsive">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th style="width: 50px;">Type</th>
                        <th>Notification Details</th>
                        <th style="width: 160px;">Target Audience</th>
                        <th style="width: 100px;">Status</th>
                        <th style="width: 100px;">Reads</th>
                        <th style="width: 140px;">Date</th>
                        <th style="width: 130px; text-align: right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($notifications as $n): ?>
                        <?php
                        $typeIcon = 'fa-bell';
                        $typeBadgeBg = 'rgba(255,255,255,0.08)';
                        $typeColor = '#FFF';

                        switch ($n['type']) {
                            case 'new_recipe':
                                $typeIcon = 'fa-utensils';
                                $typeBadgeBg = 'rgba(229,9,21,0.15)';
                                $typeColor = '#E50915';
                                break;
                            case 'recipe_updated':
                                $typeIcon = 'fa-sparkles';
                                $typeBadgeBg = 'rgba(255,179,0,0.15)';
                                $typeColor = '#FFB300';
                                break;
                            case 'admin_announcement':
                                $typeIcon = 'fa-bullhorn';
                                $typeBadgeBg = 'rgba(41,182,246,0.15)';
                                $typeColor = '#29B6F6';
                                break;
                            case 'new_feature':
                                $typeIcon = 'fa-rocket';
                                $typeBadgeBg = 'rgba(171,71,188,0.15)';
                                $typeColor = '#AB47BC';
                                break;
                            case 'recipe_approved':
                                $typeIcon = 'fa-circle-check';
                                $typeBadgeBg = 'rgba(76,175,80,0.15)';
                                $typeColor = '#4CAF50';
                                break;
                            case 'recipe_rejected':
                                $typeIcon = 'fa-circle-xmark';
                                $typeBadgeBg = 'rgba(229,9,21,0.15)';
                                $typeColor = '#E50915';
                                break;
                            case 'changes_requested':
                                $typeIcon = 'fa-pen-to-square';
                                $typeBadgeBg = 'rgba(255,160,0,0.15)';
                                $typeColor = '#FFA000';
                                break;
                        }
                        ?>
                        <tr>
                            <td>
                                <div style="width: 38px; height: 38px; border-radius: 10px; background: <?= $typeBadgeBg ?>; color: <?= $typeColor ?>; display: flex; align-items: center; justify-content: center; font-size: 16px;">
                                    <i class="fa-solid <?= $typeIcon ?>"></i>
                                </div>
                            </td>
                            <td>
                                <strong style="color: #FFF; font-size: 14px; display: block; margin-bottom: 2px;">
                                    <?= htmlspecialchars($n['title']) ?>
                                </strong>
                                <span style="color: var(--cm-text-secondary); font-size: 12px; line-height: 1.4; display: block; max-width: 480px;">
                                    <?= htmlspecialchars($n['message']) ?>
                                </span>
                                <?php if (!empty($n['action_label'])): ?>
                                    <span style="display: inline-block; margin-top: 4px; font-size: 11px; background: rgba(255, 152, 0, 0.12); color: #FFA726; border: 1px solid rgba(255,152,0,0.25); padding: 2px 7px; border-radius: 4px;">
                                        <i class="fa-solid fa-arrow-pointer"></i> <?= htmlspecialchars($n['action_label']) ?>
                                    </span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php if ($n['target_type'] === 'specific_user'): ?>
                                    <span class="badge" style="background: rgba(41, 182, 246, 0.15); color: #29B6F6;">
                                        <i class="fa-solid fa-user"></i> <?= htmlspecialchars($n['target_user_name'] ?? 'User #' . $n['target_user_id']) ?>
                                    </span>
                                <?php elseif ($n['target_type'] === 'all_except_user'): ?>
                                    <span class="badge" style="background: rgba(255, 152, 0, 0.15); color: #FFA726;">
                                        <i class="fa-solid fa-user-xmark"></i> All except <?= htmlspecialchars($n['target_user_name'] ?? 'User #' . $n['target_user_id']) ?>
                                    </span>
                                <?php else: ?>
                                    <span class="badge" style="background: rgba(76, 175, 80, 0.15); color: #4CAF50;">
                                        <i class="fa-solid fa-globe"></i> All Users
                                    </span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <a href="<?= BASE_URL ?>/notifications.php?action=toggle&id=<?= $n['id'] ?>&user_id=<?= $selectedUserId ?>" 
                                   class="badge <?= $n['status'] === 'active' ? 'badge-success' : 'badge-secondary' ?>"
                                   style="text-decoration: none; cursor: pointer;"
                                   title="Click to toggle status">
                                    <?= ucfirst($n['status']) ?>
                                </a>
                            </td>
                            <td>
                                <span style="font-size: 13px; font-weight: 700; color: #FFF;">
                                    <?= (int)$n['read_count'] ?>
                                </span>
                                <span style="font-size: 11px; color: var(--cm-text-muted);">read</span>
                            </td>
                            <td>
                                <span style="font-size: 12px; color: var(--cm-text-secondary);">
                                    <?= date('M d, Y', strtotime($n['created_at'])) ?><br>
                                    <small style="color: var(--cm-text-muted);"><?= date('h:i A', strtotime($n['created_at'])) ?></small>
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: inline-flex; gap: 6px;">
                                    <button type="button" class="btn btn-secondary btn-sm btn-icon" 
                                            onclick='openEditModal(<?= json_encode($n, JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_HEX_AMP) ?>)' 
                                            title="Edit Notification">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </button>
                                    <a href="<?= BASE_URL ?>/notifications.php?action=delete&id=<?= $n['id'] ?>&user_id=<?= $selectedUserId ?>" 
                                       class="btn btn-secondary btn-sm btn-icon" 
                                       onclick="return confirm('Permanently delete this notification?');"
                                       title="Delete Notification"
                                       style="color: #FF5252;">
                                        <i class="fa-solid fa-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    <?php endif; ?>
</div>

<!-- ========================================================================= -->
<!-- SECTION 3: COMPOSE / EDIT NOTIFICATION MODAL                              -->
<!-- ========================================================================= -->
<div id="notificationModal" class="admin-modal" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.85); z-index: 9999; align-items: center; justify-content: center; padding: 20px;">
    <div class="card" style="max-width: 640px; width: 100%; max-height: 90vh; overflow-y: auto; padding: 24px; border: 1px solid var(--cm-border); box-shadow: 0 16px 48px rgba(0,0,0,0.8);">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
            <h3 id="modalTitle" style="font-size: 18px; margin: 0; font-weight: 800;">Create Notification</h3>
            <button type="button" onclick="closeModal()" style="background: none; border: none; color: #AAA; font-size: 24px; cursor: pointer;">&times;</button>
        </div>

        <!-- Real-Time Live Notification Card Preview Box -->
        <div style="background: rgba(255, 255, 255, 0.03); border: 1px solid var(--cm-border); border-radius: 12px; padding: 14px; margin-bottom: 20px;">
            <div style="font-size: 11px; text-transform: uppercase; font-weight: 800; color: var(--cm-text-muted); margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between;">
                <span><i class="fa-solid fa-eye" style="color: var(--cm-primary); margin-right: 6px;"></i> Live Mobile Notification Card Preview</span>
                <span style="font-size: 10.5px; color: #4CAF50;"><i class="fa-solid fa-circle-dot"></i> Real-Time</span>
            </div>
            <div id="previewCard" style="background: #181818; border: 1px solid rgba(255, 152, 0, 0.35); border-radius: 10px; padding: 14px; display: flex; gap: 12px; align-items: flex-start; box-shadow: 0 4px 16px rgba(0,0,0,0.5);">
                <div id="previewIconBox" style="width: 42px; height: 42px; border-radius: 50%; background: rgba(255, 152, 0, 0.15); color: #FFA726; display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0;">
                    <span id="previewEmoji">📢</span>
                </div>
                <div style="flex: 1; min-width: 0;">
                    <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px;">
                        <strong id="previewTitle" style="color: #FFF; font-size: 14.5px; font-weight: 700; word-break: break-word;">Food CHART Announcement</strong>
                        <span style="display: inline-block; width: 8px; height: 8px; border-radius: 50%; background: #FF5252; flex-shrink: 0;" title="Unread indicator"></span>
                    </div>
                    <p id="previewMessage" style="color: #DDD; font-size: 13px; margin: 4px 0 8px; line-height: 1.4; word-break: break-word;">
                        Enter title and message to see a live preview...
                    </p>
                    <div id="previewActionBtnContainer">
                        <span id="previewActionLabel" style="display: inline-block; font-size: 11.5px; font-weight: 700; color: var(--cm-primary); background: rgba(255, 152, 0, 0.12); border: 1px solid rgba(255, 152, 0, 0.3); padding: 4px 10px; border-radius: 6px;">
                            Tap to Explore &rarr;
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <form method="POST" action="<?= BASE_URL ?>/notifications.php">
            <input type="hidden" name="id" id="notif_id" value="0">

            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Notification Title <span style="color: var(--cm-primary);">*</span></label>
                <input type="text" name="title" id="notif_title" class="form-control" required placeholder="e.g. New Recipe Added 🍲" oninput="updateLivePreview()">
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Notification Message <span style="color: var(--cm-primary);">*</span></label>
                <textarea name="message" id="notif_message" class="form-control" rows="3" required placeholder="Enter clear description for Food CHART users..." oninput="updateLivePreview()"></textarea>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 16px;">
                <div class="form-group">
                    <label class="form-label">Notification Type</label>
                    <select name="type" id="notif_type" class="form-control" onchange="updateLivePreview()">
                        <option value="new_recipe">🍲 New Recipe</option>
                        <option value="recipe_updated">✨ Recipe Updated</option>
                        <option value="admin_announcement" selected>📢 Admin Announcement</option>
                        <option value="new_feature">🚀 New Feature</option>
                        <option value="recipe_approved">✅ Recipe Approved</option>
                        <option value="recipe_rejected">❌ Recipe Rejected</option>
                        <option value="changes_requested">📝 Changes Requested</option>
                        <option value="general">🔔 General</option>
                        <option value="promotion">🎁 Promotion</option>
                        <option value="system">⚙️ System</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select name="status" id="notif_status" class="form-control">
                        <option value="active" selected>Active</option>
                        <option value="inactive">Inactive</option>
                    </select>
                </div>
            </div>

            <!-- Target Audience with User Search Autocomplete -->
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 16px;">
                <div class="form-group">
                    <label class="form-label">Target Audience</label>
                    <select name="target_type" id="notif_target_type" class="form-control" onchange="toggleTargetUser()">
                        <option value="all" selected>🌐 All Users</option>
                        <option value="specific_user">👤 Specific User</option>
                        <option value="all_except_user">👥 All Users Except Selected User</option>
                    </select>
                </div>

                <div class="form-group" id="target_user_container" style="display: none;">
                    <label class="form-label" id="target_user_label">Select Target User</label>
                    <input type="text" id="user_search_box" class="form-control" placeholder="🔍 Search Name, Email, or ID..." oninput="filterUserList()" style="margin-bottom: 6px; font-size: 12px;">
                    <select name="target_user_id" id="notif_target_user_id" class="form-control">
                        <option value="">-- Choose User --</option>
                        <?php foreach ($usersList as $u): ?>
                            <option value="<?= $u['id'] ?>" data-search="<?= strtolower(htmlspecialchars($u['display_name'] . ' ' . ($u['email'] ?? '') . ' ' . $u['id'])) ?>">
                                #<?= $u['id'] ?> - <?= htmlspecialchars($u['display_name']) ?> <?= !empty($u['email']) ? '(' . htmlspecialchars($u['email']) . ')' : '' ?>
                            </option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; margin-bottom: 16px;">
                <div class="form-group">
                    <label class="form-label">Related Type</label>
                    <select name="related_type" id="notif_related_type" class="form-control">
                        <option value="">None / General</option>
                        <option value="recipe">Recipe</option>
                        <option value="recipe_submission">Recipe Submission</option>
                        <option value="feature">Feature / Screen</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Related ID / Identifier</label>
                    <input type="text" name="related_id" id="notif_related_id" class="form-control" placeholder="e.g. 201, rec_biryani, or submissions">
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Action Button Label (Optional)</label>
                <input type="text" name="action_label" id="notif_action_label" class="form-control" placeholder="e.g. Tap to Explore, View Recipe, Read More" oninput="updateLivePreview()">
                <small style="color: var(--cm-text-muted);">Custom button text displayed on the notification card in the mobile app.</small>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Optional Image URL</label>
                <input type="text" name="image" id="notif_image" class="form-control" placeholder="assets/images/... or https://...">
            </div>

            <div class="form-group" style="margin-bottom: 24px;">
                <label class="form-label">Expiration (Optional)</label>
                <input type="datetime-local" name="expires_at" id="notif_expires_at" class="form-control">
                <small style="color: var(--cm-text-muted);">Leave empty if no automatic expiration date is needed.</small>
            </div>

            <div style="display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal()">Cancel</button>
                <button type="submit" class="btn btn-primary" id="modalSubmitBtn">Send Notification</button>
            </div>
        </form>
    </div>
</div>

<script>
const typeEmojis = {
    'new_recipe': '🍲',
    'recipe_updated': '✨',
    'admin_announcement': '📢',
    'new_feature': '🚀',
    'recipe_approved': '🎉',
    'recipe_rejected': '❌',
    'changes_requested': '📝',
    'general': '🔔',
    'promotion': '🎁',
    'system': '⚙️'
};

// Switch App User Perspective
function switchUserPerspective(userId) {
    const url = new URL(window.location.href);
    url.searchParams.set('user_id', userId);
    window.location.href = url.toString();
}

// Toggle Phone View between Home Screen & Notifications Screen
let phoneCurrentView = 'notifications';
function togglePhoneView() {
    const feed = document.getElementById('phoneNotificationsFeed');
    const home = document.getElementById('phoneHomeScreenFeed');
    const label = document.getElementById('phoneViewModeLabel');

    if (phoneCurrentView === 'notifications') {
        feed.style.display = 'none';
        home.style.display = 'block';
        label.innerHTML = '<i class="fa-solid fa-house" style="color: #4CAF50;"></i> Food CHART Home Feed';
        phoneCurrentView = 'home';
    } else {
        home.style.display = 'none';
        feed.style.display = 'block';
        label.innerHTML = '<i class="fa-solid fa-bell" style="color: #E50915;"></i> In-App Notifications';
        phoneCurrentView = 'notifications';
    }
}

function updateLivePreview() {
    const title = document.getElementById('notif_title').value.trim() || 'Food CHART Notification';
    const message = document.getElementById('notif_message').value.trim() || 'Enter notification message to preview here...';
    const type = document.getElementById('notif_type').value || 'general';
    const action = document.getElementById('notif_action_label').value.trim() || 'Tap to Explore';

    document.getElementById('previewTitle').innerText = title;
    document.getElementById('previewMessage').innerText = message;
    document.getElementById('previewEmoji').innerText = typeEmojis[type] || '🔔';
    document.getElementById('previewActionLabel').innerHTML = action + ' &rarr;';
}

function filterUserList() {
    const query = document.getElementById('user_search_box').value.toLowerCase().trim();
    const select = document.getElementById('notif_target_user_id');
    const options = select.getElementsByTagName('option');

    for (let i = 0; i < options.length; i++) {
        if (options[i].value === '') {
            options[i].style.display = '';
            continue;
        }
        const searchData = options[i].getAttribute('data-search') || '';
        if (query === '' || searchData.includes(query)) {
            options[i].style.display = '';
        } else {
            options[i].style.display = 'none';
        }
    }
}

function openCreateModal() {
    document.getElementById('modalTitle').innerText = 'Create Notification';
    document.getElementById('modalSubmitBtn').innerText = 'Send Notification';
    document.getElementById('notif_id').value = '0';
    document.getElementById('notif_title').value = '';
    document.getElementById('notif_message').value = '';
    document.getElementById('notif_type').value = 'admin_announcement';
    document.getElementById('notif_status').value = 'active';
    document.getElementById('notif_target_type').value = 'all';
    document.getElementById('notif_target_user_id').value = '';
    document.getElementById('notif_related_type').value = '';
    document.getElementById('notif_related_id').value = '';
    document.getElementById('notif_action_label').value = '';
    document.getElementById('notif_image').value = '';
    document.getElementById('notif_expires_at').value = '';
    document.getElementById('user_search_box').value = '';
    filterUserList();
    toggleTargetUser();
    updateLivePreview();
    document.getElementById('notificationModal').style.display = 'flex';
}

function openEditModal(n) {
    document.getElementById('modalTitle').innerText = 'Edit Notification #' + n.id;
    document.getElementById('modalSubmitBtn').innerText = 'Save Changes';
    document.getElementById('notif_id').value = n.id;
    document.getElementById('notif_title').value = n.title || '';
    document.getElementById('notif_message').value = n.message || '';
    document.getElementById('notif_type').value = n.type || 'general';
    document.getElementById('notif_status').value = n.status || 'active';
    document.getElementById('notif_target_type').value = n.target_type || 'all';
    document.getElementById('notif_target_user_id').value = n.target_user_id || '';
    document.getElementById('notif_related_type').value = n.related_type || '';
    document.getElementById('notif_related_id').value = n.related_id || '';
    document.getElementById('notif_action_label').value = n.action_label || '';
    document.getElementById('notif_image').value = n.image || '';
    document.getElementById('notif_expires_at').value = n.expires_at ? n.expires_at.replace(' ', 'T') : '';
    document.getElementById('user_search_box').value = '';
    filterUserList();
    toggleTargetUser();
    updateLivePreview();
    document.getElementById('notificationModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('notificationModal').style.display = 'none';
}

function toggleTargetUser() {
    const target = document.getElementById('notif_target_type').value;
    const container = document.getElementById('target_user_container');
    const label = document.getElementById('target_user_label');
    
    if (target === 'specific_user') {
        container.style.display = 'block';
        label.innerText = 'Select Specific User';
    } else if (target === 'all_except_user') {
        container.style.display = 'block';
        label.innerText = 'Select User to Exclude';
    } else {
        container.style.display = 'none';
    }
}

// Close modal on escape key
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeModal();
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
