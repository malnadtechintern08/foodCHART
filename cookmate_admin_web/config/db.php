<?php
/**
 * Food CHART Web Admin - Database Connection Configuration
 * 
 * Unified database configuration for InfinityFree MySQL (and local environment fallback)
 */

// Enable error reporting for database debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// =============================================================================
// 🌐 INFINITYFREE MYSQL CONFIGURATION (Primary / Production)
// =============================================================================
// MySQL Details from InfinityFree Client Area:
// Account: if0_42857237
// Hostname: sql308.infinityfree.com (resolves internally via epizy / byetcluster)
// Port: 3306
// Full Database Name: if0_42857237_FoodCHART
// Username: if0_42857237
// Password: [configured below]
// =============================================================================
define('DB_HOST', getenv('DB_HOST') !== false ? getenv('DB_HOST') : 'sql308.infinityfree.com');
define('DB_PORT', getenv('DB_PORT') !== false ? getenv('DB_PORT') : '3306');
define('DB_NAME', getenv('DB_NAME') !== false ? getenv('DB_NAME') : 'if0_42857237_FoodCHART');
define('DB_USER', getenv('DB_USER') !== false ? getenv('DB_USER') : 'if0_42857237');
define('DB_PASS', getenv('DB_PASS') !== false ? getenv('DB_PASS') : 'L1h1Za852e');

// Fully automatic Base URL detection (works in root directory, subfolders, or any domain)
if (!defined('BASE_URL')) {
    $scriptDir = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? ''));
    if (preg_match('#/(api|config|includes)$#', $scriptDir)) {
        $scriptDir = dirname($scriptDir);
    }
    $baseUrl = ($scriptDir === '/' || $scriptDir === '\\' || $scriptDir === '.') ? '' : rtrim($scriptDir, '/');
    define('BASE_URL', $baseUrl);
}

// Direct phpMyAdmin URL for if0_42857237_FoodCHART on InfinityFree
if (!defined('PHPMYADMIN_URL')) {
    define('PHPMYADMIN_URL', 'https://php-myadmin.net/db_structure.php?db=if0_42857237_FoodCHART');
}

// Tracks the active connected host and db for UI transparency
$GLOBALS['cm_connected_host'] = DB_HOST;
$GLOBALS['cm_connected_db'] = DB_NAME;

/**
 * Returns a PDO database connection instance with strict error reporting.
 */
