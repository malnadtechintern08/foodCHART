<?php
/**
 * Food CHART Web Admin - Support & Policy Pages Manager
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

// Auto-ensure support tables exist
try {
    $pdo->query("SELECT 1 FROM support_pages LIMIT 1");
} catch (Exception $e) {
    if (file_exists(__DIR__ . '/migrations/004_create_support_and_pages.sql')) {
        $pdo->exec(file_get_contents(__DIR__ . '/migrations/004_create_support_and_pages.sql'));
    }
}

$pageTitle = 'Policy & Support Pages';

// Handle Toggle Publish Status
if (isset($_GET['action']) && $_GET['action'] === 'toggle' && !empty($_GET['id'])) {
    $id = trim($_GET['id']);
    try {
        $stmt = $pdo->prepare("UPDATE support_pages SET is_published = IF(is_published = 1, 0, 1) WHERE id = ?");
        $stmt->execute([$id]);
        set_flash_message('success', "Updated publishing status for page: " . htmlspecialchars($id));
    } catch (Exception $e) {
        set_flash_message('danger', "Error updating status: " . $e->getMessage());
    }
    header('Location: ' . BASE_URL . '/support_pages.php');
    exit;
}

// Fetch all support pages
$stmt = $pdo->query("SELECT * FROM support_pages ORDER BY created_at ASC");
$pages = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Counts
$faqCount = (int)$pdo->query("SELECT COUNT(*) FROM faqs")->fetchColumn();
$inquiryCount = (int)$pdo->query("SELECT COUNT(*) FROM contact_inquiries WHERE status = 'new'")->fetchColumn();

require_once __DIR__ . '/includes/header.php';
?>

<!-- Header Hub Stats -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 24px;">
    <div class="card" style="padding: 16px 20px; display: flex; align-items: center; gap: 16px;">
        <div style="width: 44px; height: 44px; border-radius: 12px; background: rgba(229, 9, 21, 0.15); display: flex; align-items: center; justify-content: center; color: var(--cm-primary); font-size: 20px;">
            <i class="fa-solid fa-file-shield"></i>
        </div>
        <div>
            <div style="font-size: 22px; font-weight: 800; color: var(--cm-text-primary); font-family: 'Outfit', sans-serif;"><?= count($pages) ?></div>
            <div style="font-size: 13px; color: var(--cm-text-muted);">Active Policy Pages</div>
        </div>
    </div>

    <a href="<?= BASE_URL ?>/faqs.php" class="card" style="padding: 16px 20px; display: flex; align-items: center; gap: 16px; text-decoration: none; transition: transform 0.15s ease;" onmouseover="this.style.transform='translateY(-2px)'" onmouseout="this.style.transform='none'">
        <div style="width: 44px; height: 44px; border-radius: 12px; background: rgba(76, 175, 80, 0.15); display: flex; align-items: center; justify-content: center; color: #4CAF50; font-size: 20px;">
            <i class="fa-solid fa-circle-question"></i>
        </div>
        <div style="flex: 1;">
            <div style="font-size: 22px; font-weight: 800; color: var(--cm-text-primary); font-family: 'Outfit', sans-serif;"><?= $faqCount ?></div>
            <div style="font-size: 13px; color: var(--cm-text-muted);">Configured FAQs &rarr;</div>
        </div>
    </a>

    <a href="<?= BASE_URL ?>/contact_inquiries.php" class="card" style="padding: 16px 20px; display: flex; align-items: center; gap: 16px; text-decoration: none; transition: transform 0.15s ease;" onmouseover="this.style.transform='translateY(-2px)'" onmouseout="this.style.transform='none'">
        <div style="width: 44px; height: 44px; border-radius: 12px; background: rgba(255, 160, 0, 0.15); display: flex; align-items: center; justify-content: center; color: #FFA000; font-size: 20px;">
            <i class="fa-solid fa-envelope-open-text"></i>
        </div>
        <div style="flex: 1;">
            <div style="font-size: 22px; font-weight: 800; color: var(--cm-text-primary); font-family: 'Outfit', sans-serif;"><?= $inquiryCount ?></div>
            <div style="font-size: 13px; color: var(--cm-text-muted);">New Contact Inquiries &rarr;</div>
        </div>
    </a>
</div>

<!-- Pages Table -->
<div class="card" style="padding: 0; overflow: hidden;">
    <div style="padding: 20px 24px; border-bottom: 1px solid var(--cm-border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
        <div>
            <h2 class="card-title" style="margin: 0;">Policy, Legal & Support Pages</h2>
            <p style="margin: 4px 0 0; font-size: 13px; color: var(--cm-text-muted);">
                Content managed here syncs live to the Food CHART mobile application over the REST API.
            </p>
        </div>
        <a href="<?= BASE_URL ?>/support_page_edit.php" class="btn btn-primary btn-sm">
            <i class="fa-solid fa-plus"></i> Create New Page
        </a>
    </div>

    <div class="table-responsive">
        <table class="admin-table">
            <thead>
                <tr>
                    <th style="width: 240px;">Page Title</th>
                    <th>Slug / Route</th>
                    <th>Summary / Overview</th>
                    <th>Status</th>
                    <th>Last Updated</th>
                    <th style="text-align: right; width: 180px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($pages)): ?>
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px; color: var(--cm-text-muted);">
                            No support pages found. Run migration to seed default pages.
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($pages as $page): ?>
                        <tr>
                            <td>
                                <div style="display: flex; align-items: center; gap: 10px;">
                                    <?php
                                    $iconClass = match($page['slug']) {
                                        'privacy-policy' => 'fa-shield-halved',
                                        'contact-us' => 'fa-headset',
                                        'help-center' => 'fa-book-open',
                                        'safety-guidelines' => 'fa-hand-holding-heart',
                                        default => 'fa-file-lines'
                                    };
                                    ?>
                                    <div style="width: 32px; height: 32px; border-radius: 8px; background: rgba(229, 9, 21, 0.1); display: flex; align-items: center; justify-content: center; color: var(--cm-primary); font-size: 14px;">
                                        <i class="fa-solid <?= $iconClass ?>"></i>
                                    </div>
                                    <div>
                                        <strong style="color: var(--cm-text-primary); font-size: 15px; font-family: 'Outfit', sans-serif;">
                                            <?= htmlspecialchars($page['title']) ?>
                                        </strong>
                                        <div style="font-size: 11px; color: var(--cm-text-muted);">ID: <?= htmlspecialchars($page['id']) ?></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <code style="color: #FF9800; font-size: 12.5px;">/<?= htmlspecialchars($page['slug']) ?></code>
                            </td>
                            <td style="max-width: 300px;">
                                <div style="font-size: 13px; color: var(--cm-text-secondary); line-height: 1.4; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;">
                                    <?= htmlspecialchars($page['summary'] ?: 'No summary provided.') ?>
                                </div>
                            </td>
                            <td>
                                <?php if ($page['is_published']): ?>
                                    <span class="badge badge-success" style="background: rgba(76, 175, 80, 0.15); color: #4CAF50; border: 1px solid rgba(76, 175, 80, 0.4);">
                                        <i class="fa-solid fa-circle-check"></i> Published
                                    </span>
                                <?php else: ?>
                                    <span class="badge" style="background: rgba(158, 158, 158, 0.15); color: #9E9E9E; border: 1px solid rgba(158, 158, 158, 0.4);">
                                        <i class="fa-solid fa-eye-slash"></i> Draft
                                    </span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <span style="font-size: 12.5px; color: var(--cm-text-muted);">
                                    <?= date('M d, Y • H:i', strtotime($page['updated_at'])) ?>
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: inline-flex; gap: 8px;">
                                    <a href="<?= BASE_URL ?>/support_page_edit.php?id=<?= urlencode($page['id']) ?>" class="btn btn-secondary btn-sm" title="Edit Page Content">
                                        <i class="fa-solid fa-pen-to-square"></i> Edit
                                    </a>
                                    <a href="<?= BASE_URL ?>/support_pages.php?action=toggle&id=<?= urlencode($page['id']) ?>" class="btn btn-icon btn-sm" style="background: rgba(255,255,255,0.05); color: var(--cm-text-secondary);" title="Toggle Publish Status">
                                        <i class="fa-solid <?= $page['is_published'] ? 'fa-eye-slash' : 'fa-eye' ?>"></i>
                                    </a>
                                    <a href="<?= BASE_URL ?>/api/support/page.php?slug=<?= urlencode($page['slug']) ?>" target="_blank" class="btn btn-icon btn-sm" style="background: rgba(255,255,255,0.05); color: #2196F3;" title="View Live API JSON">
                                        <i class="fa-solid fa-code"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
