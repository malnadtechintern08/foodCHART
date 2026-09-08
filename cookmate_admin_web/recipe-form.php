<?php
/**
 * Food CHART Web Admin - Comprehensive Recipe Editor (Create & Edit)
 */
require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/includes/recipe_share_helper.php';
$pdo = get_db_connection();
ensure_custom_share_text_column($pdo);

// Determine ID from GET or POST
$id = trim($_POST['id'] ?? $_GET['id'] ?? '');

// Check whether this recipe exists in database
$existsInDb = false;
if (!empty($id)) {
    $checkStmt = $pdo->prepare("SELECT COUNT(*) FROM recipes WHERE id = ?");
    $checkStmt->execute([$id]);
    $existsInDb = ((int)$checkStmt->fetchColumn() > 0);
}

$isEdit = $existsInDb || (!empty($_POST['is_edit']) && $_POST['is_edit'] === '1');
$pageTitle = $isEdit ? 'Edit Recipe' : 'Create New Recipe';

$returnUrl = trim($_GET['return_url'] ?? $_POST['return_url'] ?? '');
if (empty($returnUrl) && !empty($_SERVER['HTTP_REFERER'])) {
    $refHost = parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST);
    if (!$refHost || $refHost === ($_SERVER['HTTP_HOST'] ?? '')) {
        $returnUrl = $_SERVER['HTTP_REFERER'];
    }
}
$cancelUrl = !empty($returnUrl) ? $returnUrl : (BASE_URL . '/recipes.php');

$defaultCategoryId = !empty($_GET['category_id']) ? trim($_GET['category_id']) : 'cat_malnad';

$recipe = [
    'id' => !empty($id) ? $id : 'rec_' . bin2hex(random_bytes(4)),
    'title' => '',
    'description' => '',
    'chef_name' => 'Food CHART Chef',
    'cuisine' => 'Karnataka',
    'image_url' => 'assets/images/recipes/akki_rotti.jpg',
    'prep_time_minutes' => 15,
    'cook_time_minutes' => 20,
    'servings' => 4,
    'difficulty' => 'Medium',
    'category_id' => $defaultCategoryId,
    'tags' => 'Malnad Special, Karnataka, Heritage, South Indian',
    'is_favorite' => 0,
    'is_custom' => 1,
    'is_vegetarian' => 1,
    'rating' => 4.8,
    'region' => 'Malnad, Karnataka',
    'subcategory' => 'Breakfast',
    'nutrition' => '210 kcal | 8g Protein | 28g Carbs',
    'custom_share_text' => '',
];


$ingredients = [];
$instructions = [];

// If editing and not handling a POST, load existing data from DB
if ($isEdit && $_SERVER['REQUEST_METHOD'] !== 'POST') {
    $stmt = $pdo->prepare("SELECT * FROM recipes WHERE id = ?");
    $stmt->execute([$id]);
    $existing = $stmt->fetch();
    if (!$existing) {
        set_flash_message('danger', 'Recipe not found in database!');
        header('Location: ' . BASE_URL . '/recipes.php');
        exit;
    }
    $recipe = $existing;

    // Load ingredients
    $ingStmt = $pdo->prepare("SELECT * FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC, id ASC");
    $ingStmt->execute([$id]);
    $ingredients = $ingStmt->fetchAll();

    // Load instructions
    $insStmt = $pdo->prepare("SELECT * FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");
    $insStmt->execute([$id]);
    $instructions = $insStmt->fetchAll();
}

// If no ingredients, start with 2 empty rows
if (empty($ingredients)) {
    $ingredients = [
        ['name' => '', 'amount' => '', 'unit' => '', 'notes' => ''],
        ['name' => '', 'amount' => '', 'unit' => '', 'notes' => ''],
    ];
}

// If no instructions, start with 2 empty steps
if (empty($instructions)) {
    $instructions = [
        ['step_number' => 1, 'instruction' => '', 'timer_seconds' => 180, 'tip' => ''],
        ['step_number' => 2, 'instruction' => '', 'timer_seconds' => 300, 'tip' => ''],
    ];
}

