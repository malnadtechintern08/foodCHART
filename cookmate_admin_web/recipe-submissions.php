<?php
/**
 * Food CHART Web Admin - Recipe Submissions & Moderation Hub
 * Native Food CHART Design System
 */

require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$pageTitle = 'Recipe Submissions Moderation';
$currentPage = 'recipe-submissions.php';

// Check if table exists, otherwise redirect to automatic migration
try {
    $pdo->query("SELECT 1 FROM recipe_submissions LIMIT 1");
} catch (Exception $e) {
    header("Location: migrate_submissions.php");
    exit;
}

// Stats Counts
$totalSubmissions = (int)$pdo->query("SELECT COUNT(*) FROM recipe_submissions")->fetchColumn();
$pendingCount = (int)$pdo->query("SELECT COUNT(*) FROM recipe_submissions WHERE status = 'pending'")->fetchColumn();
$changesCount = (int)$pdo->query("SELECT COUNT(*) FROM recipe_submissions WHERE status = 'changes_requested'")->fetchColumn();
$publishedCount = (int)$pdo->query("SELECT COUNT(*) FROM recipe_submissions WHERE status = 'published'")->fetchColumn();
$rejectedCount = (int)$pdo->query("SELECT COUNT(*) FROM recipe_submissions WHERE status = 'rejected'")->fetchColumn();

// Filters & Pagination
$statusFilter = trim($_GET['status'] ?? '');
$search = trim($_GET['q'] ?? '');
$page = max(1, (int)($_GET['page'] ?? 1));
$limit = 20;
$offset = ($page - 1) * $limit;

$where = [];
$params = [];

if ($statusFilter !== '' && in_array($statusFilter, ['pending', 'under_review', 'changes_requested', 'approved', 'rejected', 'published'])) {
    $where[] = "s.status = ?";
    $params[] = $statusFilter;
}

if ($search !== '') {
    $where[] = "(s.recipe_name LIKE ? OR u.display_name LIKE ? OR s.author_display_name LIKE ? OR s.cuisine LIKE ?)";
    $term = "%$search%";
    $params[] = $term;
    $params[] = $term;
    $params[] = $term;
    $params[] = $term;
}

$whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

