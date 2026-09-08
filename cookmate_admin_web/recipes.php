<?php
/**
 * Food CHART Web Admin - Recipe Catalog
 */
require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/includes/recipe_share_helper.php';
$pdo = get_db_connection();
ensure_custom_share_text_column($pdo);

$pageTitle = 'Recipe Catalog';

// Filter parameters
$search = trim($_GET['q'] ?? '');
$categoryFilter = trim($_GET['category'] ?? '');
$dietFilter = trim($_GET['diet'] ?? ''); // 'veg', 'nonveg'
$diffFilter = trim($_GET['difficulty'] ?? '');
$sort = trim($_GET['sort'] ?? 'newest');
$page = max(1, (int)($_GET['page'] ?? 1));
$limit = 20;
$offset = ($page - 1) * $limit;

// Build query
$where = [];
$params = [];

if ($search !== '') {
    if (strpos($search, '#') === 0) {
        require_once __DIR__ . '/includes/tag_functions.php';
        $tagNorm = normalize_tag($search);
        $where[] = "r.id IN (
            SELECT rt.recipe_id FROM recipe_tags rt 
            INNER JOIN tags t ON t.id = rt.tag_id 
            WHERE t.name = ?
        )";
        $params[] = $tagNorm;
    } else {
        $where[] = "(r.title LIKE ? OR r.chef_name LIKE ? OR r.cuisine LIKE ? OR r.tags LIKE ? OR r.description LIKE ?)";
        $term = "%$search%";
        $params = array_merge($params, [$term, $term, $term, $term, $term]);
    }
}

if ($categoryFilter !== '') {
    $where[] = "r.category_id = ?";
    $params[] = $categoryFilter;
}

if ($dietFilter === 'veg') {
    $where[] = "r.is_vegetarian = 1";
} elseif ($dietFilter === 'nonveg') {
    $where[] = "r.is_vegetarian = 0";
}

if ($diffFilter !== '') {
    $where[] = "r.difficulty = ?";
    $params[] = $diffFilter;
}

$whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

// Sort SQL
$orderSql = match ($sort) {
    'title_asc' => 'ORDER BY r.title ASC',
    'title_desc' => 'ORDER BY r.title DESC',
    'rating_desc' => 'ORDER BY r.rating DESC, r.title ASC',
    'time_asc' => 'ORDER BY (r.prep_time_minutes + r.cook_time_minutes) ASC',
    default => 'ORDER BY r.created_at DESC, r.id DESC',
};

// Count total matching
$countStmt = $pdo->prepare("SELECT COUNT(*) FROM recipes r $whereSql");
$countStmt->execute($params);
$totalRecipes = (int)$countStmt->fetchColumn();
$totalPages = ceil($totalRecipes / $limit);

// Fetch page items
$querySql = "
    SELECT r.*, c.name AS category_name, c.color_hex AS category_color
    FROM recipes r
    LEFT JOIN categories c ON r.category_id = c.id
    $whereSql
    $orderSql
    LIMIT $limit OFFSET $offset
";
$stmt = $pdo->prepare($querySql);
$stmt->execute($params);
$recipes = $stmt->fetchAll();

// Batch-load ingredients and instructions for accurate teaser previews
$recipeIds = array_column($recipes, 'id');
$recipeIngredientsMap = [];
$recipeInstructionsMap = [];
if (!empty($recipeIds)) {
    $inPlaceholders = implode(',', array_fill(0, count($recipeIds), '?'));
    $bIngStmt = $pdo->prepare("SELECT * FROM recipe_ingredients WHERE recipe_id IN ($inPlaceholders) ORDER BY sort_order ASC, id ASC");
    $bIngStmt->execute($recipeIds);
    while ($row = $bIngStmt->fetch()) {
        $recipeIngredientsMap[$row['recipe_id']][] = $row;
    }
    $bInsStmt = $pdo->prepare("SELECT * FROM recipe_instructions WHERE recipe_id IN ($inPlaceholders) ORDER BY step_number ASC");
    $bInsStmt->execute($recipeIds);
    while ($row = $bInsStmt->fetch()) {
        $recipeInstructionsMap[$row['recipe_id']][] = $row;
    }
}

// Fetch categories for filter dropdown
$categories = $pdo->query("SELECT id, name FROM categories ORDER BY name ASC")->fetchAll();

