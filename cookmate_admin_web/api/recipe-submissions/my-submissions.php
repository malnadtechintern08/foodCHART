<?php
/**
 * Food CHART API - Get User's Own Recipe Submissions
 * GET /api/recipe-submissions/my-submissions.php
 */

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../includes/auth_middleware.php';

set_cors_headers();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$pdo = get_db_connection();
$user = get_authenticated_user($pdo, true, true);
$userId = (int)$user['id'];

try {
    $stmt = $pdo->prepare("
        SELECT 
            s.*,
            c.name AS category_name,
            c.color_hex AS category_color,
            (SELECT COUNT(*) FROM recipe_submission_ingredients WHERE submission_id = s.id) AS ingredient_count,
            (SELECT COUNT(*) FROM recipe_submission_steps WHERE submission_id = s.id) AS step_count
        FROM recipe_submissions s
        LEFT JOIN categories c ON s.category_id = c.id
        WHERE s.user_id = ?
        ORDER BY s.submitted_at DESC
    ");
    $stmt->execute([$userId]);
    $submissions = $stmt->fetchAll();

    // Attach tags and format images
    $formatted = [];
    foreach ($submissions as $sub) {
        $tagStmt = $pdo->prepare("
            SELECT t.name 
            FROM recipe_submission_tags st
            JOIN tags t ON st.tag_id = t.id
            WHERE st.submission_id = ?
            ORDER BY t.name ASC
        ");
        $tagStmt->execute([$sub['id']]);
        $tags = $tagStmt->fetchAll(PDO::FETCH_COLUMN);

        $imageUrl = $sub['image'];
        if ($imageUrl && !str_starts_with($imageUrl, 'http')) {
            $imageUrl = BASE_URL . '/' . ltrim($imageUrl, '/');
        }

        $formatted[] = [
            'id' => (int)$sub['id'],
            'recipe_name' => $sub['recipe_name'],
            'description' => $sub['description'],
            'category_id' => $sub['category_id'],
            'category_name' => $sub['category_name'] ?? 'General',
            'category_color' => $sub['category_color'] ?? '#E50914',
            'image' => $imageUrl,
            'preparation_time' => (int)$sub['preparation_time'],
            'cooking_time' => (int)$sub['cooking_time'],
            'difficulty' => $sub['difficulty'],
            'servings' => (int)$sub['servings'],
            'cuisine' => $sub['cuisine'],
            'food_type' => $sub['food_type'],
            'status' => $sub['status'],
            'allow_publication' => (bool)$sub['allow_publication'],
            'show_author_name' => (bool)$sub['show_author_name'],
            'author_display_name' => $sub['author_display_name'],
            'admin_notes' => $sub['admin_notes'],
            'rejection_reason' => $sub['rejection_reason'],
            'published_recipe_id' => $sub['published_recipe_id'],
            'submitted_at' => $sub['submitted_at'],
            'reviewed_at' => $sub['reviewed_at'],
            'ingredient_count' => (int)$sub['ingredient_count'],
            'step_count' => (int)$sub['step_count'],
            'tags' => $tags,
        ];
    }

    json_response([
        'success' => true,
        'count' => count($formatted),
        'data' => $formatted
    ]);

} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to fetch user submissions: ' . $e->getMessage()
    ], 500);
}