$countStmt = $pdo->prepare("
    SELECT COUNT(*) 
    FROM recipe_submissions s
    LEFT JOIN users u ON s.user_id = u.id
    $whereSql
");
$countStmt->execute($params);
$totalFiltered = (int)$countStmt->fetchColumn();
$totalPages = ceil($totalFiltered / $limit);

$stmt = $pdo->prepare("
    SELECT 
        s.*,
        u.display_name AS user_display_name,
        u.email AS user_email,
        c.name AS category_name,
        c.color_hex AS category_color,
        (SELECT COUNT(*) FROM recipe_submission_ingredients WHERE submission_id = s.id) AS ingredient_count,
        (SELECT COUNT(*) FROM recipe_submission_steps WHERE submission_id = s.id) AS step_count
    FROM recipe_submissions s
    LEFT JOIN users u ON s.user_id = u.id
    LEFT JOIN categories c ON s.category_id = c.id
    $whereSql
    ORDER BY 
        CASE s.status 
            WHEN 'pending' THEN 1 
            WHEN 'changes_requested' THEN 2 
            WHEN 'under_review' THEN 3 
            WHEN 'approved' THEN 4 
            WHEN 'published' THEN 5 
            ELSE 6 
        END,
        s.submitted_at DESC
    LIMIT $limit OFFSET $offset
");
$stmt->execute($params);
$submissions = $stmt->fetchAll();

require_once __DIR__ . '/includes/header.php';
?>

<!-- Header -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
    <div>
        <h1 style="font-size: 24px; font-weight: 800; color: var(--cm-text-primary); margin: 0; display: flex; align-items: center; gap: 10px;">
            <i class="fa-solid fa-inbox" style="color: var(--cm-primary);"></i>
            <span>Recipe Submissions Moderation</span>
        </h1>
        <p style="color: var(--cm-text-muted); font-size: 13px; margin: 6px 0 0;">
            Review user-contributed recipes, moderate content, verify publication consent, and publish directly into Food CHART.
        </p>
    </div>
    <div>
        <a href="<?= BASE_URL ?>/recipes.php" class="btn btn-secondary btn-sm">
            <i class="fa-solid fa-utensils"></i> Browse Main Recipes (200+)
        </a>
    </div>
</div>

<!-- Stats Grid -->
<div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); margin-bottom: 24px;">
    <a href="<?= BASE_URL ?>/recipe-submissions.php?status=pending" style="text-decoration: none;">
        <div class="stat-card" style="<?= $statusFilter === 'pending' ? 'border-color: var(--cm-primary);' : '' ?>">
            <div class="stat-icon red">
                <i class="fa-solid fa-clock"></i>
            </div>
            <div class="stat-info">
                <span class="stat-label">Pending Reviews</span>
                <span class="stat-value" style="color: #FF4D55;"><?= number_format($pendingCount) ?></span>
            </div>
        </div>
    </a>

    <a href="<?= BASE_URL ?>/recipe-submissions.php?status=changes_requested" style="text-decoration: none;">
        <div class="stat-card" style="<?= $statusFilter === 'changes_requested' ? 'border-color: #FFA726;' : '' ?>">
            <div class="stat-icon orange">
                <i class="fa-solid fa-rotate-left"></i>
            </div>
            <div class="stat-info">
                <span class="stat-label">Changes Requested</span>
                <span class="stat-value" style="color: #FFA726;"><?= number_format($changesCount) ?></span>
            </div>
        </div>
    </a>

    <a href="<?= BASE_URL ?>/recipe-submissions.php?status=published" style="text-decoration: none;">
        <div class="stat-card" style="<?= $statusFilter === 'published' ? 'border-color: var(--cm-veg);' : '' ?>">
            <div class="stat-icon green">
                <i class="fa-solid fa-circle-check"></i>
            </div>
            <div class="stat-info">
                <span class="stat-label">Published Community</span>
                <span class="stat-value" style="color: #66BB6A;"><?= number_format($publishedCount) ?></span>
            </div>
        </div>
    </a>

    <a href="<?= BASE_URL ?>/recipe-submissions.php" style="text-decoration: none;">
        <div class="stat-card" style="<?= $statusFilter === '' ? 'border-color: #555;' : '' ?>">
            <div class="stat-icon malnad">
                <i class="fa-solid fa-layer-group"></i>
            </div>
            <div class="stat-info">
                <span class="stat-label">Total Submissions</span>
                <span class="stat-value"><?= number_format($totalSubmissions) ?></span>
            </div>
        </div>
    </a>
</div>

<!-- Filter Tabs Bar -->
<div style="display: flex; gap: 8px; margin-bottom: 16px; overflow-x: auto; padding-bottom: 4px;">
    <?php
    $tabs = [
        '' => ['label' => 'All Submissions', 'count' => $totalSubmissions],
        'pending' => ['label' => 'Pending Review', 'count' => $pendingCount],
        'changes_requested' => ['label' => 'Changes Requested', 'count' => $changesCount],
        'approved' => ['label' => 'Approved (Internal)', 'count' => (int)$pdo->query("SELECT COUNT(*) FROM recipe_submissions WHERE status = 'approved'")->fetchColumn()],
        'published' => ['label' => 'Published in Food CHART', 'count' => $publishedCount],
        'rejected' => ['label' => 'Rejected', 'count' => $rejectedCount],
    ];
    foreach ($tabs as $key => $tab):
        $isActive = ($statusFilter === $key);
    ?>
        <a href="<?= BASE_URL ?>/recipe-submissions.php?status=<?= urlencode($key) ?><?= $search !== '' ? '&q=' . urlencode($search) : '' ?>" 
           style="display: inline-flex; align-items: center; gap: 8px; padding: 8px 16px; border-radius: 10px; text-decoration: none; font-size: 13px; font-weight: 700; transition: all 0.2s; white-space: nowrap; <?= $isActive ? 'background: var(--cm-primary); color: #FFF;' : 'background: #1C1C1C; color: var(--cm-text-secondary); border: 1px solid var(--cm-border);' ?>">
            <span><?= $tab['label'] ?></span>
            <span style="background: rgba(0,0,0,0.25); padding: 2px 7px; border-radius: 8px; font-size: 11px;">
                <?= $tab['count'] ?>
            </span>
        </a>
    <?php endforeach; ?>
</div>

<!-- Search Bar -->
<form method="GET" action="<?= BASE_URL ?>/recipe-submissions.php" class="filter-bar">
    <?php if ($statusFilter !== ''): ?>
        <input type="hidden" name="status" value="<?= htmlspecialchars($statusFilter) ?>">
    <?php endif; ?>
    <div class="search-input-wrapper">
        <i class="fa-solid fa-magnifying-glass search-icon"></i>
        <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" class="form-control" placeholder="Search by recipe title, author name, or cuisine...">
    </div>
    <button type="submit" class="btn btn-primary btn-sm" style="padding: 10px 18px;">
        <i class="fa-solid fa-magnifying-glass"></i> Search
    </button>
    <?php if ($search !== '' || $statusFilter !== ''): ?>
        <a href="<?= BASE_URL ?>/recipe-submissions.php" class="btn btn-secondary btn-sm" style="padding: 10px 14px;">Reset</a>
    <?php endif; ?>
    <div style="color: var(--cm-text-muted); font-size: 13px; margin-left: auto; font-weight: 600;">
        Showing <?= count($submissions) ?> of <?= $totalFiltered ?>
    </div>
</form>

<!-- Submissions Table -->
<div class="table-container">
    <table class="admin-table">
        <thead>
            <tr>
                <th style="padding-left: 20px;">ID</th>
                <th>Recipe Details</th>
                <th>Contributor</th>
                <th>Category</th>
                <th>Public Consent</th>
                <th>Status</th>
                <th>Submitted</th>
                <th style="text-align: right; padding-right: 20px;">Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($submissions)): ?>
                <tr>
                    <td colspan="8" style="text-align: center; padding: 50px; color: var(--cm-text-muted);">
                        <i class="fa-solid fa-inbox" style="font-size: 38px; margin-bottom: 12px; display: block; opacity: 0.4;"></i>
                        No recipe submissions found matching your filters.
                    </td>
                </tr>
            <?php else: ?>
                <?php foreach ($submissions as $sub): ?>
                    <?php
                    // Status Badge Styling
                    $statusBadge = match($sub['status']) {
                        'pending' => ['bg' => 'rgba(255, 152, 0, 0.15)', 'color' => '#FFA726', 'icon' => 'fa-clock', 'text' => 'Pending Review'],
                        'under_review' => ['bg' => 'rgba(33, 150, 243, 0.15)', 'color' => '#42A5F5', 'icon' => 'fa-spinner', 'text' => 'Under Review'],
                        'changes_requested' => ['bg' => 'rgba(255, 112, 67, 0.15)', 'color' => '#FF7043', 'icon' => 'fa-rotate-left', 'text' => 'Changes Requested'],
                        'approved' => ['bg' => 'rgba(76, 175, 80, 0.15)', 'color' => '#81C784', 'icon' => 'fa-check', 'text' => 'Approved (Internal)'],
                        'published' => ['bg' => 'rgba(46, 125, 50, 0.25)', 'color' => '#4CAF50', 'icon' => 'fa-circle-check', 'text' => 'Published in Food CHART'],
                        'rejected' => ['bg' => 'rgba(244, 67, 54, 0.15)', 'color' => '#EF5350', 'icon' => 'fa-ban', 'text' => 'Rejected'],
                        default => ['bg' => '#222', 'color' => '#CCC', 'icon' => 'fa-question', 'text' => $sub['status']]
                    };
                    $catHex = !empty($sub['category_color']) ? str_replace('0xFF', '#', $sub['category_color']) : '#E50914';
                    ?>
                    <tr>
                        <td style="padding-left: 20px; font-weight: 700; color: var(--cm-text-muted); font-family: monospace;">
                            #<?= $sub['id'] ?>
                        </td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 14px;">
                                <?php if (!empty($sub['image'])): ?>
                                    <img src="<?= htmlspecialchars(str_starts_with($sub['image'], 'http') ? $sub['image'] : BASE_URL . '/' . ltrim($sub['image'], '/')) ?>" 
                                         alt="Photo" 
                                         style="width: 48px; height: 48px; border-radius: 8px; object-fit: cover; border: 1px solid var(--cm-border); background: #222;"
                                         onerror="this.src='<?= BASE_URL ?>/assets/images/app_icon.png'">
                                <?php else: ?>
                                    <div style="width: 48px; height: 48px; border-radius: 8px; background: #222; border: 1px solid var(--cm-border); display: flex; align-items: center; justify-content: center; color: #555;">
                                        <i class="fa-solid fa-utensils"></i>
                                    </div>
                                <?php endif; ?>
                                <div>
                                    <a href="<?= BASE_URL ?>/recipe-submission-review.php?id=<?= $sub['id'] ?>" style="font-weight: 700; color: var(--cm-text-primary); text-decoration: none; font-size: 14.5px;" onmouseover="this.style.color='var(--cm-primary)'" onmouseout="this.style.color='var(--cm-text-primary)'">
                                        <?= htmlspecialchars($sub['recipe_name']) ?>
                                    </a>
                                    <div style="display: flex; align-items: center; gap: 10px; margin-top: 4px; font-size: 12px; color: var(--cm-text-muted);">
                                        <span><i class="fa-solid fa-clock" style="font-size: 11px;"></i> <?= (int)$sub['preparation_time'] + (int)$sub['cooking_time'] ?> min</span>
                                        <span>&bull;</span>
                                        <span><?= (int)$sub['ingredient_count'] ?> ingredients</span>
                                        <span>&bull;</span>
                                        <span><?= (int)$sub['step_count'] ?> steps</span>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div style="font-weight: 600; color: #EEE; font-size: 13.5px;">
                                <?= htmlspecialchars($sub['user_display_name'] ?? 'App User') ?>
                            </div>
                            <div style="font-size: 11.5px; color: var(--cm-text-muted); margin-top: 2px;">
                                <?= $sub['show_author_name'] ? 'Shows as: <strong>' . htmlspecialchars($sub['author_display_name'] ?: $sub['user_display_name']) . '</strong>' : '<em>Anonymous</em>' ?>
                            </div>
                        </td>
                        <td>
                            <span class="badge" style="background: <?= $catHex ?>22; color: <?= $catHex ?>; border: 1px solid <?= $catHex ?>55; font-size: 11.5px;">
                                <?= htmlspecialchars($sub['category_name'] ?? 'General') ?>
                            </span>
                        </td>
                        <td>
                            <?php if ($sub['allow_publication']): ?>
                                <span style="display: inline-flex; align-items: center; gap: 5px; color: #4CAF50; font-size: 12.5px; font-weight: 700;">
                                    <i class="fa-solid fa-circle-check"></i> Granted
                                </span>
                            <?php else: ?>
                                <span style="display: inline-flex; align-items: center; gap: 5px; color: #FFB74D; font-size: 12px; font-weight: 600;">
                                    <i class="fa-solid fa-triangle-exclamation"></i> Private Only
                                </span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <span class="badge" style="background: <?= $statusBadge['bg'] ?>; color: <?= $statusBadge['color'] ?>; border: 1px solid <?= $statusBadge['color'] ?>44; font-size: 12px; display: inline-flex; align-items: center; gap: 6px; padding: 4px 10px;">
                                <i class="fa-solid <?= $statusBadge['icon'] ?>" style="font-size: 11px;"></i>
                                <?= $statusBadge['text'] ?>
                            </span>
                        </td>
                        <td style="color: var(--cm-text-muted); font-size: 12px;">
                            <?= date('M j, Y', strtotime($sub['submitted_at'])) ?>
                        </td>
                        <td style="text-align: right; padding-right: 20px;">
                            <a href="<?= BASE_URL ?>/recipe-submission-review.php?id=<?= $sub['id'] ?>" class="btn btn-primary btn-sm" style="padding: 6px 14px; font-size: 12px;">
                                <i class="fa-solid fa-magnifying-glass"></i> Review
                            </a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>

    <!-- Pagination -->
    <?php if ($totalPages > 1): ?>
        <div class="pagination" style="border-top: 1px solid var(--cm-border); padding: 16px 20px; background: rgba(255,255,255,0.01); display: flex; justify-content: space-between; align-items: center;">
            <div style="color: var(--cm-text-muted); font-size: 13px;">
                Page <?= $page ?> of <?= $totalPages ?>
            </div>
            <div style="display: flex; gap: 6px;">
                <?php if ($page > 1): ?>
                    <a class="page-link" href="<?= BASE_URL ?>/recipe-submissions.php?page=<?= $page - 1 ?>&status=<?= urlencode($statusFilter) ?>&q=<?= urlencode($search) ?>">&laquo; Prev</a>
                <?php endif; ?>
                <?php for ($i = max(1, $page - 2); $i <= min($totalPages, $page + 2); $i++): ?>
                    <a class="page-link <?= $i === $page ? 'active' : '' ?>" href="<?= BASE_URL ?>/recipe-submissions.php?page=<?= $i ?>&status=<?= urlencode($statusFilter) ?>&q=<?= urlencode($search) ?>"><?= $i ?></a>
                <?php endfor; ?>
                <?php if ($page < $totalPages): ?>
                    <a class="page-link" href="<?= BASE_URL ?>/recipe-submissions.php?page=<?= $page + 1 ?>&status=<?= urlencode($statusFilter) ?>&q=<?= urlencode($search) ?>">Next &raquo;</a>
                <?php endif; ?>
            </div>
        </div>
    <?php endif; ?>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
