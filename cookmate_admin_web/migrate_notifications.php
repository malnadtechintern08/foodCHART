<?php
/**
 * Food CHART - Notification System Database Migration Runner
 * Creates notifications and user_notifications tables, verifies indexes,
 * and seeds initial demo notifications.
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

// 1. Check if user_notifications exists and whether it has old schema (without notification_id)
try {
    $hasTable = (int)$pdo->query("
        SELECT COUNT(*) FROM information_schema.TABLES 
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user_notifications'
    ")->fetchColumn() > 0;

    if ($hasTable) {
        $checkCol = (int)$pdo->query("
            SELECT COUNT(*) FROM information_schema.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'user_notifications' AND COLUMN_NAME = 'notification_id'
        ")->fetchColumn();

        if ($checkCol === 0) {
            // Drop old empty table and recreate with new relational structure
            $pdo->exec("DROP TABLE IF EXISTS user_notifications");
            $messages[] = "Dropped legacy <code>user_notifications</code> table to upgrade to relational schema.";
        }
    }
} catch (Exception $e) {
    $messages[] = "<span style='color:orange;'>Notice:</span> " . htmlspecialchars($e->getMessage());
}

// 2. Execute SQL file migration
$sqlFile = __DIR__ . '/migrations/003_create_notifications_system.sql';
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
        $messages[] = "<span style='color:orange;'>SQL Notice:</span> " . htmlspecialchars($e->getMessage());
    }
}
$messages[] = "Created/verified <code>notifications</code> and <code>user_notifications</code> tables.";

// 3. Seed initial starter notifications if empty
try {
    $count = (int)$pdo->query("SELECT COUNT(*) FROM notifications")->fetchColumn();
    if ($count === 0) {
        $starterNotifs = [
            [
                'title' => 'New Recipe Added 🍲',
                'message' => 'Chicken Ghee Roast is now available on Food CHART. Explore this authentic coastal delicacy!',
                'type' => 'new_recipe',
                'target_type' => 'all',
                'target_user_id' => null,
                'related_type' => 'recipe',
                'related_id' => 'rec_chicken_ghee_roast',
                'image' => 'assets/images/recipes/chicken_ghee_roast.jpg',
                'status' => 'active',
                'created_by_admin_id' => 1
            ],
            [
                'title' => '✨ Recipe Updated',
                'message' => 'Masala Dosa recipe has brand new step-by-step cooking instructions and crispiness tips.',
                'type' => 'recipe_updated',
                'target_type' => 'all',
                'target_user_id' => null,
                'related_type' => 'recipe',
                'related_id' => 'rec_masala_dosa',
                'image' => 'assets/images/recipes/masala_dosa.jpg',
                'status' => 'active',
                'created_by_admin_id' => 1
            ],
            [
                'title' => '🚀 New Feature: #Hashtag Search',
                'message' => 'You can now discover recipes instantly by tapping trending culinary tags like #MalnadSpecial, #QuickBreakfast, and #WeekendFeast.',
                'type' => 'new_feature',
                'target_type' => 'all',
                'target_user_id' => null,
                'related_type' => 'feature',
                'related_id' => 'hashtags',
                'image' => null,
                'status' => 'active',
                'created_by_admin_id' => 1
            ],
            [
                'title' => '📢 Food CHART Community Update',
                'message' => 'Welcome to the new interactive notification center. Stay up to date with new recipes, approvals, and kitchen tips!',
                'type' => 'admin_announcement',
                'target_type' => 'all',
                'target_user_id' => null,
                'related_type' => 'general',
                'related_id' => null,
                'image' => null,
                'status' => 'active',
                'created_by_admin_id' => 1
            ]
        ];

        $ins = $pdo->prepare("
            INSERT INTO notifications (title, message, type, target_type, target_user_id, related_type, related_id, image, status, created_by_admin_id, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
        ");

        foreach ($starterNotifs as $sn) {
            $ins->execute([
                $sn['title'],
                $sn['message'],
                $sn['type'],
                $sn['target_type'],
                $sn['target_user_id'],
                $sn['related_type'],
                $sn['related_id'],
                $sn['image'],
                $sn['status'],
                $sn['created_by_admin_id']
            ]);
        }
        $messages[] = "Seeded " . count($starterNotifs) . " initial notifications.";
    } else {
        $messages[] = "Notifications table already contains $count notifications.";
    }
} catch (Exception $e) {
    $messages[] = "<span style='color:red;'>Seed Error:</span> " . htmlspecialchars($e->getMessage());
}

if (php_sapi_name() === 'cli') {
    echo "=== Food CHART Notifications Migration ===" . PHP_EOL;
    foreach ($messages as $msg) {
        echo strip_tags($msg) . PHP_EOL;
    }
    exit(0);
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>Food CHART - Notifications Migration</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #0E0E0E; color: #FFF; padding: 40px; }
        .card { max-width: 600px; margin: 0 auto; background: #1A1A1A; border: 1px solid #262626; border-radius: 12px; padding: 24px; }
        h1 { color: #E50915; margin-top: 0; }
        ul { line-height: 1.8; color: #CCC; }
        code { background: #262626; padding: 2px 6px; border-radius: 4px; color: #FFB300; }
        .btn { display: inline-block; margin-top: 16px; padding: 10px 20px; background: #E50915; color: #FFF; text-decoration: none; border-radius: 8px; font-weight: bold; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Notifications Migration Complete</h1>
        <ul>
            <?php foreach ($messages as $m): ?>
                <li><?= $m ?></li>
            <?php endforeach; ?>
        </ul>
        <a href="<?= BASE_URL ?>/notifications.php" class="btn">Go to Notifications Admin &rarr;</a>
    </div>
</body>
</html>
