<?php
/**
 * Food CHART Web Admin - Recipe Visual Preview
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$id = trim($_GET['id'] ?? '');
if (empty($id)) {
    header('Location: ' . BASE_URL . '/recipes.php');
    exit;
}

$stmt = $pdo->prepare("
    SELECT r.*, c.name AS category_name, c.color_hex AS category_color
    FROM recipes r
    LEFT JOIN categories c ON r.category_id = c.id
    WHERE r.id = ?
");
$stmt->execute([$id]);
$recipe = $stmt->fetch();

if (!$recipe) {
    set_flash_message('danger', 'Recipe not found!');
    header('Location: ' . BASE_URL . '/recipes.php');
    exit;
}

$pageTitle = $recipe['title'];

// Fetch ingredients
$ingStmt = $pdo->prepare("SELECT * FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC, id ASC");
$ingStmt->execute([$id]);
$ingredients = $ingStmt->fetchAll();

// Fetch instructions
$insStmt = $pdo->prepare("SELECT * FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");
$insStmt->execute([$id]);
$instructions = $insStmt->fetchAll();

$thumb = !empty($recipe['image_url']) ? BASE_URL . '/' . ltrim($recipe['image_url'], '/') : BASE_URL . '/assets/images/app_icon.png';
$catColor = !empty($recipe['category_color']) ? str_replace('0xFF', '#', $recipe['category_color']) : '#E50914';

require_once __DIR__ . '/includes/recipe_share_helper.php';
ensure_custom_share_text_column($pdo);

// Handle manual POST save for fallback
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['save_wa_text'])) {
    $savedText = trim($_POST['custom_share_text'] ?? '');
    try {
        $updateStmt = $pdo->prepare("UPDATE recipes SET custom_share_text = ? WHERE id = ?");
        $updateStmt->execute([$savedText !== '' ? $savedText : null, $id]);
        set_flash_message('success', 'Custom WhatsApp promotional message saved successfully!');
    } catch (Throwable $e) {
        set_flash_message('danger', 'Failed to save: ' . $e->getMessage());
    }
    header('Location: ' . BASE_URL . '/recipe-view.php?id=' . urlencode($id) . '#waCustomizerCard');
    exit;
}

// Fetch all recipes list for universal switcher
$allRecipesList = $pdo->query("SELECT id, title, is_vegetarian FROM recipes ORDER BY title ASC")->fetchAll();
$hasUniversalTemplate = has_universal_whatsapp_template();

// Precompute template variants using helper
$defaultTeaserText = build_recipe_whatsapp_share_text($recipe, $ingredients, $instructions, 'teaser');
$compactText = build_recipe_whatsapp_share_text($recipe, $ingredients, $instructions, 'compact');
$fullText = build_recipe_whatsapp_share_text($recipe, $ingredients, $instructions, 'full');

// If custom share text was previously saved in DB, use that as initial text; otherwise use default teaser
$hasCustomSavedText = !empty($recipe['custom_share_text']);
$initialWaText = $hasCustomSavedText ? $recipe['custom_share_text'] : $defaultTeaserText;
$waShareUrl = "https://api.whatsapp.com/send?text=" . rawurlencode($initialWaText);

$returnUrl = trim($_GET['return_url'] ?? $_POST['return_url'] ?? '');
if (empty($returnUrl) && !empty($_SERVER['HTTP_REFERER'])) {
    $refHost = parse_url($_SERVER['HTTP_REFERER'], PHP_URL_HOST);
    if (!$refHost || $refHost === ($_SERVER['HTTP_HOST'] ?? '')) {
        $returnUrl = $_SERVER['HTTP_REFERER'];
    }
}
$backUrl = !empty($returnUrl) ? $returnUrl : (BASE_URL . '/recipes.php');
$returnParam = !empty($returnUrl) ? '&return_url=' . urlencode($returnUrl) : '';

require_once __DIR__ . '/includes/header.php';
?>

<!-- Header Action Buttons -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 12px;">
    <a href="<?= htmlspecialchars($backUrl) ?>" class="btn btn-secondary">
        <i class="fa-solid fa-arrow-left"></i> Back to Catalog
    </a>

    <div style="display: flex; gap: 10px; flex-wrap: wrap;">
        <button type="button" onclick="focusWaEditor();" class="btn" style="background: #25D366; border-color: #25D366; color: #fff; font-weight: 700;">
            <i class="fa-brands fa-whatsapp"></i> Share on WhatsApp
        </button>
        <a href="<?= BASE_URL ?>/recipe-form.php?id=<?= urlencode($recipe['id']) ?><?= $returnParam ?>" class="btn btn-primary">
            <i class="fa-regular fa-pen-to-square"></i> Edit Recipe
        </a>
        <a href="<?= BASE_URL ?>/recipe-duplicate.php?id=<?= urlencode($recipe['id']) ?><?= $returnParam ?>" class="btn btn-secondary">
            <i class="fa-regular fa-copy"></i> Duplicate
        </a>
        <a href="<?= BASE_URL ?>/recipe-delete.php?id=<?= urlencode($recipe['id']) ?><?= $returnParam ?>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete <?= addslashes($recipe['title']) ?>?');">
            <i class="fa-regular fa-trash-can"></i> Delete
        </a>
    </div>
</div>


<!-- Recipe Hero Card -->
<div class="card" style="padding: 0; overflow: hidden; margin-bottom: 24px;">
    <div style="display: flex; flex-wrap: wrap;">
        <!-- Left: Image -->
        <div style="flex: 1; min-width: 320px; max-width: 460px; height: 360px; background: var(--cm-surface); position: relative;">
            <img src="<?= htmlspecialchars($thumb) ?>" 
                 onerror="this.onerror=null;this.src='<?= BASE_URL ?>/assets/images/app_icon.png';"
                 style="width: 100%; height: 100%; object-fit: cover;" 
                 alt="<?= htmlspecialchars($recipe['title']) ?>">
            <div style="position: absolute; top: 16px; left: 16px; display: flex; gap: 8px;">
                <?php if ($recipe['is_vegetarian']): ?>
                    <span class="badge badge-veg"><i class="fa-solid fa-leaf"></i> PURE VEG</span>
                <?php else: ?>
                    <span class="badge badge-nonveg"><i class="fa-solid fa-drumstick-bite"></i> NON-VEG</span>
                <?php endif; ?>
                
                <?php if ($recipe['is_favorite']): ?>
                    <span class="badge" style="background: rgba(229, 57, 53, 0.2); color: #EF5350; border: 1px solid #EF5350;">
                        <i class="fa-solid fa-heart"></i> FAVORITE
                    </span>
                <?php endif; ?>
            </div>
        </div>

        <!-- Right: Meta & Details -->
        <div style="flex: 2; min-width: 340px; padding: 32px; display: flex; flex-direction: column; justify-content: space-between;">
            <div>
                <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
                    <span class="badge" style="background: <?= $catColor ?>25; color: <?= $catColor ?>; border: 1px solid <?= $catColor ?>50; font-size: 12px;">
                        <?= htmlspecialchars($recipe['category_name'] ?? 'General') ?>
                    </span>
                    <span style="color: var(--cm-gold); font-weight: 800; font-size: 14px;">
                        <i class="fa-solid fa-star"></i> <?= number_format($recipe['rating'], 1) ?>
                    </span>
                    <span style="color: var(--cm-text-muted); font-size: 12px;">
                        ID: <code><?= htmlspecialchars($recipe['id']) ?></code>
                    </span>
                </div>

                <h1 style="font-size: 32px; font-weight: 800; margin-bottom: 8px; color: var(--cm-text-primary);">
                    <?= htmlspecialchars($recipe['title']) ?>
                </h1>

                <div style="font-size: 14px; color: var(--cm-text-secondary); margin-bottom: 16px;">
                    Cuisine: <strong style="color: var(--cm-text-primary);"><?= htmlspecialchars($recipe['cuisine']) ?></strong>
                    • Region: <strong style="color: var(--cm-text-primary);"><?= htmlspecialchars($recipe['region'] ?: 'Traditional') ?></strong>
                    • Chef: <strong style="color: var(--cm-primary);"><?= htmlspecialchars($recipe['chef_name']) ?></strong>
                </div>

                <p style="color: #CCCCCC; font-size: 14px; line-height: 1.7; margin-bottom: 24px;">
                    <?= nl2br(htmlspecialchars($recipe['description'])) ?>
                </p>
            </div>

            <!-- Metrics Pills -->
            <div style="display: flex; flex-wrap: wrap; gap: 12px; border-top: 1px solid var(--cm-border); padding-top: 20px;">
                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Prep Time</div>
                    <div style="font-weight: 800; color: var(--cm-text-primary); font-size: 16px;"><?= $recipe['prep_time_minutes'] ?> mins</div>
                </div>

                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Cook Time</div>
                    <div style="font-weight: 800; color: var(--cm-text-primary); font-size: 16px;"><?= $recipe['cook_time_minutes'] ?> mins</div>
                </div>

                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Total Time</div>
                    <div style="font-weight: 800; color: var(--cm-primary); font-size: 16px;"><?= $recipe['prep_time_minutes'] + $recipe['cook_time_minutes'] ?> mins</div>
                </div>

                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Servings</div>
                    <div style="font-weight: 800; color: var(--cm-text-primary); font-size: 16px;"><?= $recipe['servings'] ?> portions</div>
                </div>

                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Difficulty</div>
                    <div style="font-weight: 800; color: var(--cm-text-primary); font-size: 16px;"><?= htmlspecialchars($recipe['difficulty']) ?></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- WhatsApp Share & Teaser Customizer Card -->
<div class="card" id="waCustomizerCard" style="margin-bottom: 24px; border: 1px solid rgba(37, 211, 102, 0.35); background: linear-gradient(180deg, rgba(37, 211, 102, 0.05) 0%, rgba(20, 20, 20, 0.95) 120px);">
    <!-- Card Header with Title & Template Switches -->
    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px; margin-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 16px;">
        <div style="display: flex; align-items: center; gap: 12px;">
            <div style="width: 44px; height: 44px; border-radius: 12px; background: rgba(37, 211, 102, 0.15); border: 1px solid rgba(37, 211, 102, 0.3); display: flex; align-items: center; justify-content: center;">
                <i class="fa-brands fa-whatsapp" style="color: #25D366; font-size: 26px;"></i>
            </div>
            <div>
                <h3 style="margin: 0; font-size: 19px; font-weight: 800; color: #FFF; display: flex; align-items: center; gap: 10px;">
                    WhatsApp Share & Teaser Customizer
                    <span class="badge" style="background: rgba(37, 211, 102, 0.2); color: #25D366; border: 1px solid #25D366; font-size: 11px;">
                        <i class="fa-solid fa-pen"></i> Live Editable
                    </span>
                    <?php if ($hasCustomSavedText): ?>
                        <span class="badge" style="background: rgba(255, 179, 0, 0.15); color: #FFB300; border: 1px solid #FFB300; font-size: 11px;">
                            <i class="fa-solid fa-bookmark"></i> Custom Saved
                        </span>
                    <?php endif; ?>
                </h3>
                <span style="font-size: 12px; color: var(--cm-text-muted);">
                    Edit the recipe name, category, prep time, servings, preview limit, and app download link before sharing.
                </span>
            </div>
        </div>

        <!-- Template Selector Buttons & Universal Recipe Switcher -->
        <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;" id="templateButtonGroup">
            <div style="display: inline-flex; align-items: center; gap: 6px; background: rgba(255,255,255,0.05); padding: 3px 8px; border-radius: 8px; border: 1px solid rgba(255,255,255,0.12);" title="Switch to another recipe instantly without leaving this page">
                <i class="fa-solid fa-arrows-rotate" style="color: #25D366; font-size: 11px;"></i>
                <label for="quickRecipeSwitcher" style="margin: 0; font-size: 11.5px; font-weight: 700; color: var(--cm-text-secondary); white-space: nowrap;">Recipe:</label>
                <select id="quickRecipeSwitcher" onchange="if(this.value) window.location.href='recipe-view.php?id='+encodeURIComponent(this.value)+'#waCustomizerCard'" style="background: transparent; color: #FFF; border: none; font-size: 12px; font-weight: 600; cursor: pointer; outline: none; max-width: 170px;">
                    <?php foreach ($allRecipesList as $rItem): ?>
                        <option value="<?= htmlspecialchars($rItem['id']) ?>" <?= $rItem['id'] === $recipe['id'] ? 'selected' : '' ?> style="background: #181818; color: #FFF;">
                            <?= htmlspecialchars($rItem['title']) ?> (<?= $rItem['is_vegetarian'] ? 'Veg' : 'Non-Veg' ?>)
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <button type="button" class="btn btn-secondary btn-sm active" id="btnTplTeaser" onclick="loadTemplate('teaser')" title="Standard locked preview with ingredients and steps hidden" style="border-radius: 8px; font-weight: 700;">
                <i class="fa-solid fa-lock" style="color: #FFB300;"></i> Default Teaser
            </button>
            <button type="button" class="btn btn-secondary btn-sm" id="btnTplCompact" onclick="loadTemplate('compact')" title="Compact: Recipe Name + Category + Prep + Servings + App Download link" style="border-radius: 8px; font-weight: 700;">
                <i class="fa-solid fa-bolt" style="color: var(--cm-primary);"></i> Compact
            </button>
            <button type="button" class="btn btn-secondary btn-sm" id="btnTplFull" onclick="loadTemplate('full')" title="Full Recipe with all ingredients and all instructions" style="border-radius: 8px; font-weight: 700;">
                <i class="fa-solid fa-book-open" style="color: #4CAF50;"></i> Full Recipe
            </button>
        </div>
    </div>

    <!-- 2 Columns: Editor & Live WhatsApp Bubble Simulation -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 24px;">
        <!-- Left: Textarea Editor -->
        <div style="display: flex; flex-direction: column;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <label style="font-size: 13px; font-weight: 700; color: var(--cm-text-secondary); display: flex; align-items: center; gap: 6px;">
                    <i class="fa-solid fa-align-left" style="color: var(--cm-primary);"></i> Promotional Message Text:
                </label>
                <span style="font-size: 12px; color: var(--cm-text-muted);" id="waCounter">
                    <span id="waCharCount">0</span> chars &bull; <span id="waLineCount">0</span> lines
                </span>
            </div>

            <textarea id="waShareEditor" class="form-control" rows="15"
                style="font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size: 13.5px; line-height: 1.55; background: #0c0c0c; color: #e9edef; border: 1px solid #2e2e2e; border-radius: 12px; padding: 14px; resize: vertical; width: 100%; box-shadow: inset 0 2px 6px rgba(0,0,0,0.4);"
                placeholder="Type or edit your WhatsApp promotional message..."
                oninput="updateWaLivePreview()"><?= htmlspecialchars($initialWaText) ?></textarea>

            <!-- Quick Insertion Snippets -->
            <div style="margin-top: 10px; display: flex; flex-wrap: wrap; gap: 6px; align-items: center;">
                <span style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700;">Quick Add:</span>
                <button type="button" class="btn btn-secondary btn-sm" style="padding: 3px 9px; font-size: 11px;" onclick="insertSnippet('https://play.google.com/store/apps/details?id=com.food.chart')">
                    <i class="fa-brands fa-google-play" style="color: #4CAF50;"></i> + Play Store Link
                </button>
                <button type="button" class="btn btn-secondary btn-sm" style="padding: 3px 9px; font-size: 11px;" onclick="insertSnippet('🏷 *Category:* <?= addslashes($recipe['category_name'] ?? 'Malnad Special') ?> • <?= $recipe['is_vegetarian'] ? 'Pure Veg 🌱' : 'Non-Veg 🍗' ?>')">
                    + Category
                </button>
                <button type="button" class="btn btn-secondary btn-sm" style="padding: 3px 9px; font-size: 11px;" onclick="insertSnippet('⏱ *Prep:* <?= $recipe['prep_time_minutes'] ?> mins | *Cook:* <?= $recipe['cook_time_minutes'] ?> mins\n👥 *Servings:* <?= $recipe['servings'] ?> | ⭐ *Rating:* <?= number_format($recipe['rating'], 1) ?>/5.0')">
                    + Prep & Servings
                </button>
                <button type="button" class="btn btn-secondary btn-sm" style="padding: 3px 9px; font-size: 11px;" onclick="insertSnippet('🔒 _Steps and secret spices are locked in Food CHART app_')">
                    + Lock Notice
                </button>
            </div>

            <!-- Action Buttons Bar -->
            <div style="margin-top: 18px; display: flex; gap: 10px; flex-wrap: wrap; align-items: center;">
                <button type="button" id="btnShareNow" onclick="shareOnWhatsApp()" class="btn" style="background: #25D366; border-color: #25D366; color: #FFF; font-weight: 800; font-size: 14px; padding: 10px 22px; border-radius: 10px; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-brands fa-whatsapp" style="font-size: 18px;"></i> Open in WhatsApp
                </button>
                <button type="button" id="btnCopyText" onclick="copyWaText()" class="btn btn-secondary" style="font-weight: 700; border-radius: 10px; display: inline-flex; align-items: center; gap: 8px;">
                    <i class="fa-regular fa-copy"></i> Copy Text
                </button>
                <button type="button" id="btnSaveCustom" onclick="saveCustomMessage()" class="btn btn-secondary" style="font-weight: 700; color: #81C784; border-color: rgba(76, 175, 80, 0.4); border-radius: 10px; display: inline-flex; align-items: center; gap: 8px;" title="Save for this recipe only">
                    <i class="fa-solid fa-floppy-disk"></i> Save Custom Message
                </button>
                <button type="button" id="btnApplyAll" onclick="applyToAllRecipes()" class="btn btn-secondary" style="font-weight: 700; color: #FFB300; border-color: rgba(255, 179, 0, 0.5); background: rgba(255, 179, 0, 0.08); border-radius: 10px; display: inline-flex; align-items: center; gap: 8px;" title="Apply this message format and promotional CTA to ALL recipes with 1 click">
                    <i class="fa-solid fa-wand-magic-sparkles"></i> Apply to All Recipes (1-Click)
                </button>
                <button type="button" onclick="resetToDefaultTeaser()" class="btn btn-secondary" title="Reset to default teaser" style="color: var(--cm-text-muted); border-radius: 10px;">
                    <i class="fa-solid fa-rotate-left"></i> Reset
                </button>
            </div>
        </div>

        <!-- Right: Live WhatsApp Chat Bubble Simulation -->
        <div>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <label style="font-size: 13px; font-weight: 700; color: var(--cm-text-secondary); display: flex; align-items: center; gap: 6px;">
                    <i class="fa-brands fa-whatsapp" style="color: #25D366;"></i> Live Chat Preview:
                </label>
                <span class="badge" style="background: rgba(37, 211, 102, 0.12); color: #25D366; border: 1px solid rgba(37, 211, 102, 0.3); font-size: 10px;">
                    <i class="fa-solid fa-circle" style="font-size: 7px;"></i> Updates as you type
                </span>
            </div>

            <!-- WhatsApp Chat Window -->
            <div style="background: #0b141a; border: 1px solid #1f2c34; border-radius: 14px; overflow: hidden; box-shadow: 0 12px 30px rgba(0,0,0,0.6);">
                <!-- Chat Window Header -->
                <div style="background: #202c33; padding: 10px 14px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #2a3942;">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <div style="width: 34px; height: 34px; border-radius: 50%; overflow: hidden; background: #00a884; display: flex; align-items: center; justify-content: center; font-weight: 800; color: #FFF; font-size: 14px;">
                            <i class="fa-solid fa-utensils"></i>
                        </div>
                        <div>
                            <div style="font-size: 13px; font-weight: 700; color: #e9edef;">Food CHART Community</div>
                            <div style="font-size: 10px; color: #00a884; display: flex; align-items: center; gap: 4px;">
                                <span style="width: 6px; height: 6px; border-radius: 50%; background: #00a884; display: inline-block;"></span> online
                            </div>
                        </div>
                    </div>
                    <div style="color: #8696a0; font-size: 13px; display: flex; gap: 14px;">
                        <i class="fa-solid fa-phone"></i>
                        <i class="fa-solid fa-ellipsis-vertical"></i>
                    </div>
                </div>

                <!-- Chat Wallpaper & Messages Container -->
                <div style="background: #0b141a radial-gradient(circle, rgba(255,255,255,0.02) 10%, transparent 10%) 0 0/16px 16px; padding: 18px 14px; min-height: 380px; max-height: 480px; overflow-y: auto; display: flex; flex-direction: column; justify-content: flex-start; align-items: flex-end;">
                    <!-- Outgoing Message Bubble -->
                    <div style="background: #005c4b; color: #e9edef; border-radius: 10px 0px 10px 10px; padding: 11px 14px; max-width: 92%; font-size: 13px; line-height: 1.5; box-shadow: 0 1px 3px rgba(0,0,0,0.4); word-break: break-word; position: relative;">
                        <div id="waBubbleContent" style="white-space: pre-wrap;"></div>
                        <div style="display: flex; align-items: center; justify-content: flex-end; gap: 4px; margin-top: 8px; font-size: 10px; color: rgba(255,255,255,0.65);">
                            <span id="waBubbleTime">11:45 AM</span>
                            <i class="fa-solid fa-check-double" style="color: #53bdeb; font-size: 11px;"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Nutrition & Tags -->
<?php if (!empty($recipe['nutrition']) || !empty($recipe['tags'])): ?>
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; flex-wrap: wrap; justify-content: space-between; gap: 16px;">
            <?php if (!empty($recipe['nutrition'])): ?>
                <div>
                    <span style="font-size: 12px; font-weight: 800; color: var(--cm-primary); text-transform: uppercase; letter-spacing: 0.5px;">Nutritional Info</span>
                    <div style="font-size: 14px; font-weight: 700; color: var(--cm-text-primary); margin-top: 4px;">
                        <i class="fa-solid fa-fire" style="color: var(--cm-secondary);"></i> <?= htmlspecialchars($recipe['nutrition']) ?>
                    </div>
                </div>
            <?php endif; ?>

            <?php if (!empty($recipe['tags'])): ?>
                <div>
                    <span style="font-size: 12px; font-weight: 800; color: var(--cm-primary); text-transform: uppercase; letter-spacing: 0.5px;">
                        <i class="fa-solid fa-hashtag me-1"></i> Hashtags
                    </span>
                    <div style="display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px;">
                        <?php 
                        require_once __DIR__ . '/includes/tag_functions.php';
                        foreach (explode(',', $recipe['tags']) as $t): 
                            $cleanT = normalize_tag($t);
                            if ($cleanT === '') continue;
                        ?>
                            <a href="<?= BASE_URL ?>/recipes.php?q=%23<?= urlencode($cleanT) ?>" class="hashtag-chip" style="text-decoration:none; font-size:12px; padding:4px 10px;" title="View all recipes tagged #<?= htmlspecialchars($cleanT) ?>">
                                #<?= htmlspecialchars($cleanT) ?>
                            </a>
                        <?php endforeach; ?>
                    </div>
                </div>
            <?php endif; ?>
        </div>
    </div>
<?php endif; ?>

<!-- 2 Columns: Ingredients & Instructions -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 24px;">
    <!-- Column 1: Ingredients -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-basket-shopping" style="color: var(--cm-primary);"></i> Ingredients (<?= count($ingredients) ?>)</h3>
        </div>

        <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 10px;">
            <?php if (empty($ingredients)): ?>
                <li style="color: var(--cm-text-muted); font-size: 14px;">No ingredients recorded.</li>
            <?php else: ?>
                <?php foreach ($ingredients as $ing): ?>
                    <li style="display: flex; justify-content: space-between; align-items: center; background: var(--cm-surface); padding: 12px 16px; border-radius: 10px; border: 1px solid var(--cm-border);">
                        <span style="font-weight: 700; color: var(--cm-text-primary); font-size: 14px;">
                            <?= htmlspecialchars($ing['name']) ?>
                            <?php if (!empty($ing['notes'])): ?>
                                <small style="display: block; color: var(--cm-text-muted); font-weight: 400;"><?= htmlspecialchars($ing['notes']) ?></small>
                            <?php endif; ?>
                        </span>
                        <span style="font-size: 13px; font-weight: 800; color: var(--cm-primary); background: rgba(255, 107, 53, 0.1); padding: 4px 10px; border-radius: 6px;">
                            <?= htmlspecialchars($ing['amount']) ?> <?= htmlspecialchars($ing['unit']) ?>
                        </span>
                    </li>
                <?php endforeach; ?>
            <?php endif; ?>
        </ul>
    </div>

    <!-- Column 2: Instructions -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-fire-burner" style="color: var(--cm-primary);"></i> Instructions (<?= count($instructions) ?> Steps)</h3>
        </div>

        <div style="display: flex; flex-direction: column; gap: 14px;">
            <?php if (empty($instructions)): ?>
                <p style="color: var(--cm-text-muted); font-size: 14px;">No steps recorded.</p>
            <?php else: ?>
                <?php foreach ($instructions as $ins): ?>
                    <div style="display: flex; gap: 14px; background: var(--cm-surface); padding: 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                        <span style="background: var(--cm-primary); color: #FFF; width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 14px; flex-shrink: 0;">
                            <?= $ins['step_number'] ?>
                        </span>
                        <div style="flex: 1;">
                            <p style="margin: 0; font-size: 14px; line-height: 1.6; color: var(--cm-text-primary);">
                                <?= nl2br(htmlspecialchars($ins['instruction'])) ?>
                            </p>
                            <?php if (!empty($ins['timer_seconds']) && $ins['timer_seconds'] > 0): ?>
                                <span style="display: inline-flex; align-items: center; gap: 5px; font-size: 12px; color: var(--cm-primary); margin-top: 8px; font-weight: 700;">
                                    <i class="fa-regular fa-clock"></i> <?= round($ins['timer_seconds'] / 60, 1) ?> mins timer (<?= $ins['timer_seconds'] ?>s)
                                </span>
                            <?php endif; ?>
                            <?php if (!empty($ins['tip'])): ?>
                                <div style="font-size: 12px; color: #81C784; background: rgba(76, 175, 80, 0.1); padding: 6px 10px; border-radius: 6px; margin-top: 8px; border-left: 3px solid #4CAF50;">
                                    💡 <strong>Chef Tip:</strong> <?= htmlspecialchars($ins['tip']) ?>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- Interactive JavaScript for WhatsApp Share & Teaser Customizer -->
<script>
const templateVariants = {
    teaser: <?= json_encode($defaultTeaserText, JSON_UNESCAPED_UNICODE) ?>,
    compact: <?= json_encode($compactText, JSON_UNESCAPED_UNICODE) ?>,
    full: <?= json_encode($fullText, JSON_UNESCAPED_UNICODE) ?>
};

function formatWaTime(date) {
    let hours = date.getHours();
    let minutes = date.getMinutes();
    const ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours ? hours : 12;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    return hours + ':' + minutes + ' ' + ampm;
}

function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

function renderWaMarkdown(raw) {
    let escaped = escapeHtml(raw);

    // *bold*
    escaped = escaped.replace(/\*([^*\n]+)\*/g, '<strong style="color: #FFF;">$1</strong>');

    // _italic_
    escaped = escaped.replace(/_([^_\n]+)_/g, '<em>$1</em>');

    // ~strike~
    escaped = escaped.replace(/~([^~\n]+)~/g, '<del>$1</del>');

    // URLs
    escaped = escaped.replace(/(https?:\/\/[^\s]+)/g, '<a href="$1" target="_blank" rel="noopener noreferrer" style="color: #53bdeb; text-decoration: underline; word-break: break-all;">$1</a>');

    return escaped;
}