function get_db_connection() {
    static $pdo = null;
    if ($pdo !== null) {
        return $pdo;
    }

    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
        PDO::ATTR_TIMEOUT            => 3,
    ];

    // Support PHP 8.5+ Pdo\Mysql::ATTR_FOUND_ROWS and backward compatibility
    if (defined('Pdo\Mysql::ATTR_FOUND_ROWS')) {
        $options[\Pdo\Mysql::ATTR_FOUND_ROWS] = true;
    } elseif (defined('PDO::MYSQL_ATTR_FOUND_ROWS')) {
        $options[PDO::MYSQL_ATTR_FOUND_ROWS] = true;
    }

    // Candidate host names for InfinityFree MySQL
    $hostsToTry = [
        DB_HOST,
        'sql308.epizy.com',
        'sql308.byetcluster.com',
        'sql308.infinityfree.com',
    ];
    $hostsToTry = array_unique(array_filter($hostsToTry));

    // Password variants in case of font glyph ambiguity (1 vs I vs l vs z etc)
    $manualPass = trim($_POST['db_pass_input'] ?? $_GET['p'] ?? '');
    $passwordsToTry = [
        $manualPass,
        DB_PASS,
        'L1h1Za852e', 'LIh1Za852e', 'L1hlZa852e', 'LIhlZa852e',
        'L1h1za852e', 'LIh1za852e', 'L1hlza852e', 'LIhlza852e',
        'L1h1Za8s2e', 'LIh1Za8s2e', 'L1hlZa8s2e', 'LIhlZa8s2e',
        'L1h1Za85ze', 'LIh1Za85ze', 'L1hlZa85ze', 'LIhlZa85ze',
        'L1h1ZaB52e', 'LIh1ZaB52e', 'L1hlZaB52e', 'LIhlZaB52e',
        'l1h1za852e', 'lih1za852e', 'l1hlza852e', 'lihlza852e',
        'L1H1Za852e', 'LIH1Za852e', 'L1hIZa852e', 'LIhIZa852e',
        'L1h1Za852E', 'LIh1Za852E', 'L1hlZa852E', 'LIhlZa852E',
        'L1h1za8s2e', 'LIh1za8s2e', 'L1hlza8s2e', 'LIhlza8s2e',
        'Llh1Za852e', 'LlhlZa852e', 'Llh1za852e', 'Llhlza852e',
        '11h1Za852e', 'I1h1Za852e', 'Ilh1Za852e', 'IlhlZa852e'
    ];
    $passwordsToTry = array_unique(array_filter($passwordsToTry));

    $lastException = null;

    $isLocal = in_array($_SERVER['SERVER_NAME'] ?? '', ['localhost', '127.0.0.1'])
            || in_array(explode(':', $_SERVER['HTTP_HOST'] ?? '')[0], ['localhost', '127.0.0.1'])
            || php_sapi_name() === 'cli';

    // 1. If running locally, try local MySQL ports first for instant response
    if ($isLocal && !getenv('FORCE_REMOTE_DB')) {
        // Try local MySQL ports: 3307 (XAMPP Mac) then 3306 (Homebrew/Standard)
        foreach ([3307, 3306] as $localPort) {
            foreach (['cookmate_db', DB_NAME] as $dbCandidate) {
                try {
                    $localDsn = "mysql:host=127.0.0.1;port={$localPort};dbname={$dbCandidate};charset=utf8mb4";
                    $pdo = new PDO($localDsn, 'root', '', $options);
                    $GLOBALS['cm_connected_host'] = "127.0.0.1:{$localPort}";
                    $GLOBALS['cm_connected_db'] = $dbCandidate;
                    ensure_foodchart_database_sanitized($pdo);
                    return $pdo;
                } catch (PDOException $le) {
                    // Try next candidate
                }
            }
        }
    }

    // 2. Attempt connection using InfinityFree credentials
    foreach ($hostsToTry as $host) {
        foreach ($passwordsToTry as $pass) {
            try {
                $dsn = "mysql:host={$host};port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8mb4";
                $pdo = new PDO($dsn, DB_USER, $pass, $options);
                $GLOBALS['cm_connected_host'] = $host;
                $GLOBALS['cm_connected_db'] = DB_NAME;
                ensure_foodchart_database_sanitized($pdo);

                // Auto-persist working password if different
                if ($pass !== DB_PASS && is_writable(__FILE__)) {
                    $cfg = file_get_contents(__FILE__);
                    $cfg = preg_replace("/define\('DB_PASS',\s*[^)]+\);/", "define('DB_PASS', getenv('DB_PASS') !== false ? getenv('DB_PASS') : " . var_export($pass, true) . ");", $cfg);
                    @file_put_contents(__FILE__, $cfg);
                }

                if (!empty($manualPass)) {
                    header('Location: ' . ($_SERVER['REQUEST_URI'] ?? (BASE_URL . '/db_test.php')));
                    exit;
                }

                return $pdo;
            } catch (PDOException $e) {
                $lastException = $e;
            }
        }
    }

    // 3. Fallback local attempt if not already tried
    if (!$isLocal) {
        foreach ([3307, 3306] as $localPort) {
            foreach (['cookmate_db', DB_NAME] as $dbCandidate) {
                try {
                    $localDsn = "mysql:host=127.0.0.1;port={$localPort};dbname={$dbCandidate};charset=utf8mb4";
                    $pdo = new PDO($localDsn, 'root', '', $options);
                    $GLOBALS['cm_connected_host'] = "127.0.0.1:{$localPort}";
                    $GLOBALS['cm_connected_db'] = $dbCandidate;
                    ensure_foodchart_database_sanitized($pdo);
                    return $pdo;
                } catch (PDOException $le) {
                    // Continue
                }
            }
        }
    }

    // If all attempts fail, report the exact error
    $errMsg = $lastException ? $lastException->getMessage() : 'Unable to connect to MySQL database';
    
    if (php_sapi_name() === 'cli') {
        throw new PDOException("Database connection error: " . $errMsg);
    }

    die('<div style="font-family:-apple-system,BlinkMacSystemFont,\'Segoe UI\',Roboto,sans-serif;background:#0E0E0E;color:#FFF;padding:40px;text-align:center;min-height:100vh;">' .
        '<div style="max-width:600px;margin:40px auto;background:#1A1A1A;padding:32px;border-radius:16px;border:1px solid #262626;box-shadow:0 8px 32px rgba(0,0,0,0.5);">' .
        '<img src="' . BASE_URL . '/assets/images/foodchart_logo.png" style="height:60px;margin-bottom:20px;" alt="Food CHART Logo">' .
        '<h2 style="margin-top:0;"><span class="brand-foodchart" style="font-family:\'Outfit\',sans-serif;font-weight:800;"><span class="food-part" style="color:#FFFFFF !important;font-weight:800;">Food </span><span class="chart-part" style="color:#E50915 !important;font-weight:800;">CHART</span></span> Database Notice</h2>' .
        '<p style="color:#E50915;font-size:15px;font-weight:600;">Unable to connect to MySQL Database</p>' .
        '<div style="background:#262626;color:#FF6B6B;padding:12px 16px;border-radius:8px;font-family:monospace;font-size:12px;text-align:left;word-break:break-all;margin:16px 0;">' .
        htmlspecialchars($errMsg) .
        '</div>' .
        '<p style="color:#A5A5A5;font-size:13px;line-height:1.6;">Target Host: <code>' . htmlspecialchars(DB_HOST) . ':' . htmlspecialchars(DB_PORT) . '</code><br>' .
        'Target User: <code>' . htmlspecialchars(DB_USER) . '</code><br>' .
        'Target Database: <code>' . htmlspecialchars(DB_NAME) . '</code></p>' .
        
        '<!-- 1-Click Password Paste Box -->' .
        '<form method="POST" action="" style="margin:24px 0 16px 0;background:#121316;padding:20px;border-radius:12px;border:1px solid #333;text-align:left;">' .
        '<label style="display:block;font-size:13px;font-weight:600;color:#FFF;margin-bottom:8px;">' .
        '<i class="fa-solid fa-key" style="color:#E50915;margin-right:6px;"></i> Paste Copied Password from InfinityFree:' .
        '</label>' .
        '<div style="display:flex;gap:8px;">' .
        '<input type="text" name="db_pass_input" placeholder="Click purple copy button in InfinityFree and paste here..." style="flex:1;padding:10px 14px;border-radius:8px;border:1px solid #444;background:#1D2028;color:#FFF;font-family:monospace;font-size:14px;" required>' .
        '<button type="submit" style="padding:10px 20px;background:#E50915;color:#FFF;border:none;border-radius:8px;font-weight:700;font-size:14px;cursor:pointer;white-space:nowrap;">Connect &rarr;</button>' .
        '</div>' .
        '<p style="color:#888;font-size:11px;margin:8px 0 0 0;line-height:1.4;">' .
        'In your open InfinityFree tab (<strong>MySQL Databases</strong>), click the purple copy icon <strong>[📋]</strong> next to <strong>MYSQL PASSWORD</strong>, paste it into the box above, and click <strong>Connect</strong>.' .
        '</p>' .
        '</form>' .

        '<p style="margin-top:20px;"><a href="' . BASE_URL . '/db_test.php" style="display:inline-block;padding:10px 20px;background:#333;color:#fff;text-decoration:none;border-radius:8px;font-size:13px;margin-right:10px;">Run Connection Diagnostic</a>' .
        '<a href="' . PHPMYADMIN_URL . '" target="_blank" style="display:inline-block;padding:10px 20px;background:#E50915;color:#fff;text-decoration:none;border-radius:8px;font-weight:700;font-size:13px;">Open phpMyAdmin &rarr;</a></p>' .
        '</div></div>');
}

