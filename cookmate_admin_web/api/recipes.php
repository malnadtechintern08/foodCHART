<?php
/**
 * Food CHART Web Admin - REST API endpoint for Recipes
 */
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../includes/tag_functions.php';

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

    // 1. Single recipe lookup by ID
    $recipeId = trim($_GET['id'] ?? '');
    if ($recipeId !== '') {
        $stmt = $pdo->prepare("SELECT * FROM recipes WHERE id = ? LIMIT 1");
        $stmt->execute([$recipeId]);
        $recipe = $stmt->fetch();

        if (!$recipe) {
            http_response_code(404);
            echo json_encode([
                'status' => 'error',
                'message' => "Recipe '$recipeId' not found"
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            exit;
        }

        // Attach ingredients
        $ingStmt = $pdo->prepare("SELECT name, amount, unit, notes FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC");
        $ingStmt->execute([$recipe['id']]);
        $recipe['ingredients'] = $ingStmt->fetchAll();

        // Attach instructions
        $insStmt = $pdo->prepare("SELECT step_number, instruction, timer_seconds, tip FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");
        $insStmt->execute([$recipe['id']]);
        $recipe['instructions'] = $insStmt->fetchAll();

        // Attach tags_list
        $recipe['tags_list'] = get_recipe_tags($pdo, $recipe['id']);

        echo json_encode([
            'status' => 'success',
            'data' => $recipe
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        exit;
    }

    // 2. Multiple recipes query
    $search = trim($_GET['q'] ?? '');
    $category = trim($_GET['category'] ?? '');
    $limit = min(1000, max(1, (int)($_GET['limit'] ?? 500)));
    $offset = max(0, (int)($_GET['offset'] ?? 0));

    $where = [];
    $params = [];

    if ($search !== '') {
        if (strpos($search, '#') === 0) {
            $tagClean = normalize_tag($search);
            $where[] = "id IN (
                SELECT rt.recipe_id FROM recipe_tags rt 
                INNER JOIN tags t ON t.id = rt.tag_id 
                WHERE t.name = ?
            )";
            $params[] = $tagClean;
        } else {
            $where[] = "(title LIKE ? OR chef_name LIKE ? OR cuisine LIKE ? OR tags LIKE ?)";
            $term = "%$search%";
            $params[] = $term;
            $params[] = $term;
            $params[] = $term;
            $params[] = $term;
        }
    }

    if ($category !== '') {
        $where[] = "category_id = ?";
        $params[] = $category;
    }

    $whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

    $stmt = $pdo->prepare("SELECT * FROM recipes $whereSql ORDER BY rating DESC, title ASC LIMIT $limit OFFSET $offset");
    $stmt->execute($params);
    $recipes = $stmt->fetchAll();

    // Include ingredients, steps, and tags_list for each recipe
    $ingStmt = $pdo->prepare("SELECT name, amount, unit, notes FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC");
    $insStmt = $pdo->prepare("SELECT step_number, instruction, timer_seconds, tip FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");

    foreach ($recipes as &$r) {
        $ingStmt->execute([$r['id']]);
        $r['ingredients'] = $ingStmt->fetchAll();

        $insStmt->execute([$r['id']]);
        $r['instructions'] = $insStmt->fetchAll();

        $r['tags_list'] = get_recipe_tags($pdo, $r['id']);
    }

    echo json_encode([
        'status' => 'success',
        'count' => count($recipes),
        'data' => $recipes
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