require_once __DIR__ . '/includes/header.php';
?>

<!-- Filter & Search Toolbar -->
<form method="GET" action="<?= BASE_URL ?>/recipes.php" class="filter-bar">
    <div class="search-input-wrapper">
        <i class="fa-solid fa-magnifying-glass search-icon"></i>
        <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" class="form-control" placeholder="Search by title, chef, cuisine, tags...">
    </div>

    <div style="min-width: 170px;">
        <select name="category" class="form-control" onchange="this.form.submit()">
            <option value="">All Categories</option>
            <?php foreach ($categories as $cat): ?>
                <option value="<?= htmlspecialchars($cat['id']) ?>" <?= $categoryFilter === $cat['id'] ? 'selected' : '' ?>>
                    <?= htmlspecialchars($cat['name']) ?>
                </option>
            <?php endforeach; ?>
        </select>
    </div>

    <div style="min-width: 130px;">
        <select name="diet" class="form-control" onchange="this.form.submit()">
            <option value="">All Diets</option>
            <option value="veg" <?= $dietFilter === 'veg' ? 'selected' : '' ?>>🌱 Pure Veg</option>
            <option value="nonveg" <?= $dietFilter === 'nonveg' ? 'selected' : '' ?>>🍗 Non-Veg</option>
        </select>
    </div>

    <div style="min-width: 130px;">
        <select name="difficulty" class="form-control" onchange="this.form.submit()">
            <option value="">All Difficulty</option>
            <option value="Easy" <?= $diffFilter === 'Easy' ? 'selected' : '' ?>>Easy</option>
            <option value="Medium" <?= $diffFilter === 'Medium' ? 'selected' : '' ?>>Medium</option>
            <option value="Hard" <?= $diffFilter === 'Hard' ? 'selected' : '' ?>>Hard</option>
        </select>
    </div>

    <div style="min-width: 150px;">
        <select name="sort" class="form-control" onchange="this.form.submit()">
            <option value="newest" <?= $sort === 'newest' ? 'selected' : '' ?>>Newest First</option>
            <option value="rating_desc" <?= $sort === 'rating_desc' ? 'selected' : '' ?>>Top Rated ⭐</option>
            <option value="title_asc" <?= $sort === 'title_asc' ? 'selected' : '' ?>>Name (A-Z)</option>
            <option value="title_desc" <?= $sort === 'title_desc' ? 'selected' : '' ?>>Name (Z-A)</option>
            <option value="time_asc" <?= $sort === 'time_asc' ? 'selected' : '' ?>>Shortest Cook Time</option>
        </select>
    </div>

    <button type="submit" class="btn btn-primary btn-sm">Filter</button>
    <?php if ($search !== '' || $categoryFilter !== '' || $dietFilter !== '' || $diffFilter !== '' || $sort !== 'newest'): ?>
        <a href="<?= BASE_URL ?>/recipes.php" class="btn btn-secondary btn-sm" title="Clear Filters">Reset</a>
    <?php endif; ?>
</form>

<!-- Results Header & Counter -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px;">
    <div style="color: var(--cm-text-secondary); font-size: 14px;">
        Showing <strong style="color: var(--cm-text-primary);" id="countShowingNum"><?= count($recipes) ?></strong> of <strong style="color: var(--cm-primary);" id="countTotalNum"><?= number_format($totalRecipes) ?></strong> recipes
        <?php if ($search !== ''): ?>
            for "<em><?= htmlspecialchars($search) ?></em>"
        <?php endif; ?>
    </div>
    <a href="<?= BASE_URL ?>/recipe-form.php?return_url=<?= urlencode($_SERVER['REQUEST_URI']) ?><?= $categoryFilter !== '' ? '&category_id=' . urlencode($categoryFilter) : '' ?>" class="btn btn-primary btn-sm">
        <i class="fa-solid fa-plus"></i> Add New Recipe
    </a>
</div>


