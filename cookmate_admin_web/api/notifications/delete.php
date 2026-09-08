<?php
/**
 * Food CHART API - Delete / Dismiss Notification Endpoint
 * POST /api/notifications/delete.php
 * Payload: { "notification_id": 123 } OR { "clear_all": true }
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
$clearAll = !empty($input['clear_all']) || !empty($input['all']);

try {
    if ($clearAll) {
        $deletedCount = dismiss_all_user_notifications($pdo, $userId);
        $unreadCount = get_user_unread_count($pdo, $userId);
        json_response([
            'success'       => true,
            'message'       => "All notifications cleared ($deletedCount removed).",
            'deleted_count' => $deletedCount,
            'unread_count'  => $unreadCount
        ]);
    } elseif ($notifId > 0) {
        $dismissed = dismiss_user_notification($pdo, $notifId, $userId);
        $unreadCount = get_user_unread_count($pdo, $userId);
        json_response([
            'success'      => $dismissed,
            'message'      => $dismissed ? 'Notification deleted successfully.' : 'Failed to delete notification.',
            'unread_count' => $unreadCount
        ]);
    } else {
        json_response([
            'success' => false,
            'message' => 'Missing notification_id or clear_all parameter.'
        ], 400);
    }
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to delete notification: ' . $e->getMessage()
    ], 500);
}
