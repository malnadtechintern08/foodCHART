<?php
/**
 * Food CHART API - Submit Recipe for Moderation
 * POST /api/recipe-submissions/create.php
 * Accepts multipart/form-data or application/json.
 */

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../includes/auth_middleware.php';
require_once __DIR__ . '/../../includes/tag_functions.php';

set_cors_headers();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_response(['success' => false, 'message' => 'Method Not Allowed. Use POST.'], 405);
}

// Parse input
$input = $_POST;
if (empty($input) && str_contains($_SERVER['CONTENT_TYPE'] ?? '', 'application/json')) {
    $raw = file_get_contents('php://input');
    $input = json_decode($raw, true) ?? [];
}

$authorDisplayName = trim($input['author_display_name'] ?? '');

$pdo = get_db_connection();
$user = get_authenticated_user($pdo, true, true, !empty($authorDisplayName) ? $authorDisplayName : null);
$userId = (int)$user['id'];

$recipeName = trim($input['recipe_name'] ?? $input['title'] ?? '');
$description = trim($input['description'] ?? '');
$categoryId = trim($input['category_id'] ?? '');
$prepTime = max(1, (int)($input['preparation_time'] ?? $input['prep_time_minutes'] ?? 15));
$cookTime = max(0, (int)($input['cooking_time'] ?? $input['cook_time_minutes'] ?? 20));
$servings = max(1, (int)($input['servings'] ?? 4));
$difficulty = trim($input['difficulty'] ?? 'Medium');
$cuisine = trim($input['cuisine'] ?? 'Homemade');
$foodType = trim($input['food_type'] ?? (!empty($input['is_vegetarian']) ? 'Vegetarian' : 'Non-Vegetarian'));
$notes = trim($input['notes'] ?? '');

// Permission flags
$allowPublication = (int)($input['allow_publication'] ?? 0) === 1 ? 1 : 0;
$showAuthorName = (int)($input['show_author_name'] ?? 0) === 1 ? 1 : 0;
if (empty($authorDisplayName)) {
    $authorDisplayName = trim($user['display_name'] ?? 'Food CHART Chef');
}
$permissionGivenAt = $allowPublication ? date('Y-m-d H:i:s') : null;

// Validation
if (empty($recipeName)) {
    json_response(['success' => false, 'message' => 'Recipe name is required.'], 400);
}
if (empty($categoryId)) {
    json_response(['success' => false, 'message' => 'Category is required.'], 400);
}

// Verify category exists
$catCheck = $pdo->prepare("SELECT id FROM categories WHERE id = ?");
$catCheck->execute([$categoryId]);
if (!$catCheck->fetch()) {
    json_response(['success' => false, 'message' => "Category '$categoryId' does not exist."], 400);
}

// Handle Image Upload
$imagePath = null;
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $fileTmp = $_FILES['image']['tmp_name'];
    $fileSize = $_FILES['image']['size'];

    // 10MB limit
    if ($fileSize > 10 * 1024 * 1024) {
        json_response(['success' => false, 'message' => 'Image file is too large. Maximum size is 10MB.'], 400);
    }

    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $fileTmp);
    finfo_close($finfo);

    $allowedMimes = [
        'image/jpeg' => 'jpg',
        'image/png'  => 'png',
        'image/webp' => 'webp',
    ];

    if (!isset($allowedMimes[$mimeType])) {
        json_response(['success' => false, 'message' => 'Invalid image format. Allowed: JPEG, PNG, WEBP.'], 400);
    }

    $ext = $allowedMimes[$mimeType];
    $uploadDir = __DIR__ . '/../../uploads/recipe-submissions/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }

    $newFilename = 'sub_' . time() . '_' . bin2hex(random_bytes(6)) . '.' . $ext;
    $destination = $uploadDir . $newFilename;

    if (move_uploaded_file($fileTmp, $destination)) {
        $imagePath = 'uploads/recipe-submissions/' . $newFilename;
    } else {
        json_response(['success' => false, 'message' => 'Failed to save uploaded photo.'], 500);
    }
} elseif (!empty($input['image_url'])) {
    $imagePath = trim($input['image_url']);
}

// Parse Ingredients
$ingredientsRaw = $input['ingredients'] ?? [];
if (is_string($ingredientsRaw)) {
    $ingredientsRaw = json_decode($ingredientsRaw, true) ?? [];
}
if (!is_array($ingredientsRaw) || empty($ingredientsRaw)) {
    json_response(['success' => false, 'message' => 'Please provide at least 1 ingredient.'], 400);
}

