<?php
/**
 * Food CHART REST API - Contact Us Message Submission Endpoint
 * 
 * POST /api/support/contact.php
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
    // Read input (JSON or Form POST)
    $input = json_decode(file_get_contents('php://input'), true);
    if (!is_array($input)) {
        $input = $_POST;
    }

    $name = trim($input['name'] ?? '');
    $email = trim($input['email'] ?? '');
    $subject = trim($input['subject'] ?? 'General Inquiry');
    $message = trim($input['message'] ?? '');

    if (empty($name)) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Name is required.']);
        exit;
    }

    if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'A valid email address is required.']);
        exit;
    }

    if (empty($message)) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Message body cannot be empty.']);
        exit;
    }

    if (strlen($message) < 10) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Message must be at least 10 characters long.']);
        exit;
    }

    $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';

    $pdo = get_db_connection();
    $stmt = $pdo->prepare("
        INSERT INTO contact_inquiries (name, email, subject, message, status, ip_address, created_at)
        VALUES (?, ?, ?, ?, 'new', ?, NOW())
    ");
    $stmt->execute([$name, $email, $subject, $message, $ipAddress]);
    $inquiryId = (int)$pdo->lastInsertId();

    http_response_code(201);
    echo json_encode([
        'status' => 'success',
        'message' => 'Thank you! Your message has been received. The Food CHART support team will review it shortly.',
        'data' => [
            'inquiry_id' => $inquiryId,
            'name' => $name,
            'email' => $email,
            'subject' => $subject,
            'created_at' => date('Y-m-d H:i:s')
        ]
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Failed to process inquiry: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
}
