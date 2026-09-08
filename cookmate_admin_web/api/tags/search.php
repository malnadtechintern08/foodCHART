<?php
/**
 * Food CHART REST API - Hashtag Autocomplete Suggestions
 * 
 * GET /api/tags/search.php?q=ri&limit=10
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

    $q = trim($_GET['q'] ?? '');
    $limit = min(30, max(1, (int)($_GET['limit'] ?? 10)));

    // Clean leading hash or whitespace
    $cleanQ = normalize_tag($q);

    if ($cleanQ === '') {
        // Return top popular tags if query is empty or just '#'
        $stmt = $pdo->prepare("
            SELECT id, name, slug, usage_count 
            FROM tags 
            ORDER BY usage_count DESC, name ASC 
            LIMIT $limit
        ");
        $stmt->execute();
        $tags = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } else {
        $prefix = "$cleanQ%";
        $contains = "%$cleanQ%";

        $stmt = $pdo->prepare("
            SELECT id, name, slug, usage_count,
                   CASE WHEN name LIKE ? THEN 1 ELSE 2 END as match_priority
            FROM tags 
            WHERE name LIKE ?
            ORDER BY match_priority ASC, usage_count DESC, name ASC 
            LIMIT $limit
        ");
        $stmt->execute([$prefix, $contains]);
        $tags = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    echo json_encode([
        'status' => 'success',
        'query' => $cleanQ,
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
