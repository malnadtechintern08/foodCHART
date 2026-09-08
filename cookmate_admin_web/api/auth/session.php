<?php
/**
 * Food CHART API - User Authentication Session Endpoint
 * POST /api/auth/session.php
 */

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../includes/auth_middleware.php';

set_cors_headers();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$pdo = get_db_connection();

$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$token = get_auth_token_from_headers() ?: trim($input['auth_token'] ?? '');
$displayName = trim($input['display_name'] ?? '');
$deviceInfo = trim($input['device_info'] ?? '');

try {
    $user = get_or_register_user($pdo, $token ?: null, $displayName ?: null, $deviceInfo ?: null);

    json_response([
        'success' => true,
        'message' => 'User session active.',
        'data' => [
            'id' => (int)$user['id'],
            'auth_token' => $user['auth_token'],
            'display_name' => $user['display_name'],
            'email' => $user['email'],
            'created_at' => $user['created_at'],
        ]
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to initialize user session: ' . $e->getMessage()
    ], 500);
}