function updateWaLivePreview() {
    const editor = document.getElementById('waShareEditor');
    const bubble = document.getElementById('waBubbleContent');
    const charCount = document.getElementById('waCharCount');
    const lineCount = document.getElementById('waLineCount');
    const bubbleTime = document.getElementById('waBubbleTime');

    if (!editor || !bubble) return;

    const val = editor.value;

    if (charCount) charCount.textContent = val.length;
    if (lineCount) lineCount.textContent = val ? val.split('\n').length : 0;

    bubble.innerHTML = renderWaMarkdown(val);

    if (bubbleTime) {
        bubbleTime.textContent = formatWaTime(new Date());
    }
}

function loadTemplate(type) {
    const editor = document.getElementById('waShareEditor');
    if (!editor || !templateVariants[type]) return;

    editor.value = templateVariants[type];

    // Update active button
    document.querySelectorAll('#templateButtonGroup button').forEach(btn => {
        btn.classList.remove('active');
        btn.style.borderColor = 'transparent';
    });

    const activeBtn = document.getElementById('btnTpl' + type.charAt(0).toUpperCase() + type.slice(1));
    if (activeBtn) {
        activeBtn.classList.add('active');
        activeBtn.style.borderColor = 'var(--cm-primary)';
    }

    updateWaLivePreview();
    showCmToast(`Switched to ${type.toUpperCase()} template!`, 'success');
}