<!-- Recipes Table Card -->
<div class="card" style="padding: 0; overflow: hidden;">
    <div class="table-responsive">
        <table class="admin-table">
            <thead>
                <tr>
                    <th style="width: 54px; text-align: center;">Photo</th>
                    <th>Recipe & Cuisine</th>
                    <th>Category</th>
                    <th>Diet</th>
                    <th>Prep / Cook</th>
                    <th>Difficulty</th>
                    <th>Rating</th>
                    <th style="text-align: right; width: 170px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($recipes)): ?>
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 48px; color: var(--cm-text-muted);">
                            <i class="fa-solid fa-bowl-rice" style="font-size: 36px; margin-bottom: 12px; display: block; color: var(--cm-primary);"></i>
                            <h3 style="font-size: 18px; margin-bottom: 6px;">No recipes found</h3>
                            <p style="font-size: 13px;">Try adjusting your search criteria or add a new recipe.</p>
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($recipes as $r): ?>
                        <?php
                            $thumb = !empty($r['image_url']) ? BASE_URL . '/' . ltrim($r['image_url'], '/') : BASE_URL . '/assets/images/app_icon.png';
                            $catColor = !empty($r['category_color']) ? str_replace('0xFF', '#', $r['category_color']) : '#E50914';
                        ?>
                        <tr id="recipe-row-<?= htmlspecialchars($r['id']) ?>" data-recipe-id="<?= htmlspecialchars($r['id']) ?>">
                            <td style="text-align: center;">
                                <img src="<?= htmlspecialchars($thumb) ?>" 
                                     onerror="this.onerror=null;this.src='<?= BASE_URL ?>/assets/images/app_icon.png';" 
                                     class="recipe-cell-thumb" 
                                     alt="<?= htmlspecialchars($r['title']) ?>">
                            </td>
                            <td>
                                <a href="<?= BASE_URL ?>/recipe-view.php?id=<?= urlencode($r['id']) ?>&return_url=<?= urlencode($_SERVER['REQUEST_URI']) ?>" class="recipe-cell-title">
                                    <?= htmlspecialchars($r['title']) ?>
                                </a>
                                <span class="recipe-cell-sub">
                                    <?= htmlspecialchars($r['cuisine']) ?> • by <?= htmlspecialchars($r['chef_name']) ?>
                                    <?php if (!empty($r['region'])): ?>
                                        • <span style="color: var(--cm-text-muted);"><?= htmlspecialchars($r['region']) ?></span>
                                    <?php endif; ?>
                                </span>
                            </td>
                            <td>
                                <span class="badge" style="background: <?= $catColor ?>20; color: <?= $catColor ?>; border: 1px solid <?= $catColor ?>40;">
                                    <?= htmlspecialchars($r['category_name'] ?? 'General') ?>
                                </span>
                            </td>
                            <td>
                                <?php if ($r['is_vegetarian']): ?>
                                    <span class="badge badge-veg"><i class="fa-solid fa-leaf"></i> VEG</span>
                                <?php else: ?>
                                    <span class="badge badge-nonveg"><i class="fa-solid fa-drumstick-bite"></i> NON-VEG</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <span style="font-size: 13px; color: var(--cm-text-secondary); white-space: nowrap;">
                                    <i class="fa-regular fa-clock" style="color: var(--cm-primary);"></i> 
                                    <?= $r['prep_time_minutes'] ?>m prep + <?= $r['cook_time_minutes'] ?>m cook
                                </span>
                            </td>
                            <td>
                                <?php
                                    $diffClass = match (strtolower($r['difficulty'])) {
                                        'easy' => 'badge-diff-easy',
                                        'hard' => 'badge-diff-hard',
                                        default => 'badge-diff-medium'
                                    };
                                ?>
                                <span class="badge <?= $diffClass ?>">
                                    <?= htmlspecialchars($r['difficulty']) ?>
                                </span>
                            </td>
                            <td>
                                <span style="color: var(--cm-gold); font-weight: 700; font-size: 13px; white-space: nowrap;">
                                    <i class="fa-solid fa-star"></i> <?= number_format($r['rating'], 1) ?>
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: inline-flex; gap: 6px;">
                                    <?php
                                        $rIngs = $recipeIngredientsMap[$r['id']] ?? [];
                                        $rIns = $recipeInstructionsMap[$r['id']] ?? [];
                                        $rTeaserText = !empty($r['custom_share_text']) 
                                            ? $r['custom_share_text'] 
                                            : build_recipe_whatsapp_share_text($r, $rIngs, $rIns, 'teaser');
                                        $rCompactText = build_recipe_whatsapp_share_text($r, $rIngs, $rIns, 'compact');
                                        $rFullText = build_recipe_whatsapp_share_text($r, $rIngs, $rIns, 'full');
                                        $recipeShareData = [
                                            'id' => $r['id'],
                                            'title' => $r['title'],
                                            'is_veg' => (bool)$r['is_vegetarian'],
                                            'teaser' => $rTeaserText,
                                            'compact' => $rCompactText,
                                            'full' => $rFullText
                                        ];
                                    ?>
                                    <button type="button" class="btn btn-secondary btn-icon" title="Share & Customize WhatsApp Teaser" style="color: #25D366;"
                                        onclick='openWaModal(<?= json_encode($recipeShareData, JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_UNICODE) ?>)'>
                                        <i class="fa-brands fa-whatsapp"></i>
                                    </button>
                                    <a href="<?= BASE_URL ?>/recipe-view.php?id=<?= urlencode($r['id']) ?>&return_url=<?= urlencode($_SERVER['REQUEST_URI']) ?>" class="btn btn-secondary btn-icon" title="View Recipe">
                                        <i class="fa-regular fa-eye"></i>
                                    </a>
                                    <a href="<?= BASE_URL ?>/recipe-form.php?id=<?= urlencode($r['id']) ?>&return_url=<?= urlencode($_SERVER['REQUEST_URI']) ?>" class="btn btn-secondary btn-icon" title="Edit Recipe" style="color: var(--cm-primary);">
                                        <i class="fa-regular fa-pen-to-square"></i>
                                    </a>
                                    <a href="<?= BASE_URL ?>/recipe-duplicate.php?id=<?= urlencode($r['id']) ?>&return_url=<?= urlencode($_SERVER['REQUEST_URI']) ?>" class="btn btn-secondary btn-icon" title="Duplicate Recipe">
                                        <i class="fa-regular fa-copy"></i>
                                    </a>
                                    <button type="button" class="btn btn-danger btn-icon btn-delete-recipe" title="Delete Recipe"
                                        onclick="deleteRecipeAjax(event, '<?= htmlspecialchars($r['id'], ENT_QUOTES) ?>', '<?= htmlspecialchars($r['title'], ENT_QUOTES) ?>')">
                                        <i class="fa-regular fa-trash-can"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<!-- Pagination Links -->
