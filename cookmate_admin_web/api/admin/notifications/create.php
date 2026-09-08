<?php
/**
 * Food CHART Admin API - Create Notification
 * POST /api/admin/notifications/create.php
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

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_response(['success' => false, 'message' => 'Method not allowed.'], 405);
}

$raw = file_get_contents('php://input');
$data = json_decode($raw, true) ?? $_POST;

$title = trim($data['title'] ?? '');
$message = trim($data['message'] ?? '');
$type = trim($data['type'] ?? 'general');

if (empty($title) || empty($message)) {
    json_response([
        'success' => false,
        'message' => 'Notification title and message are required.'
    ], 400);
}

try {
    $notifId = create_system_notification($pdo, [
        'title'               => $title,
        'message'             => $message,
        'type'                => $type,
        'target_type'         => in_array($data['target_type'] ?? '', ['all', 'specific_user', 'all_except_user', 'selected_users']) ? $data['target_type'] : 'all',
        'target_user_id'      => !empty($data['target_user_id']) ? (int)$data['target_user_id'] : null,
        'related_type'        => !empty($data['related_type']) ? trim($data['related_type']) : null,
        'related_id'          => !empty($data['related_id']) ? trim($data['related_id']) : null,
        'image'               => !empty($data['image']) ? trim($data['image']) : null,
        'action_label'        => !empty($data['action_label']) ? trim($data['action_label']) : null,
        'status'              => in_array($data['status'] ?? '', ['active', 'inactive']) ? $data['status'] : 'active',
        'created_by_admin_id' => !empty($data['created_by_admin_id']) ? (int)$data['created_by_admin_id'] : 1,
        'expires_at'          => !empty($data['expires_at']) ? $data['expires_at'] : null,
    ]);

    json_response([
        'success'         => true,
        'message'         => 'Notification created successfully.',
        'notification_id' => $notifId
    ], 201);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to create notification: ' . $e->getMessage()
    ], 500);
}
