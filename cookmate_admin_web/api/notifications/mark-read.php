<?php
/**
 * Food CHART API - Mark Single Notification As Read
 * POST /api/notifications/mark-read.php
 * Body: { "notification_id": 123 }
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

$raw = file_get_contents('php://input');
$input = json_decode($raw, true) ?? $_POST;
$notifId = (int)($input['notification_id'] ?? $input['id'] ?? 0);

if ($notifId <= 0) {
    json_response([
        'success' => false,
        'message' => 'Valid notification_id is required.'
    ], 400);
}

try {
    mark_notification_as_read($pdo, $notifId, $userId);
    $unreadCount = get_user_unread_count($pdo, $userId);

    json_response([
        'success'         => true,
        'message'         => 'Notification marked as read.',
        'notification_id' => $notifId,
        'unread_count'    => $unreadCount
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to mark notification as read: ' . $e->getMessage()
    ], 500);
}
