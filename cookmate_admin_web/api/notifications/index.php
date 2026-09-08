<?php
/**
 * Food CHART API - User Notifications Endpoint
 * GET  /api/notifications/index.php?page=1&limit=20&filter=unread
 * POST /api/notifications/index.php (Mark read fallback)
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

// Handle DELETE: Dismiss notification or clear all
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    $raw = file_get_contents('php://input');
    $input = json_decode($raw, true) ?? [];
    $notifId = (int)($input['notification_id'] ?? $input['id'] ?? $_GET['id'] ?? 0);
    $clearAll = !empty($input['clear_all']) || !empty($input['all']) || (isset($_GET['clear_all']) && $_GET['clear_all'] == '1');

    if ($clearAll) {
        $deleted = dismiss_all_user_notifications($pdo, $userId);
    } elseif ($notifId > 0) {
        $deleted = dismiss_user_notification($pdo, $notifId, $userId);
    }
    $unreadCount = get_user_unread_count($pdo, $userId);
    json_response([
        'success'      => true,
        'message'      => 'Notification(s) deleted successfully.',
        'unread_count' => $unreadCount
    ]);
}

// Handle POST (Mark read compatibility)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $raw = file_get_contents('php://input');
    $input = json_decode($raw, true) ?? $_POST;
    $notifId = (int)($input['notification_id'] ?? $input['id'] ?? 0);

    if ($notifId > 0) {
        mark_notification_as_read($pdo, $notifId, $userId);
    } else {
        mark_all_notifications_as_read($pdo, $userId);
    }

    $unreadCount = get_user_unread_count($pdo, $userId);
    json_response([
        'success'      => true,
        'message'      => 'Notifications status updated successfully.',
        'unread_count' => $unreadCount
    ]);
}

// Handle GET: Fetch notification list with 24-hour read retention rule
try {
    $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
    $limit = isset($_GET['limit']) ? (int)$_GET['limit'] : 20;
    $filter = isset($_GET['filter']) ? trim($_GET['filter']) : null;

    $notifications = get_user_notifications($pdo, $userId, $page, $limit, $filter);
    $unreadCount = get_user_unread_count($pdo, $userId);

    json_response([
        'success'      => true,
        'unread_count' => $unreadCount,
        'count'        => count($notifications),
        'page'         => $page,
        'limit'        => $limit,
        'data'         => $notifications
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to fetch notifications: ' . $e->getMessage()
    ], 500);
}
