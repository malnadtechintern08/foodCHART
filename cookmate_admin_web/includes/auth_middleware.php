<?php
/**
 * Food CHART - Mobile User Authentication Middleware
 * Validates Bearer tokens and resolves authenticated user identity from MySQL.
 */

require_once __DIR__ . '/../config/db.php';

function set_cors_headers(): void {
    if (!headers_sent()) {
        header('Content-Type: application/json; charset=utf-8');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Foodchart-Token, X-Cookmate-Token');
    }
}

function json_response(array $data, int $statusCode = 200): void {
    while (ob_get_level() > 0) {
        ob_end_clean();
    }
    if (!headers_sent()) {
        http_response_code($statusCode);
        header('Content-Type: application/json; charset=utf-8');
    }
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    exit;
}

function get_auth_token_from_headers(): ?string {
    $authHeader = null;

    if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = trim($_SERVER['HTTP_AUTHORIZATION']);
    } elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $authHeader = trim($_SERVER['REDIRECT_HTTP_AUTHORIZATION']);
    } elseif (isset($_SERVER['HTTP_X_FOODCHART_TOKEN'])) {
        $authHeader = 'Bearer ' . trim($_SERVER['HTTP_X_FOODCHART_TOKEN']);
    } elseif (isset($_SERVER['HTTP_X_COOKMATE_TOKEN'])) {
        $authHeader = 'Bearer ' . trim($_SERVER['HTTP_X_COOKMATE_TOKEN']);
    } elseif (function_exists('apache_request_headers')) {
        $headers = apache_request_headers();
        if (isset($headers['Authorization'])) {
            $authHeader = trim($headers['Authorization']);
        } elseif (isset($headers['authorization'])) {
            $authHeader = trim($headers['authorization']);
        } elseif (isset($headers['X-Foodchart-Token'])) {
            $authHeader = 'Bearer ' . trim($headers['X-Foodchart-Token']);
        } elseif (isset($headers['X-Cookmate-Token'])) {
            $authHeader = 'Bearer ' . trim($headers['X-Cookmate-Token']);
        }
    }

    if ($authHeader && preg_match('/Bearer\s+(\S+)/i', $authHeader, $matches)) {
        return $matches[1];
    }

    // Direct token header without Bearer prefix
    if (isset($_SERVER['HTTP_X_FOODCHART_TOKEN']) && !empty(trim($_SERVER['HTTP_X_FOODCHART_TOKEN']))) {
        return trim($_SERVER['HTTP_X_FOODCHART_TOKEN']);
    }
    if (isset($_SERVER['HTTP_X_COOKMATE_TOKEN']) && !empty(trim($_SERVER['HTTP_X_COOKMATE_TOKEN']))) {
        return trim($_SERVER['HTTP_X_COOKMATE_TOKEN']);
    }

    // Fallback to POST/GET parameter if header was stripped by web server or proxy
    if (!empty($_POST['auth_token'])) {
        return trim($_POST['auth_token']);
    }
    if (!empty($_GET['auth_token'])) {
        return trim($_GET['auth_token']);
    }

    return null;
}

function get_authenticated_user(PDO $pdo, bool $required = true, bool $autoRegister = false, ?string $displayName = null): ?array {
    $token = get_auth_token_from_headers();

    if (!$token) {
        // Fallback to user_id parameter for admin inspection & debugging
        $fallbackUserId = !empty($_GET['user_id']) ? (int)$_GET['user_id'] : (!empty($_POST['user_id']) ? (int)$_POST['user_id'] : 0);
        if ($fallbackUserId > 0) {
            $stmt = $pdo->prepare("SELECT * FROM users WHERE id = ? LIMIT 1");
            $stmt->execute([$fallbackUserId]);
            $fallbackUser = $stmt->fetch();
            if ($fallbackUser) {
                return $fallbackUser;
            }
        }

        if ($autoRegister) {
            return get_or_register_user($pdo, null, $displayName);
        }
        if ($required) {
            json_response([
                'success' => false,
                'message' => 'Authentication required. Missing Bearer token in Authorization header.'
            ], 401);
        }
        return null;
    }

    $stmt = $pdo->prepare("SELECT * FROM users WHERE auth_token = ? LIMIT 1");
    $stmt->execute([$token]);
    $user = $stmt->fetch();

    if (!$user) {
        if ($autoRegister) {
            return get_or_register_user($pdo, $token, $displayName);
        }
        if ($required) {
            json_response([
                'success' => false,
                'message' => 'Invalid or expired user session token.'
            ], 401);
        }
        return null;
    }

    return $user;
}

function get_or_register_user(PDO $pdo, ?string $token, ?string $displayName = null, ?string $deviceInfo = null): array {
    if ($token) {
        $stmt = $pdo->prepare("SELECT * FROM users WHERE auth_token = ? LIMIT 1");
        $stmt->execute([$token]);
        $existing = $stmt->fetch();
        if ($existing) {
            if ($displayName && $displayName !== $existing['display_name']) {
                $up = $pdo->prepare("UPDATE users SET display_name = ? WHERE id = ?");
                $up->execute([$displayName, $existing['id']]);
                $existing['display_name'] = $displayName;
            }
            return $existing;
        }
    }

    // If client supplied a valid formatted token string, retain it so client stays in sync!
    $cleanToken = null;
    if ($token && preg_match('/^[a-zA-Z0-9_\-\.]{8,64}$/', $token)) {
        $cleanToken = $token;
    }

    // Generate fresh secure token if no valid token provided
    $newToken = $cleanToken ?: bin2hex(random_bytes(24));
    $name = !empty($displayName) ? trim($displayName) : 'Food CHART Chef';
    $device = !empty($deviceInfo) ? trim($deviceInfo) : 'Food CHART Mobile App';

    try {
        $stmt = $pdo->prepare("INSERT INTO users (auth_token, display_name, device_info) VALUES (?, ?, ?)");
        $stmt->execute([$newToken, $name, $device]);
    } catch (PDOException $e) {
        $stmt = $pdo->prepare("INSERT INTO users (auth_token, display_name) VALUES (?, ?)");
        $stmt->execute([$newToken, $name]);
    }
    $newId = (int)$pdo->lastInsertId();

    return [
        'id' => $newId,
        'auth_token' => $newToken,
        'display_name' => $name,
        'device_info' => $device,
        'email' => null,
        'created_at' => date('Y-m-d H:i:s'),
        'updated_at' => date('Y-m-d H:i:s'),
    ];
}
