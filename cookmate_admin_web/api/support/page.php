<?php
/**
 * Food CHART REST API - Support & Legal Page Endpoint
 * 
 * GET /api/support/page.php?slug=privacy-policy
 * GET /api/support/page.php?slug=contact-us
 * GET /api/support/page.php?slug=help-center
 * GET /api/support/page.php?slug=safety-guidelines
 * GET /api/support/page.php (lists all published pages)
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
    $slug = trim($_GET['slug'] ?? $_GET['id'] ?? '');

    if (!empty($slug)) {
        $stmt = $pdo->prepare("SELECT * FROM support_pages WHERE (slug = ? OR id = ?) AND is_published = 1 LIMIT 1");
        $stmt->execute([$slug, $slug]);
        $page = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$page) {
            http_response_code(404);
            echo json_encode([
                'status' => 'error',
                'message' => 'Requested page not found or is currently unpublished.'
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            exit;
        }

        // Decode meta JSON if present
        $page['meta'] = !empty($page['meta_json']) ? json_decode($page['meta_json'], true) : [];

        echo json_encode([
            'status' => 'success',
            'data' => $page
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    } else {
        $stmt = $pdo->query("SELECT id, title, slug, summary, meta_json, updated_at FROM support_pages WHERE is_published = 1 ORDER BY title ASC");
        $pages = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($pages as &$p) {
            $p['meta'] = !empty($p['meta_json']) ? json_decode($p['meta_json'], true) : [];
        }

        echo json_encode([
            'status' => 'success',
            'count' => count($pages),
            'data' => $pages
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