<?php if ($totalPages > 1): ?>
    <div class="pagination">
        <?php
            function build_query_str($p) {
                $params = $_GET;
                $params['page'] = $p;
                return '?' . http_build_query($params);
            }
        ?>
        <?php if ($page > 1): ?>
            <a href="<?= build_query_str(1) ?>" class="page-link" title="First Page">&laquo;</a>
            <a href="<?= build_query_str($page - 1) ?>" class="page-link" title="Previous Page">&lsaquo;</a>
        <?php endif; ?>

        <?php
            $startP = max(1, $page - 3);
            $endP = min($totalPages, $page + 3);
            for ($i = $startP; $i <= $endP; $i++):
        ?>
            <a href="<?= build_query_str($i) ?>" class="page-link <?= $i === $page ? 'active' : '' ?>">
                <?= $i ?>
            </a>
        <?php endfor; ?>

        <?php if ($page < $totalPages): ?>
            <a href="<?= build_query_str($page + 1) ?>" class="page-link" title="Next Page">&rsaquo;</a>
            <a href="<?= build_query_str($totalPages) ?>" class="page-link" title="Last Page">&raquo;</a>
        <?php endif; ?>
    </div>
<?php endif; ?>

<!-- Food CHART WhatsApp Share & Teaser Modal -->
<div class="cm-modal-overlay" id="waShareModalOverlay" onclick="if (event.target === this) closeWaModal();">
    <div class="cm-modal" style="max-width: 620px;">
        <div class="cm-modal-header" style="background: rgba(37, 211, 102, 0.08); border-bottom: 1px solid rgba(37, 211, 102, 0.2);">
            <h3 class="cm-modal-title" style="font-size: 16px;">
                <i class="fa-brands fa-whatsapp" style="color: #25D366; font-size: 20px;"></i>
                <span>Share Recipe on WhatsApp</span>
                <span id="waModalDietBadge" class="badge" style="font-size: 10px;"></span>
            </h3>
            <button type="button" class="cm-modal-close" onclick="closeWaModal()">&times;</button>
        </div>
        <div class="cm-modal-body" style="padding: 20px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; flex-wrap: wrap; gap: 8px;">
                <div>
                    <h4 id="waModalRecipeTitle" style="margin: 0; font-size: 16px; font-weight: 800; color: #FFF;"></h4>
                    <span style="font-size: 11px; color: var(--cm-text-muted);">
                        Customize the promotional message before sharing. Edit words freely!
                    </span>
                </div>
                <div style="display: flex; gap: 6px;" id="waModalTemplateGroup">
                    <button type="button" class="btn btn-secondary btn-sm active" id="btnModalTeaser" onclick="switchModalTemplate('teaser')" style="font-size: 11px; padding: 4px 10px; border-radius: 6px; font-weight: 700;">
                        <i class="fa-solid fa-lock" style="color: #FFB300;"></i> Teaser
                    </button>
                    <button type="button" class="btn btn-secondary btn-sm" id="btnModalCompact" onclick="switchModalTemplate('compact')" style="font-size: 11px; padding: 4px 10px; border-radius: 6px; font-weight: 700;">
                        <i class="fa-solid fa-bolt" style="color: var(--cm-primary);"></i> Compact
                    </button>
                    <button type="button" class="btn btn-secondary btn-sm" id="btnModalFull" onclick="switchModalTemplate('full')" style="font-size: 11px; padding: 4px 10px; border-radius: 6px; font-weight: 700;">
                        <i class="fa-solid fa-book-open" style="color: #4CAF50;"></i> Full
                    </button>
                </div>
            </div>

            <textarea id="waModalEditor" class="form-control" rows="12"
                style="font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace; font-size: 13px; line-height: 1.5; background: #0c0c0c; color: #e9edef; border: 1px solid #2f2f2f; border-radius: 10px; padding: 12px; resize: vertical; width: 100%; box-shadow: inset 0 2px 6px rgba(0,0,0,0.5);"
                oninput="updateModalCharCount()"></textarea>

            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 10px; font-size: 11px; color: var(--cm-text-muted);">
                <span>Includes limited-access ingredients, locked steps, and Food CHART Play Store CTA.</span>
                <span id="waModalCharCount">0 chars</span>
            </div>
        </div>
        <div class="cm-modal-footer" style="padding: 14px 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
            <div style="display: flex; gap: 8px;">
                <button type="button" class="btn btn-secondary btn-sm" id="btnModalSave" onclick="saveModalCustomMessage()" style="color: #81C784; border-color: rgba(76, 175, 80, 0.4); font-weight: 700;">
                    <i class="fa-solid fa-floppy-disk"></i> Save for Recipe
                </button>
                <button type="button" class="btn btn-sm" id="btnModalApplyAll" onclick="applyModalUniversalToAll()" style="color: #FFB300; background: rgba(255, 179, 0, 0.12); border: 1px solid rgba(255, 179, 0, 0.5); font-weight: 800;" title="Apply this promotional message format to ALL recipes with 1 click">
                    <i class="fa-solid fa-wand-magic-sparkles"></i> Apply to All (1-Click)
                </button>
            </div>
            <div style="display: flex; gap: 8px;">
                <button type="button" class="btn btn-secondary btn-sm" onclick="copyModalWaText()" style="font-weight: 700;">
                    <i class="fa-regular fa-copy"></i> Copy Text
                </button>
                <button type="button" class="btn btn-sm" onclick="sendModalWhatsApp()" style="background: #25D366; border-color: #25D366; color: #FFF; font-weight: 800;">
                    <i class="fa-brands fa-whatsapp"></i> Send via WhatsApp
                </button>
            </div>
        </div>
    </div>
