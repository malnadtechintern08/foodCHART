<?php
/**
 * Food CHART Web Admin - FAQ Manager (Full CRUD)
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

// Auto-ensure support tables exist
try {
    $pdo->query("SELECT 1 FROM faqs LIMIT 1");
} catch (Exception $e) {
    if (file_exists(__DIR__ . '/migrations/004_create_support_and_pages.sql')) {
        $pdo->exec(file_get_contents(__DIR__ . '/migrations/004_create_support_and_pages.sql'));
    }
}

$pageTitle = 'FAQ Management';

// Handle Actions
$action = $_GET['action'] ?? $_POST['action'] ?? '';

// 1. Delete FAQ
if ($action === 'delete') {
    $delId = (int)($_GET['id'] ?? $_POST['id'] ?? 0);
    if ($delId > 0) {
        try {
            $stmt = $pdo->prepare("DELETE FROM faqs WHERE id = ?");
            $stmt->execute([$delId]);
            set_flash_message('success', 'FAQ was successfully deleted.');
        } catch (Exception $e) {
            set_flash_message('danger', 'Error deleting FAQ: ' . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/faqs.php');
    exit;
}

// 2. Toggle Publish
if ($action === 'toggle') {
    $toggleId = (int)($_GET['id'] ?? 0);
    if ($toggleId > 0) {
        try {
            $stmt = $pdo->prepare("UPDATE faqs SET is_published = IF(is_published = 1, 0, 1) WHERE id = ?");
            $stmt->execute([$toggleId]);
            set_flash_message('success', 'FAQ publishing status toggled.');
        } catch (Exception $e) {
            set_flash_message('danger', 'Error updating status: ' . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/faqs.php');
    exit;
}

// 3. Save (Create or Update)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($action === 'create' || $action === 'update')) {
    $faqId = (int)($_POST['id'] ?? 0);
    $category = trim($_POST['category'] ?? 'General');
    $question = trim($_POST['question'] ?? '');
    $answer = trim($_POST['answer'] ?? '');
    $sortOrder = (int)($_POST['sort_order'] ?? 0);
    $isPublished = isset($_POST['is_published']) ? 1 : 0;

    if (empty($question) || empty($answer)) {
        set_flash_message('danger', 'Both Question and Answer are required fields.');
    } else {
        try {
            if ($action === 'update' && $faqId > 0) {
                $stmt = $pdo->prepare("
                    UPDATE faqs SET
                        category = ?,
                        question = ?,
                        answer = ?,
                        sort_order = ?,
                        is_published = ?,
                        updated_at = NOW()
                    WHERE id = ?
                ");
                $stmt->execute([$category, $question, $answer, $sortOrder, $isPublished, $faqId]);
                set_flash_message('success', 'FAQ updated successfully.');
            } else {
                $stmt = $pdo->prepare("
                    INSERT INTO faqs (category, question, answer, sort_order, is_published, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, NOW(), NOW())
                ");
                $stmt->execute([$category, $question, $answer, $sortOrder, $isPublished]);
                set_flash_message('success', 'New FAQ added successfully.');
            }
        } catch (Exception $e) {
            set_flash_message('danger', 'Database error: ' . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/faqs.php');
    exit;
}

// Filter parameters
$catFilter = trim($_GET['category'] ?? '');
$search = trim($_GET['q'] ?? '');

$where = [];
$params = [];

if (!empty($catFilter)) {
    $where[] = "category = ?";
    $params[] = $catFilter;
}

if (!empty($search)) {
    $where[] = "(question LIKE ? OR answer LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

$whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';
$stmt = $pdo->prepare("SELECT * FROM faqs $whereSql ORDER BY sort_order ASC, id ASC");
$stmt->execute($params);
$faqs = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Distinct categories
$categories = $pdo->query("SELECT DISTINCT category FROM faqs WHERE category != '' ORDER BY category ASC")->fetchAll(PDO::FETCH_COLUMN);
if (!in_array('General', $categories)) $categories[] = 'General';
if (!in_array('Recipes & Cooking', $categories)) $categories[] = 'Recipes & Cooking';
if (!in_array('Submissions', $categories)) $categories[] = 'Submissions';
if (!in_array('Dietary & Health', $categories)) $categories[] = 'Dietary & Health';
if (!in_array('App & Account', $categories)) $categories[] = 'App & Account';
sort($categories);

// Check if editing specific FAQ
$editFaq = null;
if (isset($_GET['edit_id'])) {
    $editId = (int)$_GET['edit_id'];
    $stmt = $pdo->prepare("SELECT * FROM faqs WHERE id = ?");
    $stmt->execute([$editId]);
    $editFaq = $stmt->fetch(PDO::FETCH_ASSOC);
}

require_once __DIR__ . '/includes/header.php';
?>

<div style="display: grid; grid-template-columns: 1fr 380px; gap: 24px; align-items: flex-start;">
    <!-- Left Column: FAQ List -->
    <div>
        <!-- Filter Toolbar -->
        <form method="GET" class="filter-bar" style="margin-bottom: 20px;">
            <div class="search-input-wrapper">
                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" class="form-control" placeholder="Search FAQ question or answer...">
            </div>

            <div style="min-width: 180px;">
                <select name="category" class="form-control" onchange="this.form.submit()">
                    <option value="">All Categories (<?= count($faqs) ?>)</option>
                    <?php foreach ($categories as $c): ?>
                        <option value="<?= htmlspecialchars($c) ?>" <?= $catFilter === $c ? 'selected' : '' ?>>
                            <?= htmlspecialchars($c) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>

            <button type="submit" class="btn btn-primary btn-sm">Filter</button>
            <?php if (!empty($search) || !empty($catFilter)): ?>
                <a href="<?= BASE_URL ?>/faqs.php" class="btn btn-secondary btn-sm">Reset</a>
            <?php endif; ?>
        </form>

        <div class="card" style="padding: 0; overflow: hidden;">
            <div style="padding: 20px 24px; border-bottom: 1px solid var(--cm-border); display: flex; justify-content: space-between; align-items: center;">
                <h2 class="card-title" style="margin: 0;">Frequently Asked Questions (<?= count($faqs) ?>)</h2>
                <a href="<?= BASE_URL ?>/api/support/faqs.php" target="_blank" class="pma-badge-btn" style="padding: 6px 12px; color: #2196F3;">
                    <i class="fa-solid fa-code"></i> Live FAQ API
                </a>
            </div>

            <?php if (empty($faqs)): ?>
                <div style="padding: 40px; text-align: center; color: var(--cm-text-muted);">
                    <i class="fa-solid fa-circle-question" style="font-size: 32px; margin-bottom: 12px; opacity: 0.5;"></i>
                    <p>No FAQs match your current filters.</p>
                </div>
            <?php else: ?>
                <div style="padding: 12px 16px;">
                    <?php foreach ($faqs as $faq): ?>
                        <div style="background: rgba(255,255,255,0.03); border: 1px solid var(--cm-border); border-radius: 12px; padding: 16px; margin-bottom: 12px; transition: border-color 0.2s ease;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 12px;">
                                <div style="flex: 1;">
                                    <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 6px; flex-wrap: wrap;">
                                        <span class="badge" style="background: rgba(229, 9, 21, 0.15); color: var(--cm-primary); border: 1px solid rgba(229, 9, 21, 0.3);">
                                            <?= htmlspecialchars($faq['category']) ?>
                                        </span>
                                        <span style="font-size: 11px; color: var(--cm-text-muted);">Order: #<?= $faq['sort_order'] ?></span>
                                        <?php if ($faq['is_published']): ?>
                                            <span class="badge badge-success" style="font-size: 11px;"><i class="fa-solid fa-check"></i> Published</span>
                                        <?php else: ?>
                                            <span class="badge" style="font-size: 11px; color: #9E9E9E; background: rgba(158,158,158,0.1);"><i class="fa-solid fa-eye-slash"></i> Draft</span>
                                        <?php endif; ?>
                                    </div>
                                    <h4 style="margin: 0 0 8px; font-size: 15px; font-weight: 700; color: var(--cm-text-primary); font-family: 'Outfit', sans-serif;">
                                        <?= htmlspecialchars($faq['question']) ?>
                                    </h4>
                                    <p style="margin: 0; font-size: 13.5px; color: var(--cm-text-secondary); line-height: 1.5;">
                                        <?= nl2br(htmlspecialchars($faq['answer'])) ?>
                                    </p>
                                </div>
                                <div style="display: flex; flex-direction: column; gap: 6px;">
                                    <a href="<?= BASE_URL ?>/faqs.php?edit_id=<?= $faq['id'] ?>" class="btn btn-secondary btn-sm" style="padding: 5px 10px;" title="Edit this FAQ">
                                        <i class="fa-solid fa-pen-to-square"></i>
                                    </a>
                                    <a href="<?= BASE_URL ?>/faqs.php?action=toggle&id=<?= $faq['id'] ?>" class="btn btn-icon btn-sm" style="background: rgba(255,255,255,0.05); color: var(--cm-text-muted);" title="Toggle Published">
                                        <i class="fa-solid <?= $faq['is_published'] ? 'fa-eye-slash' : 'fa-eye' ?>"></i>
                                    </a>
                                    <a href="<?= BASE_URL ?>/faqs.php?action=delete&id=<?= $faq['id'] ?>" class="btn btn-icon btn-sm" style="background: rgba(229, 9, 21, 0.1); color: var(--cm-primary);" onclick="return confirm('Are you sure you want to permanently delete this FAQ?');" title="Delete FAQ">
                                        <i class="fa-solid fa-trash"></i>
                                    </a>
                                </div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>
    </div>

    <!-- Right Column: Add / Edit Form -->
    <div class="card" style="position: sticky; top: 90px;">
        <h3 class="card-title" style="margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
            <i class="fa-solid <?= $editFaq ? 'fa-pen-to-square' : 'fa-plus' ?>" style="color: var(--cm-primary);"></i>
            <?= $editFaq ? 'Edit FAQ #' . $editFaq['id'] : 'Add New FAQ' ?>
        </h3>

        <form method="POST" action="<?= BASE_URL ?>/faqs.php">
            <input type="hidden" name="action" value="<?= $editFaq ? 'update' : 'create' ?>">
            <?php if ($editFaq): ?>
                <input type="hidden" name="id" value="<?= $editFaq['id'] ?>">
            <?php endif; ?>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" for="faq_category">Category</label>
                <select id="faq_category" name="category" class="form-control" required>
                    <?php foreach ($categories as $cat): ?>
                        <option value="<?= htmlspecialchars($cat) ?>" <?= ($editFaq['category'] ?? '') === $cat ? 'selected' : '' ?>>
                            <?= htmlspecialchars($cat) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" for="faq_question">Question <span style="color: var(--cm-primary);">*</span></label>
                <input type="text" id="faq_question" name="question" class="form-control" required placeholder="e.g. Does Food CHART work offline?" value="<?= htmlspecialchars($editFaq['question'] ?? '') ?>">
            </div>

            <div class="form-group" style="margin-bottom: 14px;">
                <label class="form-label" for="faq_answer">Answer <span style="color: var(--cm-primary);">*</span></label>
                <textarea id="faq_answer" name="answer" class="form-control" rows="5" required placeholder="Provide a clear, helpful answer..."><?= htmlspecialchars($editFaq['answer'] ?? '') ?></textarea>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 16px; align-items: center;">
                <div class="form-group">
                    <label class="form-label" for="faq_sort">Sort Order</label>
                    <input type="number" id="faq_sort" name="sort_order" class="form-control" value="<?= htmlspecialchars($editFaq['sort_order'] ?? '0') ?>">
                </div>

                <div style="padding-top: 18px;">
                    <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; user-select: none;">
                        <input type="checkbox" name="is_published" value="1" <?= ($editFaq['is_published'] ?? 1) ? 'checked' : '' ?> style="accent-color: var(--cm-primary); width: 16px; height: 16px;">
                        <span style="font-size: 13px; font-weight: 700; color: var(--cm-text-primary);">Publish</span>
                    </label>
                </div>
            </div>

            <div style="display: flex; gap: 10px;">
                <button type="submit" class="btn btn-primary" style="flex: 1;">
                    <i class="fa-solid fa-floppy-disk"></i> <?= $editFaq ? 'Update FAQ' : 'Save FAQ' ?>
                </button>
                <?php if ($editFaq): ?>
                    <a href="<?= BASE_URL ?>/faqs.php" class="btn btn-secondary">Cancel</a>
                <?php endif; ?>
            </div>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
