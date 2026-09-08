<?php
/**
 * Food CHART Web Admin - Export Data Tools (JSON & Dart Seed Format)
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$pageTitle = 'Export & Sync Data';

$action = $_GET['action'] ?? '';

if ($action === 'download_json') {
    $categories = $pdo->query("SELECT * FROM categories ORDER BY name ASC")->fetchAll();
    $recipes = $pdo->query("SELECT * FROM recipes ORDER BY id ASC")->fetchAll();

    foreach ($recipes as &$r) {
        $ingStmt = $pdo->prepare("SELECT name, amount, unit, notes, is_optional FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC");
        $ingStmt->execute([$r['id']]);
        $r['ingredients'] = $ingStmt->fetchAll();

        $insStmt = $pdo->prepare("SELECT step_number, instruction, timer_seconds, tip FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");
        $insStmt->execute([$r['id']]);
        $r['instructions'] = $insStmt->fetchAll();
    }

    header('Content-Type: application/json; charset=utf-8');
    header('Content-Disposition: attachment; filename="foodchart_recipes_' . date('Y-m-d') . '.json"');
    echo json_encode(['categories' => $categories, 'recipes' => $recipes], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;
}

if ($action === 'download_sql') {
    header('Content-Type: application/sql; charset=utf-8');
    header('Content-Disposition: attachment; filename="foodchart_database_' . date('Y-m-d') . '.sql"');
    $sqlFile = __DIR__ . '/foodchart_database.sql';
    if (!file_exists($sqlFile)) {
        $sqlFile = __DIR__ . '/data/seed_data.sql';
    }
    if (file_exists($sqlFile)) {
        readfile($sqlFile);
    }
    exit;
}

require_once __DIR__ . '/includes/header.php';
?>

<div style="max-width: 860px; margin: 0 auto;">
    <div class="card">
        <div class="card-header">
            <h2 class="card-title"><i class="fa-solid fa-cloud-arrow-down" style="color: var(--cm-primary);"></i> Export Recipes & Database</h2>
        </div>

        <p style="color: var(--cm-text-secondary); font-size: 14px; line-height: 1.6; margin-bottom: 24px;">
            Export the current contents of your MySQL <code><?= htmlspecialchars(DB_NAME) ?></code> database into various formats to sync with the mobile app or create backups.
        </p>

        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 20px;">
            <!-- Export JSON -->
            <div style="background: var(--cm-surface); border: 1px solid var(--cm-border); border-radius: 14px; padding: 24px; display: flex; flex-direction: column; justify-content: space-between;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
                        <span style="width: 40px; height: 40px; border-radius: 10px; background: rgba(255, 107, 53, 0.15); color: var(--cm-primary); display: flex; align-items: center; justify-content: center; font-size: 18px;">
                            <i class="fa-solid fa-code"></i>
                        </span>
                        <h3 style="font-size: 17px; margin: 0;">Export Full JSON</h3>
                    </div>
                    <p style="color: var(--cm-text-secondary); font-size: 13px; line-height: 1.5; margin-bottom: 20px;">
                        Complete nested JSON export containing all recipes, categories, ingredients, and instructions.
                    </p>
                </div>
                <a href="<?= BASE_URL ?>/export.php?action=download_json" class="btn btn-primary" style="width: 100%;">
                    <i class="fa-solid fa-download"></i> Download JSON
                </a>
            </div>

            <!-- Export SQL Database Dump -->
            <div style="background: var(--cm-surface); border: 1px solid var(--cm-border); border-radius: 14px; padding: 24px; display: flex; flex-direction: column; justify-content: space-between;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
                        <span style="width: 40px; height: 40px; border-radius: 10px; background: rgba(76, 175, 80, 0.15); color: #4CAF50; display: flex; align-items: center; justify-content: center; font-size: 18px;">
                            <i class="fa-solid fa-database"></i>
                        </span>
                        <h3 style="font-size: 17px; margin: 0;">Export SQL Backup</h3>
                    </div>
                    <p style="color: var(--cm-text-secondary); font-size: 13px; line-height: 1.5; margin-bottom: 20px;">
                        Clean MySQL database dump (.sql) with schema, 200 recipes & categories ready to import on any host.
                    </p>
                </div>
                <a href="<?= BASE_URL ?>/export.php?action=download_sql" class="btn btn-secondary" style="width: 100%; border-color: rgba(76, 175, 80, 0.4); color: #81C784;">
                    <i class="fa-solid fa-file-arrow-down"></i> Download SQL Dump
                </a>
            </div>

            <!-- phpMyAdmin Direct Access -->
            <div style="background: var(--cm-surface); border: 1px solid var(--cm-border); border-radius: 14px; padding: 24px; display: flex; flex-direction: column; justify-content: space-between;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
                        <span style="width: 40px; height: 40px; border-radius: 10px; background: rgba(255, 179, 0, 0.15); color: var(--cm-gold); display: flex; align-items: center; justify-content: center; font-size: 18px;">
                            <i class="fa-solid fa-server"></i>
                        </span>
                        <h3 style="font-size: 17px; margin: 0;">phpMyAdmin Manager</h3>
                    </div>
                    <p style="color: var(--cm-text-secondary); font-size: 13px; line-height: 1.5; margin-bottom: 20px;">
                        Browse raw SQL tables, run custom queries, and perform database-level operations directly in phpMyAdmin.
                    </p>
                </div>
                <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="btn btn-secondary" style="width: 100%; border-color: rgba(255, 179, 0, 0.4); color: #FFCA28;">
                    <i class="fa-solid fa-arrow-up-right-from-square"></i> Open phpMyAdmin
                </a>
            </div>

            <!-- REST API Access -->
            <div style="background: var(--cm-surface); border: 1px solid var(--cm-border); border-radius: 14px; padding: 24px; display: flex; flex-direction: column; justify-content: space-between;">
                <div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
                        <span style="width: 40px; height: 40px; border-radius: 10px; background: rgba(41, 182, 246, 0.15); color: var(--cm-blue); display: flex; align-items: center; justify-content: center; font-size: 18px;">
                            <i class="fa-solid fa-network-wired"></i>
                        </span>
                        <h3 style="font-size: 17px; margin: 0;">Live REST API</h3>
                    </div>
                    <p style="color: var(--cm-text-secondary); font-size: 13px; line-height: 1.5; margin-bottom: 20px;">
                        Query recipe data dynamically via JSON endpoint (supports <code>?q=</code>, <code>?category=</code>, and <code>?limit=</code>).
                    </p>
                </div>
                <a href="<?= BASE_URL ?>/api/recipes.php" target="_blank" class="btn btn-secondary" style="width: 100%;">
                    <i class="fa-solid fa-arrow-up-right-from-square"></i> Open REST API
                </a>
            </div>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
