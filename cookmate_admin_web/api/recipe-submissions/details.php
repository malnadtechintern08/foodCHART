<?php
/**
 * Food CHART API - Get Full Submission Details
 * GET /api/recipe-submissions/details.php?id=123
 */

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../includes/auth_middleware.php';

set_cors_headers();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$pdo = get_db_connection();
$user = get_authenticated_user($pdo, true);
$userId = (int)$user['id'];

$submissionId = (int)($_GET['id'] ?? 0);
if ($submissionId <= 0) {
    json_response(['success' => false, 'message' => 'Invalid or missing submission ID.'], 400);
}

try {
    $stmt = $pdo->prepare("
        SELECT 
            s.*,
            c.name AS category_name,
            c.color_hex AS category_color
        FROM recipe_submissions s
        LEFT JOIN categories c ON s.category_id = c.id
        WHERE s.id = ?
    ");
    $stmt->execute([$submissionId]);
    $sub = $stmt->fetch();

    if (!$sub) {
        json_response(['success' => false, 'message' => 'Recipe submission not found.'], 404);
    }

    // Security check: User can only access their own submission
    if ((int)$sub['user_id'] !== $userId) {
        json_response(['success' => false, 'message' => 'Forbidden: You do not have permission to view this submission.'], 403);
    }

    // Fetch ingredients
    $ingStmt = $pdo->prepare("
        SELECT ingredient AS name, quantity, unit, position
        FROM recipe_submission_ingredients
        WHERE submission_id = ?
        ORDER BY position ASC
    ");
    $ingStmt->execute([$submissionId]);
    $ingredients = $ingStmt->fetchAll();

    // Fetch steps
    $stepStmt = $pdo->prepare("
        SELECT step_number, instruction, timer_seconds
        FROM recipe_submission_steps
        WHERE submission_id = ?
        ORDER BY step_number ASC
    ");
    $stepStmt->execute([$submissionId]);
    $steps = $stepStmt->fetchAll();

    // Fetch tags
    $tagStmt = $pdo->prepare("
        SELECT t.name 
        FROM recipe_submission_tags st
        JOIN tags t ON st.tag_id = t.id
        WHERE st.submission_id = ?
        ORDER BY t.name ASC
    ");
    $tagStmt->execute([$submissionId]);
    $tags = $tagStmt->fetchAll(PDO::FETCH_COLUMN);

    $imageUrl = $sub['image'];
    if ($imageUrl && !str_starts_with($imageUrl, 'http')) {
        $imageUrl = BASE_URL . '/' . ltrim($imageUrl, '/');
    }

    json_response([
        'success' => true,
        'data' => [
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
            'notes' => $sub['notes'],
            'status' => $sub['status'],
            'allow_publication' => (bool)$sub['allow_publication'],
            'show_author_name' => (bool)$sub['show_author_name'],
            'author_display_name' => $sub['author_display_name'],
            'admin_notes' => $sub['admin_notes'],
            'rejection_reason' => $sub['rejection_reason'],
            'published_recipe_id' => $sub['published_recipe_id'],
            'submitted_at' => $sub['submitted_at'],
            'reviewed_at' => $sub['reviewed_at'],
            'ingredients' => $ingredients,
            'steps' => $steps,
            'tags' => $tags,
        ]
    ]);

} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to fetch submission details: ' . $e->getMessage()
    ], 500);
}