// Handle Form Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Priority: $_POST['id'] first, then $_GET['id']
    $recipeId = trim($_POST['id'] ?? $_GET['id'] ?? '');

    // Check whether the record already exists in the database
    $existsStmt = $pdo->prepare("SELECT COUNT(*) FROM recipes WHERE id = ?");
    $existsStmt->execute([$recipeId]);
    $isUpdate = (!empty($recipeId) && (int)$existsStmt->fetchColumn() > 0);

    if (empty($recipeId)) {
        $recipeId = 'rec_' . bin2hex(random_bytes(4));
        $isUpdate = false;
    }

    $title = trim($_POST['title'] ?? 'Untitled Recipe');
    $description = trim($_POST['description'] ?? '');
    $chefName = trim($_POST['chef_name'] ?? 'Food CHART Chef');
    $cuisine = trim($_POST['cuisine'] ?? 'Indian');
    $region = trim($_POST['region'] ?? '');
    $subcategory = trim($_POST['subcategory'] ?? '');
    $categoryId = trim($_POST['category_id'] ?? 'cat_lunch_dinner');
    $prepTime = max(0, (int)($_POST['prep_time_minutes'] ?? 0));
    $cookTime = max(0, (int)($_POST['cook_time_minutes'] ?? 0));
    $servings = max(1, (int)($_POST['servings'] ?? 1));
    $difficulty = in_array($_POST['difficulty'] ?? '', ['Easy', 'Medium', 'Hard']) ? $_POST['difficulty'] : 'Medium';
    $rating = min(5.0, max(1.0, (float)($_POST['rating'] ?? 4.5)));
    $isVeg = isset($_POST['is_vegetarian']) ? 1 : 0;
    $isFav = isset($_POST['is_favorite']) ? 1 : 0;
    $isCustom = isset($_POST['is_custom']) ? 1 : ($isUpdate ? ($recipe['is_custom'] ?? 1) : 1);
    $tags = trim($_POST['tags'] ?? '');
    $nutrition = trim($_POST['nutrition'] ?? '');
    $imageUrl = trim($_POST['image_url'] ?? '');
    $customShareText = trim($_POST['custom_share_text'] ?? '');

    // Handle File Upload if present
    if (!empty($_FILES['image_file']['name']) && $_FILES['image_file']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = __DIR__ . '/uploads/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
        $fileExt = strtolower(pathinfo($_FILES['image_file']['name'], PATHINFO_EXTENSION));
        if (in_array($fileExt, ['jpg', 'jpeg', 'png', 'webp', 'gif'])) {
            $newFileName = 'recipe_' . time() . '_' . bin2hex(random_bytes(3)) . '.' . $fileExt;
            $destPath = $uploadDir . $newFileName;
            if (move_uploaded_file($_FILES['image_file']['tmp_name'], $destPath)) {
                $imageUrl = 'uploads/' . $newFileName;
            }
        }
    }

    try {
        $pdo->beginTransaction();

        if ($isUpdate) {
            // Update existing recipe in database
            $upSql = "
                UPDATE recipes SET
                    title = ?, description = ?, chef_name = ?, cuisine = ?, image_url = ?,
                    prep_time_minutes = ?, cook_time_minutes = ?, servings = ?, difficulty = ?,
                    category_id = ?, tags = ?, is_favorite = ?, is_custom = ?, is_vegetarian = ?,
                    rating = ?, region = ?, subcategory = ?, nutrition = ?, custom_share_text = ?
                WHERE id = ?
            ";
            $upStmt = $pdo->prepare($upSql);
            $upStmt->execute([
                $title, $description, $chefName, $cuisine, $imageUrl,
                $prepTime, $cookTime, $servings, $difficulty,
                $categoryId, $tags, $isFav, $isCustom, $isVeg,
                $rating, $region, $subcategory, $nutrition,
                $customShareText !== '' ? $customShareText : null,
                $recipeId
            ]);

            // Verify the update succeeded
            if ($upStmt->rowCount() === 0) {
                // If 0 affected rows, double-check that the recipe exists
                $verifyStmt = $pdo->prepare("SELECT COUNT(*) FROM recipes WHERE id = ?");
                $verifyStmt->execute([$recipeId]);
                if ((int)$verifyStmt->fetchColumn() === 0) {
                    throw new Exception("Recipe with ID '{$recipeId}' not found in database for update.");
                }
            }
        } else {
            // Insert new recipe into database
            $inSql = "
                INSERT INTO recipes (
                    id, title, description, chef_name, cuisine, image_url,
                    prep_time_minutes, cook_time_minutes, servings, difficulty,
                    category_id, tags, is_favorite, is_custom, is_vegetarian,
                    rating, region, subcategory, nutrition, custom_share_text
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ";
            $inStmt = $pdo->prepare($inSql);
            $inStmt->execute([
                $recipeId, $title, $description, $chefName, $cuisine, $imageUrl,
                $prepTime, $cookTime, $servings, $difficulty,
                $categoryId, $tags, $isFav, $isCustom, $isVeg,
                $rating, $region, $subcategory, $nutrition,
                $customShareText !== '' ? $customShareText : null
            ]);
            if ($inStmt->rowCount() === 0) {
                throw new Exception("Failed to insert recipe into database.");
            }
        }

        // Re-sync ingredients: Delete existing and re-insert
        $pdo->prepare("DELETE FROM recipe_ingredients WHERE recipe_id = ?")->execute([$recipeId]);
        $ingNames = $_POST['ing_name'] ?? [];
        $ingAmounts = $_POST['ing_amount'] ?? [];
        $ingUnits = $_POST['ing_unit'] ?? [];
        $ingNotes = $_POST['ing_notes'] ?? [];

        $ingInsert = $pdo->prepare("INSERT INTO recipe_ingredients (id, recipe_id, name, amount, unit, notes, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?)");
        for ($i = 0; $i < count($ingNames); $i++) {
            $name = trim($ingNames[$i] ?? '');
            if ($name !== '') {
                $ingId = $recipeId . '_ing_' . ($i + 1) . '_' . bin2hex(random_bytes(2));
                $amount = trim($ingAmounts[$i] ?? '');
                $unit = trim($ingUnits[$i] ?? '');
                $notes = trim($ingNotes[$i] ?? '');
                $ingInsert->execute([$ingId, $recipeId, $name, $amount, $unit, $notes, $i + 1]);
            }
        }

        // Re-sync instructions: Delete existing and re-insert
        $pdo->prepare("DELETE FROM recipe_instructions WHERE recipe_id = ?")->execute([$recipeId]);
        $stepTexts = $_POST['step_text'] ?? [];
        $stepTimers = $_POST['step_timer'] ?? [];
        $stepTips = $_POST['step_tip'] ?? [];

        $insInsert = $pdo->prepare("INSERT INTO recipe_instructions (id, recipe_id, step_number, instruction, timer_seconds, tip) VALUES (?, ?, ?, ?, ?, ?)");
        $stepNum = 1;
        for ($i = 0; $i < count($stepTexts); $i++) {
            $text = trim($stepTexts[$i] ?? '');
            if ($text !== '') {
                $insId = $recipeId . '_step_' . $stepNum . '_' . bin2hex(random_bytes(2));
                $timer = max(0, (int)($stepTimers[$i] ?? 0));
                $tip = trim($stepTips[$i] ?? '');
                $insInsert->execute([$insId, $recipeId, $stepNum, $text, $timer, $tip]);
                $stepNum++;
            }
        }

        // Synchronize relational tags and usage counts
        require_once __DIR__ . '/includes/tag_functions.php';
        sync_recipe_tags($pdo, $recipeId, $tags);

        $pdo->commit();

        // Broadcast notification if admin checked the notify users box
        if (!empty($_POST['notify_users'])) {
            require_once __DIR__ . '/includes/notification_functions.php';
            try {
                if ($isUpdate) {
                    create_system_notification($pdo, [
                        'title'               => '✨ Recipe Updated',
                        'message'             => 'New cooking instructions or details have been added to "' . $title . '".',
                        'type'                => 'recipe_updated',
                        'target_type'         => 'all',
                        'related_type'        => 'recipe',
                        'related_id'          => $recipeId,
                        'image'               => !empty($imageUrl) ? $imageUrl : null,
                        'status'              => 'active',
                        'created_by_admin_id' => 1
                    ]);
                } else {
                    create_system_notification($pdo, [
                        'title'               => 'New Recipe Added 🍲',
                        'message'             => '"' . $title . '" is now available on Food CHART. Tap to explore ingredients and steps!',
                        'type'                => 'new_recipe',
                        'target_type'         => 'all',
                        'related_type'        => 'recipe',
                        'related_id'          => $recipeId,
                        'image'               => !empty($imageUrl) ? $imageUrl : null,
                        'status'              => 'active',
                        'created_by_admin_id' => 1
                    ]);
                }
            } catch (Exception $ne) {
                // Non-critical, recipe is already saved
            }
        }

        set_flash_message('success', "Recipe \"$title\" saved successfully!" . (!empty($_POST['notify_users']) ? " Notification broadcast to users." : ""));
        $viewReturnParam = !empty($returnUrl) ? '&return_url=' . urlencode($returnUrl) : '';
        header('Location: ' . BASE_URL . '/recipe-view.php?id=' . urlencode($recipeId) . $viewReturnParam);
        exit;
    } catch (Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        $errorMsg = 'Error saving recipe: ' . $e->getMessage();
    }
}

