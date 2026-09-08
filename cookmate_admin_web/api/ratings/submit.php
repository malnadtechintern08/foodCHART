<?php
/**
 * Food CHART REST API - App Rating & Feedback Submission Endpoint
 * 
 * POST /api/ratings/submit.php
 */
require_once __DIR__ . '/../../config/db.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Only POST method is allowed.']);
    exit;
}

try {
    $pdo = get_db_connection();

    // Auto-ensure app_ratings table exists
    try {
        $pdo->query("SELECT 1 FROM app_ratings LIMIT 1");
    } catch (Throwable $e) {
        $migrationFile = __DIR__ . '/../../migrations/005_create_app_ratings.sql';
        if (file_exists($migrationFile)) {
            $pdo->exec(file_get_contents($migrationFile));
        } else {
            $pdo->exec("
                CREATE TABLE IF NOT EXISTS `app_ratings` (
                    `id` INT AUTO_INCREMENT PRIMARY KEY,
                    `stars` INT NOT NULL,
                    `category` VARCHAR(100) DEFAULT 'General',
                    `feedback_text` TEXT NOT NULL,
                    `user_name` VARCHAR(150) DEFAULT 'App User',
                    `user_email` VARCHAR(150) DEFAULT NULL,
                    `device_info` VARCHAR(255) DEFAULT NULL,
                    `app_version` VARCHAR(50) DEFAULT '2.0.0',
                    `status` ENUM('new', 'reviewed', 'resolved', 'archived') DEFAULT 'new',
                    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    INDEX `idx_stars` (`stars`),
                    INDEX `idx_status` (`status`),
                    INDEX `idx_created_at` (`created_at`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            ");
        }
    }

    // Read input (JSON or Form POST)
    $input = json_decode(file_get_contents('php://input'), true);
    if (!is_array($input)) {
        $input = $_POST;
    }

    $stars = isset($input['stars']) ? (int)$input['stars'] : 0;
    if ($stars < 1 || $stars > 5) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Valid star rating (1-5) is required.']);
        exit;
    }

    $category = trim($input['category'] ?? 'General Feedback');
    $feedback = trim($input['feedback'] ?? ($input['feedback_text'] ?? ($input['message'] ?? '')));
    $userName = trim($input['user_name'] ?? ($input['name'] ?? 'Food CHART User'));
    $userEmail = trim($input['user_email'] ?? ($input['email'] ?? ''));
    $deviceInfo = trim($input['device_info'] ?? ($_SERVER['HTTP_USER_AGENT'] ?? 'Unknown Device'));
    $appVersion = trim($input['app_version'] ?? '2.0.0');

    if (empty($feedback)) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Feedback message cannot be empty.']);
        exit;
    }

    $stmt = $pdo->prepare("
        INSERT INTO app_ratings (stars, category, feedback_text, user_name, user_email, device_info, app_version, status, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'new', NOW())
    ");
    $stmt->execute([
        $stars,
        $category,
        $feedback,
        !empty($userName) ? $userName : 'Food CHART User',
        !empty($userEmail) ? $userEmail : null,
        !empty($deviceInfo) ? $deviceInfo : null,
        $appVersion
    ]);
    $ratingId = (int)$pdo->lastInsertId();

    http_response_code(201);
    echo json_encode([
        'status' => 'success',
        'message' => 'Thank you for your feedback! Our team will work hard to improve Food CHART.',
        'data' => [
            'id' => $ratingId,
            'stars' => $stars,
            'category' => $category,
            'created_at' => date('Y-m-d H:i:s')
        ]
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Failed to save rating: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
