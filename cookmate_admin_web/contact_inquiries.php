<?php
/**
 * Food CHART Web Admin - Contact Inquiries Manager
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

// Auto-ensure support tables exist
try {
    $pdo->query("SELECT 1 FROM contact_inquiries LIMIT 1");
} catch (Exception $e) {
    if (file_exists(__DIR__ . '/migrations/004_create_support_and_pages.sql')) {
        $pdo->exec(file_get_contents(__DIR__ . '/migrations/004_create_support_and_pages.sql'));
    }
}

$pageTitle = 'Contact Inquiries';

// Handle Actions
$action = $_GET['action'] ?? '';
$id = (int)($_GET['id'] ?? 0);

if ($id > 0 && !empty($action)) {
    try {
        if ($action === 'delete') {
            $stmt = $pdo->prepare("DELETE FROM contact_inquiries WHERE id = ?");
            $stmt->execute([$id]);
            set_flash_message('success', 'Inquiry deleted successfully.');
        } elseif (in_array($action, ['read', 'replied', 'archived', 'new'])) {
            $stmt = $pdo->prepare("UPDATE contact_inquiries SET status = ? WHERE id = ?");
            $stmt->execute([$action, $id]);
            set_flash_message('success', "Inquiry marked as $action.");
        }
    } catch (Exception $e) {
        set_flash_message('danger', 'Error: ' . $e->getMessage());
    }
    header('Location: ' . BASE_URL . '/contact_inquiries.php');
    exit;
}

// Filter parameters
$statusFilter = trim($_GET['status'] ?? '');
$search = trim($_GET['q'] ?? '');

$where = [];
$params = [];

if (!empty($statusFilter)) {
    $where[] = "status = ?";
    $params[] = $statusFilter;
}

if (!empty($search)) {
    $where[] = "(name LIKE ? OR email LIKE ? OR subject LIKE ? OR message LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

$whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';
$stmt = $pdo->prepare("SELECT * FROM contact_inquiries $whereSql ORDER BY created_at DESC");
$stmt->execute($params);
$inquiries = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Counts by status
$totalCount = (int)$pdo->query("SELECT COUNT(*) FROM contact_inquiries")->fetchColumn();
$newCount = (int)$pdo->query("SELECT COUNT(*) FROM contact_inquiries WHERE status = 'new'")->fetchColumn();
$readCount = (int)$pdo->query("SELECT COUNT(*) FROM contact_inquiries WHERE status = 'read'")->fetchColumn();
$repliedCount = (int)$pdo->query("SELECT COUNT(*) FROM contact_inquiries WHERE status = 'replied'")->fetchColumn();

require_once __DIR__ . '/includes/header.php';
?>

<!-- Toolbar -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 14px;">
    <div style="display: flex; gap: 8px; flex-wrap: wrap;">
        <a href="<?= BASE_URL ?>/contact_inquiries.php" class="btn btn-sm <?= empty($statusFilter) ? 'btn-primary' : 'btn-secondary' ?>">
            All (<?= $totalCount ?>)
        </a>
        <a href="<?= BASE_URL ?>/contact_inquiries.php?status=new" class="btn btn-sm <?= $statusFilter === 'new' ? 'btn-primary' : 'btn-secondary' ?>" style="<?= $newCount > 0 ? 'border-color: #FFA000; color: #FFA000;' : '' ?>">
            <i class="fa-solid fa-bell"></i> New (<?= $newCount ?>)
        </a>
        <a href="<?= BASE_URL ?>/contact_inquiries.php?status=read" class="btn btn-sm <?= $statusFilter === 'read' ? 'btn-primary' : 'btn-secondary' ?>">
            Read (<?= $readCount ?>)
        </a>
        <a href="<?= BASE_URL ?>/contact_inquiries.php?status=replied" class="btn btn-sm <?= $statusFilter === 'replied' ? 'btn-primary' : 'btn-secondary' ?>">
            Replied (<?= $repliedCount ?>)
        </a>
    </div>

    <form method="GET" style="display: flex; gap: 8px;">
        <?php if (!empty($statusFilter)): ?>
            <input type="hidden" name="status" value="<?= htmlspecialchars($statusFilter) ?>">
        <?php endif; ?>
        <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" class="form-control form-control-sm" placeholder="Search inquiries..." style="width: 220px;">
        <button type="submit" class="btn btn-primary btn-sm">Search</button>
        <?php if (!empty($search)): ?>
            <a href="<?= BASE_URL ?>/contact_inquiries.php<?= !empty($statusFilter) ? '?status=' . urlencode($statusFilter) : '' ?>" class="btn btn-secondary btn-sm">Clear</a>
        <?php endif; ?>
    </form>
</div>

<!-- Inquiries List -->
<div class="card" style="padding: 0; overflow: hidden;">
    <div style="padding: 20px 24px; border-bottom: 1px solid var(--cm-border); display: flex; justify-content: space-between; align-items: center;">
        <h2 class="card-title" style="margin: 0;">Contact Us Messages (<?= count($inquiries) ?>)</h2>
        <span style="font-size: 13px; color: var(--cm-text-muted);">Submitted via Mobile App</span>
    </div>

    <?php if (empty($inquiries)): ?>
        <div style="padding: 50px; text-align: center; color: var(--cm-text-muted);">
            <i class="fa-solid fa-inbox" style="font-size: 38px; margin-bottom: 12px; opacity: 0.4;"></i>
            <p style="margin: 0;">No contact inquiries found matching criteria.</p>
        </div>
    <?php else: ?>
        <div style="padding: 16px 20px;">
            <?php foreach ($inquiries as $inq): ?>
                <div style="background: rgba(255,255,255,0.03); border: 1px solid <?= $inq['status'] === 'new' ? 'rgba(229, 9, 21, 0.4)' : 'var(--cm-border)' ?>; border-radius: 12px; padding: 20px; margin-bottom: 16px; position: relative;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 16px; flex-wrap: wrap;">
                        <div>
                            <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 8px;">
                                <strong style="color: var(--cm-text-primary); font-size: 16px; font-family: 'Outfit', sans-serif;">
                                    <?= htmlspecialchars($inq['name']) ?>
                                </strong>
                                <a href="mailto:<?= htmlspecialchars($inq['email']) ?>?subject=Re: <?= urlencode($inq['subject']) ?>" style="color: #2196F3; font-size: 13px; text-decoration: none;">
                                    <i class="fa-solid fa-envelope"></i> <?= htmlspecialchars($inq['email']) ?>
                                </a>

                                <?php
                                $statusBadge = match($inq['status']) {
                                    'new' => ['#FFA000', 'New Message'],
                                    'read' => ['#9E9E9E', 'Read'],
                                    'replied' => ['#4CAF50', 'Replied'],
                                    'archived' => ['#607D8B', 'Archived'],
                                    default => ['#9E9E9E', $inq['status']]
                                };
                                ?>
                                <span class="badge" style="background: <?= $statusBadge[0] ?>20; color: <?= $statusBadge[0] ?>; border: 1px solid <?= $statusBadge[0] ?>50;">
                                    <?= $statusBadge[1] ?>
                                </span>
                            </div>

                            <div style="font-size: 14px; font-weight: 700; color: var(--cm-primary); margin-bottom: 8px;">
                                Subject: <?= htmlspecialchars($inq['subject']) ?>
                            </div>

                            <div style="background: rgba(0,0,0,0.25); border-radius: 8px; padding: 12px 14px; color: var(--cm-text-secondary); font-size: 13.5px; line-height: 1.6; white-space: pre-wrap; margin-bottom: 12px; border: 1px solid rgba(255,255,255,0.05);">
                                <?= htmlspecialchars($inq['message']) ?>
                            </div>

                            <div style="font-size: 12px; color: var(--cm-text-muted); display: flex; gap: 16px;">
                                <span><i class="fa-regular fa-clock"></i> <?= date('M d, Y • h:i A', strtotime($inq['created_at'])) ?></span>
                                <?php if (!empty($inq['ip_address'])): ?>
                                    <span><i class="fa-solid fa-network-wired"></i> IP: <?= htmlspecialchars($inq['ip_address']) ?></span>
                                <?php endif; ?>
                            </div>
                        </div>

                        <!-- Action buttons -->
                        <div style="display: flex; gap: 8px; align-self: flex-start;">
                            <a href="mailto:<?= htmlspecialchars($inq['email']) ?>?subject=Re: <?= urlencode($inq['subject']) ?>" class="btn btn-primary btn-sm" title="Reply via Email">
                                <i class="fa-solid fa-reply"></i> Reply
                            </a>
                            <?php if ($inq['status'] === 'new'): ?>
                                <a href="<?= BASE_URL ?>/contact_inquiries.php?action=read&id=<?= $inq['id'] ?>" class="btn btn-secondary btn-sm" title="Mark as Read">
                                    <i class="fa-solid fa-check"></i> Mark Read
                                </a>
                            <?php endif; ?>
                            <?php if ($inq['status'] !== 'replied'): ?>
                                <a href="<?= BASE_URL ?>/contact_inquiries.php?action=replied&id=<?= $inq['id'] ?>" class="btn btn-secondary btn-sm" title="Mark as Replied">
                                    <i class="fa-solid fa-check-double"></i> Mark Replied
                                </a>
                            <?php endif; ?>
                            <a href="<?= BASE_URL ?>/contact_inquiries.php?action=delete&id=<?= $inq['id'] ?>" class="btn btn-icon btn-sm" style="background: rgba(229, 9, 21, 0.1); color: var(--cm-primary);" onclick="return confirm('Delete this inquiry?');" title="Delete">
                                <i class="fa-solid fa-trash"></i>
                            </a>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
