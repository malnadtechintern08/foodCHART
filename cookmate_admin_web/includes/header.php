<?php
/**
 * Food CHART Web Admin - Global Header & Navigation Shell
 */
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/admin_auth.php';
require_admin_login();

$currentAdmin = get_logged_in_admin();

if (!isset($currentPage) || empty($currentPage)) {
    $currentPage = basename($_SERVER['PHP_SELF'] ?? '');
}
$flash = get_flash_message();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= isset($pageTitle) ? htmlspecialchars($pageTitle) . ' • ' : '' ?>Food CHART Admin</title>
    <link rel="icon" type="image/png" href="<?= BASE_URL ?>/assets/images/app_icon.png">
    
    <!-- Google Fonts: Outfit (brand) & Plus Jakarta Sans (UI) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800;900&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Food CHART Admin Brand CSS with cache buster -->
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/admin.css?v=<?= file_exists(__DIR__ . '/../assets/css/admin.css') ? filemtime(__DIR__ . '/../assets/css/admin.css') : time() ?>">
</head>
<body>

    <!-- Sidebar Navigation -->
    <aside class="admin-sidebar" id="adminSidebar">
        <div class="sidebar-header">
            <img src="<?= BASE_URL ?>/assets/images/foodchart_logo.png" alt="Food CHART Logo" class="sidebar-logo">
            <div class="sidebar-brand-title">
                <span class="brand-foodchart"><span class="food-part">Food </span><span class="chart-part">CHART</span></span>
                <span class="sidebar-brand-subtitle">Admin Hub</span>
            </div>
        </div>

        <nav class="sidebar-nav">
            <div class="nav-section-label">Management</div>
            
            <a href="<?= BASE_URL ?>/index.php" class="nav-item <?= $currentPage === 'index.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-gauge-high"></i>
                <span>Dashboard</span>
            </a>

            <?php
            $totalRecipeCount = 0;
            try {
                if (!isset($pdo) || !$pdo) {
                    $pdo = get_db_connection();
                }
                $totalRecipeCount = (int)$pdo->query("SELECT COUNT(*) FROM recipes")->fetchColumn();
            } catch (Throwable $e) {}
            ?>
            <a href="<?= BASE_URL ?>/recipes.php" class="nav-item <?= in_array($currentPage, ['recipes.php', 'recipe-view.php']) ? 'active' : '' ?>">
                <i class="fa-solid fa-utensils"></i>
                <span>All Recipes (<?= $totalRecipeCount ?>)</span>
            </a>

            <?php
            $pendingCount = 0;
            try {
                if (!isset($pdo) || !$pdo) {
                    $pdo = get_db_connection();
                }
                $pendingCount = (int)$pdo->query("SELECT COUNT(*) FROM recipe_submissions WHERE status = 'pending'")->fetchColumn();
            } catch (Throwable $e) {}
            ?>
            <a href="<?= BASE_URL ?>/recipe-submissions.php" class="nav-item <?= in_array($currentPage, ['recipe-submissions.php', 'recipe-submission-review.php']) ? 'active' : '' ?>">
                <i class="fa-solid fa-inbox"></i>
                <span style="flex: 1;">Recipe Submissions</span>
                <?php if ($pendingCount > 0): ?>
                    <span style="background: var(--cm-primary); color: #FFF; font-size: 11px; font-weight: 800; padding: 2px 7px; border-radius: 10px; line-height: 1;">
                        <?= $pendingCount ?>
                    </span>
                <?php endif; ?>
            </a>

            <a href="<?= BASE_URL ?>/recipe-form.php" class="nav-item <?= $currentPage === 'recipe-form.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-circle-plus"></i>
                <span>Add New Recipe</span>
            </a>

            <a href="<?= BASE_URL ?>/categories.php" class="nav-item <?= $currentPage === 'categories.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-layer-group"></i>
                <span>Categories</span>
            </a>

            <a href="<?= BASE_URL ?>/hashtags.php" class="nav-item <?= $currentPage === 'hashtags.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-hashtag"></i>
                <span>Hashtags</span>
            </a>

            <?php
            $activeNotifCount = 0;
            try {
                $activeNotifCount = (int)$pdo->query("SELECT COUNT(*) FROM notifications WHERE status = 'active'")->fetchColumn();
            } catch (Exception $e) {}
            ?>
            <a href="<?= BASE_URL ?>/notifications.php" class="nav-item <?= in_array($currentPage, ['notifications.php']) ? 'active' : '' ?>">
                <i class="fa-solid fa-bell"></i>
                <span style="flex: 1;">Notifications</span>
                <?php if ($activeNotifCount > 0): ?>
                    <span style="background: rgba(229, 9, 21, 0.2); color: var(--cm-primary); border: 1px solid var(--cm-primary); font-size: 11px; font-weight: 800; padding: 2px 7px; border-radius: 10px; line-height: 1;">
                        <?= $activeNotifCount ?>
                    </span>
                <?php endif; ?>
            </a>

            <div class="nav-section-label">Legal & Support</div>

            <a href="<?= BASE_URL ?>/support_pages.php" class="nav-item <?= in_array($currentPage, ['support_pages.php', 'support_page_edit.php']) ? 'active' : '' ?>">
                <i class="fa-solid fa-file-shield"></i>
                <span>Policy & Pages</span>
            </a>

            <a href="<?= BASE_URL ?>/faqs.php" class="nav-item <?= in_array($currentPage, ['faqs.php']) ? 'active' : '' ?>">
                <i class="fa-solid fa-circle-question"></i>
                <span>FAQ Manager</span>
            </a>

            <?php
            $newInquiriesCount = 0;
            try {
                $newInquiriesCount = (int)$pdo->query("SELECT COUNT(*) FROM contact_inquiries WHERE status = 'new'")->fetchColumn();
            } catch (Exception $e) {}
            ?>
            <a href="<?= BASE_URL ?>/contact_inquiries.php" class="nav-item <?= in_array($currentPage, ['contact_inquiries.php']) ? 'active' : '' ?>">
                <i class="fa-solid fa-envelope-open-text"></i>
                <span style="flex: 1;">Contact Inquiries</span>
                <?php if ($newInquiriesCount > 0): ?>
                    <span style="background: rgba(255, 160, 0, 0.2); color: #FFA000; border: 1px solid #FFA000; font-size: 11px; font-weight: 800; padding: 2px 7px; border-radius: 10px; line-height: 1;">
                        <?= $newInquiriesCount ?>
                    </span>
                <?php endif; ?>
            </a>

            <?php
            $newRatingsCount = 0;
            try {
                $newRatingsCount = (int)$pdo->query("SELECT COUNT(*) FROM app_ratings WHERE status = 'new'")->fetchColumn();
            } catch (Throwable $e) {}
            ?>
            <a href="<?= BASE_URL ?>/rateus.php" class="nav-item <?= in_array($currentPage, ['rateus.php']) ? 'active' : '' ?>">
                <i class="fa-solid fa-star-half-stroke"></i>
                <span style="flex: 1;">Rate Us Reviews</span>
                <?php if ($newRatingsCount > 0): ?>
                    <span style="background: rgba(255, 179, 0, 0.2); color: #FFB300; border: 1px solid #FFB300; font-size: 11px; font-weight: 800; padding: 2px 7px; border-radius: 10px; line-height: 1;">
                        <?= $newRatingsCount ?>
                    </span>
                <?php endif; ?>
            </a>

            <div class="nav-section-label">Data & Database</div>

            <a href="<?= BASE_URL ?>/db_test.php" class="nav-item <?= $currentPage === 'db_test.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-stethoscope"></i>
                <span>DB Diagnostics</span>
            </a>

            <a href="<?= BASE_URL ?>/export.php" class="nav-item <?= $currentPage === 'export.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-file-export"></i>
                <span>Export JSON / Dart</span>
            </a>

            <a href="<?= BASE_URL ?>/setup_db.php" class="nav-item <?= $currentPage === 'setup_db.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-arrows-rotate"></i>
                <span>Seed / Reset DB</span>
            </a>

            <div class="nav-section-label">Account</div>

            <a href="<?= BASE_URL ?>/logout.php" class="nav-item" style="color: #FF5252;" onclick="return confirm('Are you sure you want to sign out of Food CHART Admin?');">
                <i class="fa-solid fa-right-from-bracket" style="color: #FF5252;"></i>
                <span>Sign Out</span>
            </a>
        </nav>

        <div class="sidebar-footer">
            <div style="padding: 10px 12px; background: rgba(255, 255, 255, 0.03); border-radius: 10px; margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between; border: 1px solid var(--cm-border);">
                <div style="display: flex; align-items: center; gap: 10px; overflow: hidden;">
                    <div style="width: 32px; height: 32px; border-radius: 8px; background: var(--cm-primary); color: #FFF; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px; flex-shrink: 0;">
                        <?= strtoupper(substr($currentAdmin['username'] ?? 'A', 0, 1)) ?>
                    </div>
                    <div style="overflow: hidden; line-height: 1.2;">
                        <div style="font-size: 13px; font-weight: 700; color: #FFF; white-space: nowrap; text-overflow: ellipsis; overflow: hidden;">
                            <?= htmlspecialchars(str_ireplace(['CookMate Administrator', 'CookMate'], ['Food CHART Admin', 'Food CHART'], $currentAdmin['full_name'] ?? 'Food CHART Admin')) ?>
                        </div>
                        <div style="font-size: 11px; color: var(--cm-text-muted);">
                            @<?= htmlspecialchars($currentAdmin['username'] ?? 'admin') ?>
                        </div>
                    </div>
                </div>
                <a href="<?= BASE_URL ?>/logout.php" title="Sign Out" style="color: #FF5252; padding: 6px; font-size: 13px;" onclick="return confirm('Sign out of Food CHART Admin?');">
                    <i class="fa-solid fa-right-from-bracket"></i>
                </a>
            </div>

            <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="pma-badge-btn" title="Open Food CHART Database in phpMyAdmin">
                <span><i class="fa-solid fa-database"></i> phpMyAdmin DB</span>
                <i class="fa-solid fa-arrow-up-right-from-square" style="font-size: 10px;"></i>
            </a>
            
            <div style="display: flex; align-items: center; gap: 8px; font-size: 11px; color: var(--cm-text-muted); padding: 4px 6px;">
                <span style="width: 8px; height: 8px; border-radius: 50%; background: #4CAF50; display: inline-block; box-shadow: 0 0 8px #4CAF50;"></span>
                <span>MySQL: <code>Food CHART DB</code></span>
            </div>
        </div>
    </aside>

    <!-- Main Container -->
    <div class="admin-main">
        <header class="admin-header">
            <div style="display: flex; align-items: center; gap: 14px;">
                <button id="sidebarToggle" class="btn btn-secondary btn-icon" style="display: none;" title="Toggle Sidebar">
                    <i class="fa-solid fa-bars"></i>
                </button>
                <h1 class="admin-header-title"><?= isset($pageTitle) ? htmlspecialchars($pageTitle) : 'Admin Dashboard' ?></h1>
            </div>

            <div class="admin-header-actions">
                <a href="<?= BASE_URL ?>/notifications.php" class="btn btn-secondary btn-sm <?= in_array($currentPage, ['notifications.php', 'notifications']) ? 'active' : '' ?>" title="Manage In-App Notifications">
                    <i class="fa-solid fa-bell" style="color: #FF5252;"></i>
                    <span>Notifications</span>
                    <?php if ($activeNotifCount > 0): ?>
                        <span style="background: var(--cm-primary); color: #FFF; font-size: 11px; font-weight: 800; padding: 1px 6px; border-radius: 10px; margin-left: 4px;">
                            <?= $activeNotifCount ?>
                        </span>
                    <?php endif; ?>
                </a>

                <a href="<?= BASE_URL ?>/recipe-form.php" class="btn btn-primary btn-sm">
                    <i class="fa-solid fa-plus"></i>
                    <span>Add Recipe</span>
                </a>
                
                <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="btn btn-secondary btn-sm" title="View in phpMyAdmin">
                    <i class="fa-solid fa-database" style="color: #FFB300;"></i>
                    <span>phpMyAdmin</span>
                </a>

                <a href="<?= BASE_URL ?>/logout.php" class="btn btn-secondary btn-sm" title="Sign Out of Food CHART Admin" onclick="return confirm('Sign out of Food CHART Admin?');" style="color: #FF5252; border-color: rgba(255, 82, 82, 0.3);">
                    <i class="fa-solid fa-right-from-bracket"></i>
                    <span>Logout</span>
                </a>
            </div>
        </header>

        <main class="admin-content">
            <?php if ($flash): ?>
                <div class="alert alert-<?= htmlspecialchars($flash['type']) ?>">
                    <span><?= htmlspecialchars($flash['message']) ?></span>
                    <button type="button" onclick="this.parentElement.remove()" style="background:none;border:none;color:inherit;cursor:pointer;font-size:16px;">&times;</button>
                </div>
            <?php endif; ?>