</div>

<script>
let activeRecipeData = null;

function openWaModal(recipeData) {
    activeRecipeData = recipeData;
    const modal = document.getElementById('waShareModalOverlay');
    const titleEl = document.getElementById('waModalRecipeTitle');
    const dietBadge = document.getElementById('waModalDietBadge');
    const editor = document.getElementById('waModalEditor');

    titleEl.textContent = recipeData.title;
    if (recipeData.is_veg) {
        dietBadge.className = 'badge badge-veg';
        dietBadge.textContent = 'Pure Veg 🌱';
    } else {
        dietBadge.className = 'badge badge-nonveg';
        dietBadge.textContent = 'Non-Veg 🍗';
    }

    editor.value = recipeData.teaser || '';
    updateModalCharCount();
    resetModalTemplateButtons();

    modal.classList.add('active');
}

function closeWaModal() {
    const modal = document.getElementById('waShareModalOverlay');
    modal.classList.remove('active');
    activeRecipeData = null;
}

function resetModalTemplateButtons() {
    document.querySelectorAll('#waModalTemplateGroup button').forEach(b => b.classList.remove('active'));
    document.getElementById('btnModalTeaser')?.classList.add('active');
}

function switchModalTemplate(type) {
    if (!activeRecipeData) return;
    const editor = document.getElementById('waModalEditor');

    if (type === 'teaser') {
        editor.value = activeRecipeData.teaser || '';
    } else if (type === 'compact') {
        editor.value = activeRecipeData.compact || '';
    } else if (type === 'full') {
        editor.value = activeRecipeData.full || '';
    }

    document.querySelectorAll('#waModalTemplateGroup button').forEach(b => b.classList.remove('active'));
    document.getElementById('btnModal' + type.charAt(0).toUpperCase() + type.slice(1))?.classList.add('active');
    updateModalCharCount();
}

