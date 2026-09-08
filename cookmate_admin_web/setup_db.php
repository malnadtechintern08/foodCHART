<?php
/**
 * Food CHART Web Admin - 1-Click Database Setup & Reset
 */
require_once __DIR__ . '/config/db.php';

$message = '';
$status = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' || isset($_GET['auto'])) {
    try {
        $pdo = null;
        try {
            // Attempt to connect directly to the target database
            $dsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8mb4";
            $pdo = new PDO($dsn, DB_USER, DB_PASS, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            ]);
        } catch (PDOException $connEx) {
            // If database does not exist, try creating it (works if user has CREATE DATABASE privilege)
            try {
                $serverDsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";charset=utf8mb4";
                $serverPdo = new PDO($serverDsn, DB_USER, DB_PASS, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                ]);
                $cleanDbName = str_replace('`', '', DB_NAME);
                $serverPdo->exec("CREATE DATABASE IF NOT EXISTS `{$cleanDbName}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
                
                $pdo = new PDO($dsn, DB_USER, DB_PASS, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                ]);
            } catch (Exception $createEx) {
                // Throw the original connection error with actionable advice
                throw new Exception("Unable to connect to database `" . DB_NAME . "` (" . $connEx->getMessage() . "). Please ensure the database exists in your hosting cPanel/phpMyAdmin and credentials in `config/db.php` are correct.");
            }
        }

        $sqlFile = __DIR__ . '/foodchart_database.sql';
        if (!file_exists($sqlFile)) {
            $sqlFile = __DIR__ . '/data/seed_data.sql';
        }
        if (!file_exists($sqlFile)) {
            throw new Exception("Seed SQL file not found at " . $sqlFile);
        }

        $sql = file_get_contents($sqlFile);

        // Strip CREATE DATABASE and USE statements so it imports cleanly into any assigned host DB
        $sql = preg_replace('/CREATE\s+DATABASE\s+[^;]+;/i', '', $sql);
        $sql = preg_replace('/USE\s+[^;]+;/i', '', $sql);

        $pdo->exec($sql);

        // Run hashtag migration if tags table does not exist or is empty
        $tagMigrationFile = __DIR__ . '/migrations/001_create_hashtag_tables.sql';
        if (file_exists($tagMigrationFile)) {
            $pdo->exec(file_get_contents($tagMigrationFile));
            require_once __DIR__ . '/includes/tag_functions.php';
            recalculate_all_tag_usage_counts($pdo);
        }

        // Run recipe submissions migration
        $subMigrationFile = __DIR__ . '/migrations/002_create_recipe_submissions.sql';
        if (file_exists($subMigrationFile)) {
            $pdo->exec(file_get_contents($subMigrationFile));
        }

        // Run notifications migration
        $notifMigrationFile = __DIR__ . '/migrations/003_create_notifications_system.sql';
        if (file_exists($notifMigrationFile)) {
            $pdo->exec(file_get_contents($notifMigrationFile));
        }

        // Run support & pages migration
        $supportMigrationFile = __DIR__ . '/migrations/004_create_support_and_pages.sql';
        if (file_exists($supportMigrationFile)) {
            $pdo->exec(file_get_contents($supportMigrationFile));
        }

        // Verify count
        $catCount = $pdo->query("SELECT COUNT(*) FROM categories")->fetchColumn();
        $recCount = $pdo->query("SELECT COUNT(*) FROM recipes")->fetchColumn();
        $tagCount = $pdo->query("SELECT COUNT(*) FROM tags")->fetchColumn();

        $message = "Database `" . htmlspecialchars(DB_NAME) . "` initialized successfully! Loaded $recCount recipes, $catCount categories, and $tagCount hashtags.";
        $status = 'success';
    } catch (Exception $e) {
        $message = "Error: " . $e->getMessage();
        $status = 'error';
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Food CHART Admin - Database Setup</title>
    <link rel="icon" type="image/png" href="<?= BASE_URL ?>/assets/images/app_icon.png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #0E0E0E;
            --card-bg: #1A1A1A;
            --border-color: #262626;
            --primary-orange: #E50914;
            --secondary-orange: #FF2E36;
            --veg-green: #4CAF50;
            --non-veg-red: #E50914;
            --text-primary: #FFFFFF;
            --text-secondary: #A5A5A5;
        }
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background: var(--bg-color);
            color: var(--text-primary);
            margin: 0;
            padding: 40px 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            box-sizing: border-box;
        }
        .setup-card {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 40px;
            max-width: 540px;
            width: 100%;
            text-align: center;
            box-shadow: 0 16px 40px rgba(0,0,0,0.6);
        }
        .logo-img {
            height: 70px;
            margin-bottom: 20px;
            object-fit: contain;
        }
        h1 {
            font-family: 'Outfit', sans-serif;
            font-size: 26px;
            font-weight: 800;
            margin: 0 0 10px 0;
            color: var(--text-primary);
        }
        .subtitle {
            color: var(--text-secondary);
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 28px;
        }
        .alert {
            padding: 14px 18px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 24px;
            text-align: left;
        }
        .alert-success {
            background: rgba(76, 175, 80, 0.15);
            border: 1px solid var(--veg-green);
            color: #81C784;
        }
        .alert-error {
            background: rgba(229, 57, 53, 0.15);
            border: 1px solid var(--non-veg-red);
            color: #EF5350;
        }
        .btn-primary {
            display: inline-block;
            background: linear-gradient(135deg, var(--primary-orange), var(--secondary-orange));
            color: #FFFFFF;
            border: none;
            padding: 14px 32px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            box-shadow: 0 6px 20px rgba(229, 9, 20, 0.4);
            transition: all 0.2s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(229, 9, 20, 0.5);
        }
        .btn-secondary {
            display: inline-block;
            background: #262626;
            color: var(--text-primary);
            border: 1px solid #333333;
            padding: 14px 28px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 700;
            text-decoration: none;
            margin-left: 10px;
            transition: all 0.2s ease;
        }
        .btn-secondary:hover {
            background: #333333;
        }
        .pma-link {
            display: block;
            margin-top: 24px;
            color: var(--primary-orange);
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
        }
        .pma-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="setup-card">
        <img src="<?= BASE_URL ?>/assets/images/foodchart_logo.png" alt="Food CHART Logo" class="logo-img">
        <h1><?= cookmate_brand_html() ?> Database Setup</h1>
        <p class="subtitle">Initialize the MySQL database and import 50 authentic recipes, 8 categories, hashtags, notifications, and policy pages directly into phpMyAdmin.</p>

        <?php if ($message): ?>
            <div class="alert alert-<?= $status ?>">
                <?= htmlspecialchars($message) ?>
            </div>
            <div style="margin-top: 20px;">
                <a href="<?= BASE_URL ?>/index.php" class="btn-primary">Go to Admin Dashboard &rarr;</a>
                <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="btn-secondary">Open phpMyAdmin 🗄️</a>
            </div>
        <?php else: ?>
            <form method="POST">
                <button type="submit" class="btn-primary">⚡ Initialize & Seed 50 Recipes</button>
                <a href="<?= BASE_URL ?>/index.php" class="btn-secondary">Cancel</a>
            </form>
        <?php endif; ?>

        <a href="/phpmyadmin/" target="_blank" class="pma-link">Open phpMyAdmin Server &rarr;</a>
    </div>
</body>
</html>
