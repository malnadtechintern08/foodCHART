<?php
/**
 * Food CHART Web Admin - Categories Manager (CRUD)
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$pageTitle = 'Category Management';

// Detect AJAX
$isAjax = (!empty($_POST['ajax']) || !empty($_GET['ajax']) 
    || (!empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest')
    || (isset($_SERVER['HTTP_ACCEPT']) && strpos($_SERVER['HTTP_ACCEPT'], 'application/json') !== false));

// Handle Delete Category
if (isset($_REQUEST['action']) && $_REQUEST['action'] === 'delete') {
    $delId = trim($_POST['id'] ?? $_GET['id'] ?? '');
    $success = false;
    $msg = '';

    if (!empty($delId)) {
        try {
            $countStmt = $pdo->prepare("SELECT COUNT(*) FROM recipes WHERE category_id = ?");
            $countStmt->execute([$delId]);
            $linkedRecipes = (int)$countStmt->fetchColumn();

            if ($linkedRecipes > 0) {
                $msg = "Cannot delete category '{$delId}': {$linkedRecipes} recipes are currently assigned to it. Reassign or delete those recipes first.";
                set_flash_message('danger', $msg);
            } else {
                $delStmt = $pdo->prepare("DELETE FROM categories WHERE id = ?");
                $delStmt->execute([$delId]);
                if ($delStmt->rowCount() > 0) {
                    $success = true;
                    $msg = "Category '{$delId}' was successfully deleted from the database.";
                    set_flash_message('success', $msg);
                } else {
                    $msg = "Category '{$delId}' not found or already deleted.";
                    set_flash_message('warning', $msg);
                }
            }
        } catch (Exception $e) {
            $msg = "Error deleting category: " . $e->getMessage();
            set_flash_message('danger', $msg);
        }
    }

    if ($isAjax) {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode(['success' => $success, 'message' => $msg, 'id' => $delId]);
        exit;
    }

    header('Location: ' . BASE_URL . '/categories.php');
    exit;
}

// Handle Add / Edit Category
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $catId = trim($_POST['id'] ?? '');
    $catName = trim($_POST['name'] ?? '');
    $iconName = trim($_POST['icon_name'] ?? 'restaurant');
    $colorHex = trim($_POST['color_hex'] ?? '0xFFE50914');
    $desc = trim($_POST['description'] ?? '');

    if (empty($catId) || empty($catName)) {
        set_flash_message('danger', 'Both Category ID and Name are strictly required.');
    } else {
        try {
            // Check if category already exists
            $checkStmt = $pdo->prepare("SELECT COUNT(*) FROM categories WHERE id = ?");
            $checkStmt->execute([$catId]);
            $isExisting = ((int)$checkStmt->fetchColumn() > 0);

            if ($isExisting) {
                $stmt = $pdo->prepare("
                    UPDATE categories SET
                        name = ?,
                        icon_name = ?,
                        color_hex = ?,
                        description = ?
                    WHERE id = ?
                ");
                $stmt->execute([$catName, $iconName, $colorHex, $desc, $catId]);
                $msg = "Category \"$catName\" ($catId) updated successfully in the database!";
                set_flash_message('success', $msg);
                if ($isAjax) {
                    header('Content-Type: application/json; charset=utf-8');
                    echo json_encode([
                        'success' => true,
                        'message' => $msg,
                        'category' => [
                            'id' => $catId,
                            'name' => $catName,
                            'icon_name' => $iconName,
                            'color_hex' => $colorHex,
                            'description' => $desc
                        ]
                    ]);
                    exit;
                }
            } else {
                $stmt = $pdo->prepare("
                    INSERT INTO categories (id, name, icon_name, color_hex, description)
                    VALUES (?, ?, ?, ?, ?)
                ");
                $stmt->execute([$catId, $catName, $iconName, $colorHex, $desc]);
                if ($stmt->rowCount() > 0) {
                    $msg = "New category \"$catName\" ($catId) created successfully in the database!";
                    set_flash_message('success', $msg);
                    if ($isAjax) {
                        header('Content-Type: application/json; charset=utf-8');
                        echo json_encode([
                            'success' => true,
                            'message' => $msg,
                            'category' => [
                                'id' => $catId,
                                'name' => $catName,
                                'icon_name' => $iconName,
                                'color_hex' => $colorHex,
                                'description' => $desc,
                                'recipe_count' => 0
                            ]
                        ]);
                        exit;
                    }
                } else {
                    throw new Exception("Failed to insert category into database.");
                }
            }
        } catch (Exception $e) {
            $msg = "Database error: " . $e->getMessage();
            set_flash_message('danger', $msg);
            if ($isAjax) {
                header('Content-Type: application/json; charset=utf-8');
                http_response_code(400);
                echo json_encode(['success' => false, 'message' => $msg]);
                exit;
            }
        }
    }
    if ($isAjax) {
        header('Content-Type: application/json; charset=utf-8');
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Both Category ID and Name are strictly required.']);
        exit;
    }
    header('Location: ' . BASE_URL . '/categories.php');
    exit;
}

// Fetch categories with recipe count
$categories = $pdo->query("
    SELECT c.*, COUNT(r.id) AS recipe_count 
    FROM categories c 
    LEFT JOIN recipes r ON c.id = r.category_id 
    GROUP BY c.id 
    ORDER BY c.name ASC
")->fetchAll();

require_once __DIR__ . '/includes/header.php';
?>

<div style="display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: flex-start;">
    <!-- Left: Categories Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 20px 24px; border-bottom: 1px solid var(--cm-border); display: flex; justify-content: space-between; align-items: center;">
            <h2 class="card-title" style="margin: 0;">Existing Categories (<?= count($categories) ?>)</h2>
            <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="pma-badge-btn" style="padding: 6px 12px;">
                <i class="fa-solid fa-database"></i> Browse in phpMyAdmin
            </a>
        </div>

        <div class="table-responsive">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Category</th>
                        <th>Identifier</th>
                        <th>Color Badge</th>
                        <th>Recipes</th>
                        <th>Description</th>
                        <th style="text-align: right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($categories as $cat): ?>
                        <?php 
                            $hex = !empty($cat['color_hex']) ? str_replace('0xFF', '#', $cat['color_hex']) : '#E50914';
                        ?>
                        <tr id="cat-row-<?= htmlspecialchars($cat['id']) ?>">
                            <td>
                                <strong id="cat-name-<?= htmlspecialchars($cat['id']) ?>" style="color: var(--cm-text-primary); font-size: 15px; font-family: 'Outfit', sans-serif;">
                                    <?= htmlspecialchars($cat['name']) ?>
                                </strong>
                            </td>
                            <td>
                                <code style="color: var(--cm-text-muted);"><?= htmlspecialchars($cat['id']) ?></code>
                            </td>
                            <td id="cat-badge-<?= htmlspecialchars($cat['id']) ?>">
                                <span class="badge" style="background: <?= $hex ?>25; color: <?= $hex ?>; border: 1px solid <?= $hex ?>60;">
                                    <span style="width: 8px; height: 8px; border-radius: 50%; background: <?= $hex ?>; display: inline-block;"></span>
                                    <?= htmlspecialchars($cat['color_hex']) ?>
                                </span>
                            </td>
                            <td>
                                <a href="<?= BASE_URL ?>/recipes.php?category=<?= urlencode($cat['id']) ?>" style="color: var(--cm-primary); font-weight: 700; text-decoration: none;">
                                    <?= $cat['recipe_count'] ?> recipes
                                </a>
                            </td>
                            <td id="cat-desc-<?= htmlspecialchars($cat['id']) ?>" style="color: var(--cm-text-secondary); font-size: 12px; max-width: 250px;">
                                <?= htmlspecialchars($cat['description']) ?>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: inline-flex; gap: 6px;">
                                    <button type="button" class="btn btn-secondary btn-icon" title="Edit Category"
                                            onclick='editCategory(<?= json_encode($cat) ?>)'>
                                        <i class="fa-regular fa-pen-to-square"></i>
                                    </button>
                                    <button type="button" class="btn btn-danger btn-icon btn-del-cat" 
                                            title="Delete Category" 
                                            onclick="deleteCategoryAjax(event, '<?= htmlspecialchars($cat['id'], ENT_QUOTES) ?>', '<?= htmlspecialchars($cat['name'], ENT_QUOTES) ?>')">
                                        <i class="fa-regular fa-trash-can"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Add / Edit Category Panel -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title" id="formTitle"><i class="fa-solid fa-plus" style="color: var(--cm-primary);"></i> Add / Update Category</h3>
        </div>

        <form method="POST" action="<?= BASE_URL ?>/categories.php" id="catForm" onsubmit="handleCategoryFormSubmit(event)">
            <input type="hidden" name="ajax" value="1">
            <div class="form-group">
                <label class="form-label">Category ID *</label>
                <input type="text" name="id" id="catInputId" class="form-control" placeholder="e.g. cat_chaat or cat_beverages" required>
                <small style="color: var(--cm-text-muted); font-size: 11px;">Unique identifier in database</small>
            </div>

            <div class="form-group">
                <label class="form-label">Category Name *</label>
                <input type="text" name="name" id="catInputName" class="form-control" placeholder="e.g. Street Chaat" required>
            </div>

            <div class="form-group">
                <label class="form-label">Icon Identifier</label>
                <input type="text" name="icon_name" id="catInputIcon" class="form-control" placeholder="e.g. fastfood or local_dining" value="restaurant">
            </div>

            <div class="form-group">
                <label class="form-label">Color Hex (Flutter Format)</label>
                <input type="text" name="color_hex" id="catInputColor" class="form-control" placeholder="e.g. 0xFFE50914" value="0xFFE50914">
            </div>

            <div class="form-group">
                <label class="form-label">Description</label>
                <textarea name="description" id="catInputDesc" class="form-control" rows="3" placeholder="Brief summary of foods in this category..."></textarea>
            </div>

            <div style="display: flex; gap: 8px;">
                <button type="submit" class="btn btn-primary" id="btnSubmitCat" style="flex: 1;">
                    <i class="fa-solid fa-floppy-disk"></i> Save Category
                </button>
                <button type="button" class="btn btn-secondary" onclick="resetCatForm()" id="resetBtn" style="display: none;">
                    Reset
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Category Toast Notification -->
<div id="catToast" style="position: fixed; bottom: 24px; right: 24px; z-index: 9999; display: none; padding: 14px 20px; border-radius: 8px; font-weight: 500; font-size: 14px; box-shadow: 0 8px 24px rgba(0,0,0,0.4); animation: toastFadeIn 0.3s ease-out;">
</div>
<style>
@keyframes toastFadeIn {
    from { opacity: 0; transform: translateY(12px); }
    to { opacity: 1; transform: translateY(0); }
}
</style>

<script>
function showCategoryToast(message, type = 'success') {
    const toast = document.getElementById('catToast');
    if (!toast) return;
    toast.textContent = message;
    if (type === 'success') {
        toast.style.background = '#10B981';
        toast.style.color = '#fff';
    } else if (type === 'warning') {
        toast.style.background = '#F59E0B';
        toast.style.color = '#000';
    } else {
        toast.style.background = '#EF4444';
        toast.style.color = '#fff';
    }
    toast.style.display = 'block';
    setTimeout(() => {
        toast.style.display = 'none';
    }, 3800);
}

function editCategory(cat) {
    document.getElementById('formTitle').innerHTML = '<i class="fa-solid fa-pen-to-square" style="color: var(--cm-primary);"></i> Edit: ' + cat.name;
    document.getElementById('catInputId').value = cat.id;
    document.getElementById('catInputId').readOnly = true;
    document.getElementById('catInputName').value = cat.name;
    document.getElementById('catInputIcon').value = cat.icon_name || 'restaurant';
    document.getElementById('catInputColor').value = cat.color_hex || '0xFFE50914';
    document.getElementById('catInputDesc').value = cat.description || '';
    document.getElementById('resetBtn').style.display = 'inline-block';
}

function resetCatForm() {
    document.getElementById('formTitle').innerHTML = '<i class="fa-solid fa-plus" style="color: var(--cm-primary);"></i> Add / Update Category';
    document.getElementById('catInputId').value = '';
    document.getElementById('catInputId').readOnly = false;
    document.getElementById('catInputName').value = '';
    document.getElementById('catInputIcon').value = 'restaurant';
    document.getElementById('catInputColor').value = '0xFFE50914';
    document.getElementById('catInputDesc').value = '';
    document.getElementById('resetBtn').style.display = 'none';
}

function deleteCategoryAjax(event, id, name) {
    if (event) event.preventDefault();
    if (!confirm('Are you sure you want to permanently delete category "' + name + '"?')) {
        return;
    }

    const row = document.getElementById('cat-row-' + id);
    const btn = row ? row.querySelector('.btn-del-cat') : null;
    const origHtml = btn ? btn.innerHTML : '';
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';
    }

    const formData = new FormData();
    formData.append('action', 'delete');
    formData.append('id', id);
    formData.append('ajax', '1');

    fetch('<?= BASE_URL ?>/categories.php', {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest', 'Accept': 'application/json' },
        body: formData
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showCategoryToast(data.message || ('Category "' + name + '" deleted successfully!'), 'success');
            if (row) {
                row.style.transition = 'all 0.35s ease-out';
                row.style.background = 'rgba(229, 9, 20, 0.18)';
                row.style.opacity = '0';
                row.style.transform = 'translateX(35px)';
                setTimeout(() => row.remove(), 350);
            }
            // If current form has this category, reset it
            if (document.getElementById('catInputId').value === id) {
                resetCatForm();
            }
        } else {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = origHtml;
            }
            showCategoryToast(data.message || 'Failed to delete category', 'danger');
        }
    })
    .catch(err => {
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = origHtml;
        }
        showCategoryToast('Network error: ' + err.message, 'danger');
    });
}

function handleCategoryFormSubmit(event) {
    event.preventDefault();
    const form = document.getElementById('catForm');
    const btn = document.getElementById('btnSubmitCat');
    const origHtml = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving...';

    const formData = new FormData(form);

    fetch('<?= BASE_URL ?>/categories.php', {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest', 'Accept': 'application/json' },
        body: formData
    })
    .then(r => r.json())
    .then(data => {
        btn.disabled = false;
        btn.innerHTML = origHtml;
        if (data.success) {
            showCategoryToast(data.message || 'Category saved successfully!', 'success');
            // If updating existing row, reflect changes dynamically
            const cat = data.category;
            const existingRow = document.getElementById('cat-row-' + cat.id);
            if (existingRow) {
                const nameEl = document.getElementById('cat-name-' + cat.id);
                if (nameEl) nameEl.textContent = cat.name;
                const descEl = document.getElementById('cat-desc-' + cat.id);
                if (descEl) descEl.textContent = cat.description;
                const badgeEl = document.getElementById('cat-badge-' + cat.id);
                const hex = cat.color_hex ? cat.color_hex.replace('0xFF', '#') : '#E50914';
                if (badgeEl) {
                    badgeEl.innerHTML = `<span class="badge" style="background: ${hex}25; color: ${hex}; border: 1px solid ${hex}60;"><span style="width: 8px; height: 8px; border-radius: 50%; background: ${hex}; display: inline-block;"></span> ${cat.color_hex}</span>`;
                }
            } else {
                // New category: reload cleanly or append
                setTimeout(() => window.location.reload(), 600);
            }
            resetCatForm();
        } else {
            showCategoryToast(data.message || 'Error saving category', 'danger');
        }
    })
    .catch(err => {
        btn.disabled = false;
        btn.innerHTML = origHtml;
        showCategoryToast('Error saving: ' + err.message, 'danger');
    });
}
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
