<?php
/**
 * Food CHART Admin API - Update Notification
 * POST /api/admin/notifications/update.php
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

$id = (int)($data['id'] ?? 0);
if ($id <= 0) {
    json_response(['success' => false, 'message' => 'Valid notification ID is required.'], 400);
}

try {
    $stmt = $pdo->prepare("SELECT * FROM notifications WHERE id = ?");
    $stmt->execute([$id]);
    $existing = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$existing) {
        json_response(['success' => false, 'message' => 'Notification not found.'], 404);
    }

    $title       = trim($data['title'] ?? $existing['title']);
    $message     = trim($data['message'] ?? $existing['message']);
    $type        = trim($data['type'] ?? $existing['type']);
    $targetType  = in_array($data['target_type'] ?? '', ['all', 'specific_user', 'all_except_user', 'selected_users']) ? $data['target_type'] : $existing['target_type'];
    $targetUser  = isset($data['target_user_id']) ? (!empty($data['target_user_id']) ? (int)$data['target_user_id'] : null) : $existing['target_user_id'];
    $relatedType = isset($data['related_type']) ? trim($data['related_type']) : $existing['related_type'];
    $relatedId   = isset($data['related_id']) ? trim($data['related_id']) : $existing['related_id'];
    $image       = isset($data['image']) ? trim($data['image']) : $existing['image'];
    $actionLabel = isset($data['action_label']) ? trim($data['action_label']) : ($existing['action_label'] ?? null);
    $status      = in_array($data['status'] ?? '', ['active', 'inactive']) ? $data['status'] : $existing['status'];
    $expiresAt   = isset($data['expires_at']) ? (!empty($data['expires_at']) ? $data['expires_at'] : null) : $existing['expires_at'];

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
        $title,
        $message,
        $type,
        $targetType,
        $targetUser,
        $relatedType,
        $relatedId,
        $image,
        $actionLabel,
        $status,
        $expiresAt,
        $id
    ]);

    json_response([
        'success' => true,
        'message' => 'Notification updated successfully.'
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to update notification: ' . $e->getMessage()
    ], 500);
}
