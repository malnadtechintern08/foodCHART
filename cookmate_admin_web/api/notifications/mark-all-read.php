<?php
/**
 * Food CHART API - Mark All Notifications As Read
 * POST /api/notifications/mark-all-read.php
 */

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../includes/auth_middleware.php';
require_once __DIR__ . '/../../includes/notification_functions.php';

set_cors_headers();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$pdo = get_db_connection();
ensure_notifications_tables_exist($pdo);
$user = get_authenticated_user($pdo, false, true, 'Food CHART Foodie');
$userId = $user ? (int)$user['id'] : 1;

try {
    $updatedCount = mark_all_notifications_as_read($pdo, $userId);
    $unreadCount = get_user_unread_count($pdo, $userId);

    json_response([
        'success'       => true,
        'message'       => 'All notifications marked as read.',
        'updated_count' => $updatedCount,
        'unread_count'  => $unreadCount
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to mark all notifications as read: ' . $e->getMessage()
    ], 500);
}
