<?php
/**
 * Food CHART REST API - Popular / Trending Hashtags
 * 
 * GET /api/tags/popular.php?limit=15
 */

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../includes/tag_functions.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $pdo = get_db_connection();

    $limit = min(50, max(1, (int)($_GET['limit'] ?? 15)));

    $stmt = $pdo->prepare("
        SELECT id, name, slug, usage_count 
        FROM tags 
        WHERE usage_count > 0
        ORDER BY usage_count DESC, name ASC 
        LIMIT $limit
    ");
    $stmt->execute();
    $tags = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'status' => 'success',
        'count' => count($tags),
        'data' => $tags
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
