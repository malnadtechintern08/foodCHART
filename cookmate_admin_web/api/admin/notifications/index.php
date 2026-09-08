<?php
/**
 * Food CHART Admin API - List Notifications with Analytics
 * GET /api/admin/notifications/index.php
 */

require_once __DIR__ . '/../../../config/db.php';
require_once __DIR__ . '/../../../includes/auth_middleware.php';
require_once __DIR__ . '/../../../includes/notification_functions.php';

set_cors_headers();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$pdo = get_db_connection();

try {
    $search = trim($_GET['q'] ?? '');
    $type = trim($_GET['type'] ?? '');
    $status = trim($_GET['status'] ?? '');
    $target = trim($_GET['target'] ?? '');

    $where = ['1=1'];
    $params = [];

    if (!empty($search)) {
        $where[] = '(n.title LIKE ? OR n.message LIKE ?)';
        $params[] = "%$search%";
        $params[] = "%$search%";
    }
    if (!empty($type)) {
        $where[] = 'n.type = ?';
        $params[] = $type;
    }
    if (!empty($status)) {
        $where[] = 'n.status = ?';
        $params[] = $status;
    }
    if (!empty($target)) {
        $where[] = 'n.target_type = ?';
        $params[] = $target;
    }

    $whereSql = implode(' AND ', $where);

    // Summary statistics
    $totalCount = (int)$pdo->query("SELECT COUNT(*) FROM notifications")->fetchColumn();
    $activeCount = (int)$pdo->query("SELECT COUNT(*) FROM notifications WHERE status = 'active'")->fetchColumn();
    $recipeCount = (int)$pdo->query("SELECT COUNT(*) FROM notifications WHERE type IN ('new_recipe', 'recipe_updated')")->fetchColumn();
    $announcementCount = (int)$pdo->query("SELECT COUNT(*) FROM notifications WHERE type IN ('admin_announcement', 'new_feature', 'general')")->fetchColumn();

    $stmt = $pdo->prepare("
        SELECT 
            n.*,
            (SELECT COUNT(*) FROM user_notifications un WHERE un.notification_id = n.id AND un.is_read = 1) AS read_count,
            (SELECT COUNT(*) FROM user_notifications un WHERE un.notification_id = n.id) AS delivery_count,
            u.display_name AS target_user_name
        FROM notifications n
        LEFT JOIN users u ON u.id = n.target_user_id
        WHERE {$whereSql}
        ORDER BY n.created_at DESC
        LIMIT 100
    ");
    $stmt->execute($params);
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    json_response([
        'success' => true,
        'stats'   => [
            'total'         => $totalCount,
            'active'        => $activeCount,
            'recipe'        => $recipeCount,
            'announcements' => $announcementCount,
        ],
        'data'    => $items
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to fetch admin notifications: ' . $e->getMessage()
    ], 500);
}
