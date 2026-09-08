<?php
/**
 * Food CHART Web Admin - Hashtag Management Page
 * Native Food CHART Design System (No external Bootstrap dependencies)
 */

require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/includes/tag_functions.php';

$pdo = get_db_connection();
$pageTitle = 'Hashtag Management';
$currentPage = 'hashtags.php';

// Handle POST actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = trim($_POST['action'] ?? '');

    if ($action === 'add') {
        $rawName = trim($_POST['tag_name'] ?? '');
        $norm = normalize_tag($rawName);
        if ($norm === '') {
            set_flash_message('danger', 'Please provide a valid hashtag name (letters, numbers, underscores).');
        } else {
            try {
                $stmt = $pdo->prepare("INSERT INTO tags (name, slug, usage_count) VALUES (?, ?, 0)");
                $stmt->execute([$norm, $norm]);
                set_flash_message('success', "Hashtag <strong>#$norm</strong> created successfully!");
            } catch (PDOException $e) {
                if ($e->getCode() == 23000) {
                    set_flash_message('warning', "Hashtag <strong>#$norm</strong> already exists.");
                } else {
                    set_flash_message('danger', 'Database error: ' . $e->getMessage());
                }
            }
        }
        header("Location: " . BASE_URL . "/hashtags.php");
        exit;
    }

    if ($action === 'edit') {
        $tagId = (int)($_POST['tag_id'] ?? 0);
        $rawName = trim($_POST['tag_name'] ?? '');
        $norm = normalize_tag($rawName);

        if ($tagId <= 0 || $norm === '') {
            set_flash_message('danger', 'Invalid tag ID or name.');
        } else {
            try {
                $stmt = $pdo->prepare("UPDATE tags SET name = ?, slug = ? WHERE id = ?");
                $stmt->execute([$norm, $norm, $tagId]);
                set_flash_message('success', "Hashtag updated to <strong>#$norm</strong>!");
            } catch (PDOException $e) {
                if ($e->getCode() == 23000) {
                    set_flash_message('warning', "Hashtag <strong>#$norm</strong> is already used by another tag.");
                } else {
                    set_flash_message('danger', 'Database error: ' . $e->getMessage());
                }
            }
        }
        header("Location: " . BASE_URL . "/hashtags.php");
        exit;
    }

    if ($action === 'delete') {
        $tagId = (int)($_POST['tag_id'] ?? 0);
        if ($tagId > 0) {
            try {
                $stmt = $pdo->prepare("SELECT name FROM tags WHERE id = ?");
                $stmt->execute([$tagId]);
                $tagName = $stmt->fetchColumn();

                $delStmt = $pdo->prepare("DELETE FROM tags WHERE id = ?");
                $delStmt->execute([$tagId]);

                set_flash_message('success', "Hashtag <strong>#" . htmlspecialchars($tagName) . "</strong> deleted and unlinked safely.");
            } catch (Exception $e) {
                set_flash_message('danger', 'Error deleting tag: ' . $e->getMessage());
            }
        }
        header("Location: " . BASE_URL . "/hashtags.php");
        exit;
    }

    if ($action === 'recalculate') {
        recalculate_all_tag_usage_counts($pdo);
        set_flash_message('success', 'All hashtag usage counts recalculated and verified!');
        header("Location: " . BASE_URL . "/hashtags.php");
        exit;
    }
}

// Stats
$totalTags = (int)$pdo->query("SELECT COUNT(*) FROM tags")->fetchColumn();
$totalTaggedRecipes = (int)$pdo->query("SELECT COUNT(DISTINCT recipe_id) FROM recipe_tags")->fetchColumn();
$topTagRow = $pdo->query("SELECT name, usage_count FROM tags ORDER BY usage_count DESC LIMIT 1")->fetch();

// Filtering & Pagination
$q = trim($_GET['q'] ?? '');
$limit = 25;
$page = max(1, (int)($_GET['page'] ?? 1));
$offset = ($page - 1) * $limit;

$where = [];
$params = [];
if ($q !== '') {
    $normQ = normalize_tag($q);
    $where[] = "(name LIKE ? OR slug LIKE ?)";
    $term = "%$normQ%";
    $params[] = $term;
    $params[] = $term;
}

$whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

$countStmt = $pdo->prepare("SELECT COUNT(*) FROM tags $whereSql");
$countStmt->execute($params);
$filteredTotal = (int)$countStmt->fetchColumn();
$totalPages = ceil($filteredTotal / $limit);

