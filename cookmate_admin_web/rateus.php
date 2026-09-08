<?php
/**
 * Food CHART Web Admin - App Ratings & Feedback (Rate Us) Manager
 * 
 * Displays and manages reviews submitted from the mobile app's Rate Us screen
 * (specifically focused on 1, 2, and 3 star feedback).
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

// Auto-ensure app_ratings table exists
try {
    $pdo->query("SELECT 1 FROM app_ratings LIMIT 1");
} catch (Throwable $e) {
    $migrationFile = __DIR__ . '/migrations/005_create_app_ratings.sql';
    if (file_exists($migrationFile)) {
        $pdo->exec(file_get_contents($migrationFile));
    } else {
        $pdo->exec("
            CREATE TABLE IF NOT EXISTS `app_ratings` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `stars` INT NOT NULL,
                `category` VARCHAR(100) DEFAULT 'General',
                `feedback_text` TEXT NOT NULL,
                `user_name` VARCHAR(150) DEFAULT 'App User',
                `user_email` VARCHAR(150) DEFAULT NULL,
                `device_info` VARCHAR(255) DEFAULT NULL,
                `app_version` VARCHAR(50) DEFAULT '2.0.0',
                `status` ENUM('new', 'reviewed', 'resolved', 'archived') DEFAULT 'new',
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                INDEX `idx_stars` (`stars`),
                INDEX `idx_status` (`status`),
                INDEX `idx_created_at` (`created_at`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        ");
    }
}

$pageTitle = 'Rate Us Feedback & Reviews';

// Handle Actions (Delete / Status Change)
$action = $_GET['action'] ?? '';
$id = (int)($_GET['id'] ?? 0);

if ($id > 0 && !empty($action)) {
    try {
        if ($action === 'delete') {
            $stmt = $pdo->prepare("DELETE FROM app_ratings WHERE id = ?");
            $stmt->execute([$id]);
            set_flash_message('success', 'Rating review deleted successfully.');
        } elseif (in_array($action, ['new', 'reviewed', 'resolved', 'archived'])) {
            $stmt = $pdo->prepare("UPDATE app_ratings SET status = ? WHERE id = ?");
            $stmt->execute([$action, $id]);
            set_flash_message('success', "Review marked as " . htmlspecialchars(ucfirst($action)) . ".");
        }
    } catch (Throwable $e) {
        set_flash_message('danger', 'Error updating review: ' . $e->getMessage());
    }
    header('Location: ' . BASE_URL . '/rateus.php');
    exit;
}

// Filter parameters
$starsFilter = isset($_GET['stars']) && $_GET['stars'] !== '' ? (int)$_GET['stars'] : null;
$statusFilter = trim($_GET['status'] ?? '');
$search = trim($_GET['q'] ?? '');

$where = [];
$params = [];

if ($starsFilter !== null && $starsFilter >= 1 && $starsFilter <= 5) {
    $where[] = "stars = ?";
    $params[] = $starsFilter;
}

if (!empty($statusFilter)) {
    $where[] = "status = ?";
    $params[] = $statusFilter;
}

if (!empty($search)) {
    $where[] = "(feedback_text LIKE ? OR user_name LIKE ? OR user_email LIKE ? OR category LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

$whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';
$stmt = $pdo->prepare("SELECT * FROM app_ratings $whereSql ORDER BY created_at DESC");
$stmt->execute($params);
$ratings = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Calculate Statistics
$totalReviews = (int)$pdo->query("SELECT COUNT(*) FROM app_ratings")->fetchColumn();
$newReviewsCount = (int)$pdo->query("SELECT COUNT(*) FROM app_ratings WHERE status = 'new'")->fetchColumn();
$oneStarCount = (int)$pdo->query("SELECT COUNT(*) FROM app_ratings WHERE stars = 1")->fetchColumn();
$twoStarCount = (int)$pdo->query("SELECT COUNT(*) FROM app_ratings WHERE stars = 2")->fetchColumn();
$threeStarCount = (int)$pdo->query("SELECT COUNT(*) FROM app_ratings WHERE stars = 3")->fetchColumn();
$avgStars = (float)$pdo->query("SELECT COALESCE(AVG(stars), 0) FROM app_ratings")->fetchColumn();

require_once __DIR__ . '/includes/header.php';
?>

<!-- Header / Title Bar -->
<div class="content-header" style="margin-bottom: 24px;">
    <div>
        <h1 class="page-title" style="display: flex; align-items: center; gap: 10px;">
            <i class="fa-solid fa-star-half-stroke" style="color: #FFB300;"></i>
            Rate Us Reviews (1–3 Stars)
        </h1>
        <p class="page-description" style="color: var(--cm-text-muted); margin: 4px 0 0 0; font-size: 14px;">
            Feedback submitted from users who rated Food CHART 1, 2, or 3 stars. Use these insights to address pain points and enhance the user experience.
        </p>
    </div>
</div>

<!-- Stats Row -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px;">
    <!-- Total Reviews -->
    <div class="stat-card" style="background: var(--cm-card-bg); border: 1px solid var(--cm-border); border-radius: 12px; padding: 20px; display: flex; align-items: center; gap: 16px;">
        <div style="width: 50px; height: 50px; border-radius: 12px; background: rgba(229, 9, 21, 0.12); color: var(--cm-primary); display: flex; align-items: center; justify-content: center; font-size: 24px;">
            <i class="fa-solid fa-comments"></i>
        </div>
        <div>
            <div style="font-size: 24px; font-weight: 800; line-height: 1.1; color: var(--cm-text-primary);"><?= $totalReviews ?></div>
            <div style="font-size: 13px; color: var(--cm-text-muted); margin-top: 4px;">Total App Reviews</div>
        </div>
    </div>

    <!-- 1-Star Reviews -->
    <a href="<?= BASE_URL ?>/rateus.php?stars=1" style="text-decoration: none; display: block;">
        <div class="stat-card" style="background: var(--cm-card-bg); border: 1px solid <?= $starsFilter === 1 ? 'var(--cm-primary)' : 'var(--cm-border)' ?>; border-radius: 12px; padding: 20px; display: flex; align-items: center; gap: 16px; transition: transform 0.2s;">
            <div style="width: 50px; height: 50px; border-radius: 12px; background: rgba(229, 9, 21, 0.15); color: #E50914; display: flex; align-items: center; justify-content: center; font-size: 22px;">
                ★
            </div>
            <div>
                <div style="font-size: 24px; font-weight: 800; line-height: 1.1; color: #E50914;"><?= $oneStarCount ?></div>
                <div style="font-size: 13px; color: var(--cm-text-muted); margin-top: 4px;">1 Star (Critical)</div>
            </div>
        </div>
    </a>

    <!-- 2-Star Reviews -->
    <a href="<?= BASE_URL ?>/rateus.php?stars=2" style="text-decoration: none; display: block;">
        <div class="stat-card" style="background: var(--cm-card-bg); border: 1px solid <?= $starsFilter === 2 ? '#FF9800' : 'var(--cm-border)' ?>; border-radius: 12px; padding: 20px; display: flex; align-items: center; gap: 16px; transition: transform 0.2s;">
            <div style="width: 50px; height: 50px; border-radius: 12px; background: rgba(255, 152, 0, 0.15); color: #FF9800; display: flex; align-items: center; justify-content: center; font-size: 20px;">
                ★★
            </div>
            <div>
                <div style="font-size: 24px; font-weight: 800; line-height: 1.1; color: #FF9800;"><?= $twoStarCount ?></div>
                <div style="font-size: 13px; color: var(--cm-text-muted); margin-top: 4px;">2 Stars (Needs Work)</div>
            </div>
        </div>
    </a>

    <!-- 3-Star Reviews -->
    <a href="<?= BASE_URL ?>/rateus.php?stars=3" style="text-decoration: none; display: block;">
        <div class="stat-card" style="background: var(--cm-card-bg); border: 1px solid <?= $starsFilter === 3 ? '#FFB300' : 'var(--cm-border)' ?>; border-radius: 12px; padding: 20px; display: flex; align-items: center; gap: 16px; transition: transform 0.2s;">
            <div style="width: 50px; height: 50px; border-radius: 12px; background: rgba(255, 179, 0, 0.15); color: #FFB300; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                ★★★
            </div>
            <div>
                <div style="font-size: 24px; font-weight: 800; line-height: 1.1; color: #FFB300;"><?= $threeStarCount ?></div>
                <div style="font-size: 13px; color: var(--cm-text-muted); margin-top: 4px;">3 Stars (Average)</div>
            </div>
        </div>
    </a>

    <!-- Average Rating -->
    <div class="stat-card" style="background: var(--cm-card-bg); border: 1px solid var(--cm-border); border-radius: 12px; padding: 20px; display: flex; align-items: center; gap: 16px;">
        <div style="width: 50px; height: 50px; border-radius: 12px; background: rgba(76, 175, 80, 0.15); color: #4CAF50; display: flex; align-items: center; justify-content: center; font-size: 22px;">
            <i class="fa-solid fa-chart-line"></i>
        </div>
        <div>
            <div style="font-size: 24px; font-weight: 800; line-height: 1.1; color: var(--cm-text-primary);">
                <?= number_format($avgStars, 1) ?> <span style="font-size: 14px; color: #FFB300;">★</span>
            </div>
            <div style="font-size: 13px; color: var(--cm-text-muted); margin-top: 4px;">Average Rating</div>
        </div>
    </div>
</div>

<!-- Toolbar: Filter Tabs & Search -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 14px;">
    <!-- Rating & Status Filter Chips -->
    <div style="display: flex; gap: 8px; flex-wrap: wrap;">
        <a href="<?= BASE_URL ?>/rateus.php" class="btn btn-sm <?= ($starsFilter === null && empty($statusFilter)) ? 'btn-primary' : 'btn-secondary' ?>">
            All (<?= $totalReviews ?>)
        </a>
        <a href="<?= BASE_URL ?>/rateus.php?stars=1" class="btn btn-sm <?= $starsFilter === 1 ? 'btn-primary' : 'btn-secondary' ?>" style="<?= $oneStarCount > 0 ? 'border-color: #E50914; color: #E50914;' : '' ?>">
            ★ 1 Star (<?= $oneStarCount ?>)
        </a>
        <a href="<?= BASE_URL ?>/rateus.php?stars=2" class="btn btn-sm <?= $starsFilter === 2 ? 'btn-primary' : 'btn-secondary' ?>" style="<?= $twoStarCount > 0 ? 'border-color: #FF9800; color: #FF9800;' : '' ?>">
            ★★ 2 Stars (<?= $twoStarCount ?>)
        </a>
        <a href="<?= BASE_URL ?>/rateus.php?stars=3" class="btn btn-sm <?= $starsFilter === 3 ? 'btn-primary' : 'btn-secondary' ?>" style="<?= $threeStarCount > 0 ? 'border-color: #FFB300; color: #FFB300;' : '' ?>">
            ★★★ 3 Stars (<?= $threeStarCount ?>)
        </a>
        <a href="<?= BASE_URL ?>/rateus.php?status=new" class="btn btn-sm <?= $statusFilter === 'new' ? 'btn-primary' : 'btn-secondary' ?>" style="<?= $newReviewsCount > 0 ? 'border-color: #2196F3; color: #2196F3;' : '' ?>">
            <i class="fa-solid fa-bell"></i> New (<?= $newReviewsCount ?>)
        </a>
    </div>

    <!-- Search Form -->
    <form method="GET" style="display: flex; gap: 8px;">
        <?php if ($starsFilter !== null): ?>
            <input type="hidden" name="stars" value="<?= $starsFilter ?>">
        <?php endif; ?>
        <?php if (!empty($statusFilter)): ?>
            <input type="hidden" name="status" value="<?= htmlspecialchars($statusFilter) ?>">
        <?php endif; ?>
        <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" class="form-control form-control-sm" placeholder="Search reviews..." style="width: 230px;">
        <button type="submit" class="btn btn-primary btn-sm">Search</button>
        <?php if (!empty($search) || $starsFilter !== null || !empty($statusFilter)): ?>
            <a href="<?= BASE_URL ?>/rateus.php" class="btn btn-secondary btn-sm">Reset</a>
        <?php endif; ?>
    </form>
</div>

<!-- Reviews List -->
<div class="card" style="padding: 0; overflow: hidden;">
    <div style="padding: 20px 24px; border-bottom: 1px solid var(--cm-border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
        <h2 class="card-title" style="margin: 0; font-size: 17px;">
            Submitted App Reviews (<?= count($ratings) ?>)
        </h2>
        <span style="font-size: 13px; color: var(--cm-text-muted);">
            Filtered: <?= $starsFilter ? "$starsFilter-Star only" : "All ratings" ?>
        </span>
    </div>

    <?php if (empty($ratings)): ?>
        <div style="padding: 60px 20px; text-align: center; color: var(--cm-text-muted);">
            <div style="width: 64px; height: 64px; border-radius: 50%; background: rgba(255, 179, 0, 0.1); color: #FFB300; display: inline-flex; align-items: center; justify-content: center; font-size: 28px; margin-bottom: 16px;">
                <i class="fa-solid fa-star-half-stroke"></i>
            </div>
            <h3 style="margin: 0 0 8px 0; font-size: 16px; color: var(--cm-text-primary);">No reviews found</h3>
            <p style="margin: 0; font-size: 14px; max-width: 400px; margin-inline: auto;">
                <?php if (!empty($search) || $starsFilter !== null || !empty($statusFilter)): ?>
                    No feedback matching your current filter. Try resetting filters.
                <?php else: ?>
                    When users rate the app 1, 2, or 3 stars from the Rate Us screen, their constructive feedback will appear here.
                <?php endif; ?>
            </p>
        </div>
    <?php else: ?>
        <div style="padding: 16px 20px;">
            <?php foreach ($ratings as $r): ?>
                <?php
                $stars = (int)$r['stars'];
                $starColor = $stars === 1 ? '#E50914' : ($stars === 2 ? '#FF9800' : ($stars === 3 ? '#FFB300' : '#4CAF50'));
                $status = $r['status'];
                $statusColor = $status === 'new' ? '#2196F3' : ($status === 'reviewed' ? '#FF9800' : '#4CAF50');
                ?>
                <div style="background: rgba(255,255,255,0.02); border: 1px solid <?= $status === 'new' ? 'rgba(33, 150, 243, 0.35)' : 'var(--cm-border)' ?>; border-radius: 12px; padding: 20px; margin-bottom: 16px; transition: border-color 0.2s;">
                    <!-- Top row: Stars, Category, Status, Actions -->
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 14px; flex-wrap: wrap; margin-bottom: 12px;">
                        <div style="display: flex; align-items: center; gap: 12px; flex-wrap: wrap;">
                            <!-- Star Badge -->
                            <div style="background: rgba(0,0,0,0.25); border: 1px solid <?= $starColor ?>; padding: 4px 10px; border-radius: 8px; display: inline-flex; align-items: center; gap: 4px;">
                                <span style="color: <?= $starColor ?>; font-size: 16px; letter-spacing: 2px;">
                                    <?= str_repeat('★', $stars) ?><span style="color: rgba(255,255,255,0.2);"><?= str_repeat('☆', 5 - $stars) ?></span>
                                </span>
                                <span style="font-size: 13px; font-weight: 800; color: <?= $starColor ?>; margin-left: 4px;">
                                    <?= $stars ?>/5
                                </span>
                            </div>

                            <!-- Category Badge -->
                            <span style="background: rgba(255,255,255,0.06); color: var(--cm-text-primary); border: 1px solid var(--cm-border); padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 600;">
                                <i class="fa-solid fa-tag" style="margin-right: 4px; opacity: 0.6;"></i>
                                <?= htmlspecialchars($r['category'] ?? 'General') ?>
                            </span>

                            <!-- Status Badge -->
                            <span style="background: <?= $statusColor ?>20; color: <?= $statusColor ?>; border: 1px solid <?= $statusColor ?>60; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; text-transform: uppercase;">
                                <?= htmlspecialchars($status) ?>
                            </span>
                        </div>

                        <!-- Action Controls -->
                        <div style="display: flex; gap: 8px; align-items: center;">
                            <?php if ($status === 'new'): ?>
                                <a href="<?= BASE_URL ?>/rateus.php?action=reviewed&id=<?= $r['id'] ?>" class="btn btn-sm btn-secondary" title="Mark as Reviewed" style="font-size: 12px;">
                                    <i class="fa-solid fa-check"></i> Mark Reviewed
                                </a>
                            <?php elseif ($status === 'reviewed'): ?>
                                <a href="<?= BASE_URL ?>/rateus.php?action=resolved&id=<?= $r['id'] ?>" class="btn btn-sm btn-secondary" title="Mark as Resolved" style="font-size: 12px; color: #4CAF50;">
                                    <i class="fa-solid fa-circle-check"></i> Resolve
                                </a>
                            <?php endif; ?>

                            <a href="<?= BASE_URL ?>/rateus.php?action=delete&id=<?= $r['id'] ?>" class="btn btn-sm btn-secondary" onclick="return confirm('Are you sure you want to delete this rating feedback?');" title="Delete Review" style="font-size: 12px; color: #E50914;">
                                <i class="fa-solid fa-trash"></i>
                            </a>
                        </div>
                    </div>

                    <!-- Feedback Text Content -->
                    <div style="background: rgba(0,0,0,0.18); border-left: 3px solid <?= $starColor ?>; padding: 14px 16px; border-radius: 0 8px 8px 0; margin-bottom: 14px; font-size: 14px; line-height: 1.6; color: var(--cm-text-primary);">
                        <?= nl2br(htmlspecialchars($r['feedback_text'])) ?>
                    </div>

                    <!-- Metadata Footer: User, Email, Device, Date -->
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; font-size: 12px; color: var(--cm-text-muted);">
                        <div style="display: flex; gap: 16px; flex-wrap: wrap; align-items: center;">
                            <span>
                                <i class="fa-solid fa-user" style="margin-right: 5px; opacity: 0.7;"></i>
                                <strong style="color: var(--cm-text-primary);"><?= htmlspecialchars($r['user_name'] ?? 'Food CHART User') ?></strong>
                            </span>
                            <?php if (!empty($r['user_email'])): ?>
                                <span>
                                    <i class="fa-solid fa-envelope" style="margin-right: 5px; opacity: 0.7;"></i>
                                    <a href="mailto:<?= htmlspecialchars($r['user_email']) ?>" style="color: var(--cm-text-muted); text-decoration: underline;">
                                        <?= htmlspecialchars($r['user_email']) ?>
                                    </a>
                                </span>
                            <?php endif; ?>
                            <?php if (!empty($r['app_version'])): ?>
                                <span>
                                    <i class="fa-solid fa-code-branch" style="margin-right: 5px; opacity: 0.7;"></i>
                                    v<?= htmlspecialchars($r['app_version']) ?>
                                </span>
                            <?php endif; ?>
                            <?php if (!empty($r['device_info'])): ?>
                                <span>
                                    <i class="fa-solid fa-mobile-screen" style="margin-right: 5px; opacity: 0.7;"></i>
                                    <?= htmlspecialchars($r['device_info']) ?>
                                </span>
                            <?php endif; ?>
                        </div>

                        <div>
                            <i class="fa-regular fa-clock" style="margin-right: 5px; opacity: 0.7;"></i>
                            <?= date('M d, Y • h:i A', strtotime($r['created_at'])) ?>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
