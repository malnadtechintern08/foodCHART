<?php
/**
 * Food CHART API - Withdraw Recipe Submission
 * POST /api/recipe-submissions/withdraw.php
 */

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../includes/auth_middleware.php';

set_cors_headers();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$pdo = get_db_connection();
$user = get_authenticated_user($pdo, true);
$userId = (int)$user['id'];

$input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
$submissionId = (int)($input['id'] ?? $input['submission_id'] ?? 0);

if ($submissionId <= 0) {
    json_response(['success' => false, 'message' => 'Invalid or missing submission ID.'], 400);
}

$stmt = $pdo->prepare("SELECT * FROM recipe_submissions WHERE id = ?");
$stmt->execute([$submissionId]);
$sub = $stmt->fetch();

if (!$sub) {
    json_response(['success' => false, 'message' => 'Recipe submission not found.'], 404);
}

if ((int)$sub['user_id'] !== $userId) {
    json_response(['success' => false, 'message' => 'Forbidden: You cannot withdraw another user\'s submission.'], 403);
}

if ($sub['status'] === 'published') {
    json_response(['success' => false, 'message' => 'Published recipes cannot be withdrawn directly. Please contact admin.'], 400);
}

try {
    $del = $pdo->prepare("DELETE FROM recipe_submissions WHERE id = ?");
    $del->execute([$submissionId]);

    json_response([
        'success' => true,
        'message' => 'Recipe submission withdrawn successfully.'
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to withdraw recipe submission: ' . $e->getMessage()
    ], 500);
}
