<?php
/**
 * Food CHART API - Update / Resubmit Recipe Submission
 * POST /api/recipe-submissions/update.php
 * Allows editing while status is 'pending' or 'changes_requested'.
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

$pdo = get_db_connection();
$user = get_authenticated_user($pdo, true);
$userId = (int)$user['id'];

$input = $_POST;
if (empty($input) && str_contains($_SERVER['CONTENT_TYPE'] ?? '', 'application/json')) {
    $raw = file_get_contents('php://input');
    $input = json_decode($raw, true) ?? [];
}

$submissionId = (int)($input['id'] ?? $input['submission_id'] ?? 0);
if ($submissionId <= 0) {
    json_response(['success' => false, 'message' => 'Invalid or missing submission ID.'], 400);
}

// Fetch submission and verify ownership & status
$stmt = $pdo->prepare("SELECT * FROM recipe_submissions WHERE id = ?");
$stmt->execute([$submissionId]);
$sub = $stmt->fetch();

if (!$sub) {
    json_response(['success' => false, 'message' => 'Recipe submission not found.'], 404);
}

if ((int)$sub['user_id'] !== $userId) {
    json_response(['success' => false, 'message' => 'Forbidden: You cannot modify another user\'s submission.'], 403);
}

if ($sub['status'] === 'published') {
    json_response(['success' => false, 'message' => 'This recipe has already been published and cannot be modified directly.'], 400);
}

// Extract update fields
$recipeName = trim($input['recipe_name'] ?? $input['title'] ?? $sub['recipe_name']);
$description = trim($input['description'] ?? $sub['description']);
$categoryId = trim($input['category_id'] ?? $sub['category_id']);
$prepTime = max(1, (int)($input['preparation_time'] ?? $input['prep_time_minutes'] ?? $sub['preparation_time']));
$cookTime = max(0, (int)($input['cooking_time'] ?? $input['cook_time_minutes'] ?? $sub['cooking_time']));
$servings = max(1, (int)($input['servings'] ?? $sub['servings']));
$difficulty = trim($input['difficulty'] ?? $sub['difficulty']);
$cuisine = trim($input['cuisine'] ?? $sub['cuisine']);
$foodType = trim($input['food_type'] ?? $sub['food_type']);
$notes = trim($input['notes'] ?? $sub['notes']);

// Consent updates
$allowPublication = isset($input['allow_publication']) ? ((int)$input['allow_publication'] === 1 ? 1 : 0) : (int)$sub['allow_publication'];
$showAuthorName = isset($input['show_author_name']) ? ((int)$input['show_author_name'] === 1 ? 1 : 0) : (int)$sub['show_author_name'];
$authorDisplayName = trim($input['author_display_name'] ?? $sub['author_display_name'] ?? $user['display_name']);

// Photo upload if provided
$imagePath = $sub['image'];
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
    $fileTmp = $_FILES['image']['tmp_name'];
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $fileTmp);
    finfo_close($finfo);

    $allowedMimes = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
    if (isset($allowedMimes[$mimeType])) {
        $ext = $allowedMimes[$mimeType];
        $uploadDir = __DIR__ . '/../../uploads/recipe-submissions/';
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);
        $newFilename = 'sub_' . time() . '_' . bin2hex(random_bytes(6)) . '.' . $ext;
        if (move_uploaded_file($fileTmp, $uploadDir . $newFilename)) {
            $imagePath = 'uploads/recipe-submissions/' . $newFilename;
        }
    }
} elseif (!empty($input['image_url'])) {
    $imagePath = trim($input['image_url']);
}

// Ingredients & Steps if provided
$ingredientsRaw = $input['ingredients'] ?? null;
if (is_string($ingredientsRaw)) $ingredientsRaw = json_decode($ingredientsRaw, true);

$stepsRaw = $input['steps'] ?? $input['instructions'] ?? null;
if (is_string($stepsRaw)) $stepsRaw = json_decode($stepsRaw, true);

$tagsRaw = $input['tags'] ?? $input['hashtags'] ?? null;
if (is_string($tagsRaw)) {
    $decoded = json_decode($tagsRaw, true);
    $tagsRaw = is_array($decoded) ? $decoded : array_filter(array_map('trim', explode(',', $tagsRaw)));
}

try {
    $pdo->beginTransaction();

    // 1. Update recipe_submissions (reset status to 'pending' if it was changes_requested)
    $upStmt = $pdo->prepare("
        UPDATE recipe_submissions SET
            recipe_name = ?,
            description = ?,
            category_id = ?,
            image = ?,
            preparation_time = ?,
            cooking_time = ?,
            difficulty = ?,
            servings = ?,
            cuisine = ?,
            food_type = ?,
            notes = ?,
            status = 'pending',
            allow_publication = ?,
            show_author_name = ?,
            author_display_name = ?,
            permission_given_at = IF(? = 1 AND permission_given_at IS NULL, NOW(), permission_given_at),
            submitted_at = NOW(),
            updated_at = NOW()
        WHERE id = ?
    ");
    $upStmt->execute([
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
        $allowPublication,
        $submissionId
    ]);

    // 2. Replace Ingredients if updated
    if (is_array($ingredientsRaw) && !empty($ingredientsRaw)) {
        $pdo->prepare("DELETE FROM recipe_submission_ingredients WHERE submission_id = ?")->execute([$submissionId]);
        $ingStmt = $pdo->prepare("INSERT INTO recipe_submission_ingredients (submission_id, ingredient, quantity, unit, position) VALUES (?, ?, ?, ?, ?)");
        $pos = 1;
        foreach ($ingredientsRaw as $ing) {
            $name = is_array($ing) ? trim($ing['name'] ?? $ing['ingredient'] ?? '') : trim($ing);
            $qty = is_array($ing) ? trim((string)($ing['quantity'] ?? $ing['amount'] ?? '1')) : '1';
            $unit = is_array($ing) ? trim($ing['unit'] ?? '') : '';
            if (!empty($name)) {
                $ingStmt->execute([$submissionId, $name, $qty, $unit, $pos++]);
            }
        }
    }

    // 3. Replace Steps if updated
    if (is_array($stepsRaw) && !empty($stepsRaw)) {
        $pdo->prepare("DELETE FROM recipe_submission_steps WHERE submission_id = ?")->execute([$submissionId]);
        $stepStmt = $pdo->prepare("INSERT INTO recipe_submission_steps (submission_id, step_number, instruction, timer_seconds) VALUES (?, ?, ?, ?)");
        $stepNum = 1;
        foreach ($stepsRaw as $st) {
            $instruction = is_array($st) ? trim($st['instruction'] ?? $st['step'] ?? '') : trim($st);
            $timer = is_array($st) ? max(0, (int)($st['timer_seconds'] ?? $st['timer'] ?? 0)) : 0;
            if (!empty($instruction)) {
                $stepStmt->execute([$submissionId, $stepNum++, $instruction, $timer]);
            }
        }
    }

    // 4. Replace Tags if updated
    if (is_array($tagsRaw)) {
        $pdo->prepare("DELETE FROM recipe_submission_tags WHERE submission_id = ?")->execute([$submissionId]);
        $normalizedTags = parse_and_normalize_tags($tagsRaw);
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
                } catch (Exception $tagEx) {}
            }
        }
    }

    $pdo->commit();

    json_response([
        'success' => true,
        'message' => 'Recipe submission updated and resubmitted for review successfully.',
        'data' => [
            'submission_id' => $submissionId,
            'status' => 'pending',
            'recipe_name' => $recipeName,
        ]
    ]);

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    json_response(['success' => false, 'message' => 'Failed to update submission: ' . $e->getMessage()], 500);
}