// Fetch categories for select
$categories = $pdo->query("SELECT * FROM categories ORDER BY name ASC")->fetchAll();

require_once __DIR__ . '/includes/header.php';
?>

<?php if (!empty($errorMsg)): ?>
    <div class="alert alert-danger">
        <i class="fa-solid fa-triangle-exclamation"></i> <?= htmlspecialchars($errorMsg) ?>
    </div>
<?php endif; ?>

<form method="POST" action="<?= BASE_URL ?>/recipe-form.php<?= $isEdit ? '?id=' . urlencode($recipe['id']) : '' ?>" enctype="multipart/form-data" id="recipeForm">
    <input type="hidden" name="id" value="<?= htmlspecialchars($recipe['id']) ?>">
    <input type="hidden" name="is_edit" value="<?= $isEdit ? '1' : '0' ?>">
    <input type="hidden" name="return_url" value="<?= htmlspecialchars($returnUrl) ?>">

    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
            <h2 style="font-size: 24px; font-weight: 800;"><?= $isEdit ? 'Edit Recipe: ' . htmlspecialchars($recipe['title']) : 'Add New Recipe' ?></h2>
            <p style="color: var(--cm-text-secondary); font-size: 13px;">ID: <code><?= htmlspecialchars($recipe['id']) ?></code></p>
        </div>
        <div style="display: flex; gap: 10px;">
            <a href="<?= htmlspecialchars($cancelUrl) ?>" class="btn btn-secondary">Cancel</a>
            <button type="submit" class="btn btn-primary">
                <i class="fa-solid fa-floppy-disk"></i> Save Recipe
            </button>
        </div>
    </div>


    <!-- Section 1: Basic Information -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-circle-info" style="color: var(--cm-primary);"></i> Basic Information</h3>
        </div>

        <div class="form-group">
            <label class="form-label">Recipe Title *</label>
            <input type="text" name="title" class="form-control" value="<?= htmlspecialchars($recipe['title']) ?>" placeholder="e.g. Mysore Masala Dosa" required style="font-size: 16px; font-weight: 700;">
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Category *</label>
                <select name="category_id" class="form-control" required>
                    <?php foreach ($categories as $cat): ?>
                        <option value="<?= htmlspecialchars($cat['id']) ?>" <?= $recipe['category_id'] === $cat['id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($cat['name']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">Cuisine</label>
                <input type="text" name="cuisine" class="form-control" value="<?= htmlspecialchars($recipe['cuisine']) ?>" placeholder="e.g. Karnataka, South Indian, Mughlai">
            </div>

            <div class="form-group">
                <label class="form-label">Region</label>
                <input type="text" name="region" class="form-control" value="<?= htmlspecialchars($recipe['region']) ?>" placeholder="e.g. Malnad, Mysore, Coastal">
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Chef / Author Name</label>
                <input type="text" name="chef_name" class="form-control" value="<?= htmlspecialchars($recipe['chef_name']) ?>" placeholder="e.g. Malnad Aji or Chef Name">
            </div>

            <div class="form-group">
                <label class="form-label">Subcategory / Meal Time</label>
                <input type="text" name="subcategory" class="form-control" value="<?= htmlspecialchars($recipe['subcategory']) ?>" placeholder="e.g. Breakfast, Main Course, Snack">
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">Description</label>
            <textarea name="description" class="form-control" rows="3" placeholder="Describe the recipe history, taste, and serving suggestions..."><?= htmlspecialchars($recipe['description']) ?></textarea>
        </div>
    </div>

    <!-- Section 2: Dietary, Timings & Metrics -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-sliders" style="color: var(--cm-primary);"></i> Dietary, Timings & Attributes</h3>
        </div>

        <div class="form-row">
            <!-- Dietary Toggle -->
            <div class="form-group">
                <label class="form-label">Dietary Classification</label>
                <div class="switch-container" style="background: var(--cm-surface); padding: 12px 16px; border-radius: var(--cm-radius-sm); border: 1px solid var(--cm-border);">
                    <label class="switch">
                        <input type="checkbox" name="is_vegetarian" id="vegToggle" value="1" <?= $recipe['is_vegetarian'] ? 'checked' : '' ?> onchange="updateDietBadge()">
                        <span class="slider"></span>
                    </label>
                    <span id="dietLabel" class="badge <?= $recipe['is_vegetarian'] ? 'badge-veg' : 'badge-nonveg' ?>">
                        <?= $recipe['is_vegetarian'] ? 'Pure Vegetarian 🌱' : 'Non-Vegetarian 🍗' ?>
                    </span>
                </div>
            </div>

            <!-- Favorite Toggle -->
            <div class="form-group">
                <label class="form-label">Featured / Favorite</label>
                <div class="switch-container" style="background: var(--cm-surface); padding: 12px 16px; border-radius: var(--cm-radius-sm); border: 1px solid var(--cm-border);">
                    <label class="switch">
                        <input type="checkbox" name="is_favorite" value="1" <?= $recipe['is_favorite'] ? 'checked' : '' ?>>
                        <span class="slider" style="background-color: #333;"></span>
                    </label>
                    <span style="font-size: 13px; font-weight: 700; color: #EF5350;"><i class="fa-solid fa-heart"></i> Favorite Recipe</span>
                </div>
            </div>

            <!-- Rating -->
            <div class="form-group">
                <label class="form-label">Rating (1.0 to 5.0)</label>
                <input type="number" step="0.1" min="1.0" max="5.0" name="rating" class="form-control" value="<?= htmlspecialchars($recipe['rating']) ?>">
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Prep Time (Minutes)</label>
                <input type="number" min="0" name="prep_time_minutes" class="form-control" value="<?= htmlspecialchars($recipe['prep_time_minutes']) ?>">
            </div>

            <div class="form-group">
                <label class="form-label">Cook Time (Minutes)</label>
                <input type="number" min="0" name="cook_time_minutes" class="form-control" value="<?= htmlspecialchars($recipe['cook_time_minutes']) ?>">
            </div>

            <div class="form-group">
                <label class="form-label">Servings</label>
                <input type="number" min="1" name="servings" class="form-control" value="<?= htmlspecialchars($recipe['servings']) ?>">
            </div>

            <div class="form-group">
                <label class="form-label">Difficulty</label>
                <select name="difficulty" class="form-control">
                    <option value="Easy" <?= $recipe['difficulty'] === 'Easy' ? 'selected' : '' ?>>Easy</option>
                    <option value="Medium" <?= $recipe['difficulty'] === 'Medium' ? 'selected' : '' ?>>Medium</option>
                    <option value="Hard" <?= $recipe['difficulty'] === 'Hard' ? 'selected' : '' ?>>Hard</option>
                </select>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Nutritional Information</label>
                <input type="text" name="nutrition" class="form-control" value="<?= htmlspecialchars($recipe['nutrition']) ?>" placeholder="e.g. 190 kcal | 8g Protein | 30g Carbs">
            </div>

            <div class="form-group">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                    <label class="form-label" style="margin: 0; font-weight: 700;">
                        <i class="fa-solid fa-hashtag" style="color: var(--cm-primary); margin-right: 4px;"></i> Hashtags (Food Discovery)
                    </label>
                    <button type="button" class="btn btn-secondary btn-sm" onclick="autoSuggestHashtags()" style="font-size: 11px; padding: 4px 10px; border-color: rgba(255, 152, 0, 0.4); color: #FFB74D;">
                        <i class="fa-solid fa-wand-magic-sparkles"></i> ✨ Auto-Suggest Hashtags
                    </button>
                </div>
                
                <input type="hidden" name="tags" id="hiddenTagsInput" value="<?= htmlspecialchars($recipe['tags']) ?>">

                <!-- Rendered Chip Tags -->
                <div id="hashtagChipsContainer" class="hashtag-chips-container"></div>

                <!-- Add Tag Input with Live Autocomplete -->
                <div style="position: relative;">
                    <div class="hashtag-input-bar">
                        <span class="hashtag-prefix-pill">#</span>
                        <input type="text" id="hashtagInput" class="hashtag-native-input" placeholder="Type a hashtag (e.g. rice, spicy, malnad) and press Enter or comma..." autocomplete="off">
                        <button type="button" class="hashtag-add-btn" onclick="addHashtagFromInput()">
                            <i class="fa-solid fa-plus"></i> Add
                        </button>
                    </div>
                    <div id="hashtagAutocompleteDropdown" class="hashtag-autocomplete-dropdown" style="display: none;"></div>
                </div>

                <!-- Auto-suggestion preview bar -->
                <div id="autoSuggestBar" class="auto-suggest-box" style="display: none;">
                    <div style="font-size: 12px; color: #FFB74D; font-weight: 600; display: flex; align-items: center; flex-wrap: wrap; gap: 6px;">
                        <span><i class="fa-solid fa-lightbulb"></i> Suggested for this recipe:</span>
                        <span id="suggestedChipsList"></span>
                    </div>
                    <button type="button" class="btn btn-primary btn-sm" style="font-size: 11px; padding: 3px 10px;" onclick="addAllSuggestedHashtags()">
                        Add All
                    </button>
                </div>

                <!-- Quick Popular Hashtag Shortcuts -->
                <div style="margin-top: 10px; display: flex; align-items: center; gap: 6px; flex-wrap: wrap; font-size: 11px; color: var(--cm-text-muted);">
                    <span style="font-weight: 700; color: var(--cm-primary);"><i class="fa-solid fa-fire"></i> Popular:</span>
                    <?php
                    $quickPopular = $pdo->query("SELECT name FROM tags WHERE usage_count > 0 ORDER BY usage_count DESC LIMIT 8")->fetchAll(PDO::FETCH_COLUMN);
                    foreach ($quickPopular as $qp):
                    ?>
                        <a href="javascript:void(0)" class="quick-tag-pill" onclick="addHashtag('<?= htmlspecialchars($qp, ENT_QUOTES) ?>')">+ #<?= htmlspecialchars($qp) ?></a>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
    </div>

    <!-- Section 3: Recipe Image -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-image" style="color: var(--cm-primary);"></i> Recipe Photo</h3>
        </div>

        <div style="display: flex; gap: 24px; align-items: flex-start;">
            <div style="flex: 1;">
                <div class="form-group">
                    <label class="form-label">Image URL / Asset Path</label>
                    <input type="text" name="image_url" id="imageUrlInput" class="form-control" value="<?= htmlspecialchars($recipe['image_url']) ?>" placeholder="assets/images/recipes/akki_rotti.jpg" oninput="updateImagePreview()">
                    <small style="color: var(--cm-text-muted); display: block; margin-top: 6px;">
                        Path inside the app (e.g. <code>assets/images/recipes/your_image.jpg</code>) or a full web URL.
                    </small>
                </div>

                <div class="form-group">
                    <label class="form-label">Or Upload New Photo from Computer</label>
                    <input type="file" name="image_file" id="imageFileInput" class="form-control" accept="image/*" onchange="previewUpload(this)">
                </div>
            </div>

            <!-- Preview Card -->
            <div style="width: 180px; text-align: center;">
                <label class="form-label">Live Preview</label>
                <?php
                    $previewSrc = !empty($recipe['image_url']) ? BASE_URL . '/' . ltrim($recipe['image_url'], '/') : BASE_URL . '/assets/images/app_icon.png';
                ?>
                <img id="imagePreview" src="<?= htmlspecialchars($previewSrc) ?>" 
                     onerror="this.onerror=null;this.src='<?= BASE_URL ?>/assets/images/app_icon.png';" 
                     style="width: 160px; height: 160px; object-fit: cover; border-radius: 14px; border: 2px solid var(--cm-border); background: var(--cm-surface);" alt="Recipe Preview">
            </div>
        </div>
    </div>

    <!-- Section 4: Ingredients List -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-carrot" style="color: var(--cm-primary);"></i> Ingredients</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="addIngredientRow()">
                <i class="fa-solid fa-plus"></i> Add Ingredient
            </button>
        </div>

        <div id="ingredientsContainer">
            <?php foreach ($ingredients as $idx => $ing): ?>
                <div class="dynamic-row">
                    <div style="flex: 2;">
                        <input type="text" name="ing_name[]" class="form-control" value="<?= htmlspecialchars($ing['name']) ?>" placeholder="Ingredient name (e.g. Rice flour)" required>
                    </div>
                    <div style="width: 110px;">
                        <input type="text" name="ing_amount[]" class="form-control" value="<?= htmlspecialchars($ing['amount']) ?>" placeholder="Qty (e.g. 2)">
                    </div>
                    <div style="width: 130px;">
                        <input type="text" name="ing_unit[]" class="form-control" value="<?= htmlspecialchars($ing['unit']) ?>" placeholder="Unit (cups, tsp)">
                    </div>
                    <div style="flex: 2;">
                        <input type="text" name="ing_notes[]" class="form-control" value="<?= htmlspecialchars($ing['notes'] ?? '') ?>" placeholder="Notes (optional, finely chopped)">
                    </div>
                    <button type="button" class="remove-row-btn" onclick="this.closest('.dynamic-row').remove()" title="Remove ingredient">
                        <i class="fa-solid fa-trash"></i>
                    </button>
                </div>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- Section 5: Cooking Steps / Instructions -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-list-ol" style="color: var(--cm-primary);"></i> Step-by-Step Instructions</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="addStepRow()">
                <i class="fa-solid fa-plus"></i> Add Step
            </button>
        </div>

        <div id="stepsContainer">
            <?php foreach ($instructions as $idx => $ins): ?>
                <div class="dynamic-row" style="align-items: flex-start; flex-direction: column;">
                    <div style="display: flex; width: 100%; gap: 12px; align-items: center; margin-bottom: 8px;">
                        <span class="step-badge" style="background: var(--cm-primary); color: #fff; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px;">
                            <?= $idx + 1 ?>
                        </span>
                        <div style="flex: 1;">
                            <textarea name="step_text[]" class="form-control" rows="2" placeholder="Step description..." required><?= htmlspecialchars($ins['instruction']) ?></textarea>
                        </div>
                        <button type="button" class="remove-row-btn" onclick="this.closest('.dynamic-row').remove(); renumberSteps();" title="Remove step">
                            <i class="fa-solid fa-trash"></i>
                        </button>
                    </div>
                    <div style="display: flex; width: 100%; gap: 12px; padding-left: 40px;">
                        <div style="width: 170px;">
                            <label style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; display: block; margin-bottom: 4px;">Timer (Seconds)</label>
                            <input type="number" min="0" step="10" name="step_timer[]" class="form-control" value="<?= htmlspecialchars($ins['timer_seconds']) ?>" placeholder="e.g. 180">
                        </div>
                        <div style="flex: 1;">
                            <label style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; display: block; margin-bottom: 4px;">Chef Tip (Optional)</label>
                            <input type="text" name="step_tip[]" class="form-control" value="<?= htmlspecialchars($ins['tip'] ?? '') ?>" placeholder="e.g. Keep flame on medium-low">
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- Section 6: WhatsApp Promotional Share Teaser Customizer -->
    <div class="card" style="border: 1px solid rgba(37, 211, 102, 0.35); background: rgba(37, 211, 102, 0.03); margin-bottom: 24px;">
        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
            <h3 class="card-title" style="display: flex; align-items: center; gap: 8px;">
                <i class="fa-brands fa-whatsapp" style="color: #25D366; font-size: 20px;"></i> WhatsApp Share & Teaser Customizer
            </h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="autoGenerateFormWaTeaser()" style="font-weight: 700; color: #25D366; border-color: rgba(37, 211, 102, 0.4); border-radius: 8px;">
                <i class="fa-solid fa-wand-magic-sparkles"></i> Auto-Generate from Current Form
            </button>
        </div>

        <p style="font-size: 13px; color: var(--cm-text-secondary); margin-bottom: 12px; line-height: 1.5;">
            Customize the promotional message sent when this recipe is shared to WhatsApp. Leave blank to automatically use the standard locked teaser with key ingredients preview, locked steps, and the Food CHART Play Store download CTA.
        </p>

        <div class="form-group" style="margin-bottom: 0;">
            <textarea name="custom_share_text" id="customShareTextInput" class="form-control" rows="8"
                style="font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size: 13px; line-height: 1.5; background: #0c0c0c; color: #e9edef; border: 1px solid #2e2e2e; border-radius: 10px; padding: 12px;"
                placeholder="Leave blank for standard auto-generated teaser, or customize message here..."><?= htmlspecialchars($recipe['custom_share_text'] ?? '') ?></textarea>
        </div>

        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 8px; font-size: 11px; color: var(--cm-text-muted);">
            <span>Format: Recipe name, category, prep, servings, locked preview, and Food CHART app download link.</span>
            <button type="button" class="btn btn-secondary btn-sm" onclick="copyFormWaText()" style="padding: 2px 10px; font-size: 11px;">
                <i class="fa-regular fa-copy"></i> Copy Text
            </button>
        </div>
    </div>

    <!-- Notification Section -->
    <div class="card" style="border: 1px solid rgba(229, 9, 21, 0.35); background: rgba(229, 9, 21, 0.04); margin-bottom: 24px;">
        <div style="display: flex; align-items: center; gap: 12px;">
            <input type="checkbox" name="notify_users" id="notify_users" value="1" <?= !$isEdit ? 'checked' : '' ?> style="width: 20px; height: 20px; accent-color: var(--cm-primary); cursor: pointer;">
            <label for="notify_users" style="cursor: pointer; font-size: 15px; font-weight: 700; color: #FFF; margin: 0;">
                <?= $isEdit ? '✨ Notify Food CHART users about this recipe update' : '🍲 Notify Food CHART users about this new recipe' ?>
            </label>
        </div>
        <p style="margin: 6px 0 0 32px; font-size: 13px; color: var(--cm-text-secondary); line-height: 1.4;">
            <?= $isEdit ? 'Sends a notification to all users that this recipe has new instructions, ingredients, or cooking tips.' : 'Broadcasts an automatic arrival notification to the in-app notification center for all Food CHART users.' ?>
        </p>
    </div>

    <!-- Bottom Save Action Bar -->
    <div style="display: flex; justify-content: flex-end; gap: 12px; margin-bottom: 40px;">
        <a href="<?= htmlspecialchars($cancelUrl) ?>" class="btn btn-secondary">Cancel</a>
        <button type="submit" class="btn btn-primary" style="padding: 14px 36px; font-size: 16px;">
            <i class="fa-solid fa-check"></i> Save Recipe
        </button>
    </div>

</form>

<script>
function updateDietBadge() {
    const isVeg = document.getElementById('vegToggle').checked;
    const badge = document.getElementById('dietLabel');
    if (isVeg) {
        badge.className = 'badge badge-veg';
        badge.innerHTML = 'Pure Vegetarian 🌱';
    } else {
        badge.className = 'badge badge-nonveg';
        badge.innerHTML = 'Non-Vegetarian 🍗';
    }
}

function updateImagePreview() {
    const val = document.getElementById('imageUrlInput').value.trim();
    const preview = document.getElementById('imagePreview');
    if (val.startsWith('http://') || val.startsWith('https://')) {
        preview.src = val;
    } else if (val !== '') {
        preview.src = '<?= BASE_URL ?>/' + val.replace(/^\/+/, '');
    } else {
        preview.src = '<?= BASE_URL ?>/assets/images/app_icon.png';
    }
}

function previewUpload(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('imagePreview').src = e.target.result;
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function addIngredientRow() {
    const container = document.getElementById('ingredientsContainer');
    const div = document.createElement('div');
    div.className = 'dynamic-row';
    div.innerHTML = `
        <div style="flex: 2;">
            <input type="text" name="ing_name[]" class="form-control" placeholder="Ingredient name (e.g. Mustard seeds)" required>
        </div>
        <div style="width: 110px;">
            <input type="text" name="ing_amount[]" class="form-control" placeholder="Qty">
        </div>
        <div style="width: 130px;">
            <input type="text" name="ing_unit[]" class="form-control" placeholder="Unit">
        </div>
        <div style="flex: 2;">
            <input type="text" name="ing_notes[]" class="form-control" placeholder="Notes (optional)">
        </div>
        <button type="button" class="remove-row-btn" onclick="this.closest('.dynamic-row').remove()" title="Remove ingredient">
            <i class="fa-solid fa-trash"></i>
        </button>
    `;
    container.appendChild(div);
}

function addStepRow() {
    const container = document.getElementById('stepsContainer');
    const stepCount = container.querySelectorAll('.dynamic-row').length + 1;
    const div = document.createElement('div');
    div.className = 'dynamic-row';
    div.style.alignItems = 'flex-start';
    div.style.flexDirection = 'column';
    div.innerHTML = `
        <div style="display: flex; width: 100%; gap: 12px; align-items: center; margin-bottom: 8px;">
            <span class="step-badge" style="background: var(--cm-primary); color: #fff; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px;">
                ${stepCount}
            </span>
            <div style="flex: 1;">
                <textarea name="step_text[]" class="form-control" rows="2" placeholder="Step description..." required></textarea>
            </div>
            <button type="button" class="remove-row-btn" onclick="this.closest('.dynamic-row').remove(); renumberSteps();" title="Remove step">
                <i class="fa-solid fa-trash"></i>
            </button>
        </div>
        <div style="display: flex; width: 100%; gap: 12px; padding-left: 40px;">
            <div style="width: 170px;">
                <label style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; display: block; margin-bottom: 4px;">Timer (Seconds)</label>
                <input type="number" min="0" step="10" name="step_timer[]" class="form-control" value="180" placeholder="e.g. 180">
            </div>
            <div style="flex: 1;">
                <label style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; display: block; margin-bottom: 4px;">Chef Tip (Optional)</label>
                <input type="text" name="step_tip[]" class="form-control" placeholder="e.g. Cook until golden brown">
            </div>
        </div>
    `;
    container.appendChild(div);
}

function renumberSteps() {
    const badges = document.querySelectorAll('#stepsContainer .step-badge');
    badges.forEach((b, i) => {
        b.textContent = (i + 1);
    });
}

/* ==========================================================================
   Hashtags Management & Autocomplete
   ========================================================================== */
let currentHashtags = [];
let pendingSuggestions = [];

function normalizeHashtag(raw) {
    if (!raw) return '';
    return raw.toString()
        .toLowerCase()
        .replace(/^#+/, '')
        .replace(/#+$/, '')
        .trim()
        .replace(/[\s\-]+/g, '_')
        .replace(/[^a-z0-9_]/g, '')
        .replace(/_+/g, '_')
        .replace(/^_+|_+$/g, '');
}

function initHashtags() {
    const hiddenVal = document.getElementById('hiddenTagsInput').value;
    if (hiddenVal) {
        hiddenVal.split(',').forEach(t => {
            const norm = normalizeHashtag(t);
            if (norm && !currentHashtags.includes(norm)) {
                currentHashtags.push(norm);
            }
        });
    }
    renderHashtagChips();
}

function syncHiddenInput() {
    document.getElementById('hiddenTagsInput').value = currentHashtags.join(', ');
}

function renderHashtagChips() {
    const container = document.getElementById('hashtagChipsContainer');
    if (!container) return;

    if (currentHashtags.length === 0) {
        container.innerHTML = '<span class="text-muted small italic">No hashtags added yet. Type below or click auto-suggest.</span>';
        syncHiddenInput();
        return;
    }

    container.innerHTML = currentHashtags.map(tag => `
        <span class="hashtag-chip" data-tag="${tag}">
            <span>#${tag}</span>
            <button type="button" class="chip-remove-btn" onclick="removeHashtag('${tag}')" title="Remove #${tag}">&times;</button>
        </span>
    `).join('');

    syncHiddenInput();
}

function addHashtag(raw) {
    const norm = normalizeHashtag(raw);
    if (!norm) return false;

    if (currentHashtags.includes(norm)) {
        // Flash existing chip
        const chip = document.querySelector(`.hashtag-chip[data-tag="${norm}"]`);
        if (chip) {
            chip.style.transform = 'scale(1.15)';
            chip.style.borderColor = '#FFFFFF';
            setTimeout(() => {
                chip.style.transform = 'none';
                chip.style.borderColor = '';
            }, 250);
        }
        return false;
    }

    currentHashtags.push(norm);
    renderHashtagChips();
    return true;
}

function removeHashtag(tag) {
    currentHashtags = currentHashtags.filter(t => t !== tag);
    renderHashtagChips();
}

function addHashtagFromInput() {
    const input = document.getElementById('hashtagInput');
    const val = input.value.trim();
    if (!val) return;

    // Handle comma or space separated entry
    val.split(/[,]+/).forEach(part => {
        addHashtag(part);
    });

    input.value = '';
    closeAutocomplete();
}

// Live Autocomplete
const hashtagInput = document.getElementById('hashtagInput');
const dropdown = document.getElementById('hashtagAutocompleteDropdown');
let autocompleteTimer = null;

if (hashtagInput) {
    hashtagInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter' || e.key === ',') {
            e.preventDefault();
            addHashtagFromInput();
        } else if (e.key === 'Escape') {
            closeAutocomplete();
        }
    });

    hashtagInput.addEventListener('input', function() {
        const val = normalizeHashtag(this.value);
        clearTimeout(autocompleteTimer);
        if (!val || val.length < 1) {
            closeAutocomplete();
            return;
        }

        autocompleteTimer = setTimeout(() => {
            fetch('<?= BASE_URL ?>/api/tags/search.php?q=' + encodeURIComponent(val) + '&limit=8')
                .then(r => r.json())
                .then(res => {
                    if (res && res.status === 'success' && res.data && res.data.length > 0) {
                        dropdown.innerHTML = res.data.map(item => `
                            <div class="hashtag-autocomplete-item" onclick="selectAutocompleteTag('${item.name}')">
                                <span style="font-weight:700; color:var(--cm-primary);">#${item.name}</span>
                                <span class="item-count">${item.usage_count} recipes</span>
                            </div>
                        `).join('');
                        dropdown.style.display = 'block';
                    } else {
                        dropdown.innerHTML = `
                            <div class="hashtag-autocomplete-item" onclick="selectAutocompleteTag('${val}')">
                                <span>Create new: <strong class="text-danger">#${val}</strong></span>
                                <span class="item-count"><i class="fa-solid fa-plus"></i></span>
                            </div>
                        `;
                        dropdown.style.display = 'block';
                    }
                })
                .catch(() => closeAutocomplete());
        }, 180);
    });
}

function selectAutocompleteTag(tagName) {
    addHashtag(tagName);
    if (hashtagInput) hashtagInput.value = '';
    closeAutocomplete();
}

function closeAutocomplete() {
    if (dropdown) dropdown.style.display = 'none';
}

document.addEventListener('click', function(e) {
    if (dropdown && !dropdown.contains(e.target) && e.target !== hashtagInput) {
        closeAutocomplete();
    }
});

// Auto-Suggest Hashtags based on Title, Category, and Ingredients
function autoSuggestHashtags() {
    const title = (document.querySelector('input[name="title"]')?.value || '').toLowerCase();
    const categorySelect = document.querySelector('select[name="category_id"]');
    const categoryText = (categorySelect?.options[categorySelect.selectedIndex]?.text || '').toLowerCase();
    
    const ingredients = [];
    document.querySelectorAll('input[name="ingredient_name[]"]').forEach(inp => {
        if (inp.value.trim()) ingredients.push(inp.value.trim().toLowerCase());
    });

    const suggestions = [];

    // Keyword detection
    const foodKeywords = {
        'rice': ['rice', 'biryani', 'pulao', 'bath', 'puliyogare', 'chitranna', 'curd_rice', 'jeera'],
        'chicken': ['chicken', 'koli', 'murgh'],
        'biryani': ['biryani'],
        'breakfast': ['dosa', 'idli', 'upma', 'poha', 'puri', 'paratha', 'vada', 'appam', 'breakfast'],
        'malnad': ['malnad', 'akki', 'kadabu', 'havyaka', 'saaru', 'patrode', 'halasina'],
        'spicy': ['spicy', 'masala', 'pepper', 'mirchi', 'chilli', 'sukka', 'roast'],
        'healthy': ['salad', 'soup', 'ragi', 'millet', 'diet', 'sprouts', 'healthy'],
        'snacks': ['snack', 'bonda', 'bajji', 'samosa', 'pakoda', 'crispy'],
        'paneer': ['paneer'],
        'south_indian': ['south indian', 'karnataka', 'dosa', 'idli', 'sambar', 'rasam'],
        'curry': ['curry', 'gravy', 'kurma', 'sambar', 'saaru', 'dal']
    };

    const combinedText = title + ' ' + categoryText + ' ' + ingredients.join(' ');

    for (const [tag, triggers] of Object.entries(foodKeywords)) {
        for (const trig of triggers) {
            if (combinedText.includes(trig)) {
                if (!currentHashtags.includes(tag) && !suggestions.includes(tag)) {
                    suggestions.push(tag);
                }
                break;
            }
        }
    }

    const isVeg = document.querySelector('input[name="is_vegetarian"]')?.checked;
    if (isVeg !== undefined) {
        const dietTag = isVeg ? 'veg' : 'nonveg';
        if (!currentHashtags.includes(dietTag) && !suggestions.includes(dietTag)) {
            suggestions.push(dietTag);
        }
    }

    pendingSuggestions = suggestions;
    const bar = document.getElementById('autoSuggestBar');
    const list = document.getElementById('suggestedChipsList');

    if (suggestions.length === 0) {
        list.innerHTML = '<em>No new keywords detected. Type tags manually!</em>';
        bar.style.display = 'block';
        return;
    }

    list.innerHTML = suggestions.map(s => `
        <button type="button" class="btn btn-outline-warning btn-sm py-0 px-2 me-1 mb-1" style="font-size:11px;" onclick="addSuggestedHashtag('${s}', this)">
            + #${s}
        </button>
    `).join('');
    bar.style.display = 'block';
}

function addSuggestedHashtag(tag, btn) {
    addHashtag(tag);
    if (btn) btn.remove();
}

function addAllSuggestedHashtags() {
    pendingSuggestions.forEach(s => addHashtag(s));
    document.getElementById('autoSuggestBar').style.display = 'none';
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', initHashtags);

function autoGenerateFormWaTeaser() {
    const title = document.querySelector('input[name="title"]')?.value.trim() || 'Delicious Recipe';
    const desc = document.querySelector('textarea[name="description"]')?.value.trim() || '';
    const catSelect = document.querySelector('select[name="category_id"]');
    const catName = (catSelect && catSelect.selectedIndex >= 0) ? catSelect.options[catSelect.selectedIndex].text.trim() : 'Malnad Special';
    const isVeg = document.getElementById('vegToggle')?.checked;
    const prep = document.querySelector('input[name="prep_time_minutes"]')?.value || '15';
    const cook = document.querySelector('input[name="cook_time_minutes"]')?.value || '20';
    const servings = document.querySelector('input[name="servings"]')?.value || '4';
    const rating = document.querySelector('input[name="rating"]')?.value || '4.8';

    const ingInputs = document.querySelectorAll('input[name="ing_name[]"]');
    const amtInputs = document.querySelectorAll('input[name="ing_amount[]"]');
    const unitInputs = document.querySelectorAll('input[name="ing_unit[]"]');
    const stepInputs = document.querySelectorAll('textarea[name="step_text[]"]');

    const lines = [];
    lines.push('🍛 *' + title + '*');
    if (desc) {
        lines.push(desc);
    }
    lines.push('');

    const dietBadge = isVeg ? 'Pure Veg 🌱' : 'Non-Veg 🍗';
    lines.push('🏷 *Category:* ' + catName + ' • ' + dietBadge);
    lines.push('⏱ *Prep:* ' + prep + ' mins | *Cook:* ' + cook + ' mins');
    lines.push('👥 *Servings:* ' + servings + ' | ⭐ *Rating:* ' + parseFloat(rating).toFixed(1) + '/5.0');
    lines.push('');

    // Ingredients
    const validIngs = [];
    for (let i = 0; i < ingInputs.length; i++) {
        const name = ingInputs[i].value.trim();
        if (name) {
            const amt = amtInputs[i]?.value.trim() || '';
            const unit = unitInputs[i]?.value.trim() || '';
            validIngs.push((amt ? amt + ' ' : '') + (unit ? unit + ' ' : '') + name);
        }
    }

    if (validIngs.length > 0) {
        lines.push('🛒 *KEY INGREDIENTS PREVIEW:*');
        const showCount = Math.min(2, validIngs.length);
        for (let i = 0; i < showCount; i++) {
            lines.push('• ' + validIngs[i]);
        }
        const hidden = validIngs.length - showCount;
        if (hidden > 0) {
            lines.push('🔒 _+ ' + hidden + ' more ingredients hidden in Food CHART_');
        }
        lines.push('');
    }

    // Steps
    const validSteps = [];
    for (let i = 0; i < stepInputs.length; i++) {
        const s = stepInputs[i].value.trim();
        if (s) validSteps.push(s);
    }

    if (validSteps.length > 0) {
        lines.push('👩‍🍳 *METHOD PREVIEW:*');
        let s1 = validSteps[0];
        if (s1.length > 90) s1 = s1.substring(0, 87) + '...';
        lines.push('1. ' + s1);
        if (validSteps.length > 1) {
            lines.push('🔒 _Steps 2 to ' + validSteps.length + ' are locked in the app_');
        }
        lines.push('');
    }

    lines.push('━━━━━━━━━━━━━━━━━━━━━━');
    lines.push('📲 *Unlock Full Recipe, Ingredients & Cooking Timers:*');
    lines.push('👉 Download *Food CHART* (100% Free & Offline):');
    lines.push('https://play.google.com/store/apps/details?id=com.food.chart');
    lines.push('━━━━━━━━━━━━━━━━━━━━━━');

    const finalTeaser = lines.join('\n');
    const input = document.getElementById('customShareTextInput');
    if (input) {
        input.value = finalTeaser;
        input.scrollIntoView({ behavior: 'smooth', block: 'center' });
        input.focus();
    }
}

function copyFormWaText() {
    const input = document.getElementById('customShareTextInput');
    if (!input || !input.value.trim()) {
        alert('Please auto-generate or enter a teaser first!');
        return;
    }
    navigator.clipboard.writeText(input.value).then(() => {
        alert('WhatsApp teaser copied to clipboard!');
    }).catch(() => {
        input.select();
        document.execCommand('copy');
        alert('WhatsApp teaser copied to clipboard!');
    });
}
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