function insertSnippet(snippet) {
    const editor = document.getElementById('waShareEditor');
    if (!editor) return;

    const start = editor.selectionStart;
    const end = editor.selectionEnd;
    const text = editor.value;

    if (start !== undefined && end !== undefined) {
        editor.value = text.substring(0, start) + "\n" + snippet + "\n" + text.substring(end);
        editor.selectionStart = editor.selectionEnd = start + snippet.length + 2;
    } else {
        editor.value += "\n" + snippet;
    }

    editor.focus();
    updateWaLivePreview();
}

function shareOnWhatsApp() {
    const editor = document.getElementById('waShareEditor');
    if (!editor) return;
    const text = editor.value.trim();
    if (!text) {
        showCmToast('Cannot send empty message!', 'danger');
        return;
    }

    const shareUrl = 'https://api.whatsapp.com/send?text=' + encodeURIComponent(text);
    window.open(shareUrl, '_blank');
}

function copyWaText() {
    const editor = document.getElementById('waShareEditor');
    if (!editor) return;
    const text = editor.value;

    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(() => {
            showCmToast('WhatsApp promotional text copied to clipboard!', 'success');
        }).catch(() => {
            fallbackCopy(text);
        });
    } else {
        fallbackCopy(text);
    }
}

function fallbackCopy(text) {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.left = '-9999px';
    document.body.appendChild(ta);
    ta.select();
    try {
        document.execCommand('copy');
        showCmToast('WhatsApp promotional text copied to clipboard!', 'success');
    } catch (err) {
        showCmToast('Failed to copy text', 'danger');
    }
    document.body.removeChild(ta);
}

