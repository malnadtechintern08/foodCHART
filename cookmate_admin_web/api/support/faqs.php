<?php
/**
 * Food CHART REST API - FAQs Endpoint
 * 
 * GET /api/support/faqs.php
 * GET /api/support/faqs.php?category=General
 */
require_once __DIR__ . '/../../config/db.php';

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
    $category = trim($_GET['category'] ?? '');

    $where = ["is_published = 1"];
    $params = [];

    if (!empty($category)) {
        $where[] = "category = ?";
        $params[] = $category;
    }

    $whereSql = implode(' AND ', $where);
    $stmt = $pdo->prepare("SELECT id, category, question, answer, sort_order, updated_at FROM faqs WHERE $whereSql ORDER BY sort_order ASC, id ASC");
    $stmt->execute($params);
    $faqs = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Group by category
    $grouped = [];
    foreach ($faqs as $f) {
        $cat = $f['category'] ?: 'General';
        if (!isset($grouped[$cat])) {
            $grouped[$cat] = [];
        }
        $grouped[$cat][] = $f;
    }

    echo json_encode([
        'status' => 'success',
        'count' => count($faqs),
        'data' => $faqs,
        'grouped' => $grouped
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