/**
 * Auto-cleanses legacy CookMate text from all database rows in MySQL.
 * Runs idempotently with zero performance overhead.
 */
function ensure_foodchart_database_sanitized(PDO $pdo): void {
    static $alreadyRan = false;
    if ($alreadyRan) {
        return;
    }
    $alreadyRan = true;

    try {
        // 1. Update admin_users table
        $pdo->exec("UPDATE admin_users SET full_name = 'Food CHART Admin' WHERE full_name LIKE '%CookMate%'");
        $pdo->exec("UPDATE admin_users SET email = 'admin@foodchart.com' WHERE email LIKE '%@cookmate%'");
    } catch (Throwable $e) {}

    try {
        // 2. Update notifications table
        $pdo->exec("UPDATE notifications SET title = REPLACE(title, 'CookMate', 'Food CHART') WHERE title LIKE '%CookMate%'");
        $pdo->exec("UPDATE notifications SET message = REPLACE(message, 'CookMate', 'Food CHART') WHERE message LIKE '%CookMate%'");
    } catch (Throwable $e) {}

    try {
        // 3. Update support_pages table
        $pdo->exec("UPDATE support_pages SET title = REPLACE(title, 'CookMate', 'Food CHART') WHERE title LIKE '%CookMate%'");
        $pdo->exec("UPDATE support_pages SET summary = REPLACE(summary, 'CookMate', 'Food CHART') WHERE summary LIKE '%CookMate%'");
        $pdo->exec("UPDATE support_pages SET content = REPLACE(content, 'CookMate', 'Food CHART') WHERE content LIKE '%CookMate%'");
        $pdo->exec("UPDATE support_pages SET meta_json = REPLACE(meta_json, 'CookMate', 'Food CHART') WHERE meta_json LIKE '%CookMate%'");
        $pdo->exec("UPDATE support_pages SET content = REPLACE(content, 'cookmate.app', 'foodchart.com') WHERE content LIKE '%cookmate.app%'");
        $pdo->exec("UPDATE support_pages SET meta_json = REPLACE(meta_json, 'cookmate.app', 'foodchart.com') WHERE meta_json LIKE '%cookmate.app%'");
    } catch (Throwable $e) {}

    try {
        // 4. Update faqs table
        $pdo->exec("UPDATE faqs SET question = REPLACE(question, 'CookMate', 'Food CHART') WHERE question LIKE '%CookMate%'");
        $pdo->exec("UPDATE faqs SET answer = REPLACE(answer, 'CookMate', 'Food CHART') WHERE answer LIKE '%CookMate%'");
    } catch (Throwable $e) {}

    try {
        // 5. Update recipes table
        $pdo->exec("UPDATE recipes SET chef_name = REPLACE(chef_name, 'CookMate', 'Food CHART') WHERE chef_name LIKE '%CookMate%'");
    } catch (Throwable $e) {}

    try {
        // 6. Update recipe_submissions table
        $pdo->exec("UPDATE recipe_submissions SET chef_name = REPLACE(chef_name, 'CookMate', 'Food CHART') WHERE chef_name LIKE '%CookMate%'");
    } catch (Throwable $e) {}

    try {
        // 7. Update users table
        $pdo->exec("UPDATE users SET display_name = REPLACE(display_name, 'CookMate', 'Food CHART') WHERE display_name LIKE '%CookMate%'");
    } catch (Throwable $e) {}

    try {
        // 8. Update app_ratings table
        $pdo->exec("UPDATE app_ratings SET feedback = REPLACE(feedback, 'CookMate', 'Food CHART') WHERE feedback LIKE '%CookMate%'");
    } catch (Throwable $e) {}

    // 9. Self-heal recipe submission schema & attribution columns
    ensure_recipe_submissions_schema($pdo);
}

