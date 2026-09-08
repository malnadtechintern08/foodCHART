<?php
/**
 * Food CHART Web Admin - Production Database Configuration Template
 * Rename or copy this file to config/db.php on your server
 */

// 1. Enter your live MySQL credentials:
define('DB_HOST', 'localhost');       // Usually 'localhost' on cPanel / shared hosts
define('DB_PORT', '3306');            // Default MySQL port is 3306
define('DB_NAME', 'your_db_name');    // e.g., 'u123456_cookmate'
define('DB_USER', 'your_db_user');    // e.g., 'u123456_admin'
define('DB_PASS', 'your_db_password');// Your MySQL user password

// 2. Base URL configuration (Optional - auto-detected by default)
// If you host at domain root (e.g., https://admin.yourdomain.com), leave as '' (auto-detected).
// If you host in a subdirectory (e.g., https://yourdomain.com/cookmate-admin), leave as auto-detected or set '/cookmate-admin'.
// define('BASE_URL', '');

// 3. phpMyAdmin link (Optional)
// define('PHPMYADMIN_URL', '/phpmyadmin/');