// Parse Steps
$stepsRaw = $input['steps'] ?? $input['instructions'] ?? [];
if (is_string($stepsRaw)) {
    $stepsRaw = json_decode($stepsRaw, true) ?? [];
}
if (!is_array($stepsRaw) || empty($stepsRaw)) {
    json_response(['success' => false, 'message' => 'Please provide at least 1 cooking instruction step.'], 400);
}

// Parse Tags
$tagsRaw = $input['tags'] ?? $input['hashtags'] ?? [];
if (is_string($tagsRaw)) {
    // If JSON array or comma separated
    $decoded = json_decode($tagsRaw, true);
    if (is_array($decoded)) {
        $tagsRaw = $decoded;
    } else {
        $tagsRaw = array_filter(array_map('trim', explode(',', $tagsRaw)));
    }
}
$normalizedTags = parse_and_normalize_tags($tagsRaw);

// Database Transaction
try {
    $pdo->beginTransaction();

    // 1. Insert into recipe_submissions
    $stmt = $pdo->prepare("
        INSERT INTO recipe_submissions (
            user_id, recipe_name, description, category_id, image,
            preparation_time, cooking_time, difficulty, servings, cuisine, food_type,
            notes, status, allow_publication, show_author_name, author_display_name,
            permission_given_at, submitted_at
        ) VALUES (
            ?, ?, ?, ?, ?,
            ?, ?, ?, ?, ?, ?,
            ?, 'pending', ?, ?, ?,
            ?, NOW()
        )
    ");
    $stmt->execute([
        $userId,
        $recipeName,
        $description,
        $categoryId,
        $imagePath,
        $prepTime,
        $cookTime,
        $difficulty,
        $servings,
        $cuisine,
        $foodType,
        $notes,
        $allowPublication,
        $showAuthorName,
        $authorDisplayName,
        $permissionGivenAt,
    ]);
    $submissionId = (int)$pdo->lastInsertId();

    // 2. Insert ingredients
    $ingStmt = $pdo->prepare("
        INSERT INTO recipe_submission_ingredients (submission_id, ingredient, quantity, unit, position)
        VALUES (?, ?, ?, ?, ?)
    ");
    $pos = 1;
    foreach ($ingredientsRaw as $ing) {
        $name = is_array($ing) ? trim($ing['name'] ?? $ing['ingredient'] ?? '') : trim($ing);
        $qty = is_array($ing) ? trim((string)($ing['quantity'] ?? $ing['amount'] ?? '1')) : '1';
        $unit = is_array($ing) ? trim($ing['unit'] ?? '') : '';
        if (!empty($name)) {
            $ingStmt->execute([$submissionId, $name, $qty, $unit, $pos++]);
        }
    }

    // 3. Insert steps
    $stepStmt = $pdo->prepare("
        INSERT INTO recipe_submission_steps (submission_id, step_number, instruction, timer_seconds)
        VALUES (?, ?, ?, ?)
    ");
    $stepNum = 1;
    foreach ($stepsRaw as $st) {
        $instruction = is_array($st) ? trim($st['instruction'] ?? $st['step'] ?? '') : trim($st);
        $timer = is_array($st) ? max(0, (int)($st['timer_seconds'] ?? $st['timer'] ?? 0)) : 0;
        if (!empty($instruction)) {
            $stepStmt->execute([$submissionId, $stepNum++, $instruction, $timer]);
        }
    }

    // 4. Link Tags
    if (!empty($normalizedTags)) {
        $tagStmt = $pdo->prepare("INSERT INTO recipe_submission_tags (submission_id, tag_id) VALUES (?, ?)");
        $findTag = $pdo->prepare("SELECT id FROM tags WHERE name = ?");
        $insertTag = $pdo->prepare("INSERT INTO tags (name, slug, usage_count) VALUES (?, ?, 0)");

        foreach ($normalizedTags as $t) {
            $findTag->execute([$t]);
            $tagId = $findTag->fetchColumn();
            if (!$tagId) {
                $insertTag->execute([$t, $t]);
                $tagId = (int)$pdo->lastInsertId();
            }
            try {
                $tagStmt->execute([$submissionId, $tagId]);
            } catch (Exception $tagEx) {
                // Ignore unique duplicate constraint
            }
        }
    }

    $pdo->commit();

    json_response([
        'success' => true,
        'message' => 'Recipe submitted for review successfully. Current Status: Pending Review.',
        'data' => [
            'submission_id' => $submissionId,
            'status' => 'pending',
            'recipe_name' => $recipeName,
            'allow_publication' => (bool)$allowPublication,
            'submitted_at' => date('Y-m-d H:i:s'),
        ]
    ], 201);

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    json_response([
        'success' => false,
        'message' => 'Database error while submitting recipe: ' . $e->getMessage()
    ], 500);
}