function saveCustomMessage() {
    const editor = document.getElementById('waShareEditor');
    const btn = document.getElementById('btnSaveCustom');
    if (!editor || !btn) return;

    const text = editor.value.trim();
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving...';

    const formData = new FormData();
    formData.append('recipe_id', '<?= addslashes($recipe['id']) ?>');
    formData.append('share_text', text);

    fetch('<?= BASE_URL ?>/api/save_recipe_share_text.php', {
        method: 'POST',
        body: formData
    })
    .then(r => r.json())
    .then(data => {
        btn.disabled = false;
        if (data.status === 'success') {
            btn.innerHTML = '<i class="fa-solid fa-check"></i> Saved!';
            showCmToast('Custom WhatsApp message saved to database!', 'success');
            setTimeout(() => {
                btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save Custom Message';
            }, 2500);
        } else {
            btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save Custom Message';
            showCmToast('Error: ' + (data.message || 'Could not save'), 'danger');
        }
    })
    .catch(err => {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save Custom Message';
        showCmToast('Network error while saving message', 'danger');
    });
}

function applyToAllRecipes() {
    const editor = document.getElementById('waShareEditor');
    const btn = document.getElementById('btnApplyAll');
    if (!editor || !btn) return;

    const text = editor.value.trim();
    if (!text) {
        showCmToast('Cannot apply an empty message template!', 'danger');
        return;
    }

    if (!confirm('Apply this WhatsApp promotional message template & app download link to ALL recipes across Food CHART in 1 click?')) {
        return;
    }

    btn.disabled = true;
    const origHtml = btn.innerHTML;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Applying to all...';

    const formData = new FormData();
    formData.append('recipe_id', '<?= addslashes($recipe['id']) ?>');
    formData.append('share_text', text);

    fetch('<?= BASE_URL ?>/api/apply_universal_share_text.php', {
        method: 'POST',
        body: formData
    })
    .then(r => r.json())
    .then(data => {
        btn.disabled = false;
        if (data.status === 'success') {
            btn.innerHTML = `<i class="fa-solid fa-check" style="color: #25D366;"></i> Applied to ${data.total_updated || 'All'} Recipes!`;
            showCmToast(data.message || 'Universal WhatsApp template applied to all recipes!', 'success');
            setTimeout(() => {
                btn.innerHTML = origHtml;
            }, 3500);
        } else {
            btn.innerHTML = origHtml;
            showCmToast('Error: ' + (data.message || 'Could not apply universally'), 'danger');
        }
    })
    .catch(err => {
        btn.disabled = false;
        btn.innerHTML = origHtml;
        showCmToast('Network error while applying universal template', 'danger');
    });
}

