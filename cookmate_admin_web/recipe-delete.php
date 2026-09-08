<?php
/**
 * Food CHART Web Admin - Delete Recipe Handler
 */
require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/includes/admin_auth.php';
require_admin_login();

$pdo = get_db_connection();

// Accept ID from POST (preferred) or GET
$id = trim($_POST['id'] ?? $_GET['id'] ?? '');

$isAjax = (!empty($_POST['ajax']) || !empty($_GET['ajax']) 
    || (!empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest')
    || (isset($_SERVER['HTTP_ACCEPT']) && strpos($_SERVER['HTTP_ACCEPT'], 'application/json') !== false));

// Determine return URL, prioritizing explicit return_url, then HTTP_REFERER, then recipes.php
$returnUrl = trim($_POST['return_url'] ?? $_GET['return_url'] ?? '');
if (empty($returnUrl) && !empty($_SERVER['HTTP_REFERER'])) {
    $ref = $_SERVER['HTTP_REFERER'];
    $refHost = parse_url($ref, PHP_URL_HOST);
    $currHost = $_SERVER['HTTP_HOST'] ?? '';
    if (!$refHost || $refHost === $currHost) {
        $returnUrl = $ref;
    }
}
if (empty($returnUrl)) {
    $returnUrl = BASE_URL . '/recipes.php';
}

// Ensure filter parameters like category, search query, diet, etc. are preserved on redirect
if (strpos($returnUrl, '?') === false) {
    $queryParams = [];
    if (!empty($_REQUEST['category'])) $queryParams['category'] = $_REQUEST['category'];
    if (!empty($_REQUEST['q'])) $queryParams['q'] = $_REQUEST['q'];
    if (!empty($_REQUEST['diet'])) $queryParams['diet'] = $_REQUEST['diet'];
    if (!empty($_REQUEST['difficulty'])) $queryParams['difficulty'] = $_REQUEST['difficulty'];
    if (!empty($_REQUEST['sort'])) $queryParams['sort'] = $_REQUEST['sort'];
    if (!empty($_REQUEST['page'])) $queryParams['page'] = $_REQUEST['page'];
    if (!empty($queryParams)) {
        $returnUrl .= '?' . http_build_query($queryParams);
    }
}

$success = false;
$message = '';
$title = '';

if (!empty($id)) {
    try {
        $stmt = $pdo->prepare("SELECT title FROM recipes WHERE id = ?");
        $stmt->execute([$id]);
        $title = $stmt->fetchColumn();

        if ($title !== false) {
            $pdo->beginTransaction();

            // CASCADE foreign keys delete child rows, but explicit delete ensures compatibility
            $pdo->prepare("DELETE FROM recipe_instructions WHERE recipe_id = ?")->execute([$id]);
            $pdo->prepare("DELETE FROM recipe_ingredients WHERE recipe_id = ?")->execute([$id]);
            $pdo->prepare("DELETE FROM recipe_tags WHERE recipe_id = ?")->execute([$id]);

            $delStmt = $pdo->prepare("DELETE FROM recipes WHERE id = ?");
            $delStmt->execute([$id]);

            if ($delStmt->rowCount() > 0) {
                $pdo->commit();
                $success = true;
                $message = "Recipe \"$title\" has been permanently deleted from database.";
                set_flash_message('success', $message);
            } else {
                $pdo->rollBack();
                $message = "Recipe \"$title\" could not be deleted (0 rows affected).";
                set_flash_message('warning', $message);
            }
        } else {
            $message = "Recipe not found in database (ID: " . htmlspecialchars($id) . ").";
            set_flash_message('warning', $message);
        }
    } catch (Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        $message = "Error deleting recipe: " . $e->getMessage();
        set_flash_message('danger', $message);
    }
} else {
    $message = "No recipe ID specified for deletion.";
    set_flash_message('warning', $message);
}

if ($isAjax) {
    header('Content-Type: application/json; charset=utf-8');
    if ($success) {
        echo json_encode([
            'success' => true,
            'message' => $message,
            'id' => $id,
            'title' => $title
        ]);
    } else {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => $message,
            'id' => $id
        ]);
    }
    exit;
}

header('Location: ' . $returnUrl);
exit;