function updateModalCharCount() {
    const editor = document.getElementById('waModalEditor');
    const countEl = document.getElementById('waModalCharCount');
    if (editor && countEl) {
        countEl.textContent = editor.value.length + ' chars';
    }
}

function sendModalWhatsApp() {
    const editor = document.getElementById('waModalEditor');
    if (!editor) return;
    const text = editor.value.trim();
    if (!text) {
        showRecipesToast('Cannot send empty message!', 'danger');
        return;
    }
    const url = 'https://api.whatsapp.com/send?text=' + encodeURIComponent(text);
    window.open(url, '_blank');
}

function copyModalWaText() {
    const editor = document.getElementById('waModalEditor');
    if (!editor) return;
    const text = editor.value;

    if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(() => {
            showRecipesToast('WhatsApp text copied to clipboard!', 'success');
        }).catch(() => {
            fallbackModalCopy(text);
        });
    } else {
        fallbackModalCopy(text);
    }
}

function fallbackModalCopy(text) {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.left = '-9999px';
    document.body.appendChild(ta);
    ta.select();
    try {
        document.execCommand('copy');
        showRecipesToast('WhatsApp text copied to clipboard!', 'success');
    } catch (err) {
        showRecipesToast('Failed to copy text', 'danger');
    }
    document.body.removeChild(ta);
}

function saveModalCustomMessage() {
    if (!activeRecipeData) return;
    const editor = document.getElementById('waModalEditor');
    const btn = document.getElementById('btnModalSave');
    const text = editor.value.trim();

    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving...';

    const formData = new FormData();
    formData.append('recipe_id', activeRecipeData.id);
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
            activeRecipeData.teaser = text;
            showRecipesToast('Custom WhatsApp message saved for this recipe!', 'success');
            setTimeout(() => {
                btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save for Recipe';
            }, 2000);
        } else {
            btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save for Recipe';
            showRecipesToast('Error saving: ' + (data.message || 'Unknown'), 'danger');
        }
    })
    .catch(err => {
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save for Recipe';
        showRecipesToast('Network error while saving message', 'danger');
    });
}

function applyModalUniversalToAll() {
    const editor = document.getElementById('waModalEditor');
    const btn = document.getElementById('btnModalApplyAll');
    if (!editor || !btn) return;

    const text = editor.value.trim();
    if (!text) {
        showRecipesToast('Cannot apply an empty message template!', 'danger');
        return;
    }

    if (!confirm('Apply this WhatsApp promotional message format and app link to ALL recipes across Food CHART in 1 click?')) {
        return;
    }

    btn.disabled = true;
    const origHtml = btn.innerHTML;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Applying to all...';

    const formData = new FormData();
    if (activeRecipeData && activeRecipeData.id) {
        formData.append('recipe_id', activeRecipeData.id);
    }
    formData.append('share_text', text);

    fetch('<?= BASE_URL ?>/api/apply_universal_share_text.php', {
        method: 'POST',
        body: formData
    })
    .then(r => r.json())
    .then(data => {
        btn.disabled = false;
        if (data.status === 'success') {
            btn.innerHTML = `<i class="fa-solid fa-check" style="color: #25D366;"></i> Done (${data.total_updated || 'All'})!`;
            showRecipesToast(data.message || 'Applied to all recipes successfully!', 'success');
            setTimeout(() => {
                btn.innerHTML = origHtml;
            }, 3000);
        } else {
            btn.innerHTML = origHtml;
            showRecipesToast('Error: ' + (data.message || 'Failed to apply'), 'danger');
        }
    })
    .catch(err => {
        btn.disabled = false;
        btn.innerHTML = origHtml;
        showRecipesToast('Network error while applying universal template', 'danger');
    });
}