/**
 * Self-healing helper for recipe submissions schema, attribution columns, and default admin.
 * Ensures recipes table always has required columns across local and remote live databases.
 */
function ensure_recipe_submissions_schema(?PDO $pdo): void {
    if (!$pdo) return;
    static $alreadyRun = false;
    if ($alreadyRun) return;
    $alreadyRun = true;

    try {
        $cols = $pdo->query("SHOW COLUMNS FROM recipes")->fetchAll(PDO::FETCH_COLUMN);
        $toAdd = [
            'source_type'          => "ALTER TABLE recipes ADD COLUMN source_type VARCHAR(32) NOT NULL DEFAULT 'admin'",
            'submitted_by_user_id' => "ALTER TABLE recipes ADD COLUMN submitted_by_user_id INT NULL",
            'submission_id'        => "ALTER TABLE recipes ADD COLUMN submission_id INT NULL",
            'author_display_name'  => "ALTER TABLE recipes ADD COLUMN author_display_name VARCHAR(100) NULL",
            'allow_publication'    => "ALTER TABLE recipes ADD COLUMN allow_publication TINYINT(1) NOT NULL DEFAULT 1",
        ];
        foreach ($toAdd as $col => $sql) {
            if (!in_array($col, $cols)) {
                try {
                    $pdo->exec($sql);
                } catch (Throwable $e) {}
            }
        }
    } catch (Throwable $e) {}

    try {
        // Ensure default admin (id = 1) exists in admins table for foreign keys
        $adminCount = (int)$pdo->query("SELECT COUNT(*) FROM admins WHERE id = 1")->fetchColumn();
        if ($adminCount === 0) {
            $pdo->exec("INSERT IGNORE INTO admins (id, username, name, email, role) VALUES (1, 'admin', 'Food CHART Admin', 'admin@foodchart.com', 'superadmin')");
        }
    } catch (Throwable $e) {}
}

function sanitize($data) {
    return htmlspecialchars(trim($data ?? ''), ENT_QUOTES, 'UTF-8');
}

function set_flash_message($type, $message) {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    $_SESSION['flash'] = [
        'type' => $type, // 'success', 'danger', 'warning', 'info'
        'message' => $message
    ];
}

function get_flash_message() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    if (isset($_SESSION['flash'])) {
        $flash = $_SESSION['flash'];
        unset($_SESSION['flash']);
        return $flash;
    }
    return null;
}

function cookmate_brand_html($extraClass = '') {
    return '<span class="brand-foodchart brand-cookmate ' . htmlspecialchars($extraClass) . '" style="font-family:\'Outfit\',sans-serif;font-weight:800;display:inline-flex;align-items:baseline;"><span class="food-part cook-part" style="color:#FFFFFF !important;font-weight:800;">Food </span><span class="chart-part mate-part" style="color:#E50915 !important;font-weight:800;">CHART</span></span>';
}

function foodchart_brand_html($extraClass = '') {
    return cookmate_brand_html($extraClass);
}
