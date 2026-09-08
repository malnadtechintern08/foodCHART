<?php
/**
 * Food CHART REST API - List Tags
 * 
 * GET /api/tags/index.php?q=...&limit=50&page=1&sort=usage
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
    $limit = min(100, max(1, (int)($_GET['limit'] ?? 30)));
    $page = max(1, (int)($_GET['page'] ?? 1));
    $offset = ($page - 1) * $limit;
    $sort = ($_GET['sort'] ?? 'usage') === 'name' ? 'name ASC' : 'usage_count DESC, name ASC';

    $where = [];
    $params = [];

    if ($q !== '') {
        $cleanQ = normalize_tag($q);
        $where[] = "(name LIKE ? OR slug LIKE ?)";
        $term = "%$cleanQ%";
        $params[] = $term;
        $params[] = $term;
    }

    $whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

    // Total count
    $countStmt = $pdo->prepare("SELECT COUNT(*) FROM tags $whereSql");
    $countStmt->execute($params);
    $total = (int)$countStmt->fetchColumn();

    // Query rows
    $stmt = $pdo->prepare("
        SELECT id, name, slug, usage_count, created_at, updated_at 
        FROM tags 
        $whereSql 
        ORDER BY $sort 
        LIMIT $limit OFFSET $offset
    ");
    $stmt->execute($params);
    $tags = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        'status' => 'success',
        'total' => $total,
        'page' => $page,
        'limit' => $limit,
        'totalPages' => ceil($total / $limit),
        'data' => $tags
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