$stmt = $pdo->prepare("
    SELECT t.*, 
           (SELECT COUNT(*) FROM recipe_tags rt WHERE rt.tag_id = t.id) as real_recipe_count,
           0 as product_count
    FROM tags t
    $whereSql
    ORDER BY t.usage_count DESC, t.name ASC
    LIMIT $limit OFFSET $offset
");
$stmt->execute($params);
$tags = $stmt->fetchAll();

require_once __DIR__ . '/includes/header.php';
?>

<!-- Page Header Bar -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; flex-wrap: wrap; gap: 16px;">
    <div>
        <h1 style="font-size: 24px; font-weight: 800; color: var(--cm-text-primary); margin: 0; display: flex; align-items: center; gap: 10px;">
            <i class="fa-solid fa-hashtag" style="color: var(--cm-primary);"></i>
            <span>Hashtag Management</span>
        </h1>
        <p style="color: var(--cm-text-muted); font-size: 13px; margin: 6px 0 0;">
            Manage food tags, track usage counts, and power discovery across the mobile app.
        </p>
    </div>
    <div style="display: flex; align-items: center; gap: 12px;">
        <button type="button" class="btn btn-secondary btn-sm" onclick="document.getElementById('recalcForm').submit();" title="Recalculate usage counts from relations">
            <i class="fa-solid fa-arrows-rotate"></i> Recalculate Counts
        </button>
        <button type="button" class="btn btn-primary btn-sm" onclick="openAddModal()">
            <i class="fa-solid fa-plus"></i> Add Hashtag
        </button>
    </div>
</div>

<form id="recalcForm" method="POST" style="display:none;">
    <input type="hidden" name="action" value="recalculate">
</form>

<!-- Stats Grid (Identical to Dashboard) -->
<div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); margin-bottom: 24px;">
    <div class="stat-card">
        <div class="stat-icon red">
            <i class="fa-solid fa-tags"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Total Hashtags</span>
            <span class="stat-value"><?= number_format($totalTags) ?></span>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon green">
            <i class="fa-solid fa-utensils"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Tagged Recipes</span>
            <span class="stat-value"><?= number_format($totalTaggedRecipes) ?></span>
        </div>
    </div>

    <div class="stat-card">
        <div class="stat-icon orange">
            <i class="fa-solid fa-fire"></i>
        </div>
        <div class="stat-info">
            <span class="stat-label">Top Trending Tag</span>
            <span class="stat-value" style="color: var(--cm-primary); font-size: 22px;">
                #<?= htmlspecialchars($topTagRow['name'] ?? 'none') ?>
                <span style="font-size: 13px; color: var(--cm-text-muted); font-weight: 500;">(<?= (int)($topTagRow['usage_count'] ?? 0) ?>)</span>
            </span>
        </div>
    </div>
</div>

<!-- Search & Filter Bar (Identical to recipes.php) -->
<form method="GET" action="<?= BASE_URL ?>/hashtags.php" class="filter-bar">
    <div class="search-input-wrapper">
        <i class="fa-solid fa-magnifying-glass search-icon"></i>
        <input type="text" name="q" value="<?= htmlspecialchars($q) ?>" class="form-control" placeholder="Search hashtags by name (e.g. rice, malnad, spicy)...">
    </div>

    <button type="submit" class="btn btn-primary btn-sm" style="padding: 10px 18px;">
        <i class="fa-solid fa-magnifying-glass"></i> Search
    </button>
    <?php if ($q !== ''): ?>
        <a href="<?= BASE_URL ?>/hashtags.php" class="btn btn-secondary btn-sm" style="padding: 10px 14px;">Reset</a>
    <?php endif; ?>

    <div style="color: var(--cm-text-muted); font-size: 13px; margin-left: auto; font-weight: 600;">
        Showing <?= count($tags) ?> of <?= $filteredTotal ?> hashtags
    </div>
</form>

