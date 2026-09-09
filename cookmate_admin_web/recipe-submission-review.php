<?php
/**
 * Food CHART Web Admin - Recipe Submission Review & Approval Interface
 * Native Food CHART Design System (Zero external Bootstrap dependencies)
 */

require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/includes/tag_functions.php';
require_once __DIR__ . '/includes/notification_functions.php';

$pdo = get_db_connection();
$pageTitle = 'Review Recipe Submission';
$currentPage = 'recipe-submission-review.php';

$submissionId = (int)($_GET['id'] ?? $_POST['submission_id'] ?? 0);
if ($submissionId <= 0) {
    header("Location: " . BASE_URL . "/recipe-submissions.php");
    exit;
}

// Fetch submission details
$stmt = $pdo->prepare("
    SELECT 
        s.*,
        u.display_name AS user_display_name,
        u.email AS user_email,
        c.name AS category_name,
        c.color_hex AS category_color
    FROM recipe_submissions s
    LEFT JOIN users u ON s.user_id = u.id
    LEFT JOIN categories c ON s.category_id = c.id
    WHERE s.id = ?
");
$stmt->execute([$submissionId]);
$sub = $stmt->fetch();

if (!$sub) {
    set_flash_message('danger', "Recipe submission #$submissionId not found.");
    header("Location: " . BASE_URL . "/recipe-submissions.php");
    exit;
}

// Handle Admin Actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = trim($_POST['action'] ?? '');

    // -------------------------------------------------------------
    // ACTION 1: APPROVE & PUBLISH (Only if allow_publication == 1)
    // -------------------------------------------------------------
    if ($action === 'approve_and_publish') {
        if ((int)$sub['allow_publication'] !== 1) {
            set_flash_message('danger', 'Cannot publish: The user has NOT granted permission for public publication.');
            header("Location: " . BASE_URL . "/recipe-submission-review.php?id=" . $submissionId);
            exit;
        }

        try {
            $pdo->beginTransaction();

            // 1. Generate unique recipe ID
            $newRecipeId = 'recipe_c_' . $submissionId . '_' . substr(md5(uniqid('', true)), 0, 6);

            // Fetch ingredients for this submission
            $ingStmt = $pdo->prepare("SELECT * FROM recipe_submission_ingredients WHERE submission_id = ? ORDER BY position ASC");
            $ingStmt->execute([$submissionId]);
            $ingredients = $ingStmt->fetchAll();

            // Fetch steps for this submission
            $stepStmt = $pdo->prepare("SELECT * FROM recipe_submission_steps WHERE submission_id = ? ORDER BY step_number ASC");
            $stepStmt->execute([$submissionId]);
            $steps = $stepStmt->fetchAll();

            // Fetch tags
            $tagStmt = $pdo->prepare("
                SELECT t.id, t.name 
                FROM recipe_submission_tags st
                JOIN tags t ON st.tag_id = t.id
                WHERE st.submission_id = ?
            ");
            $tagStmt->execute([$submissionId]);
            $tags = $tagStmt->fetchAll();
            $tagNames = array_column($tags, 'name');
            $tagsString = implode(', ', $tagNames);

            // Determine author credit
            $chefName = $sub['show_author_name'] ? ($sub['author_display_name'] ?: $sub['user_display_name']) : 'Community Contributor';
            $authorDisplayName = $sub['show_author_name'] ? ($sub['author_display_name'] ?: $sub['user_display_name']) : 'Community Recipe';
            $isVeg = (strcasecmp($sub['food_type'], 'Vegetarian') === 0 || strcasecmp($sub['food_type'], 'Veg') === 0) ? 1 : 0;

            // 2. Insert into main recipes table (with dynamic column discovery and self-healing)
            if (function_exists('ensure_recipe_submissions_schema')) {
                ensure_recipe_submissions_schema($pdo);
            }

            $recCols = [];
            try {
                $recCols = $pdo->query("SHOW COLUMNS FROM recipes")->fetchAll(PDO::FETCH_COLUMN);
            } catch (Throwable $e) {}

            $recipePayload = [
                'id'                   => $newRecipeId,
                'title'                => $sub['recipe_name'],
                'description'          => $sub['description'] ?: 'A delicious recipe prepared with authentic techniques and fresh ingredients.',
                'chef_name'            => $chefName,
                'cuisine'              => $sub['cuisine'] ?: 'Homemade',
                'image_url'            => $sub['image'] ?: 'assets/images/recipes/samosa.jpg',
                'prep_time_minutes'    => (int)$sub['preparation_time'],
                'cook_time_minutes'    => (int)$sub['cooking_time'],
                'servings'             => (int)$sub['servings'],
                'difficulty'           => $sub['difficulty'] ?: 'Medium',
                'category_id'          => $sub['category_id'],
                'is_vegetarian'        => $isVeg,
                'rating'               => 4.8,
                'tags'                 => $tagsString,
                'source_type'          => 'user_submission',
                'submitted_by_user_id' => $sub['user_id'],
                'submission_id'        => $submissionId,
                'author_display_name'  => $authorDisplayName,
                'allow_publication'    => 1,
            ];

            $insertCols = [];
            $insertPlaceholders = [];
            $insertParams = [];

            foreach ($recipePayload as $field => $val) {
                if (empty($recCols) || in_array($field, $recCols)) {
                    $insertCols[] = "`$field`";
                    $insertPlaceholders[] = "?";
                    $insertParams[] = $val;
                }
            }

            if (empty($recCols) || in_array('created_at', $recCols)) {
                $insertCols[] = "`created_at`";
                $insertPlaceholders[] = "NOW()";
            }

            $sql = "INSERT INTO recipes (" . implode(', ', $insertCols) . ") VALUES (" . implode(', ', $insertPlaceholders) . ")";
            $insRecipe = $pdo->prepare($sql);
            $insRecipe->execute($insertParams);

            // 3. Copy Ingredients into recipe_ingredients
            $insIng = $pdo->prepare("
                INSERT INTO recipe_ingredients (id, recipe_id, name, amount, unit, sort_order)
                VALUES (?, ?, ?, ?, ?, ?)
            ");
            $ingPos = 1;
            foreach ($ingredients as $ing) {
                $ingId = 'ing_' . $newRecipeId . '_' . $ingPos;
                $amount = (string)$ing['quantity'];
                $insIng->execute([
                    $ingId,
                    $newRecipeId,
                    $ing['ingredient'],
                    $amount,
                    $ing['unit'] ?: 'item',
                    $ingPos++
                ]);
            }

            // 4. Copy Steps into recipe_instructions
            $insStep = $pdo->prepare("
                INSERT INTO recipe_instructions (id, recipe_id, step_number, instruction, timer_seconds)
                VALUES (?, ?, ?, ?, ?)
            ");
            $stepPos = 1;
            foreach ($steps as $st) {
                $stepId = 'inst_' . $newRecipeId . '_' . $stepPos;
                $insStep->execute([
                    $stepId,
                    $newRecipeId,
                    (int)$st['step_number'],
                    $st['instruction'],
                    (int)$st['timer_seconds']
                ]);
                $stepPos++;
            }

            // 5. Link Tags in recipe_tags and update usage counts
            if (!empty($tags)) {
                try {
                    $insRel = $pdo->prepare("INSERT IGNORE INTO recipe_tags (recipe_id, tag_id) VALUES (?, ?)");
                    foreach ($tags as $t) {
                        $insRel->execute([$newRecipeId, $t['id']]);
                    }
                    if (function_exists('recalculate_all_tag_usage_counts')) {
                        recalculate_all_tag_usage_counts($pdo);
                    }
                } catch (Throwable $tagErr) {}
            }

            // 6. Update submission record
            $upSub = $pdo->prepare("
                UPDATE recipe_submissions SET
                    status = 'published',
                    published_recipe_id = ?,
                    reviewed_at = NOW(),
                    reviewed_by = 1,
                    updated_at = NOW()
                WHERE id = ?
            ");
            $upSub->execute([$newRecipeId, $submissionId]);

            // 7. Send personal notification to recipe owner
            try {
                create_system_notification($pdo, [
                    'title'               => '🎉 Your Recipe Is Live!',
                    'message'             => 'Your recipe "' . $sub['recipe_name'] . '" has been approved and published on Food CHART. Tap to view your recipe.',
                    'type'                => 'recipe_approved',
                    'target_type'         => 'specific_user',
                    'target_user_id'      => $sub['user_id'],
                    'related_type'        => 'recipe',
                    'related_id'          => $newRecipeId,
                    'action_label'        => 'View Recipe',
                    'status'              => 'active',
                    'created_by_admin_id' => 1
                ]);

                // Send notification to all other Food CHART users (owner is excluded to prevent duplicate)
                if (!isset($_POST['notify_community']) || !empty($_POST['notify_community'])) {
                    create_system_notification($pdo, [
                        'title'               => '🍲 New Recipe Added',
                        'message'             => '"' . $sub['recipe_name'] . '" is now available on Food CHART. Tap to explore the recipe.',
                        'type'                => 'new_recipe',
                        'target_type'         => 'all_except_user',
                        'target_user_id'      => $sub['user_id'],
                        'related_type'        => 'recipe',
                        'related_id'          => $newRecipeId,
                        'action_label'        => 'Tap to Explore',
                        'status'              => 'active',
                        'created_by_admin_id' => 1
                    ]);
                }
            } catch (Throwable $notifErr) {}

            // 8. Log admin activity
            try {
                $log = $pdo->prepare("
                    INSERT INTO admin_activity_logs (admin_id, action, submission_id, details, created_at)
                    VALUES (1, 'approve_and_publish', ?, ?, NOW())
                ");
                $log->execute([
                    $submissionId,
                    "Published submission #$submissionId as recipe $newRecipeId ('{$sub['recipe_name']}')."
                ]);
            } catch (Throwable $logErr) {}

            $pdo->commit();

            set_flash_message('success', "🎉 Recipe <strong>" . htmlspecialchars($sub['recipe_name']) . "</strong> was successfully approved and published into Food CHART! (Recipe ID: $newRecipeId)");
            header("Location: " . BASE_URL . "/recipe-submission-review.php?id=" . $submissionId);
            exit;

        } catch (Exception $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            set_flash_message('danger', "Failed to publish recipe: " . $e->getMessage());
            header("Location: " . BASE_URL . "/recipe-submission-review.php?id=" . $submissionId);
            exit;
        }
    }

    // -------------------------------------------------------------
    // ACTION 2: APPROVE FOR INTERNAL RECORD (When permission == 0)
    // -------------------------------------------------------------
    if ($action === 'approve_internal') {
        try {
            $up = $pdo->prepare("
                UPDATE recipe_submissions SET 
                    status = 'approved',
                    reviewed_at = NOW(),
                    reviewed_by = 1,
                    updated_at = NOW()
                WHERE id = ?
            ");
            $up->execute([$submissionId]);

            create_system_notification($pdo, [
                'title'               => '✅ Recipe Approved',
                'message'             => 'Your recipe submission "' . $sub['recipe_name'] . '" was reviewed and approved internally.',
                'type'                => 'recipe_approved',
                'target_type'         => 'specific_user',
                'target_user_id'      => $sub['user_id'],
                'related_type'        => 'recipe_submission',
                'related_id'          => $submissionId,
                'status'              => 'active',
                'created_by_admin_id' => 1
            ]);

            set_flash_message('success', "Recipe #$submissionId approved internally.");
            header("Location: " . BASE_URL . "/recipe-submission-review.php?id=" . $submissionId);
            exit;
        } catch (Exception $e) {
            set_flash_message('danger', "Error: " . $e->getMessage());
        }
    }

    // -------------------------------------------------------------
    // ACTION 3: REQUEST CHANGES
    // -------------------------------------------------------------
    if ($action === 'request_changes') {
        $notes = trim($_POST['admin_notes'] ?? '');
        if (empty($notes)) {
            set_flash_message('danger', 'Please enter feedback instructions for the user.');
        } else {
            try {
                $up = $pdo->prepare("
                    UPDATE recipe_submissions SET 
                        status = 'changes_requested',
                        admin_notes = ?,
                        reviewed_at = NOW(),
                        reviewed_by = 1,
                        updated_at = NOW()
                    WHERE id = ?
                ");
                $up->execute([$notes, $submissionId]);

                create_system_notification($pdo, [
                    'title'               => '📝 Changes Requested',
                    'message'             => 'Food CHART Admin requested changes to your recipe "' . $sub['recipe_name'] . '". Tap to edit and resubmit: ' . $notes,
                    'type'                => 'changes_requested',
                    'target_type'         => 'specific_user',
                    'target_user_id'      => $sub['user_id'],
                    'related_type'        => 'recipe_submission',
                    'related_id'          => $submissionId,
                    'action_label'        => 'Edit & Resubmit',
                    'status'              => 'active',
                    'created_by_admin_id' => 1
                ]);

                set_flash_message('warning', "Changes requested. User has been notified with your message.");
                header("Location: " . BASE_URL . "/recipe-submission-review.php?id=" . $submissionId);
                exit;
            } catch (Exception $e) {
                set_flash_message('danger', "Error: " . $e->getMessage());
            }
        }
    }

    // -------------------------------------------------------------
    // ACTION 4: REJECT SUBMISSION
    // -------------------------------------------------------------
    if ($action === 'reject') {
        $preset = trim($_POST['rejection_preset'] ?? '');
        $custom = trim($_POST['rejection_notes'] ?? '');
        $reason = !empty($custom) ? ($preset . ($preset ? ': ' : '') . $custom) : $preset;

        if (empty($reason)) {
            set_flash_message('danger', 'Please provide a reason for rejecting the recipe submission.');
        } else {
            try {
                $up = $pdo->prepare("
                    UPDATE recipe_submissions SET 
                        status = 'rejected',
                        rejection_reason = ?,
                        reviewed_at = NOW(),
                        reviewed_by = 1,
                        updated_at = NOW()
                    WHERE id = ?
                ");
                $up->execute([$reason, $submissionId]);

                create_system_notification($pdo, [
                    'title'               => '❌ Recipe Not Approved',
                    'message'             => 'Your recipe "' . $sub['recipe_name'] . '" was not approved. Reason: ' . $reason,
                    'type'                => 'recipe_rejected',
                    'target_type'         => 'specific_user',
                    'target_user_id'      => $sub['user_id'],
                    'related_type'        => 'recipe_submission',
                    'related_id'          => $submissionId,
                    'action_label'        => 'View Reason',
                    'status'              => 'active',
                    'created_by_admin_id' => 1
                ]);

                set_flash_message('danger', "Recipe submission #$submissionId rejected.");
                header("Location: " . BASE_URL . "/recipe-submission-review.php?id=" . $submissionId);
                exit;
            } catch (Exception $e) {
                set_flash_message('danger', "Error: " . $e->getMessage());
            }
        }
    }
}

// Fetch ingredients
$ingStmt = $pdo->prepare("SELECT * FROM recipe_submission_ingredients WHERE submission_id = ? ORDER BY position ASC");
$ingStmt->execute([$submissionId]);
$ingredients = $ingStmt->fetchAll();

// Fetch steps
$stepStmt = $pdo->prepare("SELECT * FROM recipe_submission_steps WHERE submission_id = ? ORDER BY step_number ASC");
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

// Duplicate check
$dupStmt = $pdo->prepare("
    SELECT id, title, chef_name 
    FROM recipes 
    WHERE LOWER(TRIM(title)) = LOWER(TRIM(?))
    LIMIT 3
");
$dupStmt->execute([$sub['recipe_name']]);
$duplicates = $dupStmt->fetchAll();

require_once __DIR__ . '/includes/header.php';
?>

<!-- Header Bar -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
    <div>
        <a href="<?= BASE_URL ?>/recipe-submissions.php" style="color: var(--cm-text-muted); text-decoration: none; font-size: 13px; display: inline-flex; align-items: center; gap: 6px; margin-bottom: 8px;">
            <i class="fa-solid fa-arrow-left"></i> Back to Submissions List
        </a>
        <h1 style="font-size: 24px; font-weight: 800; color: var(--cm-text-primary); margin: 0; display: flex; align-items: center; gap: 12px;">
            <span>Review Submission #<?= $sub['id'] ?>: <?= htmlspecialchars($sub['recipe_name']) ?></span>
        </h1>
    </div>

    <!-- Quick Status Badge -->
    <div>
        <?php
        $statusBadge = match($sub['status']) {
            'pending' => ['bg' => 'rgba(255, 152, 0, 0.15)', 'color' => '#FFA726', 'icon' => 'fa-clock', 'text' => 'Pending Review'],
            'under_review' => ['bg' => 'rgba(33, 150, 243, 0.15)', 'color' => '#42A5F5', 'icon' => 'fa-spinner', 'text' => 'Under Review'],
            'changes_requested' => ['bg' => 'rgba(255, 112, 67, 0.15)', 'color' => '#FF7043', 'icon' => 'fa-rotate-left', 'text' => 'Changes Requested'],
            'approved' => ['bg' => 'rgba(76, 175, 80, 0.15)', 'color' => '#81C784', 'icon' => 'fa-check', 'text' => 'Approved (Internal)'],
            'published' => ['bg' => 'rgba(46, 125, 50, 0.25)', 'color' => '#4CAF50', 'icon' => 'fa-circle-check', 'text' => 'Published in Food CHART'],
            'rejected' => ['bg' => 'rgba(244, 67, 54, 0.15)', 'color' => '#EF5350', 'icon' => 'fa-ban', 'text' => 'Rejected'],
            default => ['bg' => '#222', 'color' => '#CCC', 'icon' => 'fa-question', 'text' => $sub['status']]
        };
        ?>
        <span class="badge" style="background: <?= $statusBadge['bg'] ?>; color: <?= $statusBadge['color'] ?>; border: 1px solid <?= $statusBadge['color'] ?>55; font-size: 14px; padding: 8px 16px; border-radius: 8px; display: inline-flex; align-items: center; gap: 8px;">
            <i class="fa-solid <?= $statusBadge['icon'] ?>"></i>
            <strong><?= $statusBadge['text'] ?></strong>
        </span>
    </div>
</div>

<!-- ==========================================================================
     PUBLICATION PERMISSION BANNER (CRITICAL REQUIREMENT)
     ========================================================================== -->
<?php if ($sub['allow_publication']): ?>
    <div style="background: rgba(76, 175, 80, 0.12); border: 1px solid rgba(76, 175, 80, 0.35); border-radius: 12px; padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;">
        <div style="display: flex; align-items: center; gap: 14px;">
            <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(76, 175, 80, 0.2); color: #81C784; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                <i class="fa-solid fa-shield-halved"></i>
            </div>
            <div>
                <strong style="color: #81C784; font-size: 15px; display: block;">Public Publication Permission Granted</strong>
                <span style="color: #DDD; font-size: 13px;">
                    User explicitly agreed to publish this recipe in the main Food CHART collection.
                    <?= $sub['permission_given_at'] ? '(Consent recorded at ' . date('M j, Y H:i', strtotime($sub['permission_given_at'])) . ')' : '' ?>
                </span>
            </div>
        </div>
        <div style="font-size: 13px; color: #BBB;">
            Attribution: <strong><?= $sub['show_author_name'] ? htmlspecialchars($sub['author_display_name'] ?: $sub['user_display_name']) : 'Community Recipe (Anonymous)' ?></strong>
        </div>
    </div>
<?php else: ?>
    <div style="background: rgba(255, 152, 0, 0.12); border: 1px solid rgba(255, 152, 0, 0.4); border-radius: 12px; padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;">
        <div style="display: flex; align-items: center; gap: 14px;">
            <div style="width: 40px; height: 40px; border-radius: 10px; background: rgba(255, 152, 0, 0.2); color: #FFA726; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                <i class="fa-solid fa-triangle-exclamation"></i>
            </div>
            <div>
                <strong style="color: #FFA726; font-size: 15px; display: block;">No Public Publication Permission</strong>
                <span style="color: #DDD; font-size: 13px;">
                    ⚠️ User has NOT granted permission for public publication. Adding to public Food CHART collection is strictly disabled.
                </span>
            </div>
        </div>
        <span class="badge" style="background: #333; color: #FFA726; border: 1px solid #FFA726; font-size: 12px; padding: 5px 12px;">
            Private Record Only
        </span>
    </div>
<?php endif; ?>

<!-- Duplicate Recipe Warning -->
<?php if (!empty($duplicates)): ?>
    <div style="background: rgba(239, 83, 80, 0.12); border: 1px solid rgba(239, 83, 80, 0.4); border-radius: 12px; padding: 16px 20px; margin-bottom: 24px;">
        <div style="display: flex; align-items: center; gap: 10px; color: #EF5350; font-weight: 700; margin-bottom: 6px;">
            <i class="fa-solid fa-triangle-exclamation"></i> Possible Duplicate Recipe in Food CHART
        </div>
        <p style="margin: 0 0 10px; font-size: 13px; color: #DDD;">
            A recipe with the same or very similar title already exists in the Food CHART collection:
        </p>
        <ul style="margin: 0; padding-left: 20px; font-size: 13px; color: #FFF;">
            <?php foreach ($duplicates as $dup): ?>
                <li>
                    <a href="<?= BASE_URL ?>/recipe-view.php?id=<?= urlencode($dup['id']) ?>" target="_blank" style="color: #FFB74D; font-weight: 700; text-decoration: underline;">
                        <?= htmlspecialchars($dup['title']) ?> (by <?= htmlspecialchars($dup['chef_name']) ?>)
                    </a>
                </li>
            <?php endforeach; ?>
        </ul>
    </div>
<?php endif; ?>

<!-- Previous Admin Feedback Display -->
<?php if (!empty($sub['admin_notes'])): ?>
    <div style="background: rgba(255, 112, 67, 0.1); border: 1px solid rgba(255, 112, 67, 0.3); border-radius: 12px; padding: 14px 18px; margin-bottom: 24px;">
        <strong style="color: #FF7043; font-size: 13px; display: block; margin-bottom: 4px;">
            <i class="fa-solid fa-comment-dots"></i> Admin Feedback Sent to User:
        </strong>
        <p style="margin: 0; font-size: 13.5px; color: #FFF;"><?= nl2br(htmlspecialchars($sub['admin_notes'])) ?></p>
    </div>
<?php endif; ?>

<?php if (!empty($sub['rejection_reason'])): ?>
    <div style="background: rgba(244, 67, 54, 0.1); border: 1px solid rgba(244, 67, 54, 0.3); border-radius: 12px; padding: 14px 18px; margin-bottom: 24px;">
        <strong style="color: #EF5350; font-size: 13px; display: block; margin-bottom: 4px;">
            <i class="fa-solid fa-ban"></i> Rejection Reason Recorded:
        </strong>
        <p style="margin: 0; font-size: 13.5px; color: #FFF;"><?= nl2br(htmlspecialchars($sub['rejection_reason'])) ?></p>
    </div>
<?php endif; ?>

<!-- Two-Column Review Layout -->
<div style="display: grid; grid-template-columns: 1fr 340px; gap: 24px; align-items: flex-start;">

    <!-- Left Column: Recipe Information -->
    <div style="display: flex; flex-direction: column; gap: 24px;">

        <!-- Card: Overview & Photo -->
        <div class="card" style="padding: 24px;">
            <div style="display: flex; gap: 24px; flex-wrap: wrap;">
                <?php
                $imgSrc = !empty($sub['image']) 
                    ? (str_starts_with($sub['image'], 'http') ? $sub['image'] : BASE_URL . '/' . ltrim($sub['image'], '/'))
                    : BASE_URL . '/assets/images/app_icon.png';
                ?>
                <img src="<?= htmlspecialchars($imgSrc) ?>" 
                     alt="Recipe Photo" 
                     style="width: 180px; height: 180px; border-radius: 14px; object-fit: cover; border: 1px solid var(--cm-border); background: #1C1C1C;"
                     onerror="this.src='<?= BASE_URL ?>/assets/images/app_icon.png'">

                <div style="flex: 1; min-width: 260px;">
                    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
                        <span class="badge" style="background: rgba(229, 9, 20, 0.2); color: #FF4D55; border: 1px solid rgba(229, 9, 20, 0.4); font-size: 12px;">
                            <?= htmlspecialchars($sub['category_name'] ?? 'General') ?>
                        </span>
                        <span class="badge" style="background: <?= (strcasecmp($sub['food_type'], 'Vegetarian') === 0 || strcasecmp($sub['food_type'], 'Veg') === 0) ? 'rgba(76, 175, 80, 0.2); color: #81C784;' : 'rgba(239, 83, 80, 0.2); color: #EF5350;' ?> font-size: 12px;">
                            <?= htmlspecialchars($sub['food_type']) ?>
                        </span>
                        <span class="badge" style="background: #262626; color: #CCC; font-size: 12px;">
                            <?= htmlspecialchars($sub['difficulty']) ?>
                        </span>
                    </div>

                    <h2 style="font-size: 22px; font-weight: 800; color: #FFF; margin: 0 0 10px; font-family: 'Outfit', sans-serif;">
                        <?= htmlspecialchars($sub['recipe_name']) ?>
                    </h2>

                    <p style="color: #BBB; font-size: 14px; line-height: 1.6; margin: 0 0 16px;">
                        <?= nl2br(htmlspecialchars($sub['description'] ?: 'No description provided.')) ?>
                    </p>

                    <div style="display: flex; gap: 20px; font-size: 13px; color: var(--cm-text-muted); border-top: 1px solid var(--cm-border); padding-top: 12px;">
                        <span><strong style="color: #FFF;">Prep:</strong> <?= (int)$sub['preparation_time'] ?> mins</span>
                        <span><strong style="color: #FFF;">Cook:</strong> <?= (int)$sub['cooking_time'] ?> mins</span>
                        <span><strong style="color: #FFF;">Serves:</strong> <?= (int)$sub['servings'] ?></span>
                        <span><strong style="color: #FFF;">Cuisine:</strong> <?= htmlspecialchars($sub['cuisine']) ?></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Card: Ingredients -->
        <div class="card" style="padding: 24px;">
            <div class="card-header" style="padding: 0 0 16px; margin-bottom: 16px; border-bottom: 1px solid var(--cm-border);">
                <h3 class="card-title" style="margin: 0; font-size: 17px;">
                    <i class="fa-solid fa-carrot" style="color: #FF9800; margin-right: 6px;"></i> Ingredients (<?= count($ingredients) ?>)
                </h3>
            </div>
            <?php if (empty($ingredients)): ?>
                <p style="color: var(--cm-text-muted); font-style: italic;">No ingredients submitted.</p>
            <?php else: ?>
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 10px;">
                    <?php foreach ($ingredients as $ing): ?>
                        <div style="background: #181818; border: 1px solid var(--cm-border); border-radius: 8px; padding: 10px 14px; display: flex; justify-content: space-between; align-items: center; font-size: 13.5px;">
                            <span style="color: #FFF; font-weight: 600;"><?= htmlspecialchars($ing['ingredient']) ?></span>
                            <span style="color: #FFB74D; font-weight: 700; font-size: 12.5px;">
                                <?= htmlspecialchars($ing['quantity']) ?> <?= htmlspecialchars($ing['unit']) ?>
                            </span>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>

        <!-- Card: Cooking Steps -->
        <div class="card" style="padding: 24px;">
            <div class="card-header" style="padding: 0 0 16px; margin-bottom: 16px; border-bottom: 1px solid var(--cm-border);">
                <h3 class="card-title" style="margin: 0; font-size: 17px;">
                    <i class="fa-solid fa-list-ol" style="color: var(--cm-primary); margin-right: 6px;"></i> Instructions / Steps (<?= count($steps) ?>)
                </h3>
            </div>
            <?php if (empty($steps)): ?>
                <p style="color: var(--cm-text-muted); font-style: italic;">No instruction steps submitted.</p>
            <?php else: ?>
                <div style="display: flex; flex-direction: column; gap: 14px;">
                    <?php foreach ($steps as $st): ?>
                        <div style="background: #181818; border: 1px solid var(--cm-border); border-radius: 10px; padding: 14px 18px; display: flex; gap: 14px;">
                            <div style="width: 28px; height: 28px; border-radius: 50%; background: var(--cm-primary); color: #FFF; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px; flex-shrink: 0;">
                                <?= (int)$st['step_number'] ?>
                            </div>
                            <div style="flex: 1;">
                                <p style="margin: 0; color: #EEE; font-size: 14px; line-height: 1.5;">
                                    <?= nl2br(htmlspecialchars($st['instruction'])) ?>
                                </p>
                                <?php if ($st['timer_seconds'] > 0): ?>
                                    <span style="display: inline-flex; align-items: center; gap: 4px; color: #4CAF50; font-size: 11.5px; font-weight: 700; margin-top: 8px;">
                                        <i class="fa-solid fa-stopwatch"></i> Timer: <?= round($st['timer_seconds'] / 60) ?> mins (<?= $st['timer_seconds'] ?>s)
                                    </span>
                                <?php endif; ?>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>

        <!-- Card: Hashtags -->
        <div class="card" style="padding: 24px;">
            <div class="card-header" style="padding: 0 0 16px; margin-bottom: 16px; border-bottom: 1px solid var(--cm-border);">
                <h3 class="card-title" style="margin: 0; font-size: 17px;">
                    <i class="fa-solid fa-hashtag" style="color: var(--cm-primary); margin-right: 6px;"></i> Hashtags (Discovery)
                </h3>
            </div>
            <?php if (empty($tags)): ?>
                <p style="color: var(--cm-text-muted); font-style: italic;">No hashtags submitted with this recipe.</p>
            <?php else: ?>
                <div style="display: flex; flex-wrap: wrap; gap: 8px;">
                    <?php foreach ($tags as $t): ?>
                        <span class="badge-tag">#<?= htmlspecialchars($t) ?></span>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>

        <!-- User Notes -->
        <?php if (!empty($sub['notes'])): ?>
            <div class="card" style="padding: 20px 24px;">
                <h4 style="margin: 0 0 8px; font-size: 14px; color: #FFF; display: flex; align-items: center; gap: 6px;">
                    <i class="fa-solid fa-note-sticky" style="color: #FFB74D;"></i> Contributor Notes
                </h4>
                <p style="margin: 0; color: #AAA; font-size: 13.5px; line-height: 1.5;">
                    <?= nl2br(htmlspecialchars($sub['notes'])) ?>
                </p>
            </div>
        <?php endif; ?>

    </div>

    <!-- Right Column: Moderation Actions & Audit -->
    <div style="display: flex; flex-direction: column; gap: 24px; position: sticky; top: 20px;">

        <!-- Action Box -->
        <div class="card" style="padding: 24px; border: 1px solid var(--cm-border);">
            <h3 style="font-size: 16px; font-weight: 800; color: #FFF; margin: 0 0 16px; border-bottom: 1px solid var(--cm-border); padding-bottom: 12px;">
                Moderator Decision
            </h3>

            <?php if ($sub['status'] === 'published'): ?>
                <div style="background: rgba(76, 175, 80, 0.15); border: 1px solid rgba(76, 175, 80, 0.4); border-radius: 10px; padding: 14px; margin-bottom: 16px; text-align: center;">
                    <i class="fa-solid fa-circle-check" style="font-size: 28px; color: #81C784; margin-bottom: 8px; display: block;"></i>
                    <strong style="color: #81C784; display: block; font-size: 15px;">Published in Food CHART</strong>
                    <span style="color: #BBB; font-size: 12.5px; display: block; margin: 4px 0 10px;">
                        Recipe ID: <code><?= htmlspecialchars($sub['published_recipe_id']) ?></code>
                    </span>
                    <a href="<?= BASE_URL ?>/recipe-view.php?id=<?= urlencode($sub['published_recipe_id']) ?>" class="btn btn-secondary btn-sm" style="width: 100%;">
                        <i class="fa-solid fa-eye"></i> View Live Recipe
                    </a>
                </div>
            <?php else: ?>

                <!-- Action 1: Approve & Publish -->
                <?php if ($sub['allow_publication']): ?>
                    <button type="button" class="btn btn-primary" onclick="openPublishModal()" style="width: 100%; padding: 12px; margin-bottom: 12px; font-size: 14.5px; font-weight: 700;">
                        <i class="fa-solid fa-circle-check"></i> Approve &amp; Publish
                    </button>
                <?php else: ?>
                    <button type="button" class="btn btn-secondary" style="width: 100%; padding: 12px; margin-bottom: 12px; opacity: 0.5; cursor: not-allowed;" title="User has not given permission to publish" disabled>
                        <i class="fa-solid fa-lock"></i> Publish Disabled (No Consent)
                    </button>
                    <form method="POST" action="<?= BASE_URL ?>/recipe-submission-review.php">
                        <input type="hidden" name="submission_id" value="<?= $sub['id'] ?>">
                        <input type="hidden" name="action" value="approve_internal">
                        <button type="submit" class="btn btn-secondary btn-sm" style="width: 100%; margin-bottom: 12px;">
                            <i class="fa-solid fa-check"></i> Approve (Private Record Only)
                        </button>
                    </form>
                <?php endif; ?>

                <!-- Action 2: Request Changes -->
                <button type="button" class="btn btn-secondary" style="width: 100%; padding: 10px; margin-bottom: 12px; color: #FFA726; border-color: rgba(255, 152, 0, 0.4);" onclick="openChangesModal()">
                    <i class="fa-solid fa-rotate-left"></i> Request Changes
                </button>

                <!-- Action 3: Reject -->
                <button type="button" class="btn btn-danger btn-sm" style="width: 100%; padding: 10px;" onclick="openRejectModal()">
                    <i class="fa-solid fa-ban"></i> Reject Submission
                </button>

            <?php endif; ?>
        </div>

        <!-- Contributor Details Box -->
        <div class="card" style="padding: 20px; font-size: 13px;">
            <h4 style="margin: 0 0 12px; color: #FFF; font-size: 14px; border-bottom: 1px solid var(--cm-border); padding-bottom: 8px;">
                Contributor Profile
            </h4>
            <div style="margin-bottom: 10px;">
                <span style="color: var(--cm-text-muted); display: block; font-size: 11.5px;">User Name:</span>
                <strong style="color: #FFF; font-size: 14px;"><?= htmlspecialchars($sub['user_display_name'] ?? 'Food CHART User') ?></strong>
            </div>
            <div style="margin-bottom: 10px;">
                <span style="color: var(--cm-text-muted); display: block; font-size: 11.5px;">Public Display Name:</span>
                <strong style="color: #FFB74D;"><?= htmlspecialchars($sub['author_display_name'] ?: 'Same as user') ?></strong>
            </div>
            <div style="margin-bottom: 10px;">
                <span style="color: var(--cm-text-muted); display: block; font-size: 11.5px;">Consent Granted:</span>
                <?= $sub['allow_publication'] ? '<span style="color:#4CAF50; font-weight:700;">YES</span>' : '<span style="color:#FF5252; font-weight:700;">NO</span>' ?>
            </div>
            <div style="margin-bottom: 10px;">
                <span style="color: var(--cm-text-muted); display: block; font-size: 11.5px;">Show Contributor Name:</span>
                <?= $sub['show_author_name'] ? '<span style="color:#4CAF50; font-weight:700;">YES</span>' : '<span style="color:#BBB;">NO (Anonymous)</span>' ?>
            </div>
            <div>
                <span style="color: var(--cm-text-muted); display: block; font-size: 11.5px;">Submitted On:</span>
                <span style="color: #FFF;"><?= date('M j, Y • H:i', strtotime($sub['submitted_at'])) ?></span>
            </div>
        </div>

    </div>

</div>

<!-- ==========================================================================
     Native Food CHART Modals (Zero Bootstrap dependency)
     ========================================================================== -->

<!-- Request Changes Modal -->
<div id="changesModal" class="cm-modal-overlay" onclick="handleOverlayClick(event, 'changesModal')">
    <div class="cm-modal">
        <form method="POST" action="<?= BASE_URL ?>/recipe-submission-review.php">
            <input type="hidden" name="submission_id" value="<?= $sub['id'] ?>">
            <input type="hidden" name="action" value="request_changes">
            <div class="cm-modal-header">
                <h3 class="cm-modal-title" style="color: #FFA726;">
                    <i class="fa-solid fa-rotate-left"></i>
                    <span>Request Changes</span>
                </h3>
                <button type="button" class="cm-modal-close" onclick="closeModal('changesModal')">&times;</button>
            </div>
            <div class="cm-modal-body">
                <p style="margin: 0 0 12px; font-size: 13.5px; color: #DDD;">
                    Send feedback to <strong><?= htmlspecialchars($sub['user_display_name'] ?? 'the user') ?></strong> explaining what modifications are needed before publication.
                </p>
                <label class="form-label" style="font-size: 12px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Message to User</label>
                <textarea name="admin_notes" class="form-control" rows="4" placeholder="e.g. Please provide clearer cooking steps for step 3 and check the chili powder quantity..." required></textarea>
            </div>
            <div class="cm-modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('changesModal')">Cancel</button>
                <button type="submit" class="btn btn-primary btn-sm" style="background: #FFA726; color: #000; font-weight: 800;">
                    Send Feedback &amp; Request Changes
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Reject Modal -->
<div id="rejectModal" class="cm-modal-overlay" onclick="handleOverlayClick(event, 'rejectModal')">
    <div class="cm-modal">
        <form method="POST" action="<?= BASE_URL ?>/recipe-submission-review.php">
            <input type="hidden" name="submission_id" value="<?= $sub['id'] ?>">
            <input type="hidden" name="action" value="reject">
            <div class="cm-modal-header">
                <h3 class="cm-modal-title" style="color: #EF5350;">
                    <i class="fa-solid fa-ban"></i>
                    <span>Reject Recipe Submission</span>
                </h3>
                <button type="button" class="cm-modal-close" onclick="closeModal('rejectModal')">&times;</button>
            </div>
            <div class="cm-modal-body">
                <label class="form-label" style="font-size: 12px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Primary Rejection Reason</label>
                <select name="rejection_preset" class="form-control" style="margin-bottom: 12px;">
                    <option value="Duplicate Recipe">Duplicate recipe already in Food CHART</option>
                    <option value="Incomplete Instructions">Incomplete or unclear cooking instructions</option>
                    <option value="Poor Image Quality">Low quality or inappropriate recipe image</option>
                    <option value="Incorrect Information">Inaccurate ingredients or preparation measurements</option>
                    <option value="Copyright Concern">Potential copyright violation / non-original content</option>
                    <option value="Inappropriate Content">Inappropriate content or spam</option>
                    <option value="Other">Other reason</option>
                </select>

                <label class="form-label" style="font-size: 12px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Detailed Explanation (Shown to User)</label>
                <textarea name="rejection_notes" class="form-control" rows="3" placeholder="Provide additional details on why this recipe was not approved..."></textarea>
            </div>
            <div class="cm-modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('rejectModal')">Cancel</button>
                <button type="submit" class="btn btn-danger btn-sm">Confirm Rejection</button>
            </div>
        </form>
    </div>
</div>

<!-- Approve & Publish Confirmation Modal -->
<div id="publishConfirmModal" class="cm-modal-overlay" onclick="handleOverlayClick(event, 'publishConfirmModal')">
    <div class="cm-modal" style="max-width: 520px;">
        <form method="POST" action="<?= BASE_URL ?>/recipe-submission-review.php">
            <input type="hidden" name="submission_id" value="<?= $sub['id'] ?>">
            <input type="hidden" name="action" value="approve_and_publish">
            <div class="cm-modal-header" style="border-bottom: 1px solid var(--cm-border);">
                <h3 class="cm-modal-title" style="color: #4CAF50; font-size: 17px; display: flex; align-items: center; gap: 8px;">
                    <i class="fa-solid fa-circle-check"></i>
                    <span>Publish Recipe?</span>
                </h3>
                <button type="button" class="cm-modal-close" onclick="closeModal('publishConfirmModal')">&times;</button>
            </div>
            <div class="cm-modal-body" style="padding: 20px;">
                <div style="background: rgba(255,255,255,0.04); border: 1px solid var(--cm-border); border-radius: 8px; padding: 14px; margin-bottom: 16px;">
                    <div style="margin-bottom: 8px;">
                        <span style="color: var(--cm-text-muted); font-size: 12px; display: block; text-transform: uppercase; font-weight: 700;">Recipe</span>
                        <strong style="color: #FFF; font-size: 15px;"><?= htmlspecialchars($sub['recipe_name']) ?></strong>
                    </div>
                    <div>
                        <span style="color: var(--cm-text-muted); font-size: 12px; display: block; text-transform: uppercase; font-weight: 700;">Submitted By</span>
                        <strong style="color: #FFB74D; font-size: 14px;"><?= htmlspecialchars($sub['user_display_name'] ?? 'Food CHART User') ?></strong>
                    </div>
                </div>

                <div style="font-size: 13px; color: #DDD; margin-bottom: 16px; line-height: 1.6;">
                    <div style="font-weight: 600; color: #FFF; margin-bottom: 6px;">After publication:</div>
                    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 5px;">
                        <i class="fa-solid fa-check" style="color: #4CAF50; font-size: 12px;"></i>
                        <span>Recipe will become available to all Food CHART users in the main catalog.</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 5px;">
                        <i class="fa-solid fa-bell" style="color: #64B5F6; font-size: 12px;"></i>
                        <span>The recipe owner will receive a personal publication notification.</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-users" style="color: #FFB74D; font-size: 12px;"></i>
                        <span>Other users will receive a new recipe announcement.</span>
                    </div>
                </div>

                <div style="background: rgba(76, 175, 80, 0.08); border: 1px solid rgba(76, 175, 80, 0.3); border-radius: 8px; padding: 12px;">
                    <label style="display: flex; align-items: center; gap: 10px; margin: 0; cursor: pointer; color: #FFF; font-size: 13.5px; font-weight: 600;">
                        <input type="checkbox" name="notify_community" value="1" checked style="width: 18px; height: 18px; accent-color: var(--cm-primary); cursor: pointer;">
                        <span>Notify Food CHART users about this new recipe</span>
                    </label>
                </div>
            </div>
            <div class="cm-modal-footer" style="border-top: 1px solid var(--cm-border); display: flex; justify-content: flex-end; gap: 10px; padding: 12px 20px;">
                <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('publishConfirmModal')">Cancel</button>
                <button type="submit" class="btn btn-primary btn-sm" style="background: #4CAF50; border-color: #4CAF50; color: #FFF; font-weight: 700; padding: 8px 18px;">
                    <i class="fa-solid fa-circle-check"></i> Approve &amp; Publish
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function openPublishModal() {
    document.getElementById('publishConfirmModal').classList.add('active');
}
function openChangesModal() {
    document.getElementById('changesModal').classList.add('active');
}
function openRejectModal() {
    document.getElementById('rejectModal').classList.add('active');
}
function closeModal(id) {
    document.getElementById(id).classList.remove('active');
}
function handleOverlayClick(e, id) {
    if (e.target.classList.contains('cm-modal-overlay')) {
        closeModal(id);
    }
}
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        document.querySelectorAll('.cm-modal-overlay.active').forEach(m => m.classList.remove('active'));
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
