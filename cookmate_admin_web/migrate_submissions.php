<?php
/**
 * Food CHART - Recipe Submissions & Moderation Database Migration
 * Runs SQL schema migration, alters recipes table, creates uploads folders.
 */

header('Content-Type: text/html; charset=utf-8');
require_once __DIR__ . '/config/db.php';

try {
    $pdo = get_db_connection();
} catch (Exception $e) {
    die("<h1>Database Connection Failed</h1><p>" . htmlspecialchars($e->getMessage()) . "</p>");
}

$messages = [];
$success = true;

// 1. Ensure upload directories exist
$subUploadDir = __DIR__ . '/uploads/recipe-submissions/';
if (!is_dir($subUploadDir)) {
    if (mkdir($subUploadDir, 0777, true)) {
        $messages[] = "Created directory: <code>uploads/recipe-submissions/</code>";
    } else {
        $messages[] = "Warning: Could not create <code>uploads/recipe-submissions/</code> directory.";
    }
} else {
    $messages[] = "Directory exists: <code>uploads/recipe-submissions/</code>";
}

// 2. Execute SQL file migration
$sqlFile = __DIR__ . '/migrations/002_create_recipe_submissions.sql';
if (!file_exists($sqlFile)) {
    die("Migration SQL file not found: $sqlFile");
}

$sql = file_get_contents($sqlFile);
$statements = array_filter(array_map('trim', explode(';', $sql)));

foreach ($statements as $stmtSql) {
    if (empty($stmtSql)) continue;
    try {
        $pdo->exec($stmtSql);
    } catch (PDOException $e) {
        // Table might already exist, log warning if not catastrophic
        $messages[] = "<span style='color:orange;'>SQL Notice:</span> " . htmlspecialchars($e->getMessage());
    }
}
$messages[] = "Executed base table migrations (users, admins, recipe_submissions, child tables, logs, notifications).";

// 3. Alter recipes table to add attribution & source columns
$columnsToAdd = [
    'source_type' => "ALTER TABLE recipes ADD COLUMN source_type VARCHAR(32) NOT NULL DEFAULT 'admin'",
    'submitted_by_user_id' => "ALTER TABLE recipes ADD COLUMN submitted_by_user_id INT NULL",
    'submission_id' => "ALTER TABLE recipes ADD COLUMN submission_id INT NULL",
    'author_display_name' => "ALTER TABLE recipes ADD COLUMN author_display_name VARCHAR(100) NULL",
    'allow_publication' => "ALTER TABLE recipes ADD COLUMN allow_publication TINYINT(1) NOT NULL DEFAULT 1",
];

foreach ($columnsToAdd as $col => $alterSql) {
    try {
        $check = $pdo->prepare("
            SELECT COUNT(*) FROM information_schema.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() 
              AND TABLE_NAME = 'recipes' 
              AND COLUMN_NAME = ?
        ");
        $check->execute([$col]);
        if ((int)$check->fetchColumn() === 0) {
            $pdo->exec($alterSql);
            $messages[] = "Added column <code>$col</code> to table <code>recipes</code>.";
        } else {
            $messages[] = "Column <code>$col</code> already exists in table <code>recipes</code>.";
        }
    } catch (Exception $e) {
        $messages[] = "Error checking/adding column <code>$col</code>: " . htmlspecialchars($e->getMessage());
    }
}

// Verify tables exist
$existingTables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);
$requiredTables = [
    'users',
    'admins',
    'recipe_submissions',
    'recipe_submission_ingredients',
    'recipe_submission_steps',
    'recipe_submission_tags',
    'admin_activity_logs',
    'user_notifications',
];

$allTablesPresent = true;
foreach ($requiredTables as $rt) {
    if (!in_array($rt, $existingTables)) {
        $allTablesPresent = false;
        $messages[] = "<span style='color:red;'>Missing table: <code>$rt</code></span>";
    }
}

if ($allTablesPresent) {
    $messages[] = "<strong style='color:#4CAF50;'>All required submission tables verified successfully!</strong>";
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recipe Submissions Migration • Food CHART</title>
    <style>
        body { background: #0E0E0E; color: #FFFFFF; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; padding: 40px; margin: 0; }
        .container { max-width: 760px; margin: 0 auto; background: #1A1A1A; border: 1px solid #333; border-radius: 14px; padding: 30px; box-shadow: 0 10px 40px rgba(0,0,0,0.5); }
        h1 { color: #E50914; margin-top: 0; display: flex; align-items: center; gap: 10px; }
        .log-list { list-style: none; padding: 0; margin: 20px 0; border: 1px solid #2A2A2A; border-radius: 10px; overflow: hidden; }
        .log-item { padding: 12px 16px; border-bottom: 1px solid #222; background: #141414; font-size: 13.5px; }
        .log-item:last-child { border-bottom: none; }
        .btn { display: inline-block; background: #E50914; color: #FFF; padding: 10px 20px; border-radius: 8px; text-decoration: none; font-weight: 700; font-size: 14px; margin-top: 15px; }
        code { background: #262626; padding: 2px 6px; border-radius: 4px; color: #FF4D55; font-family: monospace; }
    </style>
</head>
<body>
    <div class="container">
        <h1><span>🎉</span> Recipe Submissions Migration Complete</h1>
        <p style="color: #AAA;">Database schema for user submissions, ingredients, steps, tags, and admin review is active.</p>

        <ul class="log-list">
            <?php foreach ($messages as $msg): ?>
                <li class="log-item"><?= $msg ?></li>
            <?php endforeach; ?>
        </ul>

        <a href="<?= BASE_URL ?>/recipe-submissions.php" class="btn">Open Recipe Submissions &rarr;</a>
    </div>
</body>
</html>