function resetToDefaultTeaser() {
    if (confirm('Reset editor back to the standard locked teaser template?')) {
        loadTemplate('teaser');
    }
}

function focusWaEditor() {
    const card = document.getElementById('waCustomizerCard');
    const editor = document.getElementById('waShareEditor');
    if (card) {
        card.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
    if (editor) {
        setTimeout(() => editor.focus(), 400);
    }
}

function showCmToast(message, type = 'success') {
    let toast = document.getElementById('cmToastNotification');
    if (!toast) {
        toast = document.createElement('div');
        toast.id = 'cmToastNotification';
        toast.style.cssText = 'position: fixed; bottom: 24px; right: 24px; z-index: 99999; padding: 12px 22px; border-radius: 12px; font-weight: 700; font-size: 14px; box-shadow: 0 10px 30px rgba(0,0,0,0.6); display: flex; align-items: center; gap: 10px; transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); opacity: 0; transform: translateY(20px); pointer-events: none;';
        document.body.appendChild(toast);
    }
    toast.style.background = type === 'success' ? '#25D366' : (type === 'danger' ? '#E50914' : '#1e1e1e');
    toast.style.color = '#FFFFFF';
    toast.innerHTML = `<i class="fa-solid ${type === 'success' ? 'fa-circle-check' : 'fa-circle-exclamation'}"></i> <span>${message}</span>`;
    toast.style.opacity = '1';
    toast.style.transform = 'translateY(0)';
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(20px)';
    }, 2800);
}

// Initialize live preview on load
document.addEventListener('DOMContentLoaded', () => {
    updateWaLivePreview();
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