<!-- Table Container -->
<div class="table-container">
    <table class="admin-table">
        <thead>
            <tr>
                <th style="padding-left: 24px;">Hashtag</th>
                <th>Recipes Tagged</th>
                <th>Products</th>
                <th>Usage Count</th>
                <th>Created Date</th>
                <th style="text-align: right; padding-right: 24px;">Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($tags)): ?>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 48px; color: var(--cm-text-muted);">
                        <i class="fa-solid fa-hashtag" style="font-size: 36px; margin-bottom: 12px; display: block; opacity: 0.4;"></i>
                        No hashtags found <?= $q !== '' ? 'matching "<strong>' . htmlspecialchars($q) . '</strong>"' : '' ?>.
                    </td>
                </tr>
            <?php else: ?>
                <?php foreach ($tags as $t): ?>
                    <tr>
                        <td style="padding-left: 24px;">
                            <span class="badge-tag" style="font-size: 13px;">
                                #<?= htmlspecialchars($t['name']) ?>
                            </span>
                        </td>
                        <td>
                            <?php if ($t['real_recipe_count'] > 0): ?>
                                <a href="<?= BASE_URL ?>/recipes.php?q=%23<?= urlencode($t['name']) ?>" style="color: #4CAF50; font-weight: 700; text-decoration: none;">
                                    <i class="fa-solid fa-utensils" style="margin-right: 4px;"></i> <?= $t['real_recipe_count'] ?> recipes
                                </a>
                            <?php else: ?>
                                <span style="color: var(--cm-text-muted);">0 recipes</span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <span style="color: var(--cm-text-muted);"><?= (int)$t['product_count'] ?> products</span>
                        </td>
                        <td>
                            <span style="background: #222222; border: 1px solid var(--cm-border); padding: 4px 10px; border-radius: 8px; font-weight: 700; font-size: 12px;">
                                <?= (int)$t['usage_count'] ?>
                            </span>
                        </td>
                        <td style="color: var(--cm-text-muted); font-size: 12px;">
                            <?= date('M j, Y', strtotime($t['created_at'])) ?>
                        </td>
                        <td style="text-align: right; padding-right: 24px;">
                            <div style="display: inline-flex; gap: 6px;">
                                <a href="<?= BASE_URL ?>/recipes.php?q=%23<?= urlencode($t['name']) ?>" class="btn btn-secondary btn-icon" title="View Recipes" style="width: 32px; height: 32px; font-size: 12px;">
                                    <i class="fa-solid fa-eye"></i>
                                </a>
                                <button type="button" class="btn btn-secondary btn-icon" onclick="openEditModal(<?= $t['id'] ?>, '<?= htmlspecialchars($t['name'], ENT_QUOTES) ?>')" title="Edit Tag" style="width: 32px; height: 32px; font-size: 12px;">
                                    <i class="fa-solid fa-pen"></i>
                                </button>
                                <button type="button" class="btn btn-danger btn-icon" onclick="openDeleteModal(<?= $t['id'] ?>, '<?= htmlspecialchars($t['name'], ENT_QUOTES) ?>', <?= (int)$t['real_recipe_count'] ?>)" title="Delete Tag" style="width: 32px; height: 32px; font-size: 12px;">
                                    <i class="fa-solid fa-trash-can"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>

    <!-- Pagination Footer -->
    <?php if ($totalPages > 1): ?>
        <div class="pagination" style="border-top: 1px solid var(--cm-border); padding: 16px 24px; margin: 0; background: rgba(255,255,255,0.01);">
            <div style="color: var(--cm-text-muted); font-size: 13px;">
                Page <?= $page ?> of <?= $totalPages ?>
            </div>
            <div style="display: flex; gap: 6px;">
                <?php if ($page > 1): ?>
                    <a class="page-link" href="<?= BASE_URL ?>/hashtags.php?page=<?= $page - 1 ?>&q=<?= urlencode($q) ?>">&laquo; Prev</a>
                <?php endif; ?>

                <?php for ($i = max(1, $page - 2); $i <= min($totalPages, $page + 2); $i++): ?>
                    <a class="page-link <?= $i === $page ? 'active' : '' ?>" href="<?= BASE_URL ?>/hashtags.php?page=<?= $i ?>&q=<?= urlencode($q) ?>"><?= $i ?></a>
                <?php endfor; ?>

                <?php if ($page < $totalPages): ?>
                    <a class="page-link" href="<?= BASE_URL ?>/hashtags.php?page=<?= $page + 1 ?>&q=<?= urlencode($q) ?>">Next &raquo;</a>
                <?php endif; ?>
            </div>
        </div>
    <?php endif; ?>
</div>

<!-- ==========================================================================
     Native Food CHART Modals (Zero Bootstrap dependency)
     ========================================================================== -->

