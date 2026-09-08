<?php
/**
 * Food CHART Web Admin - Administrator Login Portal
 */
require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/includes/admin_auth.php';

admin_session_start();

// If already logged in, redirect straight to dashboard
if (is_admin_logged_in()) {
    header('Location: ' . BASE_URL . '/index.php');
    exit;
}

$error = '';
$usernameInput = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $usernameInput = trim($_POST['username'] ?? '');
    $passwordInput = trim($_POST['password'] ?? '');

    if (empty($usernameInput) || empty($passwordInput)) {
        $error = 'Please enter both username and password.';
    } else {
        $pdo = null;
        try {
            $pdo = get_db_connection();
        } catch (Throwable $dbErr) {
            $pdo = null;
        }

        if (attempt_admin_login($pdo, $usernameInput, $passwordInput)) {
            $admin = get_logged_in_admin();
            set_flash_message('success', 'Welcome back, ' . htmlspecialchars($admin['full_name'] ?? 'Admin') . '!');
            
            $targetUrl = $_SESSION['redirect_after_login'] ?? (BASE_URL . '/index.php');
            unset($_SESSION['redirect_after_login']);
            
            header('Location: ' . $targetUrl);
            exit;
        } else {
            $error = 'Invalid username/email or password. Please try again.';
        }
    }
}

