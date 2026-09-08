<?php
/**
 * Food CHART Web Admin - Edit / Create Support & Policy Page
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

$pageId = trim($_GET['id'] ?? $_POST['id'] ?? '');
$isEdit = !empty($pageId);

$pageTitle = $isEdit ? 'Edit Support Page' : 'Create Support Page';

$page = [
    'id' => '',
    'title' => '',
    'slug' => '',
    'summary' => '',
    'content' => '',
    'meta_json' => '',
    'is_published' => 1
];

if ($isEdit) {
    $stmt = $pdo->prepare("SELECT * FROM support_pages WHERE id = ?");
    $stmt->execute([$pageId]);
    $found = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($found) {
        $page = $found;
        $pageTitle = 'Edit ' . htmlspecialchars($page['title']);
    } else {
        set_flash_message('danger', "Support page '$pageId' not found.");
        header('Location: ' . BASE_URL . '/support_pages.php');
        exit;
    }
}

// Handle Form Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $title = trim($_POST['title'] ?? '');
    $slug = trim($_POST['slug'] ?? '');
    $summary = trim($_POST['summary'] ?? '');
    $content = trim($_POST['content'] ?? '');
    $isPublished = isset($_POST['is_published']) ? 1 : 0;
    
    // Auto-generate slug if empty
    if (empty($slug)) {
        $slug = strtolower(preg_replace('/[^a-zA-Z0-9]+/', '-', $title));
        $slug = trim($slug, '-');
    }

    $id = $isEdit ? $pageId : ($slug ?: uniqid('page_'));

    // Handle structured metadata
    $metaArray = [];
    if (!empty($_POST['meta_raw'])) {
        $decoded = json_decode($_POST['meta_raw'], true);
        if (is_array($decoded)) {
            $metaArray = $decoded;
        }
    }

    // Specific contact fields
    if ($id === 'contact-us' || $slug === 'contact-us') {
        if (!empty($_POST['contact_email'])) $metaArray['support_email'] = trim($_POST['contact_email']);
        if (!empty($_POST['contact_phone'])) $metaArray['phone'] = trim($_POST['contact_phone']);
        if (!empty($_POST['contact_hours'])) $metaArray['hours'] = trim($_POST['contact_hours']);
        if (!empty($_POST['contact_address'])) $metaArray['address'] = trim($_POST['contact_address']);
        if (!empty($_POST['contact_whatsapp'])) $metaArray['whatsapp'] = trim($_POST['contact_whatsapp']);
    }

    $metaJson = !empty($metaArray) ? json_encode($metaArray, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) : null;

    if (empty($title) || empty($content)) {
        set_flash_message('danger', 'Title and Content cannot be empty.');
    } else {
        try {
            if ($isEdit) {
                $stmt = $pdo->prepare("
                    UPDATE support_pages SET
                        title = ?,
                        slug = ?,
                        summary = ?,
                        content = ?,
                        meta_json = ?,
                        is_published = ?,
                        updated_at = NOW()
                    WHERE id = ?
                ");
                $stmt->execute([$title, $slug, $summary, $content, $metaJson, $isPublished, $id]);
                set_flash_message('success', "Page \"$title\" updated successfully!");
            } else {
                $stmt = $pdo->prepare("
                    INSERT INTO support_pages (id, title, slug, summary, content, meta_json, is_published, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
                ");
                $stmt->execute([$id, $title, $slug, $summary, $content, $metaJson, $isPublished]);
                set_flash_message('success', "New page \"$title\" created successfully!");
            }
            header('Location: ' . BASE_URL . '/support_pages.php');
            exit;
        } catch (Exception $e) {
            set_flash_message('danger', 'Database error: ' . $e->getMessage());
        }
    }
}

$currentMeta = !empty($page['meta_json']) ? json_decode($page['meta_json'], true) : [];

require_once __DIR__ . '/includes/header.php';
?>

<div style="max-width: 1000px; margin: 0 auto;">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <a href="<?= BASE_URL ?>/support_pages.php" class="btn btn-secondary btn-sm">
            <i class="fa-solid fa-arrow-left"></i> Back to Policy Pages
        </a>
        <?php if ($isEdit): ?>
            <a href="<?= BASE_URL ?>/api/support/page.php?slug=<?= urlencode($page['slug']) ?>" target="_blank" class="btn btn-secondary btn-sm" style="color: #2196F3;">
                <i class="fa-solid fa-code"></i> View Raw JSON API
            </a>
        <?php endif; ?>
    </div>

    <form method="POST" action="">
        <input type="hidden" name="id" value="<?= htmlspecialchars($page['id']) ?>">

        <div class="card" style="margin-bottom: 24px;">
            <h2 class="card-title" style="margin-bottom: 20px;">
                <i class="fa-solid fa-pen-nib" style="color: var(--cm-primary); margin-right: 8px;"></i>
                <?= $isEdit ? 'Edit Support Page: ' . htmlspecialchars($page['title']) : 'Create Support Page' ?>
            </h2>

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 16px; margin-bottom: 16px;">
                <div class="form-group">
                    <label class="form-label" for="title">Page Title <span style="color: var(--cm-primary);">*</span></label>
                    <input type="text" id="title" name="title" class="form-control" required value="<?= htmlspecialchars($page['title']) ?>" placeholder="e.g. Privacy Policy, FAQ, Help Center">
                </div>

                <div class="form-group">
                    <label class="form-label" for="slug">URL Slug / Route Key</label>
                    <input type="text" id="slug" name="slug" class="form-control" value="<?= htmlspecialchars($page['slug']) ?>" placeholder="e.g. privacy-policy" <?= $isEdit && in_array($page['id'], ['privacy-policy', 'contact-us', 'help-center', 'safety-guidelines']) ? 'readonly title="Core route key should remain consistent"' : '' ?>>
                    <span style="font-size: 11px; color: var(--cm-text-muted);">Matches mobile route: <code>/<?= htmlspecialchars($page['slug']) ?></code></span>
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label" for="summary">Brief Summary (shown in mobile headers / lists)</label>
                <input type="text" id="summary" name="summary" class="form-control" value="<?= htmlspecialchars($page['summary']) ?>" placeholder="One sentence summary of this page">
            </div>

            <!-- Page-Specific Structured Fields for Contact Us -->
            <?php if ($page['id'] === 'contact-us' || $page['slug'] === 'contact-us'): ?>
                <div style="background: rgba(229, 9, 21, 0.05); border: 1px solid rgba(229, 9, 21, 0.2); border-radius: 12px; padding: 16px 20px; margin-bottom: 20px;">
                    <h3 style="font-size: 15px; font-weight: 700; color: var(--cm-primary); margin: 0 0 12px; display: flex; align-items: center; gap: 8px;">
                        <i class="fa-solid fa-headset"></i> Contact Us Details (Loaded in Mobile App Cards)
                    </h3>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px;">
                        <div class="form-group">
                            <label class="form-label">Support Email</label>
                            <input type="email" name="contact_email" class="form-control" value="<?= htmlspecialchars($currentMeta['support_email'] ?? 'support@foodchart.app') ?>">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Support Phone Number</label>
                            <input type="text" name="contact_phone" class="form-control" value="<?= htmlspecialchars($currentMeta['phone'] ?? '+91 (80) 4567-8900') ?>">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Working / Support Hours</label>
                            <input type="text" name="contact_hours" class="form-control" value="<?= htmlspecialchars($currentMeta['hours'] ?? 'Mon - Sat: 9 AM - 6 PM IST') ?>">
                        </div>
                        <div class="form-group">
                            <label class="form-label">WhatsApp Helpline</label>
                            <input type="text" name="contact_whatsapp" class="form-control" value="<?= htmlspecialchars($currentMeta['whatsapp'] ?? '+91 98765 43210') ?>">
                        </div>
                    </div>
                    <div class="form-group" style="margin-top: 10px;">
                        <label class="form-label">Culinary Lab / Office Address</label>
                        <input type="text" name="contact_address" class="form-control" value="<?= htmlspecialchars($currentMeta['address'] ?? 'Bengaluru, Karnataka, India') ?>">
                    </div>
                </div>
            <?php endif; ?>

            <!-- Content Area with Markdown / Formatting Helpers -->
            <div class="form-group" style="margin-bottom: 16px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                    <label class="form-label" for="content" style="margin: 0;">Page Content (Markdown / Formatted Text) <span style="color: var(--cm-primary);">*</span></label>
                    <div style="display: flex; gap: 6px;">
                        <button type="button" class="btn btn-secondary btn-sm" onclick="insertMarkdown('# ', '')" title="Add Heading 1">H1</button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="insertMarkdown('### ', '')" title="Add Heading 3">H3</button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="insertMarkdown('**', '**')" title="Bold Text"><b>B</b></button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="insertMarkdown('- ', '')" title="Bullet List">&bull; List</button>
                        <button type="button" class="btn btn-secondary btn-sm" onclick="insertMarkdown('\n---\n', '')" title="Divider Line">&mdash;</button>
                    </div>
                </div>
                <textarea id="content" name="content" class="form-control" rows="18" required style="font-family: 'JetBrains Mono', 'Courier New', monospace; font-size: 13.5px; line-height: 1.6;"><?= htmlspecialchars($page['content']) ?></textarea>
                <span style="font-size: 12px; color: var(--cm-text-muted); display: block; margin-top: 6px;">
                    Supports standard Markdown: <code># Heading 1</code>, <code>### Section</code>, <code>**bold**</code>, <code>- Bullet point</code>, <code>--- Divider</code>.
                </span>
            </div>

            <!-- Meta JSON Configuration -->
            <details style="margin-bottom: 20px; background: rgba(0,0,0,0.2); border-radius: 8px; padding: 12px 16px; border: 1px solid var(--cm-border);">
                <summary style="cursor: pointer; font-size: 13px; font-weight: 700; color: var(--cm-text-secondary);">
                    Advanced Settings &amp; Raw JSON Metadata
                </summary>
                <div style="margin-top: 12px;">
                    <textarea name="meta_raw" class="form-control" rows="4" style="font-family: monospace; font-size: 12px;"><?= htmlspecialchars($page['meta_json'] ?: '{}') ?></textarea>
                    <span style="font-size: 11px; color: var(--cm-text-muted);">Custom parameters like version, emergency contact numbers, or social handles passed directly to mobile apps.</span>
                </div>
            </details>

            <!-- Publish Status & Actions -->
            <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--cm-border); padding-top: 20px;">
                <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; user-select: none;">
                    <input type="checkbox" name="is_published" value="1" <?= $page['is_published'] ? 'checked' : '' ?> style="width: 18px; height: 18px; accent-color: var(--cm-primary);">
                    <div>
                        <strong style="color: var(--cm-text-primary); font-size: 14px;">Publish this page</strong>
                        <div style="font-size: 12px; color: var(--cm-text-muted);">Unchecking saves as draft (hidden from mobile users)</div>
                    </div>
                </label>

                <div style="display: flex; gap: 12px;">
                    <a href="<?= BASE_URL ?>/support_pages.php" class="btn btn-secondary">Cancel</a>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-floppy-disk"></i> Save Page Content
                    </button>
                </div>
            </div>
        </div>
    </form>
</div>

<script>
function insertMarkdown(prefix, suffix) {
    const textarea = document.getElementById('content');
    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const text = textarea.value;
    const selected = text.substring(start, end);
    const replacement = prefix + selected + suffix;
    textarea.value = text.substring(0, start) + replacement + text.substring(end);
    textarea.focus();
    textarea.setSelectionRange(start + prefix.length, end + prefix.length);
}
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
