<?php
/**
 * Food CHART REST API - Unified Search Endpoint
 * 
 * Supports:
 * - Normal text search: ?q=rice
 * - Hashtag search: ?q=%23rice or ?q=#rice
 * - Multiple hashtags: ?q=#rice #veg
 * - Combined search: ?q=chicken #spicy
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

    $q = trim($_GET['q'] ?? '');
    $category = trim($_GET['category'] ?? '');
    $limit = min(100, max(1, (int)($_GET['limit'] ?? 50)));
    $page = max(1, (int)($_GET['page'] ?? 1));
    $offset = ($page - 1) * $limit;

    if ($q === '') {
        echo json_encode([
            'status' => 'success',
            'query' => '',
            'is_hashtag_search' => false,
            'total' => 0,
            'count' => 0,
            'data' => []
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
        exit;
    }

    // Parse input for hashtags (#word) vs normal keywords
    preg_match_all('/#([\w\-]+)/u', $q, $hashMatches);
    $foundHashtags = [];
    if (!empty($hashMatches[1])) {
        foreach ($hashMatches[1] as $ht) {
            $norm = normalize_tag($ht);
            if ($norm !== '' && !in_array($norm, $foundHashtags, true)) {
                $foundHashtags[] = $norm;
            }
        }
    }

    // Extract non-hashtag text words
    $remainingText = trim(preg_replace('/#[\w\-]+/u', '', $q));
    $isPureHashtag = (!empty($foundHashtags) && empty($remainingText));

    $whereClauses = [];
    $params = [];

    // 1. Filter by hashtags via recipe_tags if any hashtags were found
    if (!empty($foundHashtags)) {
        // Resolve tag IDs
        $inTags = implode(',', array_fill(0, count($foundHashtags), '?'));
        $tagStmt = $pdo->prepare("SELECT id, name FROM tags WHERE name IN ($inTags)");
        $tagStmt->execute($foundHashtags);
        $tagRows = $tagStmt->fetchAll(PDO::FETCH_ASSOC);

        if (empty($tagRows)) {
            // Searched for a tag that doesn't exist
            echo json_encode([
                'status' => 'success',
                'query' => $q,
                'is_hashtag_search' => true,
                'tags' => $foundHashtags,
                'total' => 0,
                'count' => 0,
                'data' => []
            ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
            exit;
        }

        $tagIds = array_column($tagRows, 'id');
        $tagCount = count($tagIds);
        $inTagIds = implode(',', array_fill(0, $tagCount, '?'));

        // Recipe must have all requested tags (AND logic)
        $whereClauses[] = "r.id IN (
            SELECT rt.recipe_id 
            FROM recipe_tags rt 
            WHERE rt.tag_id IN ($inTagIds) 
            GROUP BY rt.recipe_id 
            HAVING COUNT(DISTINCT rt.tag_id) = ?
        )";
        foreach ($tagIds as $tid) {
            $params[] = $tid;
        }
        $params[] = $tagCount;
    }

    // 2. Filter by remaining text query (title, description, cuisine, ingredients, or tags)
    if (!empty($remainingText)) {
        $term = "%$remainingText%";
        $whereClauses[] = "(
            r.title LIKE ? 
            OR r.description LIKE ? 
            OR r.cuisine LIKE ? 
            OR r.chef_name LIKE ? 
            OR r.tags LIKE ? 
            OR r.id IN (SELECT ri.recipe_id FROM recipe_ingredients ri WHERE ri.name LIKE ?)
        )";
        $params[] = $term;
        $params[] = $term;
        $params[] = $term;
        $params[] = $term;
        $params[] = $term;
        $params[] = $term;
    }

    // 3. Category filter
    if ($category !== '') {
        $whereClauses[] = "r.category_id = ?";
        $params[] = $category;
    }

    $whereSql = !empty($whereClauses) ? 'WHERE ' . implode(' AND ', $whereClauses) : '';

    // Total count
    $countSql = "SELECT COUNT(*) FROM recipes r $whereSql";
    $countStmt = $pdo->prepare($countSql);
    $countStmt->execute($params);
    $total = (int)$countStmt->fetchColumn();

    // Query recipes
    $querySql = "
        SELECT r.* 
        FROM recipes r 
        $whereSql 
        ORDER BY r.rating DESC, r.title ASC 
        LIMIT $limit OFFSET $offset
    ";
    $stmt = $pdo->prepare($querySql);
    $stmt->execute($params);
    $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Attach ingredients, instructions, and tags_list
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
        'status' => 'success',
        'query' => $q,
        'is_hashtag_search' => $isPureHashtag,
        'hashtags' => $foundHashtags,
        'text_query' => $remainingText,
        'total' => $total,
        'count' => count($recipes),
        'page' => $page,
        'limit' => $limit,
        'totalPages' => ceil($total / $limit),
        'data' => $recipes
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