$flash = get_flash_message();
$pageTitle = 'Admin Login';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login • Food CHART Admin Hub</title>
    <link rel="icon" type="image/png" href="<?= BASE_URL ?>/assets/images/app_icon.png">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@500;700;800;900&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Food CHART Admin Brand CSS -->
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/admin.css?v=<?= time() ?>">

    <style>
        body {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #0d0d0d radial-gradient(circle at 50% 20%, rgba(229, 9, 20, 0.15) 0%, rgba(13, 13, 13, 0.95) 70%);
            padding: 24px;
            font-family: 'Plus Jakarta Sans', sans-serif;
            color: var(--cm-text-primary);
        }

        .login-card {
            width: 100%;
            max-width: 440px;
            background: rgba(24, 24, 24, 0.92);
            backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 40px 36px;
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.8), 0 0 40px rgba(229, 9, 20, 0.12);
            animation: cmCardFadeIn 0.35s cubic-bezier(0.16, 1, 0.3, 1);
        }

        @keyframes cmCardFadeIn {
            from {
                opacity: 0;
                transform: scale(0.95) translateY(12px);
            }
            to {
                opacity: 1;
                transform: scale(1) translateY(0);
            }
        }

        .login-brand-header {
            text-align: center;
            margin-bottom: 28px;
        }

        .login-logo {
            width: 64px;
            height: 64px;
            border-radius: 16px;
            box-shadow: 0 8px 24px rgba(229, 9, 20, 0.35);
            margin-bottom: 14px;
            object-fit: cover;
        }

        .login-title {
            font-family: 'Outfit', sans-serif;
            font-size: 26px;
            font-weight: 800;
            margin: 0 0 6px 0;
            letter-spacing: -0.5px;
        }

        .login-subtitle {
            font-size: 13px;
            color: var(--cm-text-muted);
            margin: 0;
        }

        .input-group-custom {
            position: relative;
            margin-bottom: 20px;
        }

        .input-group-custom .input-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--cm-text-muted);
            font-size: 15px;
            transition: color 0.2s;
        }

        .input-group-custom .form-control {
            padding-left: 44px;
            padding-right: 44px;
            height: 48px;
            font-size: 14px;
            background: #121212;
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 12px;
            color: #FFFFFF;
            transition: all 0.2s ease;
        }

        .input-group-custom .form-control:focus {
            border-color: var(--cm-primary);
            box-shadow: 0 0 0 3px rgba(229, 9, 20, 0.25);
            background: #161616;
        }

        .input-group-custom .form-control:focus + .input-icon {
            color: var(--cm-primary);
        }

        .toggle-password-btn {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: var(--cm-text-muted);
            cursor: pointer;
            font-size: 15px;
            padding: 4px 8px;
        }

        .toggle-password-btn:hover {
            color: #FFFFFF;
        }

        .btn-signin {
            width: 100%;
            height: 50px;
            background: linear-gradient(135deg, #E50914 0%, #B20710 100%);
            color: #FFFFFF;
            font-size: 15px;
            font-weight: 800;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 8px 24px rgba(229, 9, 20, 0.4);
            transition: all 0.2s ease;
            margin-top: 24px;
        }

        .btn-signin:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(229, 9, 20, 0.55);
        }

        .btn-signin:active {
            transform: translateY(0);
        }

        .demo-chip-box {
            background: rgba(255, 179, 0, 0.08);
            border: 1px dashed rgba(255, 179, 0, 0.35);
            border-radius: 12px;
            padding: 12px 14px;
            margin-bottom: 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .demo-chip-text {
            font-size: 12px;
            color: #FFB300;
            line-height: 1.4;
        }

        .demo-fill-btn {
            background: rgba(255, 179, 0, 0.18);
            color: #FFB300;
            border: 1px solid rgba(255, 179, 0, 0.4);
            padding: 5px 10px;
            border-radius: 8px;
            font-size: 11px;
            font-weight: 800;
            cursor: pointer;
            white-space: nowrap;
            transition: all 0.2s;
        }

        .demo-fill-btn:hover {
            background: #FFB300;
            color: #000;
        }
    </style>
</head>
<body>

    <div class="login-card">
        <!-- Brand Header -->
        <div class="login-brand-header">
            <img src="<?= BASE_URL ?>/assets/images/foodchart_logo.png" alt="Food CHART Logo" class="login-logo"
                 onerror="this.onerror=null;this.src='<?= BASE_URL ?>/assets/images/app_icon.png';">
            <h1 class="login-title">
                <?= cookmate_brand_html() ?> <span style="font-weight: 400; color: #BBB;">Admin</span>
            </h1>
            <p class="login-subtitle">Sign in to manage recipes, notifications & culinary data</p>
        </div>

        <!-- Flash & Error Messages -->
        <?php if ($flash): ?>
            <div class="alert alert-<?= htmlspecialchars($flash['type']) ?>" style="margin-bottom: 20px; font-size: 13px;">
                <span><?= htmlspecialchars($flash['message']) ?></span>
            </div>
        <?php endif; ?>

        <?php if (!empty($error)): ?>
            <div class="alert alert-danger" style="margin-bottom: 20px; font-size: 13px;">
                <i class="fa-solid fa-circle-exclamation me-1"></i>
                <span><?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>

        <!-- Quick 1-Click Demo Fill Box -->
        <div class="demo-chip-box">
            <div class="demo-chip-text">
                <i class="fa-solid fa-key" style="margin-right: 4px;"></i>
                <strong>Default Credentials:</strong><br>
                <code>admin</code> &bull; <code>admin123</code>
            </div>
            <button type="button" class="demo-fill-btn" onclick="fillDemoCredentials()">
                <i class="fa-solid fa-wand-magic-sparkles"></i> Auto Fill
            </button>
        </div>

        <!-- Login Form -->
        <form method="POST" action="<?= BASE_URL ?>/login.php" id="loginForm" autocomplete="on">
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label" style="font-size: 12px; margin-bottom: 6px;">Username or Email</label>
                <div class="input-group-custom">
                    <input type="text" name="username" id="usernameInput" class="form-control" 
                           value="<?= htmlspecialchars($usernameInput) ?>" 
                           placeholder="e.g. admin or admin@foodchart.com" 
                           required autofocus autocomplete="username">
                    <i class="fa-solid fa-user input-icon"></i>
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 8px;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                    <label class="form-label" style="font-size: 12px; margin-bottom: 0;">Password</label>
                </div>
                <div class="input-group-custom">
                    <input type="password" name="password" id="passwordInput" class="form-control" 
                           placeholder="Enter your admin password" 
                           required autocomplete="current-password">
                    <i class="fa-solid fa-lock input-icon"></i>
                    <button type="button" class="toggle-password-btn" onclick="togglePasswordVisibility()" title="Show/Hide Password">
                        <i class="fa-regular fa-eye" id="eyeIcon"></i>
                    </button>
                </div>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 14px; font-size: 13px;">
                <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; color: var(--cm-text-secondary); margin: 0;">
                    <input type="checkbox" name="remember" value="1" checked style="accent-color: var(--cm-primary); width: 16px; height: 16px;">
                    <span>Remember this session</span>
                </label>
            </div>

            <button type="submit" class="btn-signin" id="submitBtn">
                <span>Sign In to Admin Hub</span>
                <i class="fa-solid fa-arrow-right-to-bracket"></i>
            </button>
        </form>

        <div style="text-align: center; margin-top: 28px; padding-top: 18px; border-top: 1px solid rgba(255,255,255,0.06); font-size: 12px; color: var(--cm-text-muted);">
            Food CHART &bull; Enterprise Culinary Admin System
        </div>
    </div>

    <script>
    function togglePasswordVisibility() {
        const pass = document.getElementById('passwordInput');
        const icon = document.getElementById('eyeIcon');
        if (pass.type === 'password') {
            pass.type = 'text';
            icon.className = 'fa-regular fa-eye-slash';
        } else {
            pass.type = 'password';
            icon.className = 'fa-regular fa-eye';
        }
    }

    function fillDemoCredentials() {
        document.getElementById('usernameInput').value = 'admin';
        document.getElementById('passwordInput').value = 'admin123';
        document.getElementById('passwordInput').focus();
    }
    </script>
</body>
</html>
