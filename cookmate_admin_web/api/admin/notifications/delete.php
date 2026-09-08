<?php
/**
 * Food CHART Admin API - Delete or Toggle Notification
 * POST /api/admin/notifications/delete.php
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
$action = trim($data['action'] ?? 'delete'); // 'delete' or 'toggle_status'

if ($id <= 0) {
    json_response(['success' => false, 'message' => 'Valid notification ID is required.'], 400);
}

try {
    if ($action === 'toggle_status') {
        $stmt = $pdo->prepare("SELECT status FROM notifications WHERE id = ?");
        $stmt->execute([$id]);
        $curr = $stmt->fetchColumn();
        if ($curr === false) {
            json_response(['success' => false, 'message' => 'Notification not found.'], 404);
        }
        $newStatus = ($curr === 'active') ? 'inactive' : 'active';
        $up = $pdo->prepare("UPDATE notifications SET status = ?, updated_at = NOW() WHERE id = ?");
        $up->execute([$newStatus, $id]);

        json_response([
            'success' => true,
            'message' => "Notification status toggled to $newStatus.",
            'new_status' => $newStatus
        ]);
    } else {
        // Permanent delete
        $del = $pdo->prepare("DELETE FROM notifications WHERE id = ?");
        $del->execute([$id]);

        json_response([
            'success' => true,
            'message' => 'Notification deleted permanently.'
        ]);
    }
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Operation failed: ' . $e->getMessage()
    ], 500);
}
