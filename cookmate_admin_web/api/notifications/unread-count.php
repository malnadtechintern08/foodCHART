<?php
/**
 * Food CHART API - Unread Notification Count
 * GET /api/notifications/unread-count.php
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
    $unreadCount = get_user_unread_count($pdo, $userId);
    json_response([
        'success'      => true,
        'unread_count' => $unreadCount
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to retrieve unread count: ' . $e->getMessage()
    ], 500);
}
