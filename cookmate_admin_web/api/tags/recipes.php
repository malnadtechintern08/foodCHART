<?php
/**
 * Food CHART REST API - Recipes by Hashtag
 * 
 * GET /api/tags/recipes.php?tag=rice&page=1&limit=20
 * Also supports multiple tags: ?tag=rice,veg (AND logic)
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

    $rawTag = trim($_GET['tag'] ?? $_GET['name'] ?? $_GET['q'] ?? '');
    $limit = min(100, max(1, (int)($_GET['limit'] ?? 20)));
    $page = max(1, (int)($_GET['page'] ?? 1));
    $offset = ($page - 1) * $limit;

    $tagList = parse_and_normalize_tags($rawTag);

    if (empty($tagList)) {
        echo json_encode([
            'success' => false,
            'status' => 'error',
            'message' => 'No valid hashtag specified.',
            'total' => 0,
            'page' => $page,
            'limit' => $limit,
            'totalPages' => 0,
            'data' => []
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        exit;
    }

    // Resolve tag IDs
    $inPlaceholders = implode(',', array_fill(0, count($tagList), '?'));
    $tagStmt = $pdo->prepare("SELECT id, name FROM tags WHERE name IN ($inPlaceholders)");
    $tagStmt->execute($tagList);
    $foundTags = $tagStmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($foundTags)) {
        echo json_encode([
            'success' => true,
            'status' => 'success',
            'tag' => implode(', ', $tagList),
            'total' => 0,
            'page' => $page,
            'limit' => $limit,
            'totalPages' => 0,
            'data' => []
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        exit;
    }

    $tagIds = array_column($foundTags, 'id');
    $tagCountRequired = count($tagIds);

    // If multiple tags are requested, we use HAVING COUNT(DISTINCT rt.tag_id) = $tagCountRequired (AND logic)
    $tagIdsPlaceholders = implode(',', array_fill(0, count($tagIds), '?'));

    // 1. Total matching recipes count
    $countSql = "
        SELECT COUNT(*) FROM (
            SELECT r.id 
            FROM recipes r
            INNER JOIN recipe_tags rt ON rt.recipe_id = r.id
            WHERE rt.tag_id IN ($tagIdsPlaceholders)
            GROUP BY r.id
            HAVING COUNT(DISTINCT rt.tag_id) = ?
        ) as matching_recipes
    ";
    $countParams = array_merge($tagIds, [$tagCountRequired]);
    $countStmt = $pdo->prepare($countSql);
    $countStmt->execute($countParams);
    $total = (int)$countStmt->fetchColumn();

    // 2. Fetch paginated recipes
    $dataSql = "
        SELECT r.* 
        FROM recipes r
        INNER JOIN recipe_tags rt ON rt.recipe_id = r.id
        WHERE rt.tag_id IN ($tagIdsPlaceholders)
        GROUP BY r.id
        HAVING COUNT(DISTINCT rt.tag_id) = ?
        ORDER BY r.rating DESC, r.title ASC
        LIMIT $limit OFFSET $offset
    ";
    $dataStmt = $pdo->prepare($dataSql);
    $dataStmt->execute($countParams);
    $recipes = $dataStmt->fetchAll(PDO::FETCH_ASSOC);

    // 3. Attach ingredients, instructions, and tags_list for each recipe
    $ingStmt = $pdo->prepare("SELECT name, amount, unit, notes FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC");
    $insStmt = $pdo->prepare("SELECT step_number, instruction, timer_seconds, tip FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");

    foreach ($recipes as &$r) {
        $ingStmt->execute([$r['id']]);
        $r['ingredients'] = $ingStmt->fetchAll(PDO::FETCH_ASSOC);

        $insStmt->execute([$r['id']]);
        $r['instructions'] = $insStmt->fetchAll(PDO::FETCH_ASSOC);

        $r['tags_list'] = get_recipe_tags($pdo, $r['id']);
    }

    echo json_encode([
        'success' => true,
        'status' => 'success',
        'tag' => implode(', ', $tagList),
        'total' => $total,
        'page' => $page,
        'limit' => $limit,
        'totalPages' => ceil($total / $limit),
        'data' => $recipes
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