function showRecipesToast(message, type = 'success') {
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

// ESC to close modal
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        const modal = document.getElementById('waShareModalOverlay');
        if (modal && modal.classList.contains('active')) {
            closeWaModal();
        }
    }
});

function deleteRecipeAjax(event, id, title) {
    if (event) event.preventDefault();

    if (!confirm('Are you sure you want to permanently delete "' + title + '" from the database?')) {
        return;
    }

    const row = document.getElementById('recipe-row-' + id);
    const deleteBtn = row ? row.querySelector('.btn-delete-recipe') : null;
    const origBtnHtml = deleteBtn ? deleteBtn.innerHTML : '';

    if (deleteBtn) {
        deleteBtn.disabled = true;
        deleteBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';
    }

    const formData = new FormData();
    formData.append('id', id);
    formData.append('ajax', '1');
    formData.append('return_url', window.location.href);

    fetch('<?= BASE_URL ?>/recipe-delete.php', {
        method: 'POST',
        headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'Accept': 'application/json'
        },
        body: formData
    })
    .then(res => {
        if (!res.ok) {
            return res.json().then(errData => { throw new Error(errData.message || 'Server returned ' + res.status); });
        }
        return res.json();
    })
    .then(data => {
        if (data.success) {
            showRecipesToast(data.message || ('Recipe "' + title + '" deleted permanently!'), 'success');
            
            if (row) {
                row.style.transition = 'all 0.35s ease-out';
                row.style.background = 'rgba(229, 9, 20, 0.18)';
                row.style.opacity = '0';
                row.style.transform = 'translateX(35px)';
                
                setTimeout(() => {
                    row.remove();
                    updateRecipeCountsAfterDelete();
                }, 350);
            }
        } else {
            if (deleteBtn) {
                deleteBtn.disabled = false;
                deleteBtn.innerHTML = origBtnHtml;
            }
            showRecipesToast(data.message || 'Failed to delete recipe', 'danger');
        }
    })
    .catch(err => {
        if (deleteBtn) {
            deleteBtn.disabled = false;
            deleteBtn.innerHTML = origBtnHtml;
        }
        showRecipesToast(err.message || 'Network error deleting recipe', 'danger');
    });
}

function updateRecipeCountsAfterDelete() {
    const tableBody = document.querySelector('.admin-table tbody');
    const visibleRows = tableBody ? tableBody.querySelectorAll('tr[id^="recipe-row-"]').length : 0;
    
    // Update "Showing X of Y recipes"
    const countShowingEl = document.getElementById('countShowingNum');
    const countTotalEl = document.getElementById('countTotalNum');
    if (countShowingEl) countShowingEl.textContent = visibleRows;
    if (countTotalEl) {
        let total = parseInt(countTotalEl.textContent.replace(/,/g, ''), 10) || 0;
        if (total > 0) countTotalEl.textContent = (total - 1).toLocaleString();
    }
    
    // Update sidebar badge if exists
    const navBadge = document.getElementById('sidebarRecipesCount');
    if (navBadge) {
        let total = parseInt(navBadge.textContent.replace(/,/g, ''), 10) || 0;
        if (total > 0) navBadge.textContent = total - 1;
    }

    if (visibleRows === 0) {
        if (tableBody) {
            tableBody.innerHTML = `
                <tr>
                    <td colspan="8" style="text-align: center; padding: 48px 20px; color: var(--cm-text-muted);">
                        <i class="fa-solid fa-utensils" style="font-size: 36px; margin-bottom: 12px; display: block; color: var(--cm-primary); opacity: 0.5;"></i>
                        <h4 style="font-size: 16px; margin-bottom: 6px; color: var(--cm-text-secondary);">No more recipes in this category</h4>
                        <p style="font-size: 13px; margin: 0;">All recipes matching your current filter have been removed.</p>
                    </td>
                </tr>
            `;
        }
    }
}
</script>


<?php require_once __DIR__ . '/includes/footer.php'; ?>
