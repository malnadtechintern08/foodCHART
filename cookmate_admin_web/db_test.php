<?php
/**
 * Food CHART Web Admin - Database Connection Diagnostic Tool
 * 
 * Verifies connectivity, active database, table schemas, and PDO configuration.
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once __DIR__ . '/config/db.php';

$isCli = (php_sapi_name() === 'cli');

if (!$isCli) {
    header('Content-Type: text/html; charset=utf-8');
}

$status = 'error';
$errorMessage = '';
$currentDb = '';
$tables = [];
$recipeCount = 0;
$categoryCount = 0;
$pdo = null;

try {
    $pdo = get_db_connection();
    $status = 'success';

    // 1. Query exact connected database name
    $dbStmt = $pdo->query("SELECT DATABASE()");
    $currentDb = $dbStmt->fetchColumn() ?: 'N/A';

    // 2. Query all tables
    $tblStmt = $pdo->query("SHOW TABLES");
    $tables = $tblStmt->fetchAll(PDO::FETCH_COLUMN);

    // 3. Count records in key tables if they exist
    if (in_array('recipes', $tables)) {
        $recipeCount = (int)$pdo->query("SELECT COUNT(*) FROM recipes")->fetchColumn();
    }
    if (in_array('categories', $tables)) {
        $categoryCount = (int)$pdo->query("SELECT COUNT(*) FROM categories")->fetchColumn();
    }
} catch (Throwable $e) {
    $status = 'error';
    $errorMessage = $e->getMessage();
}

// -----------------------------------------------------------------------------
// CLI Output
// -----------------------------------------------------------------------------
if ($isCli) {
    if ($status === 'success') {
        echo "====================================================\n";
        echo "DATABASE CONNECTED\n";
        echo "====================================================\n";
        echo "Connected Database : " . $currentDb . "\n";
        echo "Active Host Server : " . ($GLOBALS['cm_connected_host'] ?? DB_HOST) . "\n";
        echo "Configured DB_HOST : " . DB_HOST . ":" . DB_PORT . "\n";
        echo "Configured DB_NAME : " . DB_NAME . "\n";
        echo "Configured DB_USER : " . DB_USER . "\n";
        echo "Tables Found (" . count($tables) . ")   : " . implode(', ', $tables) . "\n";
        echo "Recipes Count      : " . $recipeCount . "\n";
        echo "Categories Count   : " . $categoryCount . "\n";
        echo "====================================================\n";
        exit(0);
    } else {
        echo "====================================================\n";
        echo "DATABASE CONNECTION FAILED\n";
        echo "====================================================\n";
        echo "Error: " . $errorMessage . "\n";
        echo "Target DB: " . DB_NAME . " on " . DB_HOST . ":" . DB_PORT . "\n";
        echo "====================================================\n";
        exit(1);
    }
}

// -----------------------------------------------------------------------------
// Browser HTML Output
// -----------------------------------------------------------------------------
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Food CHART Database Diagnostic</title>
    <link rel="icon" type="image/png" href="<?= BASE_URL ?>/assets/images/app_icon.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --cm-bg: #0D0E12;
            --cm-card: #151821;
            --cm-border: #232736;
            --cm-text-primary: #FFFFFF;
            --cm-text-secondary: #8E95A8;
            --cm-primary: #E50914;
            --cm-success: #10B981;
            --cm-danger: #EF4444;
        }
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: var(--cm-bg);
            color: var(--cm-text-primary);
            margin: 0;
            padding: 40px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            box-sizing: border-box;
        }
        .diag-card {
            background: var(--cm-card);
            border: 1px solid var(--cm-border);
            border-radius: 16px;
            padding: 36px;
            max-width: 680px;
            width: 100%;
            box-shadow: 0 16px 40px rgba(0,0,0,0.6);
        }
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 16px;
            border-radius: 30px;
            font-weight: 700;
            font-size: 14px;
            letter-spacing: 0.5px;
            margin-bottom: 20px;
        }
        .status-badge.success {
            background: rgba(16, 185, 129, 0.15);
            color: var(--cm-success);
            border: 1px solid rgba(16, 185, 129, 0.3);
        }
        .status-badge.error {
            background: rgba(239, 68, 68, 0.15);
            color: var(--cm-danger);
            border: 1px solid rgba(239, 68, 68, 0.3);
        }
        h1 {
            font-family: 'Outfit', sans-serif;
            font-size: 24px;
            margin: 0 0 16px 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin: 20px 0;
        }
        .info-box {
            background: #0E1017;
            border: 1px solid var(--cm-border);
            border-radius: 10px;
            padding: 12px 16px;
        }
        .info-label {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--cm-text-secondary);
            margin-bottom: 4px;
        }
        .info-value {
            font-size: 14px;
            font-weight: 600;
            color: var(--cm-text-primary);
            word-break: break-all;
        }
        .table-list {
            margin: 16px 0;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        .table-chip {
            background: #1C202E;
            border: 1px solid var(--cm-border);
            padding: 6px 12px;
            border-radius: 8px;
            font-family: monospace;
            font-size: 12px;
            color: #FFB088;
        }
        .actions {
            margin-top: 28px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 13px;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-primary {
            background: var(--cm-primary);
            color: #fff;
        }
        .btn-secondary {
            background: #1F2433;
            color: var(--cm-text-primary);
            border: 1px solid var(--cm-border);
        }
        .err-box {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.3);
            border-radius: 10px;
            padding: 16px;
            color: #FCA5A5;
            font-family: monospace;
            font-size: 13px;
            word-break: break-all;
            margin: 16px 0;
        }
    </style>
</head>
<body>
    <div class="diag-card">
        <div style="margin-bottom: 20px; display: flex; align-items: center; gap: 12px;">
            <img src="<?= BASE_URL ?>/assets/images/foodchart_logo.png" style="height: 42px;" alt="Food CHART Logo">
            <span style="font-size: 24px;">
                <?= cookmate_brand_html() ?>
            </span>
        </div>

        <?php if ($status === 'success'): ?>
            <div class="status-badge success">
                <i class="fa-solid fa-circle-check"></i> DATABASE CONNECTED
            </div>
            <h1><i class="fa-solid fa-database" style="color: var(--cm-primary);"></i> MySQL Connection Diagnostics</h1>

            <div class="info-grid">
                <div class="info-box">
                    <div class="info-label">Active Connected Database (SELECT DATABASE())</div>
                    <div class="info-value"><code><?= htmlspecialchars($currentDb) ?></code></div>
                </div>
                <div class="info-box">
                    <div class="info-label">Active Host Server</div>
                    <div class="info-value"><code><?= htmlspecialchars($GLOBALS['cm_connected_host'] ?? DB_HOST) ?></code></div>
                </div>
                <div class="info-box">
                    <div class="info-label">Target Host & Port</div>
                    <div class="info-value"><code><?= htmlspecialchars(DB_HOST) ?>:<?= htmlspecialchars(DB_PORT) ?></code></div>
                </div>
                <div class="info-box">
                    <div class="info-label">Database User</div>
                    <div class="info-value"><code><?= htmlspecialchars(DB_USER) ?></code></div>
                </div>
                <div class="info-box">
                    <div class="info-label">Total Recipes In Database</div>
                    <div class="info-value" style="color: var(--cm-primary); font-size: 18px;"><?= $recipeCount ?></div>
                </div>
                <div class="info-box">
                    <div class="info-label">Total Categories In Database</div>
                    <div class="info-value" style="color: var(--cm-primary); font-size: 18px;"><?= $categoryCount ?></div>
                </div>
            </div>

            <div style="margin-top: 20px;">
                <div class="info-label">Tables Found (SHOW TABLES)</div>
                <div class="table-list">
                    <?php foreach ($tables as $t): ?>
                        <span class="table-chip"><i class="fa-solid fa-table"></i> <?= htmlspecialchars($t) ?></span>
                    <?php endforeach; ?>
                </div>
            </div>

            <div class="actions">
                <a href="<?= BASE_URL ?>/index.php" class="btn btn-primary">
                    <i class="fa-solid fa-gauge-high"></i> Go to Admin Dashboard
                </a>
                <a href="<?= BASE_URL ?>/recipes.php" class="btn btn-secondary">
                    <i class="fa-solid fa-utensils"></i> All Recipes
                </a>
                <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="btn btn-secondary">
                    <i class="fa-solid fa-arrow-up-right-from-square"></i> Open phpMyAdmin
                </a>
            </div>

        <?php else: ?>
            <div class="status-badge error">
                <i class="fa-solid fa-triangle-exclamation"></i> DATABASE CONNECTION FAILED
            </div>
            <h1>MySQL Connection Diagnostic</h1>
            <p style="color: var(--cm-text-secondary); font-size: 14px;">The system attempted to connect using <code>config/db.php</code> but encountered a PDO error:</p>

            <div class="err-box">
                <?= htmlspecialchars($errorMessage) ?>
            </div>

            <div class="info-grid">
                <div class="info-box">
                    <div class="info-label">Target DB Host</div>
                    <div class="info-value"><code><?= htmlspecialchars(DB_HOST) ?>:<?= htmlspecialchars(DB_PORT) ?></code></div>
                </div>
                <div class="info-box">
                    <div class="info-label">Target Database</div>
                    <div class="info-value"><code><?= htmlspecialchars(DB_NAME) ?></code></div>
                </div>
                <div class="info-box">
                    <div class="info-label">Database User</div>
                    <div class="info-value"><code><?= htmlspecialchars(DB_USER) ?></code></div>
                </div>
                <div class="info-box">
                    <div class="info-label">PDO Error Reporting</div>
                    <div class="info-value" style="color: var(--cm-success);">ERRMODE_EXCEPTION (Active)</div>
                </div>
            </div>

            <div class="actions">
                <a href="<?= BASE_URL ?>/setup_db.php" class="btn btn-primary">
                    <i class="fa-solid fa-screwdriver-wrench"></i> Run Database Setup
                </a>
                <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="btn btn-secondary">
                    <i class="fa-solid fa-arrow-up-right-from-square"></i> Open phpMyAdmin
                </a>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>