<!-- Add Tag Modal -->
<div id="addTagModal" class="cm-modal-overlay" onclick="handleOverlayClick(event, 'addTagModal')">
    <div class="cm-modal">
        <form method="POST" action="<?= BASE_URL ?>/hashtags.php">
            <input type="hidden" name="action" value="add">
            <div class="cm-modal-header">
                <h3 class="cm-modal-title">
                    <i class="fa-solid fa-hashtag" style="color: var(--cm-primary);"></i>
                    <span>Add New Hashtag</span>
                </h3>
                <button type="button" class="cm-modal-close" onclick="closeModal('addTagModal')">&times;</button>
            </div>
            <div class="cm-modal-body">
                <label class="form-label" style="font-size: 12px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Hashtag Name</label>
                <div class="hashtag-input-bar">
                    <span class="hashtag-prefix-pill">#</span>
                    <input type="text" name="tag_name" id="addTagName" class="hashtag-native-input" placeholder="e.g. rice, spicy, breakfast" required autofocus>
                </div>
                <small style="color: var(--cm-text-muted); display: block; margin-top: 8px; font-size: 12px;">
                    Will be normalized automatically to lowercase letters, numbers, and underscores.
                </small>
            </div>
            <div class="cm-modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('addTagModal')">Cancel</button>
                <button type="submit" class="btn btn-primary btn-sm">Create Hashtag</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Tag Modal -->
<div id="editTagModal" class="cm-modal-overlay" onclick="handleOverlayClick(event, 'editTagModal')">
    <div class="cm-modal">
        <form method="POST" action="<?= BASE_URL ?>/hashtags.php">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="tag_id" id="editTagId" value="">
            <div class="cm-modal-header">
                <h3 class="cm-modal-title">
                    <i class="fa-solid fa-pen-to-square" style="color: var(--cm-primary);"></i>
                    <span>Edit Hashtag</span>
                </h3>
                <button type="button" class="cm-modal-close" onclick="closeModal('editTagModal')">&times;</button>
            </div>
            <div class="cm-modal-body">
                <label class="form-label" style="font-size: 12px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Hashtag Name</label>
                <div class="hashtag-input-bar">
                    <span class="hashtag-prefix-pill">#</span>
                    <input type="text" name="tag_name" id="editTagName" class="hashtag-native-input" required>
                </div>
            </div>
            <div class="cm-modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('editTagModal')">Cancel</button>
                <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteTagModal" class="cm-modal-overlay" onclick="handleOverlayClick(event, 'deleteTagModal')">
    <div class="cm-modal">
        <form method="POST" action="<?= BASE_URL ?>/hashtags.php">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="tag_id" id="deleteTagId" value="">
            <div class="cm-modal-header">
                <h3 class="cm-modal-title" style="color: #EF5350;">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <span>Delete Hashtag</span>
                </h3>
                <button type="button" class="cm-modal-close" onclick="closeModal('deleteTagModal')">&times;</button>
            </div>
            <div class="cm-modal-body">
                <p style="margin: 0 0 16px; font-size: 15px; color: var(--cm-text-primary);">
                    Are you sure you want to delete <strong id="deleteTagName" style="color: var(--cm-primary);"></strong>?
                </p>
                <div style="background: rgba(255, 152, 0, 0.1); border: 1px solid rgba(255, 152, 0, 0.3); border-radius: 10px; padding: 12px; color: #FFB74D; font-size: 13px; line-height: 1.5;">
                    <i class="fa-solid fa-circle-info" style="margin-right: 4px;"></i>
                    This tag is currently attached to <strong id="deleteTagCount">0</strong> recipe(s). Deleting it will safely unlink it without deleting the recipes themselves.
                </div>
            </div>
            <div class="cm-modal-footer">
                <button type="button" class="btn btn-secondary btn-sm" onclick="closeModal('deleteTagModal')">Cancel</button>
                <button type="submit" class="btn btn-danger btn-sm">Yes, Delete Tag</button>
            </div>
        </form>
    </div>
</div>

<script>
function openAddModal() {
    document.getElementById('addTagName').value = '';
    document.getElementById('addTagModal').classList.add('active');
    setTimeout(() => document.getElementById('addTagName').focus(), 100);
}

function openEditModal(id, name) {
    document.getElementById('editTagId').value = id;
    document.getElementById('editTagName').value = name;
    document.getElementById('editTagModal').classList.add('active');
    setTimeout(() => document.getElementById('editTagName').focus(), 100);
}

function openDeleteModal(id, name, count) {
    document.getElementById('deleteTagId').value = id;
    document.getElementById('deleteTagName').textContent = '#' + name;
    document.getElementById('deleteTagCount').textContent = count;
    document.getElementById('deleteTagModal').classList.add('active');
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
