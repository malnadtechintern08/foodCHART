<?php
/**
 * Food CHART Web Admin - Universal WhatsApp Share Message / 1-Click Mass Apply API
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

$sampleText = trim($_POST['share_text'] ?? '');
$recipeId = trim($_POST['recipe_id'] ?? '');

if (empty($sampleText)) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Message template cannot be empty']);
    exit;
}

try {
    $pdo = get_db_connection();
    $result = apply_universal_whatsapp_template_to_all($pdo, $sampleText, $recipeId ?: null);

    echo json_encode([
        'status' => 'success',
        'message' => $result['message'],
        'total_updated' => $result['total_updated']
    ]);
} catch (Throwable $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Error applying universal template: ' . $e->getMessage()
    ]);
}
