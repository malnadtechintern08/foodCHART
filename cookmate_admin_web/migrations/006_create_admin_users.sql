-- Migration: 006_create_admin_users.sql
-- Description: Creates the administrator accounts table and seeds default admin credentials.

CREATE TABLE IF NOT EXISTS `admin_users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(100) DEFAULT 'CookMate Administrator',
  `role` VARCHAR(20) DEFAULT 'superadmin',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `last_login` DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed default administrator (Username: admin | Password: admin123)
INSERT IGNORE INTO `admin_users` (`id`, `username`, `email`, `password_hash`, `full_name`, `role`)
VALUES (1, 'admin', 'admin@cookmate.com', '$2y$12$FOx7rVPAzvzR8rJU9nnXMeWTb8ljDbga2UU692rAcWs0LDAWKJnNO', 'CookMate Administrator', 'superadmin');

-- Add custom_share_text column to recipes table if not exists
ALTER TABLE `recipes` ADD COLUMN IF NOT EXISTS `custom_share_text` TEXT DEFAULT NULL AFTER `nutrition`;
