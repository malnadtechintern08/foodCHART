<?php
/**
 * Food CHART Web Admin - Save Custom WhatsApp Share Text API
 */
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../includes/admin_auth.php';
require_once __DIR__ . '/../includes/recipe_share_helper.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if (!is_admin_logged_in()) {
    http_response_code(401);
    echo json_encode(['status' => 'error', 'message' => 'Unauthorized: Please log in to Food CHART Admin']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Method not allowed']);
    exit;
}

$recipeId = trim($_POST['recipe_id'] ?? '');
$shareText = trim($_POST['share_text'] ?? '');

if (empty($recipeId)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Recipe ID is required']);
    exit;
}

try {
    $pdo = get_db_connection();
    ensure_custom_share_text_column($pdo);

    $stmt = $pdo->prepare("UPDATE recipes SET custom_share_text = ? WHERE id = ?");
    $stmt->execute([$shareText !== '' ? $shareText : null, $recipeId]);

    echo json_encode([
        'status' => 'success',
        'message' => 'Custom WhatsApp share message saved successfully!',
        'custom_share_text' => $shareText
    ]);
} catch (Throwable $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Error saving custom share text: ' . $e->getMessage()
    ]);
}
