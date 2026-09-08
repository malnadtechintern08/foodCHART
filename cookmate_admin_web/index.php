<?php
/**
 * Food CHART Web Admin - Dashboard
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$pageTitle = 'Dashboard Overview';

// Fetch statistics
$totalRecipes = $pdo->query("SELECT COUNT(*) FROM recipes")->fetchColumn();
$totalVeg = $pdo->query("SELECT COUNT(*) FROM recipes WHERE is_vegetarian = 1")->fetchColumn();
$totalNonVeg = $pdo->query("SELECT COUNT(*) FROM recipes WHERE is_vegetarian = 0")->fetchColumn();
$totalMalnad = $pdo->query("SELECT COUNT(*) FROM recipes WHERE category_id = 'cat_malnad' OR region LIKE '%Malnad%'")->fetchColumn();
$totalCategories = $pdo->query("SELECT COUNT(*) FROM categories")->fetchColumn();

// Fetch category breakdown with counts
$categories = $pdo->query("
    SELECT c.*, COUNT(r.id) AS recipe_count 
    FROM categories c 
    LEFT JOIN recipes r ON c.id = r.category_id 
    GROUP BY c.id 
    ORDER BY c.name ASC
")->fetchAll();

// Fetch 10 most recent / popular recipes
$recentRecipes = $pdo->query("
    SELECT r.*, c.name AS category_name, c.color_hex AS category_color
    FROM recipes r
    LEFT JOIN categories c ON r.category_id = c.id
    ORDER BY r.created_at DESC, r.id DESC
    LIMIT 10
")->fetchAll();

// Query pending submissions
$pendingSubmissions = 0;
try {
    $pendingSubmissions = (int)$pdo->query("SELECT COUNT(*) FROM recipe_submissions WHERE status = 'pending'")->fetchColumn();
} catch (Exception $e) {}

// Query notifications count
$activeNotifications = 0;
$totalNotifications = 0;
try {
    $activeNotifications = (int)$pdo->query("SELECT COUNT(*) FROM notifications WHERE status = 'active'")->fetchColumn();
    $totalNotifications = (int)$pdo->query("SELECT COUNT(*) FROM notifications")->fetchColumn();
} catch (Exception $e) {}

require_once __DIR__ . '/includes/header.php';
?>

<!-- Welcome Banner -->
<div style="margin-bottom: 24px;">
    <h2 style="font-size: 26px; font-weight: 800; margin-bottom: 4px;">
        Welcome to <?= cookmate_brand_html() ?> Admin
    </h2>
    <p style="color: var(--cm-text-secondary); font-size: 14px; margin: 0;">
        Control your culinary catalog, customize recipes, and manage database records.
    </p>
</div>

<?php if ($pendingSubmissions > 0): ?>
    <div style="background: linear-gradient(135deg, rgba(229, 9, 20, 0.2), rgba(229, 9, 20, 0.05)); border: 1px solid rgba(229, 9, 20, 0.4); border-radius: 14px; padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;">
        <div style="display: flex; align-items: center; gap: 14px;">
            <div style="width: 42px; height: 42px; border-radius: 10px; background: var(--cm-primary); color: #FFF; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                <i class="fa-solid fa-bell"></i>
            </div>
            <div>
                <strong style="color: #FFF; font-size: 15px; display: block;">
                    🔔 <?= $pendingSubmissions ?> New Recipe Submission<?= $pendingSubmissions > 1 ? 's' : '' ?> Awaiting Moderation
                </strong>
                <span style="color: #CCC; font-size: 13px;">App users have submitted recipes for review and publication into Food CHART.</span>
            </div>
        </div>
        <a href="<?= BASE_URL ?>/recipe-submissions.php?status=pending" class="btn btn-primary btn-sm" style="padding: 8px 18px;">
            Review Submissions &rarr;
        </a>
    </div>
<?php endif; ?>

<!-- Statistics Overview Cards -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-icon orange">
            <i class="fa-solid fa-utensils"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Total Recipes</span>
            <span class="stat-value"><?= number_format($totalRecipes) ?></span>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon green">
            <i class="fa-solid fa-leaf"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Pure Vegetarian</span>
            <span class="stat-value"><?= number_format($totalVeg) ?></span>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon red">
            <i class="fa-solid fa-drumstick-bite"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Non-Vegetarian</span>
            <span class="stat-value"><?= number_format($totalNonVeg) ?></span>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon malnad">
            <i class="fa-solid fa-mountain-sun"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">🌿 Malnad Special</span>
            <span class="stat-value"><?= number_format($totalMalnad) ?></span>
        </div>
    </div>

    <div class="stat-card" style="cursor: pointer;" onclick="window.location.href='<?= BASE_URL ?>/notifications.php';">
        <div class="stat-icon" style="background: rgba(229, 9, 21, 0.15); color: var(--cm-primary);">
            <i class="fa-solid fa-bell"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Active Broadcasts</span>
            <span class="stat-value"><?= number_format($activeNotifications) ?></span>
        </div>
    </div>
</div>

<!-- Dietary Distribution Progress Bar -->
<div class="card" style="padding: 18px 24px;">
    <div style="display: flex; justify-content: space-between; font-size: 13px; font-weight: 700; margin-bottom: 8px;">
        <span style="color: var(--cm-veg);"><i class="fa-solid fa-circle" style="font-size: 9px;"></i> Vegetarian: <?= $totalRecipes > 0 ? round(($totalVeg / $totalRecipes) * 100) : 0 ?>% (<?= $totalVeg ?> items)</span>
        <span style="color: var(--cm-nonveg);"><i class="fa-solid fa-circle" style="font-size: 9px;"></i> Non-Vegetarian: <?= $totalRecipes > 0 ? round(($totalNonVeg / $totalRecipes) * 100) : 0 ?>% (<?= $totalNonVeg ?> items)</span>
    </div>
    <div style="height: 8px; background: #262626; border-radius: 999px; overflow: hidden; display: flex;">
        <div style="width: <?= $totalRecipes > 0 ? ($totalVeg / $totalRecipes) * 100 : 0 ?>%; background: var(--cm-veg);"></div>
        <div style="width: <?= $totalRecipes > 0 ? ($totalNonVeg / $totalRecipes) * 100 : 0 ?>%; background: var(--cm-nonveg);"></div>
    </div>
</div>

<!-- Category Cards Grid -->
<div class="card">
    <div class="card-header">
        <h2 class="card-title">Explore by Categories</h2>
        <a href="<?= BASE_URL ?>/categories.php" class="btn btn-secondary btn-sm">Manage Categories</a>
    </div>

    <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 16px;">
        <?php foreach ($categories as $cat): ?>
            <?php 
                $hex = !empty($cat['color_hex']) ? str_replace('0xFF', '#', $cat['color_hex']) : '#E50914';
            ?>
            <a href="<?= BASE_URL ?>/recipes.php?category=<?= urlencode($cat['id']) ?>" 
               style="display: flex; flex-direction: column; background: var(--cm-surface); border: 1px solid var(--cm-border); border-radius: 14px; padding: 16px; text-decoration: none; transition: transform 0.2s, border-color 0.2s;"
               onmouseover="this.style.borderColor='<?= $hex ?>'; this.style.transform='translateY(-2px)';"
               onmouseout="this.style.borderColor='var(--cm-border)'; this.style.transform='none';">
                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;">
                    <span style="width: 38px; height: 38px; border-radius: 10px; background: <?= $hex ?>25; color: <?= $hex ?>; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                        <i class="fa-solid fa-utensils"></i>
                    </span>
                    <span class="badge" style="background: <?= $hex ?>20; color: <?= $hex ?>; font-weight: 800;">
                        <?= $cat['recipe_count'] ?> recipes
                    </span>
                </div>
                <div style="font-family: 'Outfit', sans-serif; font-weight: 700; font-size: 15px; color: var(--cm-text-primary);">
                    <?= htmlspecialchars($cat['name']) ?>
                </div>
                <div style="font-size: 12px; color: var(--cm-text-secondary); margin-top: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                    <?= htmlspecialchars($cat['description']) ?>
                </div>
            </a>
        <?php endforeach; ?>
    </div>
</div>

<!-- Recent Recipes Table -->
<div class="card">
    <div class="card-header">
        <h2 class="card-title">Recent Recipes</h2>
        <div style="display: flex; gap: 10px;">
            <a href="<?= BASE_URL ?>/recipes.php" class="btn btn-secondary btn-sm">View All Recipes (<?= $totalRecipes ?>)</a>
            <a href="<?= BASE_URL ?>/recipe-form.php" class="btn btn-primary btn-sm"><i class="fa-solid fa-plus"></i> Add Recipe</a>
        </div>
    </div>

    <div class="table-responsive">
        <table class="admin-table">
            <thead>
                <tr>
                    <th style="width: 60px;">Photo</th>
                    <th>Recipe</th>
                    <th>Category</th>
                    <th>Diet</th>
                    <th>Timing</th>
                    <th>Rating</th>
                    <th style="text-align: right; width: 140px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($recentRecipes as $r): ?>
                    <?php
                        $thumb = !empty($r['image_url']) ? BASE_URL . '/' . ltrim($r['image_url'], '/') : BASE_URL . '/assets/images/app_icon.png';
                        $catColor = !empty($r['category_color']) ? str_replace('0xFF', '#', $r['category_color']) : '#E50914';
                    ?>
                    <tr>
                        <td>
                            <img src="<?= htmlspecialchars($thumb) ?>" 
                                 onerror="this.onerror=null;this.src='<?= BASE_URL ?>/assets/images/app_icon.png';" 
                                 class="recipe-cell-thumb" 
                                 alt="<?= htmlspecialchars($r['title']) ?>">
                        </td>
                        <td>
                            <a href="<?= BASE_URL ?>/recipe-view.php?id=<?= urlencode($r['id']) ?>" class="recipe-cell-title">
                                <?= htmlspecialchars($r['title']) ?>
                            </a>
                            <span class="recipe-cell-sub">
                                <?= htmlspecialchars($r['cuisine']) ?> • by <?= htmlspecialchars($r['chef_name']) ?>
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
                            <span style="font-size: 13px; color: var(--cm-text-secondary);">
                                <i class="fa-regular fa-clock"></i> <?= $r['prep_time_minutes'] + $r['cook_time_minutes'] ?>m
                            </span>
                        </td>
                        <td>
                            <span style="color: var(--cm-gold); font-weight: 700; font-size: 13px;">
                                <i class="fa-solid fa-star"></i> <?= number_format($r['rating'], 1) ?>
                            </span>
                        </td>
                        <td style="text-align: right;">
                            <div style="display: inline-flex; gap: 6px;">
                                <a href="<?= BASE_URL ?>/recipe-view.php?id=<?= urlencode($r['id']) ?>" class="btn btn-secondary btn-icon" title="View Details">
                                    <i class="fa-regular fa-eye"></i>
                                </a>
                                <a href="<?= BASE_URL ?>/recipe-form.php?id=<?= urlencode($r['id']) ?>" class="btn btn-secondary btn-icon" title="Edit Recipe" style="color: var(--cm-primary);">
                                    <i class="fa-regular fa-pen-to-square"></i>
                                </a>
                                <a href="<?= BASE_URL ?>/recipe-delete.php?id=<?= urlencode($r['id']) ?>" class="btn btn-danger btn-icon" title="Delete Recipe" onclick="return confirm('Are you sure you want to delete <?= addslashes($r['title']) ?>?');">
                                    <i class="fa-regular fa-trash-can"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
