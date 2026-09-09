-- =============================================================================
-- Food CHART Admin Panel - Complete Master Database SQL Dump
-- Application: Food CHART
-- Version: 2.5.0 Production Ready
-- Compatible with: MySQL 5.7+, MySQL 8.0+, MariaDB 10.3+, InfinityFree MySQL (phpMyAdmin)
-- Default SuperAdmin Login: Username: admin | Password: admin123
-- Character Set: utf8mb4 / utf8mb4_unicode_ci
-- =============================================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- -----------------------------------------------------------------------------
-- Clean Drop Existing Tables (Reverse Dependency Order)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS `user_notifications`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `recipe_submission_tags`;
DROP TABLE IF EXISTS `recipe_submission_steps`;
DROP TABLE IF EXISTS `recipe_submission_ingredients`;
DROP TABLE IF EXISTS `recipe_submissions`;
DROP TABLE IF EXISTS `admin_activity_logs`;
DROP TABLE IF EXISTS `admins`;
DROP TABLE IF EXISTS `admin_users`;
DROP TABLE IF EXISTS `users`;
DROP TABLE IF EXISTS `product_tags`;
DROP TABLE IF EXISTS `recipe_tags`;
DROP TABLE IF EXISTS `tags`;
DROP TABLE IF EXISTS `contact_inquiries`;
DROP TABLE IF EXISTS `faqs`;
DROP TABLE IF EXISTS `support_pages`;
DROP TABLE IF EXISTS `app_ratings`;
DROP TABLE IF EXISTS `recipe_instructions`;
DROP TABLE IF EXISTS `recipe_ingredients`;
DROP TABLE IF EXISTS `recipes`;
DROP TABLE IF EXISTS `categories`;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `recipe_instructions`;
DROP TABLE IF EXISTS `recipe_ingredients`;
DROP TABLE IF EXISTS `recipes`;
DROP TABLE IF EXISTS `categories`;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE `categories` (
  `id` VARCHAR(64) PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `icon_name` VARCHAR(50) DEFAULT 'restaurant',
  `color_hex` VARCHAR(20) DEFAULT '0xFFFF6B35',
  `description` TEXT,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `recipes` (
  `id` VARCHAR(64) PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `chef_name` VARCHAR(100) DEFAULT 'Food CHART Chef',
  `cuisine` VARCHAR(100) DEFAULT 'Indian',
  `image_url` VARCHAR(500) DEFAULT '',
  `prep_time_minutes` INT DEFAULT 15,
  `cook_time_minutes` INT DEFAULT 20,
  `servings` INT DEFAULT 4,
  `difficulty` ENUM('Easy', 'Medium', 'Hard') DEFAULT 'Medium',
  `category_id` VARCHAR(64) DEFAULT 'cat_lunch_dinner',
  `tags` TEXT,
  `is_favorite` TINYINT(1) DEFAULT 0,
  `is_custom` TINYINT(1) DEFAULT 0,
  `is_vegetarian` TINYINT(1) DEFAULT 1,
  `rating` DECIMAL(3,1) DEFAULT 4.7,
  `region` VARCHAR(100) DEFAULT 'Karnataka',
  `subcategory` VARCHAR(100) DEFAULT 'Main Course',
  `nutrition` VARCHAR(255) DEFAULT '',
  `custom_share_text` TEXT DEFAULT NULL,
  `source_type` VARCHAR(32) NOT NULL DEFAULT 'admin',
  `submitted_by_user_id` INT DEFAULT NULL,
  `submission_id` INT DEFAULT NULL,
  `author_display_name` VARCHAR(100) DEFAULT NULL,
  `allow_publication` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX (`category_id`),
  INDEX (`is_vegetarian`),
  INDEX (`cuisine`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `recipe_ingredients` (
  `id` VARCHAR(64) PRIMARY KEY,
  `recipe_id` VARCHAR(64) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `amount` VARCHAR(50) DEFAULT '',
  `unit` VARCHAR(50) DEFAULT '',
  `notes` VARCHAR(255) DEFAULT '',
  `is_optional` TINYINT(1) DEFAULT 0,
  `sort_order` INT DEFAULT 0,
  INDEX (`recipe_id`),
  CONSTRAINT `fk_recipe_ingredients` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `recipe_instructions` (
  `id` VARCHAR(64) PRIMARY KEY,
  `recipe_id` VARCHAR(64) NOT NULL,
  `step_number` INT NOT NULL,
  `instruction` TEXT NOT NULL,
  `timer_seconds` INT DEFAULT 0,
  `tip` VARCHAR(255) DEFAULT '',
  INDEX (`recipe_id`),
  CONSTRAINT `fk_recipe_instructions` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `categories` (`id`, `name`, `icon_name`, `color_hex`, `description`) VALUES ('cat_malnad', 'Malnad Special', 'eco', '0xFF2E7D32', 'Traditional heritage delicacies from the misty Western Ghats of Karnataka.');
INSERT INTO `categories` (`id`, `name`, `icon_name`, `color_hex`, `description`) VALUES ('cat_breakfast', 'Breakfast', 'breakfast_dining', '0xFFFF8C42', 'Crispy dosas, fluffy idlis, hot vadas, parathas, and morning classics.');
INSERT INTO `categories` (`id`, `name`, `icon_name`, `color_hex`, `description`) VALUES ('cat_lunch_dinner', 'Lunch & Dinner', 'dinner_dining', '0xFFFF6B35', 'Aromatic biryanis, royal curries, dal tadka, and steaming rice dishes.');
INSERT INTO `categories` (`id`, `name`, `icon_name`, `color_hex`, `description`) VALUES ('cat_non_veg', 'Non-Vegetarian', 'kebab_dining', '0xFFE53935', 'Fiery chicken sukkas, rich mutton gravies, coastal fish fry, and kebabs.');
INSERT INTO `categories` (`id`, `name`, `icon_name`, `color_hex`, `description`) VALUES ('cat_snacks', 'Snacks', 'fastfood', '0xFFFFA000', 'Crunchy pakoras, golden samosas, street chaats, and evening munchies.');
INSERT INTO `categories` (`id`, `name`, `icon_name`, `color_hex`, `description`) VALUES ('cat_desserts', 'Desserts', 'cake', '0xFFEC407A', 'Decadent Gulab Jamuns, soft Mysore Pak, halwas, kheer, and sweet treats.');
INSERT INTO `categories` (`id`, `name`, `icon_name`, `color_hex`, `description`) VALUES ('cat_drinks', 'Drinks', 'local_cafe', '0xFF29B6F6', 'Tapri Masala Chai, South Indian Filter Coffee, Lassis, and coolers.');
INSERT INTO `categories` (`id`, `name`, `icon_name`, `color_hex`, `description`) VALUES ('cat_healthy', 'Healthy', 'favorite', '0xFF4CAF50', 'Nutrient-rich salads, oats, ragi dosas, quinoa, and warm wholesome soups.');

-- Insert Recipes

INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_1', 'Akki Rotti', 'Traditional Karnataka rice flour flatbread with dill, coconut and spices.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/akki_rotti.jpg', 15, 15, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 1, 0, 1, 4.7, 'Malnad, Karnataka', 'Breakfast', '187 kcal | 9g Protein | 25g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_1_ing_1', 'recipe_1', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_1_ing_2', 'recipe_1', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_1_ing_3', 'recipe_1', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_1_ing_4', 'recipe_1', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_1_ing_5', 'recipe_1', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_1_ing_6', 'recipe_1', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_1_step_1', 'recipe_1', 1, 'Prepare and measure all fresh ingredients for Akki Rotti.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_1_step_2', 'recipe_1', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_1_step_3', 'recipe_1', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 900, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_1_step_4', 'recipe_1', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Akki Rotti fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_2', 'Kotte Kadubu', 'Steamed rice cakes prepared in jackfruit leaf baskets (Kotte).', 'Malnad Aji', 'Malnad', 'assets/images/recipes/kotte_kadubu.jpg', 30, 25, 4, 'Hard', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 1, 0, 1, 4.8, 'Malnad, Karnataka', 'Breakfast', '194 kcal | 12g Protein | 30g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_2_ing_1', 'recipe_2', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_2_ing_2', 'recipe_2', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_2_ing_3', 'recipe_2', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_2_ing_4', 'recipe_2', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_2_ing_5', 'recipe_2', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_2_ing_6', 'recipe_2', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_2_step_1', 'recipe_2', 1, 'Prepare and measure all fresh ingredients for Kotte Kadubu.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_2_step_2', 'recipe_2', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_2_step_3', 'recipe_2', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_2_step_4', 'recipe_2', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Kotte Kadubu fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_3', 'Halasina Kadubu', 'Sweet jackfruit steamed cakes wrapped in aromatic leaves.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/halasina_kadubu.jpg', 20, 30, 4, 'Hard', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Dessert', '201 kcal | 15g Protein | 35g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_3_ing_1', 'recipe_3', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_3_ing_2', 'recipe_3', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_3_ing_3', 'recipe_3', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_3_ing_4', 'recipe_3', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_3_ing_5', 'recipe_3', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_3_ing_6', 'recipe_3', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_3_step_1', 'recipe_3', 1, 'Prepare and measure all fresh ingredients for Halasina Kadubu.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_3_step_2', 'recipe_3', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_3_step_3', 'recipe_3', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1800, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_3_step_4', 'recipe_3', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Halasina Kadubu fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_4', 'Halasina Hannina Idli', 'Steamed jackfruit idlis with subtle sweetness and cardamom aroma.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/halasina_hannina_idli.jpg', 20, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.9, 'Malnad, Karnataka', 'Breakfast', '208 kcal | 18g Protein | 40g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_4_ing_1', 'recipe_4', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_4_ing_2', 'recipe_4', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_4_ing_3', 'recipe_4', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_4_ing_4', 'recipe_4', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_4_ing_5', 'recipe_4', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_4_ing_6', 'recipe_4', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_4_step_1', 'recipe_4', 1, 'Prepare and measure all fresh ingredients for Halasina Hannina Idli.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_4_step_2', 'recipe_4', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_4_step_3', 'recipe_4', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_4_step_4', 'recipe_4', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Halasina Hannina Idli fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_5', 'Kesuvina Pathrode', 'Spiced colocasia leaf rolls steamed and pan-fried with coconut oil.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/kesuvina_pathrode.jpg', 25, 30, 4, 'Hard', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.6, 'Malnad, Karnataka', 'Snack', '215 kcal | 21g Protein | 45g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_5_ing_1', 'recipe_5', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_5_ing_2', 'recipe_5', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_5_ing_3', 'recipe_5', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_5_ing_4', 'recipe_5', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_5_ing_5', 'recipe_5', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_5_ing_6', 'recipe_5', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_5_step_1', 'recipe_5', 1, 'Prepare and measure all fresh ingredients for Kesuvina Pathrode.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_5_step_2', 'recipe_5', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_5_step_3', 'recipe_5', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1800, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_5_step_4', 'recipe_5', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Kesuvina Pathrode fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_6', 'Kanile Palya', 'Tender bamboo shoot stir-fry with mustard seeds, red chilies, and fresh coconut.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/kanile_palya.jpg', 20, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.7, 'Malnad, Karnataka', 'Side Dish', '222 kcal | 24g Protein | 50g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_6_ing_1', 'recipe_6', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_6_ing_2', 'recipe_6', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_6_ing_3', 'recipe_6', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_6_ing_4', 'recipe_6', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_6_ing_5', 'recipe_6', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_6_ing_6', 'recipe_6', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_6_step_1', 'recipe_6', 1, 'Prepare and measure all fresh ingredients for Kanile Palya.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_6_step_2', 'recipe_6', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_6_step_3', 'recipe_6', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_6_step_4', 'recipe_6', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Kanile Palya fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_7', 'Kanile Curry', 'Rich spiced bamboo shoot curry infused with coconut paste and malnad masala.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/kanile_curry.jpg', 20, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Main Course', '229 kcal | 27g Protein | 55g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_7_ing_1', 'recipe_7', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_7_ing_2', 'recipe_7', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_7_ing_3', 'recipe_7', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_7_ing_4', 'recipe_7', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_7_ing_5', 'recipe_7', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_7_ing_6', 'recipe_7', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_7_step_1', 'recipe_7', 1, 'Prepare and measure all fresh ingredients for Kanile Curry.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_7_step_2', 'recipe_7', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_7_step_3', 'recipe_7', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_7_step_4', 'recipe_7', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Kanile Curry fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_8', 'Huli Avalakki', 'Tangy tamarind and jaggery spiced beaten rice tempered with peanuts.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/huli_avalakki.jpg', 15, 15, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Breakfast', '236 kcal | 30g Protein | 60g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_8_ing_1', 'recipe_8', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_8_ing_2', 'recipe_8', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_8_ing_3', 'recipe_8', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_8_ing_4', 'recipe_8', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_8_ing_5', 'recipe_8', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_8_ing_6', 'recipe_8', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_8_step_1', 'recipe_8', 1, 'Prepare and measure all fresh ingredients for Huli Avalakki.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_8_step_2', 'recipe_8', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_8_step_3', 'recipe_8', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 900, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_8_step_4', 'recipe_8', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Huli Avalakki fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_9', 'Malnad Chicken Curry', 'Country chicken curry slow-cooked with roasted coconut, coriander, and black pepper.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_chicken_curry.jpg', 20, 35, 4, 'Hard', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Non-Vegetarian', 1, 0, 0, 4.9, 'Malnad, Karnataka', 'Main Course', '243 kcal | 8g Protein | 20g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_9_ing_1', 'recipe_9', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_9_ing_2', 'recipe_9', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_9_ing_3', 'recipe_9', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_9_ing_4', 'recipe_9', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_9_ing_5', 'recipe_9', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_9_ing_6', 'recipe_9', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_9_step_1', 'recipe_9', 1, 'Prepare and measure all fresh ingredients for Malnad Chicken Curry.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_9_step_2', 'recipe_9', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_9_step_3', 'recipe_9', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 2100, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_9_step_4', 'recipe_9', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Malnad Chicken Curry fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_10', 'Malnad Chicken Sukka', 'Dry roasted spicy chicken with freshly toasted spices and desiccated coconut.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_chicken_sukka.jpg', 15, 30, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Non-Vegetarian', 0, 0, 0, 4.6, 'Malnad, Karnataka', 'Main Course', '250 kcal | 11g Protein | 25g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_10_ing_1', 'recipe_10', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_10_ing_2', 'recipe_10', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_10_ing_3', 'recipe_10', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_10_ing_4', 'recipe_10', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_10_ing_5', 'recipe_10', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_10_ing_6', 'recipe_10', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_10_step_1', 'recipe_10', 1, 'Prepare and measure all fresh ingredients for Malnad Chicken Sukka.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_10_step_2', 'recipe_10', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_10_step_3', 'recipe_10', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1800, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_10_step_4', 'recipe_10', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Malnad Chicken Sukka fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_11', 'Malnad Mutton Curry', 'Rich rustic mutton curry simmered with whole spices and ginger-garlic paste.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_mutton_curry.jpg', 25, 45, 4, 'Hard', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Non-Vegetarian', 0, 0, 0, 4.7, 'Malnad, Karnataka', 'Main Course', '257 kcal | 14g Protein | 30g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_11_ing_1', 'recipe_11', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_11_ing_2', 'recipe_11', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_11_ing_3', 'recipe_11', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_11_ing_4', 'recipe_11', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_11_ing_5', 'recipe_11', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_11_ing_6', 'recipe_11', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_11_step_1', 'recipe_11', 1, 'Prepare and measure all fresh ingredients for Malnad Mutton Curry.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_11_step_2', 'recipe_11', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_11_step_3', 'recipe_11', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 2700, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_11_step_4', 'recipe_11', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Malnad Mutton Curry fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_12', 'Malnad Fish Curry', 'Fresh river fish simmered in tangy kokum and coconut gravy.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_fish_curry.jpg', 20, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Non-Vegetarian', 0, 0, 0, 4.8, 'Malnad, Karnataka', 'Main Course', '264 kcal | 17g Protein | 35g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_12_ing_1', 'recipe_12', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_12_ing_2', 'recipe_12', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_12_ing_3', 'recipe_12', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_12_ing_4', 'recipe_12', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_12_ing_5', 'recipe_12', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_12_ing_6', 'recipe_12', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_12_step_1', 'recipe_12', 1, 'Prepare and measure all fresh ingredients for Malnad Fish Curry.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_12_step_2', 'recipe_12', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_12_step_3', 'recipe_12', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_12_step_4', 'recipe_12', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Malnad Fish Curry fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_13', 'Kayi Kadubu', 'Steamed crescent dumplings stuffed with fresh coconut and jaggery filling.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/kayi_kadubu.jpg', 20, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Dessert', '271 kcal | 20g Protein | 40g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_13_ing_1', 'recipe_13', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_13_ing_2', 'recipe_13', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_13_ing_3', 'recipe_13', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_13_ing_4', 'recipe_13', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_13_ing_5', 'recipe_13', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_13_ing_6', 'recipe_13', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_13_step_1', 'recipe_13', 1, 'Prepare and measure all fresh ingredients for Kayi Kadubu.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_13_step_2', 'recipe_13', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_13_step_3', 'recipe_13', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_13_step_4', 'recipe_13', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Kayi Kadubu fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_14', 'Tambli', 'Cooling traditional yogurt and coconut-based digestive dish.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/tambli.jpg', 10, 5, 2, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 1, 0, 1, 4.9, 'Malnad, Karnataka', 'Side Dish', '278 kcal | 23g Protein | 45g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_14_ing_1', 'recipe_14', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_14_ing_2', 'recipe_14', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_14_ing_3', 'recipe_14', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_14_ing_4', 'recipe_14', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_14_ing_5', 'recipe_14', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_14_ing_6', 'recipe_14', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_14_step_1', 'recipe_14', 1, 'Prepare and measure all fresh ingredients for Tambli.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_14_step_2', 'recipe_14', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_14_step_3', 'recipe_14', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_14_step_4', 'recipe_14', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Tambli fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_15', 'Ginger Tambli', 'Zesty fresh ginger and roasted cumin yogurt broth.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/ginger_tambli.jpg', 10, 5, 2, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.6, 'Malnad, Karnataka', 'Side Dish', '285 kcal | 26g Protein | 50g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_15_ing_1', 'recipe_15', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_15_ing_2', 'recipe_15', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_15_ing_3', 'recipe_15', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_15_ing_4', 'recipe_15', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_15_ing_5', 'recipe_15', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_15_ing_6', 'recipe_15', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_15_step_1', 'recipe_15', 1, 'Prepare and measure all fresh ingredients for Ginger Tambli.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_15_step_2', 'recipe_15', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_15_step_3', 'recipe_15', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_15_step_4', 'recipe_15', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Ginger Tambli fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_16', 'Curry Leaves Tambli', 'Nutritious fresh curry leaves blended with coconut and buttermilk.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/curry_leaves_tambli.jpg', 10, 5, 2, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.7, 'Malnad, Karnataka', 'Side Dish', '292 kcal | 29g Protein | 55g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_16_ing_1', 'recipe_16', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_16_ing_2', 'recipe_16', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_16_ing_3', 'recipe_16', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_16_ing_4', 'recipe_16', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_16_ing_5', 'recipe_16', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_16_ing_6', 'recipe_16', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_16_step_1', 'recipe_16', 1, 'Prepare and measure all fresh ingredients for Curry Leaves Tambli.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_16_step_2', 'recipe_16', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_16_step_3', 'recipe_16', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_16_step_4', 'recipe_16', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Curry Leaves Tambli fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_17', 'Brahmi Tambli', 'Medicinal memory-boosting Brahmi herb tambli tempered with ghee.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/brahmi_tambli.jpg', 10, 5, 2, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Side Dish', '299 kcal | 7g Protein | 60g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_17_ing_1', 'recipe_17', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_17_ing_2', 'recipe_17', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_17_ing_3', 'recipe_17', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_17_ing_4', 'recipe_17', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_17_ing_5', 'recipe_17', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_17_ing_6', 'recipe_17', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_17_step_1', 'recipe_17', 1, 'Prepare and measure all fresh ingredients for Brahmi Tambli.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_17_step_2', 'recipe_17', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_17_step_3', 'recipe_17', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_17_step_4', 'recipe_17', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Brahmi Tambli fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_18', 'Majjige Huli', 'Ash gourd / cucumber simmered in a creamy spiced buttermilk coconut curry.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/majjige_huli.jpg', 15, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Main Course', '306 kcal | 10g Protein | 20g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_18_ing_1', 'recipe_18', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_18_ing_2', 'recipe_18', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_18_ing_3', 'recipe_18', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_18_ing_4', 'recipe_18', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_18_ing_5', 'recipe_18', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_18_ing_6', 'recipe_18', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_18_step_1', 'recipe_18', 1, 'Prepare and measure all fresh ingredients for Majjige Huli.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_18_step_2', 'recipe_18', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_18_step_3', 'recipe_18', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_18_step_4', 'recipe_18', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Majjige Huli fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_19', 'Soppina Palya', 'Fresh forest greens and amaranth sautéed with garlic, onions, and lentils.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/soppina_palya.jpg', 15, 15, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.9, 'Malnad, Karnataka', 'Side Dish', '313 kcal | 13g Protein | 25g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_19_ing_1', 'recipe_19', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_19_ing_2', 'recipe_19', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_19_ing_3', 'recipe_19', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_19_ing_4', 'recipe_19', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_19_ing_5', 'recipe_19', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_19_ing_6', 'recipe_19', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_19_step_1', 'recipe_19', 1, 'Prepare and measure all fresh ingredients for Soppina Palya.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_19_step_2', 'recipe_19', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_19_step_3', 'recipe_19', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 900, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_19_step_4', 'recipe_19', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Soppina Palya fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_20', 'Bassaru', 'Traditional strained greens broth served alongside spiced stir-fried greens.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/bassaru.jpg', 20, 30, 4, 'Hard', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.6, 'Malnad, Karnataka', 'Main Course', '320 kcal | 16g Protein | 30g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_20_ing_1', 'recipe_20', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_20_ing_2', 'recipe_20', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_20_ing_3', 'recipe_20', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_20_ing_4', 'recipe_20', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_20_ing_5', 'recipe_20', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_20_ing_6', 'recipe_20', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_20_step_1', 'recipe_20', 1, 'Prepare and measure all fresh ingredients for Bassaru.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_20_step_2', 'recipe_20', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_20_step_3', 'recipe_20', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1800, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_20_step_4', 'recipe_20', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Bassaru fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_21', 'Huruli Saaru', 'Protein-dense horse gram rasam with rustic spices and garlic.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/huruli_saaru.jpg', 20, 35, 4, 'Hard', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.7, 'Malnad, Karnataka', 'Main Course', '327 kcal | 19g Protein | 35g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_21_ing_1', 'recipe_21', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_21_ing_2', 'recipe_21', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_21_ing_3', 'recipe_21', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_21_ing_4', 'recipe_21', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_21_ing_5', 'recipe_21', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_21_ing_6', 'recipe_21', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_21_step_1', 'recipe_21', 1, 'Prepare and measure all fresh ingredients for Huruli Saaru.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_21_step_2', 'recipe_21', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_21_step_3', 'recipe_21', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 2100, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_21_step_4', 'recipe_21', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Huruli Saaru fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_22', 'Horse Gram Palya', 'Tempered horse gram cooked with onions, green chilies, and fresh grated coconut.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/horse_gram_palya.jpg', 15, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Side Dish', '334 kcal | 22g Protein | 40g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_22_ing_1', 'recipe_22', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_22_ing_2', 'recipe_22', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_22_ing_3', 'recipe_22', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_22_ing_4', 'recipe_22', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_22_ing_5', 'recipe_22', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_22_ing_6', 'recipe_22', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_22_step_1', 'recipe_22', 1, 'Prepare and measure all fresh ingredients for Horse Gram Palya.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_22_step_2', 'recipe_22', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_22_step_3', 'recipe_22', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_22_step_4', 'recipe_22', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Horse Gram Palya fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_23', 'Jackfruit Palya', 'Tender raw jackfruit stir-fry cooked with aromatic South Indian spices.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/jackfruit_palya.jpg', 20, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Side Dish', '341 kcal | 25g Protein | 45g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_23_ing_1', 'recipe_23', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_23_ing_2', 'recipe_23', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_23_ing_3', 'recipe_23', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_23_ing_4', 'recipe_23', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_23_ing_5', 'recipe_23', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_23_ing_6', 'recipe_23', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_23_step_1', 'recipe_23', 1, 'Prepare and measure all fresh ingredients for Jackfruit Palya.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_23_step_2', 'recipe_23', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_23_step_3', 'recipe_23', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_23_step_4', 'recipe_23', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Jackfruit Palya fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_24', 'Raw Jackfruit Curry', 'Hearty jackfruit chunks in a flavorful coastal coconut and tomato masala.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/raw_jackfruit_curry.jpg', 20, 30, 4, 'Hard', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.9, 'Malnad, Karnataka', 'Main Course', '348 kcal | 28g Protein | 50g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_24_ing_1', 'recipe_24', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_24_ing_2', 'recipe_24', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_24_ing_3', 'recipe_24', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_24_ing_4', 'recipe_24', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_24_ing_5', 'recipe_24', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_24_ing_6', 'recipe_24', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_24_step_1', 'recipe_24', 1, 'Prepare and measure all fresh ingredients for Raw Jackfruit Curry.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_24_step_2', 'recipe_24', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_24_step_3', 'recipe_24', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1800, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_24_step_4', 'recipe_24', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Raw Jackfruit Curry fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_25', 'Jackfruit Payasa', 'Creamy kheer made with ripe jackfruit, coconut milk, and jaggery.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/jackfruit_payasa.jpg', 15, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.6, 'Malnad, Karnataka', 'Dessert', '355 kcal | 6g Protein | 55g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_25_ing_1', 'recipe_25', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_25_ing_2', 'recipe_25', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_25_ing_3', 'recipe_25', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_25_ing_4', 'recipe_25', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_25_ing_5', 'recipe_25', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_25_ing_6', 'recipe_25', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_25_step_1', 'recipe_25', 1, 'Prepare and measure all fresh ingredients for Jackfruit Payasa.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_25_step_2', 'recipe_25', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_25_step_3', 'recipe_25', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_25_step_4', 'recipe_25', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Jackfruit Payasa fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_26', 'Halasina Hannina Mulka', 'Crispy golden fried sweet jackfruit and banana fritters.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/halasina_hannina_mulka.jpg', 15, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.7, 'Malnad, Karnataka', 'Snack', '362 kcal | 9g Protein | 60g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_26_ing_1', 'recipe_26', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_26_ing_2', 'recipe_26', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_26_ing_3', 'recipe_26', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_26_ing_4', 'recipe_26', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_26_ing_5', 'recipe_26', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_26_ing_6', 'recipe_26', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_26_step_1', 'recipe_26', 1, 'Prepare and measure all fresh ingredients for Halasina Hannina Mulka.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_26_step_2', 'recipe_26', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_26_step_3', 'recipe_26', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_26_step_4', 'recipe_26', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Halasina Hannina Mulka fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_27', 'Bamboo Shoot Fry', 'Crispy pan-fried marinated bamboo shoots seasoned with red chili and rice flour.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/bamboo_shoot_fry.jpg', 15, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Snack', '369 kcal | 12g Protein | 20g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_27_ing_1', 'recipe_27', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_27_ing_2', 'recipe_27', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_27_ing_3', 'recipe_27', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_27_ing_4', 'recipe_27', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_27_ing_5', 'recipe_27', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_27_ing_6', 'recipe_27', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_27_step_1', 'recipe_27', 1, 'Prepare and measure all fresh ingredients for Bamboo Shoot Fry.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_27_step_2', 'recipe_27', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_27_step_3', 'recipe_27', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_27_step_4', 'recipe_27', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Bamboo Shoot Fry fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_28', 'Bamboo Shoot Sambar', 'Aromatic lentil and bamboo shoot stew simmered with Malnad sambar powder.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/bamboo_shoot_sambar.jpg', 15, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Main Course', '376 kcal | 15g Protein | 25g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_28_ing_1', 'recipe_28', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_28_ing_2', 'recipe_28', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_28_ing_3', 'recipe_28', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_28_ing_4', 'recipe_28', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_28_ing_5', 'recipe_28', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_28_ing_6', 'recipe_28', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_28_step_1', 'recipe_28', 1, 'Prepare and measure all fresh ingredients for Bamboo Shoot Sambar.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_28_step_2', 'recipe_28', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_28_step_3', 'recipe_28', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_28_step_4', 'recipe_28', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Bamboo Shoot Sambar fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_29', 'Malnad Style Vegetable Sambar', 'Authentic home-style mixed vegetable sambar with freshly ground coconut paste.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_style_vegetable_sambar.jpg', 15, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.9, 'Malnad, Karnataka', 'Main Course', '383 kcal | 18g Protein | 30g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_29_ing_1', 'recipe_29', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_29_ing_2', 'recipe_29', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_29_ing_3', 'recipe_29', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_29_ing_4', 'recipe_29', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_29_ing_5', 'recipe_29', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_29_ing_6', 'recipe_29', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_29_step_1', 'recipe_29', 1, 'Prepare and measure all fresh ingredients for Malnad Style Vegetable Sambar.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_29_step_2', 'recipe_29', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_29_step_3', 'recipe_29', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_29_step_4', 'recipe_29', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Malnad Style Vegetable Sambar fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_30', 'Malnad Style Rasam', 'Spicy, peppery tomato and tamarind broth with aromatic curry leaves.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_style_rasam.jpg', 10, 15, 2, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.6, 'Malnad, Karnataka', 'Main Course', '390 kcal | 21g Protein | 35g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_30_ing_1', 'recipe_30', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_30_ing_2', 'recipe_30', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_30_ing_3', 'recipe_30', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_30_ing_4', 'recipe_30', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_30_ing_5', 'recipe_30', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_30_ing_6', 'recipe_30', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_30_step_1', 'recipe_30', 1, 'Prepare and measure all fresh ingredients for Malnad Style Rasam.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_30_step_2', 'recipe_30', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_30_step_3', 'recipe_30', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 900, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_30_step_4', 'recipe_30', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Malnad Style Rasam fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_31', 'Coconut Chutney Malnad Style', 'Fresh coconut, roasted gram, green chilies, and ginger ground to perfection.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/coconut_chutney_malnad_style.jpg', 10, 5, 2, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.7, 'Malnad, Karnataka', 'Accompaniment', '397 kcal | 24g Protein | 40g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_31_ing_1', 'recipe_31', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_31_ing_2', 'recipe_31', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_31_ing_3', 'recipe_31', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_31_ing_4', 'recipe_31', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_31_ing_5', 'recipe_31', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_31_ing_6', 'recipe_31', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_31_step_1', 'recipe_31', 1, 'Prepare and measure all fresh ingredients for Coconut Chutney Malnad Style.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_31_step_2', 'recipe_31', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_31_step_3', 'recipe_31', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_31_step_4', 'recipe_31', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Coconut Chutney Malnad Style fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_32', 'Mango Gojju', 'Sweet, sour, and spicy ripe wild mango curry with mustard and jaggery.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/mango_gojju.jpg', 15, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Accompaniment', '404 kcal | 27g Protein | 45g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_32_ing_1', 'recipe_32', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_32_ing_2', 'recipe_32', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_32_ing_3', 'recipe_32', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_32_ing_4', 'recipe_32', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_32_ing_5', 'recipe_32', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_32_ing_6', 'recipe_32', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_32_step_1', 'recipe_32', 1, 'Prepare and measure all fresh ingredients for Mango Gojju.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_32_step_2', 'recipe_32', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_32_step_3', 'recipe_32', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_32_step_4', 'recipe_32', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Mango Gojju fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_33', 'Pineapple Gojju', 'Festive sweet and tangy pineapple curry in a sesame and coconut gravy.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/pineapple_gojju.jpg', 15, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Accompaniment', '411 kcal | 30g Protein | 50g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_33_ing_1', 'recipe_33', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_33_ing_2', 'recipe_33', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_33_ing_3', 'recipe_33', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_33_ing_4', 'recipe_33', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_33_ing_5', 'recipe_33', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_33_ing_6', 'recipe_33', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_33_step_1', 'recipe_33', 1, 'Prepare and measure all fresh ingredients for Pineapple Gojju.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_33_step_2', 'recipe_33', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_33_step_3', 'recipe_33', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_33_step_4', 'recipe_33', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Pineapple Gojju fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_34', 'Appe Midi Pickle', 'King of pickles made from aromatic tender wild mangoes of Malnad.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/appe_midi_pickle.jpg', 15, 10, 4, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.9, 'Malnad, Karnataka', 'Pickle', '418 kcal | 8g Protein | 55g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_34_ing_1', 'recipe_34', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_34_ing_2', 'recipe_34', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_34_ing_3', 'recipe_34', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_34_ing_4', 'recipe_34', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_34_ing_5', 'recipe_34', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_34_ing_6', 'recipe_34', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_34_step_1', 'recipe_34', 1, 'Prepare and measure all fresh ingredients for Appe Midi Pickle.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_34_step_2', 'recipe_34', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_34_step_3', 'recipe_34', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 600, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_34_step_4', 'recipe_34', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Appe Midi Pickle fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_35', 'Malnad Lemon Pickle', 'Sun-matured whole lemons pickled with fiery Guntur red chilies and fenugreek.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_lemon_pickle.jpg', 15, 10, 4, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.6, 'Malnad, Karnataka', 'Pickle', '425 kcal | 11g Protein | 60g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_35_ing_1', 'recipe_35', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_35_ing_2', 'recipe_35', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_35_ing_3', 'recipe_35', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_35_ing_4', 'recipe_35', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_35_ing_5', 'recipe_35', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_35_ing_6', 'recipe_35', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_35_step_1', 'recipe_35', 1, 'Prepare and measure all fresh ingredients for Malnad Lemon Pickle.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_35_step_2', 'recipe_35', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_35_step_3', 'recipe_35', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 600, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_35_step_4', 'recipe_35', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Malnad Lemon Pickle fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_36', 'Kadale Chutney', 'Nutty roasted black gram chutney tempered with mustard and asafoetida.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/kadale_chutney.jpg', 10, 5, 2, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.7, 'Malnad, Karnataka', 'Accompaniment', '432 kcal | 14g Protein | 20g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_36_ing_1', 'recipe_36', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_36_ing_2', 'recipe_36', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_36_ing_3', 'recipe_36', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_36_ing_4', 'recipe_36', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_36_ing_5', 'recipe_36', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_36_ing_6', 'recipe_36', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_36_step_1', 'recipe_36', 1, 'Prepare and measure all fresh ingredients for Kadale Chutney.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_36_step_2', 'recipe_36', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_36_step_3', 'recipe_36', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_36_step_4', 'recipe_36', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Kadale Chutney fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_37', 'Ragi Mudde', 'Nutritious steamed finger millet balls, the staple powerhouse of Karnataka.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/ragi_mudde.jpg', 10, 20, 2, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Main Course', '439 kcal | 17g Protein | 25g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_37_ing_1', 'recipe_37', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_37_ing_2', 'recipe_37', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_37_ing_3', 'recipe_37', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_37_ing_4', 'recipe_37', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_37_ing_5', 'recipe_37', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_37_ing_6', 'recipe_37', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_37_step_1', 'recipe_37', 1, 'Prepare and measure all fresh ingredients for Ragi Mudde.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_37_step_2', 'recipe_37', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_37_step_3', 'recipe_37', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_37_step_4', 'recipe_37', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Ragi Mudde fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_38', 'Ragi Rotti', 'Rustic finger millet flatbread packed with onions, coriander, and green chilies.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/ragi_rotti.jpg', 15, 15, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Breakfast', '446 kcal | 20g Protein | 30g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_38_ing_1', 'recipe_38', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_38_ing_2', 'recipe_38', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_38_ing_3', 'recipe_38', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_38_ing_4', 'recipe_38', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_38_ing_5', 'recipe_38', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_38_ing_6', 'recipe_38', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_38_step_1', 'recipe_38', 1, 'Prepare and measure all fresh ingredients for Ragi Rotti.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_38_step_2', 'recipe_38', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_38_step_3', 'recipe_38', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 900, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_38_step_4', 'recipe_38', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Ragi Rotti fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_39', 'Rice Kadubu', 'Soft steamed rice dumplings ideal with spicy coconut chutney or saaru.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/rice_kadubu.jpg', 20, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.9, 'Malnad, Karnataka', 'Breakfast', '453 kcal | 23g Protein | 35g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_39_ing_1', 'recipe_39', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_39_ing_2', 'recipe_39', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_39_ing_3', 'recipe_39', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_39_ing_4', 'recipe_39', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_39_ing_5', 'recipe_39', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_39_ing_6', 'recipe_39', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_39_step_1', 'recipe_39', 1, 'Prepare and measure all fresh ingredients for Rice Kadubu.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_39_step_2', 'recipe_39', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_39_step_3', 'recipe_39', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_39_step_4', 'recipe_39', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Rice Kadubu fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_40', 'Thambittu', 'Traditional sweet balls made from roasted rice flour, jaggery, and sesame.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/thambittu.jpg', 15, 15, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.6, 'Malnad, Karnataka', 'Dessert', '460 kcal | 26g Protein | 40g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_40_ing_1', 'recipe_40', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_40_ing_2', 'recipe_40', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_40_ing_3', 'recipe_40', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_40_ing_4', 'recipe_40', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_40_ing_5', 'recipe_40', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_40_ing_6', 'recipe_40', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_40_step_1', 'recipe_40', 1, 'Prepare and measure all fresh ingredients for Thambittu.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_40_step_2', 'recipe_40', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_40_step_3', 'recipe_40', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 900, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_40_step_4', 'recipe_40', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Thambittu fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_41', 'Nuchinunde', 'Nutritious steamed spiced dal dumplings loaded with herbs and ginger.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/nuchinunde.jpg', 20, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.7, 'Malnad, Karnataka', 'Snack', '467 kcal | 29g Protein | 45g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_41_ing_1', 'recipe_41', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_41_ing_2', 'recipe_41', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_41_ing_3', 'recipe_41', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_41_ing_4', 'recipe_41', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_41_ing_5', 'recipe_41', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_41_ing_6', 'recipe_41', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_41_step_1', 'recipe_41', 1, 'Prepare and measure all fresh ingredients for Nuchinunde.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_41_step_2', 'recipe_41', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_41_step_3', 'recipe_41', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_41_step_4', 'recipe_41', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Nuchinunde fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_42', 'Shavige Bath', 'Traditional rice vermicelli tossed with mixed vegetables, mustard, and lemon.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/shavige_bath.jpg', 15, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Breakfast', '474 kcal | 7g Protein | 50g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_42_ing_1', 'recipe_42', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_42_ing_2', 'recipe_42', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_42_ing_3', 'recipe_42', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_42_ing_4', 'recipe_42', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_42_ing_5', 'recipe_42', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_42_ing_6', 'recipe_42', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_42_step_1', 'recipe_42', 1, 'Prepare and measure all fresh ingredients for Shavige Bath.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_42_step_2', 'recipe_42', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_42_step_3', 'recipe_42', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_42_step_4', 'recipe_42', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Shavige Bath fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_43', 'Malnad Coconut Rice', 'Fragrant basmati rice gently cooked with freshly grated coconut and cashews.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_coconut_rice.jpg', 15, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Main Course', '481 kcal | 10g Protein | 55g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_43_ing_1', 'recipe_43', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_43_ing_2', 'recipe_43', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_43_ing_3', 'recipe_43', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_43_ing_4', 'recipe_43', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_43_ing_5', 'recipe_43', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_43_ing_6', 'recipe_43', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_43_step_1', 'recipe_43', 1, 'Prepare and measure all fresh ingredients for Coconut Rice.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_43_step_2', 'recipe_43', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_43_step_3', 'recipe_43', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_43_step_4', 'recipe_43', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Coconut Rice fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_44', 'Mango Rice', 'Zesty tempered rice infused with grated raw mango, peanuts, and curry leaves.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/mango_rice.jpg', 15, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.9, 'Malnad, Karnataka', 'Main Course', '488 kcal | 13g Protein | 60g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_44_ing_1', 'recipe_44', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_44_ing_2', 'recipe_44', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_44_ing_3', 'recipe_44', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_44_ing_4', 'recipe_44', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_44_ing_5', 'recipe_44', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_44_ing_6', 'recipe_44', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_44_step_1', 'recipe_44', 1, 'Prepare and measure all fresh ingredients for Mango Rice.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_44_step_2', 'recipe_44', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_44_step_3', 'recipe_44', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_44_step_4', 'recipe_44', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Mango Rice fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_45', 'Malnad Puliyogare', 'Tamarind spiced rice prepared with authentic home-ground puliyogare gojju.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_puliyogare.jpg', 20, 20, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.6, 'Malnad, Karnataka', 'Main Course', '495 kcal | 16g Protein | 20g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_45_ing_1', 'recipe_45', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_45_ing_2', 'recipe_45', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_45_ing_3', 'recipe_45', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_45_ing_4', 'recipe_45', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_45_ing_5', 'recipe_45', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_45_ing_6', 'recipe_45', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_45_step_1', 'recipe_45', 1, 'Prepare and measure all fresh ingredients for Malnad Puliyogare.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_45_step_2', 'recipe_45', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_45_step_3', 'recipe_45', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1200, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_45_step_4', 'recipe_45', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Malnad Puliyogare fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_46', 'Kadubu with Coconut Chutney', 'Steamed cylindrical rice cakes served with fresh green coconut chutney.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/kadubu_with_coconut_chutney.jpg', 20, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.7, 'Malnad, Karnataka', 'Breakfast', '502 kcal | 19g Protein | 25g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_46_ing_1', 'recipe_46', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_46_ing_2', 'recipe_46', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_46_ing_3', 'recipe_46', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_46_ing_4', 'recipe_46', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_46_ing_5', 'recipe_46', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_46_ing_6', 'recipe_46', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_46_step_1', 'recipe_46', 1, 'Prepare and measure all fresh ingredients for Kadubu with Coconut Chutney.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_46_step_2', 'recipe_46', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_46_step_3', 'recipe_46', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_46_step_4', 'recipe_46', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Kadubu with Coconut Chutney fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_47', 'Avarekalu Saaru', 'Seasonal winter hyacinth bean gravy with Malnad masala.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/avarekalu_saaru.jpg', 20, 30, 4, 'Hard', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Main Course', '509 kcal | 22g Protein | 30g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_47_ing_1', 'recipe_47', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_47_ing_2', 'recipe_47', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_47_ing_3', 'recipe_47', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_47_ing_4', 'recipe_47', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_47_ing_5', 'recipe_47', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_47_ing_6', 'recipe_47', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_47_step_1', 'recipe_47', 1, 'Prepare and measure all fresh ingredients for Avarekalu Saaru.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_47_step_2', 'recipe_47', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_47_step_3', 'recipe_47', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1800, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_47_step_4', 'recipe_47', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Avarekalu Saaru fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_48', 'Sabsige Soppu Palya', 'Healthy stir-fry of fresh dill leaves, moong dal, and grated coconut.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/sabsige_soppu_palya.jpg', 10, 15, 2, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.8, 'Malnad, Karnataka', 'Side Dish', '516 kcal | 25g Protein | 35g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_48_ing_1', 'recipe_48', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_48_ing_2', 'recipe_48', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_48_ing_3', 'recipe_48', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_48_ing_4', 'recipe_48', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_48_ing_5', 'recipe_48', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_48_ing_6', 'recipe_48', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_48_step_1', 'recipe_48', 1, 'Prepare and measure all fresh ingredients for Sabsige Soppu Palya.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_48_step_2', 'recipe_48', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_48_step_3', 'recipe_48', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 900, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_48_step_4', 'recipe_48', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Sabsige Soppu Palya fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_49', 'Menthya Soppu Palya', 'Nutritious fresh fenugreek leaves stir-fried with onions and mild spices.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/menthya_soppu_palya.jpg', 10, 15, 2, 'Easy', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.9, 'Malnad, Karnataka', 'Side Dish', '523 kcal | 28g Protein | 40g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_49_ing_1', 'recipe_49', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_49_ing_2', 'recipe_49', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_49_ing_3', 'recipe_49', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_49_ing_4', 'recipe_49', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_49_ing_5', 'recipe_49', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_49_ing_6', 'recipe_49', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_49_step_1', 'recipe_49', 1, 'Prepare and measure all fresh ingredients for Menthya Soppu Palya.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_49_step_2', 'recipe_49', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_49_step_3', 'recipe_49', 3, 'Cook or simmer over balanced heat (low-medium flame) to release authentic flavors and aromas.', 900, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_49_step_4', 'recipe_49', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Menthya Soppu Palya fresh and warm.', 120, '');
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_50', 'Malnad Vegetable Kurma', 'Creamy coconut and poppy seed vegetable kurma, perfect with akki rotti or pooris.', 'Malnad Aji', 'Malnad', 'assets/images/recipes/malnad_vegetable_kurma.jpg', 20, 25, 4, 'Medium', 'cat_malnad', 'Malnad Special,Karnataka,Heritage,South Indian,Vegetarian', 0, 0, 1, 4.6, 'Malnad, Karnataka', 'Main Course', '180 kcal | 6g Protein | 45g Carbs');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_50_ing_1', 'recipe_50', 'Primary ingredient (Rice/Veg/Greens)', '2.0', 'cups', '', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_50_ing_2', 'recipe_50', 'Fresh grated coconut', '0.5', 'cup', '', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_50_ing_3', 'recipe_50', 'Malnad spice blend / Cumin', '1.0', 'tsp', '', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_50_ing_4', 'recipe_50', 'Green chilies / Red chilies', '3.0', 'pieces', '', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_50_ing_5', 'recipe_50', 'Curry leaves & Mustard seeds', '1.0', 'tbsp', '', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_50_ing_6', 'recipe_50', 'Salt to taste', '1.0', 'tsp', '', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_50_step_1', 'recipe_50', 1, 'Prepare and measure all fresh ingredients for Malnad Vegetable Kurma.', 180, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_50_step_2', 'recipe_50', 2, 'Combine the key base ingredients with aromatic spices and seasoning according to traditional technique.', 300, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_50_step_3', 'recipe_50', 3, 'Cook or simmer over balanced heat (medium flame) to release authentic flavors and aromas.', 1500, '');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_50_step_4', 'recipe_50', 4, 'Garnish with fresh herbs, roasted nuts, or tempering, and serve Malnad Vegetable Kurma fresh and warm.', 120, '');

-- =============================================================================
-- 5. TAGS & HASHTAG DISCOVERY TABLES
-- =============================================================================
CREATE TABLE IF NOT EXISTS `tags` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `usage_count` INT NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_tag_name` (`name`),
  INDEX `idx_tag_slug` (`slug`),
  INDEX `idx_tag_usage` (`usage_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recipe_tags` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `recipe_id` VARCHAR(64) NOT NULL,
  `tag_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_recipe_tag` (`recipe_id`, `tag_id`),
  INDEX `idx_rt_recipe_id` (`recipe_id`),
  INDEX `idx_rt_tag_id` (`tag_id`),
  CONSTRAINT `fk_rt_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_rt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `product_tags` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `product_id` VARCHAR(64) NOT NULL,
  `tag_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_product_tag` (`product_id`, `tag_id`),
  INDEX `idx_pt_product_id` (`product_id`),
  INDEX `idx_pt_tag_id` (`tag_id`),
  CONSTRAINT `fk_pt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tags` (`id`, `name`, `slug`, `usage_count`) VALUES
(1, 'MalnadSpecial', 'malnadspecial', 33),
(2, 'SouthIndian', 'southindian', 24),
(3, 'Breakfast', 'breakfast', 15),
(4, 'PureVegetarian', 'purevegetarian', 29),
(5, 'NonVegetarian', 'nonvegetarian', 4),
(6, 'Healthy', 'healthy', 12),
(7, 'QuickBites', 'quickbites', 10),
(8, 'Traditional', 'traditional', 20),
(9, 'SpicyCurry', 'spicycurry', 8),
(10, 'Desserts', 'desserts', 6);

-- =============================================================================
-- 6. AUTHENTICATION & USERS (Admins & App Contributors)
-- =============================================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `auth_token` VARCHAR(64) UNIQUE NOT NULL,
  `display_name` VARCHAR(100) NOT NULL DEFAULT 'Food CHART Chef',
  `email` VARCHAR(255) NULL,
  `device_info` VARCHAR(255) NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_user_auth_token` (`auth_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `admins` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(64) UNIQUE NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `role` VARCHAR(32) NOT NULL DEFAULT 'admin',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `admin_users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(100) DEFAULT 'Food CHART Admin',
  `role` VARCHAR(20) DEFAULT 'superadmin',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `last_login` DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed Default Admin Credentials (Username: admin | Password: admin123)
INSERT INTO `admin_users` (`id`, `username`, `email`, `password_hash`, `full_name`, `role`)
VALUES (1, 'admin', 'admin@foodchart.com', '$2y$12$FOx7rVPAzvzR8rJU9nnXMeWTb8ljDbga2UU692rAcWs0LDAWKJnNO', 'Food CHART Admin', 'superadmin');

INSERT INTO `admins` (`id`, `username`, `name`, `email`, `role`)
VALUES (1, 'admin', 'Food CHART Admin', 'admin@foodchart.com', 'superadmin');

INSERT INTO `users` (`id`, `auth_token`, `display_name`, `email`, `device_info`)
VALUES (1, 'foodchart_user_guest_001', 'Food CHART Guest', 'guest@foodchart.com', 'Food CHART Android Client');

-- =============================================================================
-- 7. RECIPE SUBMISSIONS & MODERATION SYSTEM
-- =============================================================================
CREATE TABLE IF NOT EXISTS `recipe_submissions` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `recipe_name` VARCHAR(255) NOT NULL,
  `description` TEXT NULL,
  `category_id` VARCHAR(64) NOT NULL,
  `image` VARCHAR(500) NULL,
  `preparation_time` INT NOT NULL DEFAULT 15,
  `cooking_time` INT NOT NULL DEFAULT 20,
  `difficulty` VARCHAR(32) NOT NULL DEFAULT 'Medium',
  `servings` INT NOT NULL DEFAULT 4,
  `cuisine` VARCHAR(100) NOT NULL DEFAULT 'Homemade',
  `food_type` VARCHAR(32) NOT NULL DEFAULT 'Vegetarian',
  `notes` TEXT NULL,
  `status` ENUM('pending', 'under_review', 'changes_requested', 'approved', 'rejected', 'published') NOT NULL DEFAULT 'pending',
  `allow_publication` TINYINT(1) NOT NULL DEFAULT 0,
  `show_author_name` TINYINT(1) NOT NULL DEFAULT 0,
  `author_display_name` VARCHAR(100) NULL,
  `permission_given_at` DATETIME NULL,
  `permission_version` VARCHAR(16) DEFAULT 'v1.0',
  `admin_notes` TEXT NULL,
  `rejection_reason` TEXT NULL,
  `published_recipe_id` VARCHAR(64) NULL,
  `submitted_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` DATETIME NULL,
  `reviewed_by` INT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_submissions_user_id` (`user_id`),
  INDEX `idx_submissions_status` (`status`),
  INDEX `idx_submissions_category` (`category_id`),
  INDEX `idx_submissions_published_recipe` (`published_recipe_id`),
  CONSTRAINT `fk_submission_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_submission_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_submission_admin` FOREIGN KEY (`reviewed_by`) REFERENCES `admins` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recipe_submission_ingredients` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `submission_id` INT NOT NULL,
  `ingredient` VARCHAR(255) NOT NULL,
  `quantity` VARCHAR(64) NOT NULL DEFAULT '1',
  `unit` VARCHAR(32) NOT NULL DEFAULT '',
  `position` INT NOT NULL DEFAULT 1,
  INDEX `idx_sub_ing_submission` (`submission_id`),
  CONSTRAINT `fk_sub_ing_submission` FOREIGN KEY (`submission_id`) REFERENCES `recipe_submissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recipe_submission_steps` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `submission_id` INT NOT NULL,
  `step_number` INT NOT NULL,
  `instruction` TEXT NOT NULL,
  `timer_seconds` INT NOT NULL DEFAULT 0,
  INDEX `idx_sub_step_submission` (`submission_id`),
  CONSTRAINT `fk_sub_step_submission` FOREIGN KEY (`submission_id`) REFERENCES `recipe_submissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recipe_submission_tags` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `submission_id` INT NOT NULL,
  `tag_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_submission_tag` (`submission_id`, `tag_id`),
  INDEX `idx_sub_tag_submission` (`submission_id`),
  INDEX `idx_sub_tag_tag` (`tag_id`),
  CONSTRAINT `fk_sub_tag_submission` FOREIGN KEY (`submission_id`) REFERENCES `recipe_submissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_sub_tag_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `admin_activity_logs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `admin_id` INT NOT NULL DEFAULT 1,
  `action` VARCHAR(100) NOT NULL,
  `submission_id` INT NULL,
  `details` TEXT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_log_action` (`action`),
  INDEX `idx_log_submission` (`submission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 8. NOTIFICATIONS ENGINE & USER DELIVERY STATUS
-- =============================================================================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `type` VARCHAR(50) NOT NULL DEFAULT 'general',
  `target_type` VARCHAR(32) NOT NULL DEFAULT 'all',
  `target_user_id` INT NULL,
  `related_type` VARCHAR(50) NULL,
  `related_id` VARCHAR(100) NULL,
  `image` VARCHAR(500) NULL,
  `action_label` VARCHAR(100) NULL,
  `status` ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  `created_by_admin_id` INT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expires_at` DATETIME NULL,
  INDEX `idx_notif_status` (`status`),
  INDEX `idx_notif_created_at` (`created_at`),
  INDEX `idx_notif_target` (`target_type`, `target_user_id`),
  INDEX `idx_notif_related` (`related_type`, `related_id`),
  CONSTRAINT `fk_notif_target_user` FOREIGN KEY (`target_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_notif_admin` FOREIGN KEY (`created_by_admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_notifications` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `notification_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `read_at` DATETIME NULL,
  `is_dismissed` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uq_notif_user` (`notification_id`, `user_id`),
  INDEX `idx_un_user` (`user_id`),
  INDEX `idx_un_notification` (`notification_id`),
  INDEX `idx_un_read_status` (`is_read`),
  INDEX `idx_un_read_at` (`read_at`),
  INDEX `idx_un_user_read` (`user_id`, `is_read`, `read_at`),
  CONSTRAINT `fk_un_notification` FOREIGN KEY (`notification_id`) REFERENCES `notifications` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_un_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `notifications` (`id`, `title`, `message`, `type`, `target_type`, `target_user_id`, `related_type`, `related_id`, `image`, `status`, `created_by_admin_id`, `created_at`)
VALUES 
(1, 'New Recipe Added 🍲', 'Chicken Ghee Roast is now available on Food CHART. Explore this authentic coastal delicacy!', 'new_recipe', 'all', NULL, 'recipe', 'rec_chicken_ghee_roast', 'assets/images/recipes/chicken_ghee_roast.jpg', 'active', 1, NOW()),
(2, '✨ Recipe Updated', 'Masala Dosa recipe has brand new step-by-step cooking instructions and crispiness tips.', 'recipe_updated', 'all', NULL, 'recipe', 'rec_masala_dosa', 'assets/images/recipes/masala_dosa.jpg', 'active', 1, NOW()),
(3, '🚀 New Feature: #Hashtag Search', 'You can now discover recipes instantly by tapping trending culinary tags like #MalnadSpecial, #QuickBreakfast, and #WeekendFeast.', 'new_feature', 'all', NULL, 'feature', 'hashtags', NULL, 'active', 1, NOW()),
(4, '📢 Food CHART Community Update', 'Welcome to the new interactive notification center. Stay up to date with new recipes, approvals, and kitchen tips!', 'admin_announcement', 'all', NULL, 'general', NULL, NULL, 'active', 1, NOW());

-- =============================================================================
-- 9. SUPPORT PAGES, FAQS, CONTACT INQUIRIES & USER FEEDBACK
-- =============================================================================
CREATE TABLE IF NOT EXISTS `support_pages` (
  `id` VARCHAR(64) PRIMARY KEY,
  `title` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(64) UNIQUE NOT NULL,
  `summary` VARCHAR(500) NULL,
  `content` LONGTEXT NOT NULL,
  `meta_json` LONGTEXT NULL,
  `is_published` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_page_slug` (`slug`),
  INDEX `idx_page_published` (`is_published`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `faqs` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `category` VARCHAR(100) NOT NULL DEFAULT 'General',
  `question` VARCHAR(500) NOT NULL,
  `answer` TEXT NOT NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `is_published` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_faq_category` (`category`),
  INDEX `idx_faq_published` (`is_published`),
  INDEX `idx_faq_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `contact_inquiries` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL,
  `subject` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `status` ENUM('new', 'read', 'replied', 'archived') NOT NULL DEFAULT 'new',
  `ip_address` VARCHAR(45) NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_inquiry_status` (`status`),
  INDEX `idx_inquiry_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- Seed Support Pages
INSERT INTO `support_pages` (`id`, `title`, `slug`, `summary`, `content`, `meta_json`, `is_published`)
VALUES 
(
  'privacy-policy',
  'Privacy Policy',
  'privacy-policy',
  'Understand how Food CHART collects, protects, and respects your culinary and device data.',
  '# Food CHART Privacy Policy\n\n**Effective Date:** January 1, 2026\n**Last Updated:** September 7, 2026\n\nWelcome to **Food CHART**, your personal culinary and recipe companion dedicated to preserving authentic heritage cuisine. Your privacy is paramount to us. This Privacy Policy explains our practices regarding the collection, use, and disclosure of your information when you use our mobile application and website services.\n\n---\n\n### 1. Information We Collect\nFood CHART is built with an **offline-first philosophy**. We minimize data collection to provide you with a seamless cooking experience:\n- **Device Preferences:** Selected theme mode (Dark/Light), active language preference, and serving multiplier.\n- **Local Culinary Data:** Favorites, recently viewed recipes, smart shopping lists, and personal kitchen notes are stored directly on your device\'s local database (SQLite) and are never transmitted to external servers without your permission.\n- **Recipe Submissions & Community Contributions:** When you voluntarily submit a recipe or feedback, we collect your contributor name, recipe details, ingredient measurements, preparation steps, and optional dish photos.\n- **Technical & Diagnostics:** Minimal anonymous performance logs and crash metrics to keep Food CHART fast and reliable.\n\n---\n\n### 2. Device Permissions\nFood CHART only requests permissions strictly necessary to deliver app features:\n- **Camera & Photo Gallery:** Used solely when you choose to attach or take a photo for recipe submissions or dish notes. Photos remain private unless you publish them in a community submission.\n- **Notifications:** Used only to send you timer alerts during cooking and updates on your recipe submissions (you can disable these anytime in device settings).\n- **Storage / Files:** Used for exporting or backing up your notes and shopping list.\n\n---\n\n### 3. How We Use Your Information\nWe use collected information exclusively to:\n1. Provide, maintain, and enhance the recipe discovery and cooking experience.\n2. Review, verify, and publish community recipes with proper contributor credit.\n3. Send cooking timer notifications and submission status updates.\n4. Detect security issues and prevent fraudulent or abusive submissions.\n\nWe **NEVER** sell, rent, or trade your personal data to third-party advertisers.\n\n---\n\n### 4. Data Storage and Security\nWe utilize industry-standard cryptographic practices (SSL/TLS encryption in transit, strict parameterized database queries) to protect any information submitted to our servers. Local app data stays encrypted and isolated within your device sandbox.\n\n---\n\n### 5. Your Rights and Choices\n- **Access & Correction:** You can review and edit your submissions, favorites, notes, and preferences directly within the app.\n- **Data Reset:** You can reset local catalog cache or delete your locally stored notes and shopping list at any time through **Settings > Offline Database > Reset Data**.\n- **Inquiries & Deletion:** To request deletion of your published community submission or contact data, please reach out via our **Contact Us** screen or email `privacy@foodchart.com`.\n\n---\n\n### 6. Updates to This Policy\nWe may periodically update this policy to reflect new features or regulatory requirements. Changes will be posted in this section with an updated revision date.',
  '{"version":"2.1","contact_email":"privacy@foodchart.com","jurisdiction":"India"}',
  1
),
(
  'contact-us',
  'Contact Us',
  'contact-us',
  'Get in touch with the Food CHART team for recipe help, partnership inquiries, or app feedback.',
  '### We Would Love to Hear From You!\n\nWhether you have questions about authentic recipes, want to report a bug, suggest new culinary features, or collaborate with our culinary research team, our friendly team is here to assist you.',
  '{"support_email":"support@foodchart.com","press_email":"press@foodchart.com","phone":"+91 (80) 4567-8900","whatsapp":"+91 98765 43210","address":"Food CHART Culinary Labs, 4th Floor, Brigade Gateway, Malleshwaram, Bengaluru, Karnataka 560055, India","hours":"Monday – Saturday: 9:00 AM – 6:00 PM IST","social":{"instagram":"@foodchart_app","twitter":"@FoodChartApp","youtube":"FoodChartKitchen"}}',
  1
),
(
  'help-center',
  'Help Center',
  'help-center',
  'Explore guides, step-by-step tutorials, and tips for making the most out of Food CHART.',
  '# Food CHART Help Center & User Guide\n\nFind answers, tutorials, and practical tips on using Food CHART to master everyday cooking and authentic heritage recipes.\n\n---\n\n### 1. Discovering & Filtering Recipes\n- **Heritage Categories:** Browse collections like Malnad Special, South Indian Breakfast, Royal Curries, Snacks, and Healthy Millets.\n- **Smart Filters:** Filter by Pure Vegetarian / Non-Vegetarian, Difficulty (Easy, Medium, Hard), and Cooking Time.\n- **Hashtag Search:** Tap any hashtag (e.g. `#MalnadSpecial`, `#DosaLove`) to view all recipes tagged with that theme.\n\n---\n\n### 2. Interactive Cooking Mode\n- When viewing a recipe, tap **Start Cooking Mode**.\n- Navigate through steps with large readable text designed for kitchen counters.\n- Built-in interactive timers ring and vibrate when simmering, boiling, or baking steps finish.\n\n---\n\n### 3. Shopping List & Dynamic Servings\n- Adjust the servings counter on any recipe; ingredient quantities dynamically re-scale automatically.\n- Tap **Add to Shopping List** to send missing items to your smart grocery checklist, organized by aisle.\n\n---\n\n### 4. Submitting Your Recipes\n- Tap the **+** button in My Kitchen or Recipe Submissions.\n- Fill in the title, preparation time, servings, step-by-step instructions, and upload a dish photo.\n- Our editorial team reviews submissions within 24-48 hours. Track real-time review progress under **My Submissions**.\n\n---\n\n### 5. Offline Access & Data Sync\n- Food CHART works **100% offline**. You can view recipes, use timers, and manage notes without cellular or Wi-Fi connectivity.\n- When internet is available, tap the sync icon to fetch newly approved recipes and notification announcements.',
  '{"topics":["Discovering Recipes","Interactive Cooking Mode","Dynamic Servings","Submitting Recipes","Offline First"]}',
  1
),
(
  'safety-guidelines',
  'Safety and Guidelines',
  'safety-guidelines',
  'Essential kitchen safety, food hygiene, allergen information, and community recipe guidelines.',
  '# Safety, Hygiene & Community Guidelines\n\nAt Food CHART, your health and safety in the kitchen are just as important as the delicious dishes you prepare. Please review these essential guidelines.\n\n---\n\n### 1. Food Hygiene & Preparation Safety\n- **Hand Washing:** Always wash hands with soap and warm water for at least 20 seconds before and after handling raw ingredients.\n- **Cross-Contamination:** Use separate cutting boards and knives for raw poultry/meat/fish and fresh vegetables/cooked foods.\n- **Safe Internal Temperatures:** Ensure meat, poultry, and seafood are cooked to safe minimum internal temperatures (Poultry: 74°C / 165°F; Ground Meat: 71°C / 160°F; Fish: 63°C / 145°F).\n- **Storing Leftovers:** Refrigerate cooked dishes within two hours of preparation in airtight glass or food-safe containers. Reheat thoroughly before eating.\n\n---\n\n### 2. Kitchen Appliance & Equipment Safety\n- **Pressure Cookers:** Always inspect steam vents, safety valves, and rubber gaskets before sealing. Never force open a hot pressure cooker; wait until pressure drops naturally.\n- **Hot Oil & Deep Frying:** Keep pan handles turned inward. Never pour water onto oil fires; use a lid or fire blanket.\n- **Sharp Knives:** Keep knives honed and sharp. Cut on stable cutting boards placed on a damp cloth to prevent slipping.\n\n---\n\n### 3. Allergen Awareness & Ingredient Substitutions\n- Many authentic Indian recipes feature tree nuts (cashews, almonds), dairy (ghee, paneer, milk), mustard seeds, or gluten.\n- Always review recipe tags and allergen notices if cooking for individuals with food allergies.\n- Feel free to use healthy substitutes (e.g. oil instead of ghee for vegan cooking, coconut milk instead of dairy cream).\n\n---\n\n### 4. Community Recipe Submission Standards\nWhen submitting recipes to Food CHART, contributors agree to uphold our community trust:\n- **Authenticity:** Submit accurate ingredients, realistic cooking times, and clear step-by-step instructions.\n- **Originality:** Share your own recipes or traditional family techniques. Do not copy copyrighted text from books or commercial websites.\n- **Photo Quality:** Upload genuine, high-quality photos of the actual prepared dish. Stock photos or irrelevant images will be rejected.\n- **Respectful Content:** Promotional spam, non-food advertisements, and abusive language are strictly prohibited.',
  '{"emergency_phone":"112 / 108","allergen_notice_enabled":true}',
  1
);

-- Seed FAQs
INSERT INTO `faqs` (`category`, `question`, `answer`, `sort_order`, `is_published`)
VALUES
(
  'General',
  'What is Food CHART and who is it for?',
  'Food CHART is an all-in-one culinary companion designed for food enthusiasts, home cooks, and lovers of authentic regional cuisine. It brings together heritage recipes (such as Malnad specialties) alongside modern pan-Indian classics with offline support, step-by-step timers, and smart grocery checklists.',
  1,
  1
),
(
  'General',
  'Does Food CHART work without an internet connection?',
  'Yes! Food CHART is built offline-first. All core recipes, instructions, ingredients, notes, and timers function completely offline. An internet connection is only needed when syncing newly published community recipes or submitting your own recipes for review.',
  2,
  1
),
(
  'Recipes & Cooking',
  'Can I adjust the recipe servings?',
  'Absolutely. When viewing any recipe details page, tap the plus (+) or minus (-) buttons next to Servings. All ingredient quantities automatically calculate and scale in real time.',
  3,
  1
),
(
  'Recipes & Cooking',
  'How do the cooking timers work?',
  'In both the Recipe Details screen and the interactive Cooking Mode, recipe steps with cooking times show a timer button. Tapping it activates a countdown timer with audio-haptic feedback so you never overcook or burn dishes.',
  4,
  1
),
(
  'Submissions',
  'How do I submit my own family recipe to Food CHART?',
  'Navigate to "My Kitchen" or the side drawer and select "Submit Recipe". Enter the title, preparation time, servings, ingredients, instructions, and optionally upload a photo of your dish. Once submitted, our editorial team reviews it before publishing it to the community.',
  5,
  1
),
(
  'Submissions',
  'How long does recipe moderation take?',
  'Our culinary moderation team typically reviews submitted recipes within 24 to 48 hours. You will receive an in-app status notification once your recipe is approved or if modifications are suggested.',
  6,
  1
),
(
  'Dietary & Health',
  'How can I find Pure Vegetarian recipes?',
  'You can tap the "Pure Veg" toggle chip on the Explore or All Recipes screen. Every recipe is also marked with a green indicator for Pure Veg or red for Non-Veg.',
  7,
  1
),
(
  'Dietary & Health',
  'Are nutritional facts available for recipes?',
  'Yes! Each recipe includes estimated calories, protein, and carbohydrates per serving to assist with your meal planning.',
  8,
  1
),
(
  'App & Account',
  'Can I save my favorite recipes and personal notes?',
  'Yes. Tap the heart icon on any recipe to add it to Favorites. You can also write personal cooking notes, secret variations, and tips under the "My Notes" section in settings.',
  9,
  1
),
(
  'App & Account',
  'How do I contact customer support?',
  'You can reach our team anytime via the "Contact Us" screen in the app, or send an email directly to support@foodchart.com.',
  10,
  1
);

-- Seed Ratings / Feedback
INSERT INTO `app_ratings` (`stars`, `category`, `feedback_text`, `user_name`, `user_email`, `device_info`, `app_version`, `status`)
VALUES
(5, 'Cooking Experience', 'Loving the offline support and precise cooking timers! Very helpful for everyday cooking.', 'Ananya Sharma', 'ananya.s@gmail.com', 'Android 14 (Pixel 8)', '2.5.0', 'reviewed'),
(5, 'Authentic Recipes', 'The Malnad recipes are incredibly authentic. Akki Rotti turns out perfect every single time.', 'Raghavendra Rao', 'raghav.rao@outlook.com', 'Android 13 (Samsung S23)', '2.5.0', 'reviewed');

SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================================
-- 60 Authentic Turnkey Food CHART Recipes (10 Breakfast, 10 Desserts, 10 Drinks, 10 Healthy, 10 Non-Veg, 10 Snacks)
-- =============================================================================

DELETE FROM `recipes` WHERE `id` = 'recipe_51';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_51', 'Crispy Masala Dosa', 'Crispy golden fermented crepe stuffed with spiced mashed potato bhaji, served with coconut chutney and piping hot sambar.', 'Chef Ramesh Rao', 'South Indian', 'assets/images/recipes/masala_dosa.jpg', 20, 15, 4, 'Medium', 'cat_breakfast', 'Breakfast,Dosa,South Indian,Crispy,Vegetarian,Popular', 1, 0, 1, 4.9, 'Karnataka', 'Dosa', '285 kcal | 6g Protein | 42g Carbs | 10g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_51_ing_1', 'recipe_51', 'Dosa batter (fermented rice & urad dal)', '3', 'cups', 'Fermented overnight', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_51_ing_2', 'recipe_51', 'Boiled potatoes, cubed', '4', 'medium', 'Mashed coarsely', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_51_ing_3', 'recipe_51', 'Onions, finely sliced', '2', 'medium', 'Sauteed until translucent', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_51_ing_4', 'recipe_51', 'Green chilies, chopped', '3', 'pieces', 'Adjust to spice preference', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_51_ing_5', 'recipe_51', 'Mustard seeds and curry leaves', '1', 'tsp', 'For tempering', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_51_ing_6', 'recipe_51', 'Pure ghee or butter', '3', 'tbsp', 'For crispy golden edges', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_51_step_1', 'recipe_51', 1, 'Heat an iron tawa until smoking, sprinkle water to temper, and pour a ladle of batter.', 120, 'Spread in thin circular motions outwards.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_51_step_2', 'recipe_51', 2, 'Drizzle ghee around the edges and cook on medium-high until the base turns deep golden brown.', 180, 'Use medium heat for consistent crispiness.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_51_step_3', 'recipe_51', 3, 'Place a generous spoonful of potato bhaji in the center, fold over, and serve hot.', 60, 'Pair immediately with fresh coconut chutney and sambar.');

DELETE FROM `recipes` WHERE `id` = 'recipe_52';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_52', 'Soft Idli Sambar', 'Steamed pillow-soft rice cakes served soaked in piping hot vegetable lentil stew and fresh coconut chutney.', 'Chef Ananya Iyer', 'South Indian', 'assets/images/recipes/idli_sambar.jpg', 15, 15, 4, 'Easy', 'cat_breakfast', 'Breakfast,Idli,Healthy,South Indian,Steamed,Vegetarian', 1, 0, 1, 4.8, 'Tamil Nadu', 'Idli', '160 kcal | 5g Protein | 32g Carbs | 1g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_52_ing_1', 'recipe_52', 'Idli batter (parboiled rice & whole urad dal)', '3', 'cups', 'Well-fermented and airy', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_52_ing_2', 'recipe_52', 'Toor dal (split pigeon peas)', '1', 'cup', 'Boiled and mashed', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_52_ing_3', 'recipe_52', 'Mixed vegetables (drumstick, carrot, pumpkin)', '1.5', 'cups', 'Diced', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_52_ing_4', 'recipe_52', 'Sambar powder', '2', 'tbsp', 'Freshly roasted blend', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_52_ing_5', 'recipe_52', 'Tamarind pulp', '2', 'tbsp', 'Soaked in warm water', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_52_ing_6', 'recipe_52', 'Coriander leaves and curry leaves', '0.25', 'cup', 'Freshly chopped', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_52_step_1', 'recipe_52', 1, 'Grease idli molds with sesame oil or ghee and pour batter into each cavity.', 60, 'Do not overfill as idlis will rise.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_52_step_2', 'recipe_52', 2, 'Steam in an idli pot or pressure cooker without whistle for 10-12 minutes.', 660, 'Check with a toothpick; it should come out clean.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_52_step_3', 'recipe_52', 3, 'Simmer cooked lentils, vegetables, tamarind, and sambar powder for 10 minutes, temper with mustard and curry leaves, and pour over warm idlis.', 600, 'Serve warm with dollop of ghee.');

DELETE FROM `recipes` WHERE `id` = 'recipe_53';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_53', 'Crispy Medu Vada', 'Golden-brown, crunchy doughnut-shaped lentil fritters with a fluffy interior, spiked with cumin, black pepper, and fresh curry leaves.', 'Chef Ramesh Rao', 'South Indian', 'assets/images/recipes/medu_vada.jpg', 25, 20, 4, 'Hard', 'cat_breakfast', 'Breakfast,Snacks,Vada,Crispy,South Indian,Vegetarian', 1, 0, 1, 4.8, 'Karnataka', 'Vada', '240 kcal | 7g Protein | 26g Carbs | 12g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_53_ing_1', 'recipe_53', 'Whole white urad dal', '1.5', 'cups', 'Soaked for 3 hours and drained', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_53_ing_2', 'recipe_53', 'Black peppercorns, crushed', '1', 'tsp', 'Coarsely pounded', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_53_ing_3', 'recipe_53', 'Cumin seeds', '1', 'tsp', 'Whole', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_53_ing_4', 'recipe_53', 'Ginger, finely grated', '1', 'tbsp', 'Fresh', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_53_ing_5', 'recipe_53', 'Curry leaves, finely chopped', '10', 'leaves', 'Fresh', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_53_ing_6', 'recipe_53', 'Cooking oil for deep frying', '500', 'ml', 'Groundnut or sunflower oil', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_53_step_1', 'recipe_53', 1, 'Grind soaked urad dal with minimal chilled water into a thick, fluffy, aerated batter.', 300, 'Beat batter vigorously with hands to incorporate air.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_53_step_2', 'recipe_53', 2, 'Fold in crushed peppercorns, cumin, ginger, chopped curry leaves, and salt.', 120, 'Test batter buoyancy by dropping a small ball in water; it must float.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_53_step_3', 'recipe_53', 3, 'Wet hands, shape into balls, make a hole in the center, and slip into hot oil; deep-fry until golden brown and crispy.', 420, 'Fry on medium flame for thorough cooking.');

DELETE FROM `recipes` WHERE `id` = 'recipe_54';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_54', 'Fluffy Poori Sagu', 'Deep-fried puffed whole wheat flatbreads paired with fragrant Karnataka-style mixed vegetable and coconut sagu.', 'Chef Shwetha Hegde', 'South Indian', 'assets/images/recipes/poori_sagu.jpg', 20, 25, 4, 'Medium', 'cat_breakfast', 'Breakfast,Poori,Karnataka,Comfort Food,Vegetarian', 0, 0, 1, 4.7, 'Karnataka', 'Poori', '340 kcal | 8g Protein | 46g Carbs | 14g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_54_ing_1', 'recipe_54', 'Whole wheat flour (atta)', '2', 'cups', 'Fine grind', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_54_ing_2', 'recipe_54', 'Mixed boiled vegetables (beans, carrot, peas, potato)', '2', 'cups', 'Diced', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_54_ing_3', 'recipe_54', 'Fresh grated coconut', '0.5', 'cup', 'For sagu masala paste', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_54_ing_4', 'recipe_54', 'Roasted gram (hurigadale)', '2', 'tbsp', 'Thickener for sagu', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_54_ing_5', 'recipe_54', 'Green chilies, cloves, and cinnamon', '1', 'tbsp', 'Spice aromatics', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_54_ing_6', 'recipe_54', 'Oil for frying pooris', '500', 'ml', 'High smoke point', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_54_step_1', 'recipe_54', 1, 'Knead wheat flour with a pinch of salt and water into a firm, pliable dough; rest for 15 minutes.', 300, 'Firm dough prevents excessive oil absorption.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_54_step_2', 'recipe_54', 2, 'Grind coconut, roasted gram, cinnamon, cloves, and chilies into a fine paste; simmer with vegetables and water to make aromatic sagu.', 600, 'Cook sagu until aromatic and velvety.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_54_step_3', 'recipe_54', 3, 'Roll small discs and slip into smoking hot oil, press gently to puff up completely, flip once, and serve warm with sagu.', 300, 'Oil must be very hot for instant puffing.');

DELETE FROM `recipes` WHERE `id` = 'recipe_55';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_55', 'Instant Rava Idli', 'Famous Bengaluru-style steamed semolina cakes tempered with mustard, cashew nuts, green chilies, and fresh ginger.', 'Chef Ramesh Rao', 'South Indian', 'assets/images/recipes/rava_idli.jpg', 15, 15, 4, 'Easy', 'cat_breakfast', 'Breakfast,Idli,Rava,Bengaluru,Instant,Vegetarian', 0, 0, 1, 4.8, 'Karnataka', 'Idli', '190 kcal | 5g Protein | 34g Carbs | 4g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_55_ing_1', 'recipe_55', 'Roasted Bombay semolina (rava)', '2', 'cups', 'Lightly roasted in ghee', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_55_ing_2', 'recipe_55', 'Thick whisked curd (yogurt)', '1.5', 'cups', 'Slightly sour', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_55_ing_3', 'recipe_55', 'Split cashews', '15', 'nuts', 'Fried golden in ghee', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_55_ing_4', 'recipe_55', 'Mustard seeds, chana dal, urad dal', '1.5', 'tsp', 'Tempering blend', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_55_ing_5', 'recipe_55', 'Finely chopped coriander & grated carrot', '0.5', 'cup', 'Fresh garnish', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_55_ing_6', 'recipe_55', 'Fruit salt (Eno) or baking soda', '1', 'tsp', 'For leavening', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_55_step_1', 'recipe_55', 1, 'Roast rava in ghee with mustard seeds, lentils, curry leaves, and green chilies until fragrant.', 300, 'Cool completely before adding curd.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_55_step_2', 'recipe_55', 2, 'Combine roasted rava with whisked curd, salt, and water to achieve thick idli batter consistency; rest 10 minutes.', 600, 'Semolina absorbs liquid while resting.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_55_step_3', 'recipe_55', 3, 'Stir in fruit salt, pour into greased idli molds garnished with cashews and grated carrot, and steam for 12 minutes.', 720, 'Serve warm with potato sagu and coconut chutney.');

DELETE FROM `recipes` WHERE `id` = 'recipe_56';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_56', 'Karnataka Set Dosa', 'Trio of soft, sponge-like, fluffy dosas served with creamy coconut chutney and flavorful vegetable saagu.', 'Chef Shwetha Hegde', 'South Indian', 'assets/images/recipes/set_dosa.jpg', 15, 15, 4, 'Easy', 'cat_breakfast', 'Breakfast,Dosa,Sponge Dosa,Karnataka,Vegetarian', 0, 0, 1, 4.7, 'Karnataka', 'Dosa', '210 kcal | 5g Protein | 38g Carbs | 4g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_56_ing_1', 'recipe_56', 'Raw rice and dosa rice blend', '2', 'cups', 'Soaked for 4 hours', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_56_ing_2', 'recipe_56', 'Beaten rice (thick poha)', '0.75', 'cup', 'Soaked for softness', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_56_ing_3', 'recipe_56', 'Urad dal', '0.5', 'cup', 'Soaked', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_56_ing_4', 'recipe_56', 'Sour curd', '0.25', 'cup', 'Enhances fermentation', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_56_ing_5', 'recipe_56', 'Butter or oil for frying', '2', 'tbsp', 'To baste surfaces', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_56_ing_6', 'recipe_56', 'Fenugreek seeds (methi)', '1', 'tsp', 'Aromatic fermentation', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_56_step_1', 'recipe_56', 1, 'Grind soaked rice, poha, and dal into a smooth, thick batter; ferment for 8 to 10 hours.', 600, 'Poha gives set dosas their signature spongy holes.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_56_step_2', 'recipe_56', 2, 'Pour a thick ladle of batter onto a hot greased griddle without spreading too thin.', 120, 'Watch dozens of tiny air holes emerge on the surface.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_56_step_3', 'recipe_56', 3, 'Cover with a lid and cook on medium flame until cooked through without flipping, top with butter, and serve in stacks of three.', 180, 'Classic restaurant style is serving 3 per plate.');

DELETE FROM `recipes` WHERE `id` = 'recipe_57';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_57', 'Kanda Poha', 'Light, fluffy flattened rice tossed with sauteed onions, crunchy peanuts, mustard seeds, curry leaves, and fresh lime juice.', 'Chef Sunita Sharma', 'Indian', 'assets/images/recipes/poha.jpg', 10, 12, 4, 'Easy', 'cat_breakfast', 'Breakfast,Poha,Maharashtrian,Quick,Healthy,Vegetarian', 0, 0, 1, 4.7, 'Maharashtra', 'Poha', '175 kcal | 4g Protein | 32g Carbs | 4g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_57_ing_1', 'recipe_57', 'Thick flattened rice (poha)', '2.5', 'cups', 'Rinsed gently and drained', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_57_ing_2', 'recipe_57', 'Onions, finely chopped', '2', 'medium', 'Sauteed until pink', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_57_ing_3', 'recipe_57', 'Raw peanuts', '0.5', 'cup', 'Roasted golden crunchy', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_57_ing_4', 'recipe_57', 'Green chilies, slit', '3', 'pieces', 'Fresh', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_57_ing_5', 'recipe_57', 'Turmeric powder', '0.5', 'tsp', 'For bright sunshine yellow color', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_57_ing_6', 'recipe_57', 'Fresh lemon juice & coriander leaves', '2', 'tbsp', 'Finishing touch', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_57_step_1', 'recipe_57', 1, 'Rinse poha in a colander under running water for 30 seconds; drain completely and season with salt and turmeric.', 180, 'Do not soak in water or it will turn mushy.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_57_step_2', 'recipe_57', 2, 'Heat oil in a pan, fry peanuts until crunchy, then temper with mustard seeds, curry leaves, green chilies, and onions.', 300, 'Saute onions until soft, not browned.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_57_step_3', 'recipe_57', 3, 'Gently toss in the drained poha, cover and steam on low flame for 2 minutes, finish with fresh lemon juice and chopped coriander.', 180, 'Serve hot with tea.');

DELETE FROM `recipes` WHERE `id` = 'recipe_58';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_58', 'Classic Rava Upma', 'Comforting roasted semolina porridge tempered with mustard seeds, crunchy lentils, ginger, green chilies, and fresh vegetables.', 'Chef Ramesh Rao', 'South Indian', 'assets/images/recipes/upma.jpg', 10, 15, 4, 'Easy', 'cat_breakfast', 'Breakfast,Upma,Rava,South Indian,Comfort Food,Vegetarian', 0, 0, 1, 4.6, 'Karnataka', 'Upma', '180 kcal | 4g Protein | 30g Carbs | 5g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_58_ing_1', 'recipe_58', 'Semolina (sooji/rava)', '1.5', 'cups', 'Dry roasted until fragrant', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_58_ing_2', 'recipe_58', 'Mustard seeds, chana dal, urad dal', '1.5', 'tsp', 'Tempering blend', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_58_ing_3', 'recipe_58', 'Finely chopped onion & ginger', '0.75', 'cup', 'Aromatics', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_58_ing_4', 'recipe_58', 'Fresh green peas and chopped carrot', '0.5', 'cup', 'Blanched', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_58_ing_5', 'recipe_58', 'Water', '3.5', 'cups', 'Boiling hot', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_58_ing_6', 'recipe_58', 'Ghee and fresh grated coconut', '2', 'tbsp', 'Rich finish', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_58_step_1', 'recipe_58', 1, 'Roast rava on medium flame for 5 minutes until warm and fragrant; transfer to a plate.', 300, 'Dry roasting prevents lumps.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_58_step_2', 'recipe_58', 2, 'Heat oil and ghee, crackle mustard seeds and dals until golden, saute onions, ginger, chilies, and vegetables.', 300, 'Ensure vegetables are tender.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_58_step_3', 'recipe_58', 3, 'Add boiling water with salt, slowly pour roasted rava in a steady stream while whisking continuously, cover and cook on low for 3 minutes.', 240, 'Finish with ghee, coriander, and fresh grated coconut.');

DELETE FROM `recipes` WHERE `id` = 'recipe_59';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_59', 'Punjabi Aloo Paratha', 'Wholesome whole wheat flatbread generously stuffed with spiced mashed potatoes, roasted on a griddle with dollops of butter.', 'Chef Harpreet Singh', 'North Indian', 'assets/images/recipes/aloo_paratha.jpg', 20, 20, 4, 'Medium', 'cat_breakfast', 'Breakfast,Paratha,North Indian,Punjab,Butter,Vegetarian', 1, 0, 1, 4.9, 'Punjab', 'Paratha', '310 kcal | 7g Protein | 45g Carbs | 11g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_59_ing_1', 'recipe_59', 'Whole wheat flour dough', '3', 'cups', 'Soft, well-rested dough', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_59_ing_2', 'recipe_59', 'Boiled potatoes, peeled & mashed', '4', 'large', 'Lump-free mash', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_59_ing_3', 'recipe_59', 'Roasted cumin powder and amchur', '1.5', 'tsp', 'Tangy spice blend', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_59_ing_4', 'recipe_59', 'Green chilies & fresh coriander', '3', 'tbsp', 'Finely chopped', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_59_ing_5', 'recipe_59', 'Garam masala & red chili powder', '1', 'tsp', 'Warm spices', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_59_ing_6', 'recipe_59', 'Desi Makhan (white butter) or ghee', '4', 'tbsp', 'For griddling and topping', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_59_step_1', 'recipe_59', 1, 'Mash boiled potatoes with cumin powder, amchur (dry mango powder), chilies, coriander, and salt.', 300, 'Let potatoes cool completely before stuffing.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_59_step_2', 'recipe_59', 2, 'Roll out a dough ball into a small circle, place a large portion of potato filling in the center, seal edges, and gently roll flat.', 240, 'Dust lightly with flour to avoid tearing.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_59_step_3', 'recipe_59', 3, 'Cook on a hot tawa with generous ghee or butter until both sides develop golden-brown crisp blisters; serve with fresh yogurt and mango pickle.', 360, 'Top with a melting slab of white butter.');

DELETE FROM `recipes` WHERE `id` = 'recipe_60';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_60', 'Ven Pongal', 'Heavenly South Indian comfort porridge made of rice and split yellow moong lentils tempered with black pepper, cumin, ginger, and cashews in ghee.', 'Chef Ananya Iyer', 'South Indian', 'assets/images/recipes/pongal.jpg', 10, 25, 4, 'Easy', 'cat_breakfast', 'Breakfast,Pongal,Comfort Food,South Indian,Temple Style,Vegetarian', 0, 0, 1, 4.8, 'Tamil Nadu', 'Pongal', '260 kcal | 7g Protein | 36g Carbs | 9g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_60_ing_1', 'recipe_60', 'Raw rice (Sona Masoori or Ponni)', '1', 'cup', 'Washed and drained', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_60_ing_2', 'recipe_60', 'Split yellow moong dal', '0.5', 'cup', 'Dry roasted until aromatic', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_60_ing_3', 'recipe_60', 'Pure cow''s ghee', '4', 'tbsp', 'Essential for rich aroma', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_60_ing_4', 'recipe_60', 'Whole black peppercorns & cumin seeds', '1.5', 'tsp', 'Coarsely bruised', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_60_ing_5', 'recipe_60', 'Cashew nuts', '15', 'pieces', 'Split', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_60_ing_6', 'recipe_60', 'Ginger (finely minced) and curry leaves', '2', 'tbsp', 'Fresh aromatics', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_60_step_1', 'recipe_60', 1, 'Pressure cook roasted moong dal and rice with 4.5 cups of water and salt for 4-5 whistles until very soft and mushy.', 720, 'The texture must be melt-in-mouth creamy.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_60_step_2', 'recipe_60', 2, 'Heat ghee in a small pan, roast cashews until golden brown, add crushed peppercorns, cumin, minced ginger, and curry leaves.', 180, 'Roast on low heat so spices release essential oils into the ghee.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_60_step_3', 'recipe_60', 3, 'Pour sizzling ghee tempering over the cooked pongal, mix gently, and serve steaming hot with coconut chutney and sambar.', 120, 'Enjoy hot for maximum aroma.');

DELETE FROM `recipes` WHERE `id` = 'recipe_61';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_61', 'Royal Gulab Jamun', 'Melt-in-mouth golden milk-solid dumplings soaked in warm rosewater and green cardamom flavored saffron sugar syrup.', 'Chef Sanjeev Kumar', 'North Indian', 'assets/images/recipes/gulab_jamun.jpg', 20, 25, 6, 'Medium', 'cat_desserts', 'Desserts,Gulab Jamun,Festive,Mithai,Indian Sweets,Vegetarian', 1, 0, 1, 4.9, 'North India', 'Mithai', '290 kcal | 4g Protein | 48g Carbs | 9g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_61_ing_1', 'recipe_61', 'Fresh khoya (mawa)', '1.5', 'cups', 'Grated smooth', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_61_ing_2', 'recipe_61', 'All-purpose flour (maida)', '3', 'tbsp', 'Binding agent', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_61_ing_3', 'recipe_61', 'Sugar', '2', 'cups', 'For sugar syrup', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_61_ing_4', 'recipe_61', 'Green cardamom pods & saffron strands', '1', 'tsp', 'Aromatic infusion', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_61_ing_5', 'recipe_61', 'Rose water', '1', 'tbsp', 'Pure edible essence', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_61_ing_6', 'recipe_61', 'Ghee or oil for deep frying', '500', 'ml', 'Medium low temperature', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_61_step_1', 'recipe_61', 1, 'Knead khoya and flour with a splash of milk into a smooth, crack-free dough; roll into miniature marble-sized balls.', 300, 'Ensure balls have zero cracks so they don''t break in oil.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_61_step_2', 'recipe_61', 2, 'Simmer sugar, water, crushed cardamom, and saffron for 8 minutes to make a sticky, warm 1-string syrup; add rosewater.', 480, 'Keep syrup warm while frying dumplings.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_61_step_3', 'recipe_61', 3, 'Deep-fry dumplings in medium-low ghee until dark mahogany brown, immediately drop into warm sugar syrup, and soak for 2 hours.', 720, 'Dumplings double in size as they absorb syrup.');

DELETE FROM `recipes` WHERE `id` = 'recipe_62';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_62', 'Authentic Mysore Pak', 'Legendary royal sweet of the Mysore Palace crafted with roasted besan, aromatic ghee, and sugar that melts effortlessly on the tongue.', 'Chef Shwetha Hegde', 'South Indian', 'assets/images/recipes/mysore_pak.jpg', 15, 30, 8, 'Hard', 'cat_desserts', 'Desserts,Mysore Pak,Karnataka,Royal,Ghee,Mithai,Vegetarian', 1, 0, 1, 4.9, 'Karnataka', 'Mithai', '380 kcal | 5g Protein | 42g Carbs | 22g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_62_ing_1', 'recipe_62', 'Gram flour (besan)', '1', 'cup', 'Sifted twice', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_62_ing_2', 'recipe_62', 'Pure melted cow''s ghee', '1.5', 'cups', 'Kept hot in a separate pan', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_62_ing_3', 'recipe_62', 'Sugar', '1.5', 'cups', 'Refined', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_62_ing_4', 'recipe_62', 'Water', '0.5', 'cup', 'For syrup', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_62_ing_5', 'recipe_62', 'Cardamom powder', '0.5', 'tsp', 'Fragrant finish', 5);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_62_step_1', 'recipe_62', 1, 'Sift besan thoroughly to eliminate lumps; heat ghee in a saucepan on low heat until warm.', 300, 'Ghee must be hot when poured into the mixture.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_62_step_2', 'recipe_62', 2, 'Boil sugar and water to a 1-string consistency, whisk in the besan smoothly without letting lumps form.', 480, 'Stir vigorously with a wooden spatula.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_62_step_3', 'recipe_62', 3, 'Pour hot ghee ladle by ladle into the mixture while stirring continuously until it turns frothy and leaves the pan sides, pour into tray and slice.', 600, 'Cut into squares while still warm.');

DELETE FROM `recipes` WHERE `id` = 'recipe_63';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_63', 'Spongy Bengali Rasgulla', 'Delicate, spongy cottage cheese spheres cooked in light cardamom-infused sugar syrup, bursting with sweet juice in every bite.', 'Chef Ananya Iyer', 'Bengali', 'assets/images/recipes/rasgulla.jpg', 30, 20, 6, 'Hard', 'cat_desserts', 'Desserts,Rasgulla,Bengali,Chenna,Spongy,Vegetarian', 0, 0, 1, 4.8, 'West Bengal', 'Mithai', '140 kcal | 4g Protein | 28g Carbs | 1g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_63_ing_1', 'recipe_63', 'Full cream cow''s milk', '1.5', 'liters', 'Fresh whole milk', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_63_ing_2', 'recipe_63', 'Lemon juice or vinegar', '3', 'tbsp', 'Diluted in water for curdling', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_63_ing_3', 'recipe_63', 'Sugar', '2', 'cups', 'For light cooking syrup', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_63_ing_4', 'recipe_63', 'Water', '6', 'cups', 'For sugar syrup', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_63_ing_5', 'recipe_63', 'Green cardamom pods', '4', 'pieces', 'Lightly crushed', 5);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_63_step_1', 'recipe_63', 1, 'Boil milk, turn off heat, curdle with diluted lemon juice to make soft chenna; drain in muslin cloth and hang for 45 minutes.', 2700, 'Do not squeeze too dry; chenna needs slight moisture.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_63_step_2', 'recipe_63', 2, 'Knead chenna with heels of palms for 7-8 minutes until glossy and completely smooth; roll into 15 small crack-free balls.', 480, 'Kneading creates the iconic spongy bounce.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_63_step_3', 'recipe_63', 3, 'Boil sugar, water, and cardamom vigorously in a wide pot, drop chenna balls, cover tightly, and boil on high flame for 15 minutes.', 900, 'Chenna balls will double in size; chill before serving.');

DELETE FROM `recipes` WHERE `id` = 'recipe_64';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_64', 'Royal Rasmalai', 'Soft poached chenna patties immersed in rich saffron, cardamom, and pistachio-infused condensed milk rabri.', 'Chef Sanjeev Kumar', 'North Indian', 'assets/images/recipes/rasmalai.jpg', 35, 35, 6, 'Hard', 'cat_desserts', 'Desserts,Rasmalai,Royal,Rabri,Saffron,Vegetarian', 1, 0, 1, 4.9, 'North India', 'Mithai', '260 kcal | 6g Protein | 32g Carbs | 11g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_64_ing_1', 'recipe_64', 'Fresh chenna dough', '1.5', 'cups', 'Kneaded until silky smooth', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_64_ing_2', 'recipe_64', 'Full fat milk (for rabri)', '1.5', 'liters', 'Simmered and reduced to half', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_64_ing_3', 'recipe_64', 'Sugar', '0.75', 'cup', 'Sweetener', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_64_ing_4', 'recipe_64', 'Kashmiri saffron strands', '0.5', 'tsp', 'Soaked in warm milk', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_64_ing_5', 'recipe_64', 'Pistachios and almonds, slivered', '0.25', 'cup', 'For garnish', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_64_ing_6', 'recipe_64', 'Cardamom powder', '0.5', 'tsp', 'Fragrant spice', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_64_step_1', 'recipe_64', 1, 'Shape smooth chenna into flat patties and poach in light boiling sugar syrup for 10 minutes until spongy.', 600, 'Gently press patties between palms to drain syrup.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_64_step_2', 'recipe_64', 2, 'Simmer whole milk in a wide heavy-bottomed pan, stirring constantly until reduced to half; add sugar, saffron milk, and cardamom.', 1200, 'Rabri should be silky and fragrant, not too thick.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_64_step_3', 'recipe_64', 3, 'Gently immerse the warm chenna discs into the saffron rabri, garnish with slivered pistachios, and refrigerate for 4 hours before serving.', 14400, 'Serve chilled for unmatched royalty.');

DELETE FROM `recipes` WHERE `id` = 'recipe_65';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_65', 'Crispy Golden Jalebi', 'Crispy spiral funnels of fermented batter fried to golden perfection and drenched in fragrant saffron-cardamom sugar syrup.', 'Chef Sanjeev Kumar', 'North Indian', 'assets/images/recipes/jalebi.jpg', 20, 20, 6, 'Medium', 'cat_desserts', 'Desserts,Jalebi,Crispy,Festive,Mithai,Vegetarian', 0, 0, 1, 4.8, 'North India', 'Mithai', '320 kcal | 3g Protein | 55g Carbs | 10g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_65_ing_1', 'recipe_65', 'All-purpose flour (maida)', '1.5', 'cups', 'Sifted', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_65_ing_2', 'recipe_65', 'Cornstarch or besan', '2', 'tbsp', 'Gives extra crispiness', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_65_ing_3', 'recipe_65', 'Thick yogurt (curd)', '0.5', 'cup', 'For mild natural tang', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_65_ing_4', 'recipe_65', 'Sugar', '2', 'cups', 'For syrup', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_65_ing_5', 'recipe_65', 'Saffron threads and rose water', '1', 'tsp', 'Aromatic flavor', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_65_ing_6', 'recipe_65', 'Ghee or oil for deep frying', '500', 'ml', 'Maintained at medium heat', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_65_step_1', 'recipe_65', 1, 'Whisk flour, cornstarch, yogurt, and water into a smooth batter; rest for 2 hours (or overnight) for slight fermentation.', 7200, 'Batter consistency should be thick yet flowy like pancake batter.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_65_step_2', 'recipe_65', 2, 'Prepare 1-string sugar syrup with sugar, water, saffron, and lemon juice to prevent crystallization.', 600, 'Keep syrup comfortably warm.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_65_step_3', 'recipe_65', 3, 'Fill batter into a squeeze bottle or cloth cone, pipe concentric spirals into hot ghee, fry until crispy golden, and soak in warm syrup for 2 minutes.', 360, 'Enjoy immediately while hot and juicy.');

DELETE FROM `recipes` WHERE `id` = 'recipe_66';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_66', 'Silver Leaf Kaju Katli', 'Decadent diamond-shaped fudge crafted from finely ground cashews and delicate sugar syrup, finished with edible silver vark.', 'Chef Sunita Sharma', 'North Indian', 'assets/images/recipes/kaju_katli.jpg', 15, 15, 8, 'Medium', 'cat_desserts', 'Desserts,Kaju Katli,Cashew,Diwali,Mithai,Vegetarian', 1, 0, 1, 4.9, 'North India', 'Mithai', '190 kcal | 4g Protein | 22g Carbs | 10g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_66_ing_1', 'recipe_66', 'Whole cashews (kaju)', '2', 'cups', 'Pulsed into fine dry powder', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_66_ing_2', 'recipe_66', 'Sugar', '1', 'cup', 'Granulated', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_66_ing_3', 'recipe_66', 'Water', '0.5', 'cup', 'For syrup', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_66_ing_4', 'recipe_66', 'Rose water or cardamom powder', '0.5', 'tsp', 'Gentle perfume', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_66_ing_5', 'recipe_66', 'Ghee', '1', 'tbsp', 'For greasing', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_66_ing_6', 'recipe_66', 'Edible silver vark', '2', 'sheets', 'Traditional garnish', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_66_step_1', 'recipe_66', 1, 'Pulse cashews in a dry blender in short bursts until finely powdered; sift through a mesh to remove granules.', 180, 'Do not over-blend or cashews will release oil into paste.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_66_step_2', 'recipe_66', 2, 'Boil sugar and water to 1-string consistency, lower flame, and stir in cashew powder continuously until it forms a non-sticky dough.', 420, 'Cook on low flame to maintain ivory white color.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_66_step_3', 'recipe_66', 3, 'Transfer onto greaseproof paper, knead gently while warm, roll thin between parchment sheets, decorate with silver vark, and slice into classic diamonds.', 300, 'Cut while still pliable.');

DELETE FROM `recipes` WHERE `id` = 'recipe_67';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_67', 'Gajar Ka Halwa', 'Rich, luscious winter pudding prepared by slowly braising grated red carrots in full-cream milk, ghee, mawa, and crunchy dry fruits.', 'Chef Harpreet Singh', 'North Indian', 'assets/images/recipes/carrot_halwa.jpg', 20, 40, 6, 'Medium', 'cat_desserts', 'Desserts,Halwa,Gajar Halwa,Carrot,Winter,Vegetarian', 1, 0, 1, 4.9, 'Punjab', 'Halwa', '280 kcal | 5g Protein | 38g Carbs | 12g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_67_ing_1', 'recipe_67', 'Fresh juicy Delhi red carrots', '1', 'kg', 'Finely grated', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_67_ing_2', 'recipe_67', 'Full fat milk', '1', 'liter', 'Creamy whole milk', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_67_ing_3', 'recipe_67', 'Pure desi ghee', '4', 'tbsp', 'For roasting', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_67_ing_4', 'recipe_67', 'Khoya (mawa) crumbled', '0.5', 'cup', 'Adds luxurious rich body', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_67_ing_5', 'recipe_67', 'Sugar', '0.75', 'cup', 'Adjust to sweetness of carrots', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_67_ing_6', 'recipe_67', 'Cashews, almonds & raisins', '0.25', 'cup', 'Fried golden in ghee', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_67_step_1', 'recipe_67', 1, 'Simmer grated carrots in milk in a heavy-bottomed kadai, stirring periodically until the milk evaporates completely.', 1800, 'Cook slowly to allow carrots to absorb the milk fats.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_67_step_2', 'recipe_67', 2, 'Add ghee and roast the carrots for 10-12 minutes until they turn glossy and deep crimson orange.', 720, 'Roasting in ghee creates an unbeatable aroma.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_67_step_3', 'recipe_67', 3, 'Stir in sugar and crumbled khoya, cook until excess moisture evaporates, and finish with cardamom and ghee-roasted nuts.', 480, 'Serve warm, optionally alongside vanilla ice cream.');

DELETE FROM `recipes` WHERE `id` = 'recipe_68';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_68', 'Shahi Badam Halwa', 'Regal Indian dessert prepared with blanched California almonds ground into a coarse paste, slow-cooked in pure desi ghee, saffron, and milk.', 'Chef Shwetha Hegde', 'South Indian', 'assets/images/recipes/badam_halwa.jpg', 25, 30, 6, 'Hard', 'cat_desserts', 'Desserts,Badam Halwa,Almonds,Royal,Ghee,Vegetarian', 1, 0, 1, 4.9, 'Karnataka', 'Halwa', '360 kcal | 8g Protein | 34g Carbs | 22g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_68_ing_1', 'recipe_68', 'Raw almonds (badam)', '1.5', 'cups', 'Soaked in hot water, peeled', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_68_ing_2', 'recipe_68', 'Pure cow''s ghee', '0.75', 'cup', 'Desi ghee', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_68_ing_3', 'recipe_68', 'Sugar', '1.25', 'cups', 'Refined', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_68_ing_4', 'recipe_68', 'Milk', '1', 'cup', 'For grinding and cooking', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_68_ing_5', 'recipe_68', 'Saffron strands', '1', 'pinch', 'Infused in warm milk', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_68_ing_6', 'recipe_68', 'Cardamom powder', '0.5', 'tsp', 'Aromatic ground spice', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_68_step_1', 'recipe_68', 1, 'Soak almonds in hot water for 30 minutes, peel the skins off, and grind with milk into a slightly textured paste.', 600, 'Do not make it completely watery; a slight texture gives halwa body.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_68_step_2', 'recipe_68', 2, 'Heat ghee in a heavy non-stick pan, add badam paste, and roast on medium-low heat continuously until it releases ghee and turns golden.', 1200, 'Patience is key; stirring constantly prevents sticking.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_68_step_3', 'recipe_68', 3, 'Add saffron milk and sugar, cook until the halwa thickens into a glossy, fudge-like consistency, and garnish with sliced almonds.', 480, 'Serve warm in ceremonial brass bowls.');

DELETE FROM `recipes` WHERE `id` = 'recipe_69';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_69', 'Creamy Rice Kheer', 'Traditional slow-simmered rice pudding enriched with aromatic Basmati rice, full-fat milk, saffron, cardamom, and toasted nuts.', 'Chef Sunita Sharma', 'North Indian', 'assets/images/recipes/rice_kheer.jpg', 15, 40, 6, 'Easy', 'cat_desserts', 'Desserts,Kheer,Rice Pudding,Traditional,Festive,Vegetarian', 0, 0, 1, 4.8, 'North India', 'Kheer', '220 kcal | 6g Protein | 34g Carbs | 7g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_69_ing_1', 'recipe_69', 'Aromatic Basmati or Gobindobhog rice', '0.5', 'cup', 'Washed, soaked, crushed', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_69_ing_2', 'recipe_69', 'Full cream milk', '1.5', 'liters', 'Heavy whole milk', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_69_ing_3', 'recipe_69', 'Sugar', '0.75', 'cup', 'Adjust to taste', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_69_ing_4', 'recipe_69', 'Saffron strands', '15', 'threads', 'Steeped in warm milk', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_69_ing_5', 'recipe_69', 'Cardamom powder', '0.75', 'tsp', 'Freshly pounded', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_69_ing_6', 'recipe_69', 'Cashews, almonds, and charoli nuts', '0.25', 'cup', 'Slivered', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_69_step_1', 'recipe_69', 1, 'Bring milk to a gentle boil in a heavy pot; add soaked crushed rice and simmer on low flame.', 1200, 'Crushing the rice slightly releases starches that thicken the milk naturally.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_69_step_2', 'recipe_69', 2, 'Stir regularly, scraping the condensed cream (malai) from the sides back into the pot until milk reduces and thickens.', 900, 'Slow simmering creates a velvety, caramelized cream base.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_69_step_3', 'recipe_69', 3, 'Stir in sugar, saffron milk, cardamom powder, and nuts; cook for another 5 minutes and serve warm or chilled.', 300, 'Thickens further as it cools.');

DELETE FROM `recipes` WHERE `id` = 'recipe_70';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_70', 'Roasted Besan Ladoo', 'Aromatic spheres of slow-roasted gram flour, fragrant desi ghee, powdered sugar, and cardamom, garnished with crunchy pistachios.', 'Chef Harpreet Singh', 'North Indian', 'assets/images/recipes/besan_ladoo.jpg', 15, 25, 8, 'Medium', 'cat_desserts', 'Desserts,Besan Ladoo,Festive,Diwali,Ghee,Vegetarian', 0, 0, 1, 4.8, 'North India', 'Mithai', '210 kcal | 4g Protein | 26g Carbs | 11g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_70_ing_1', 'recipe_70', 'Coarse gram flour (mota besan)', '2', 'cups', 'Sifted', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_70_ing_2', 'recipe_70', 'Pure desi ghee', '0.75', 'cup', 'Melted cow''s ghee', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_70_ing_3', 'recipe_70', 'Bura or powdered sugar (tagar)', '1.25', 'cups', 'Adds delightful crunch', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_70_ing_4', 'recipe_70', 'Green cardamom powder', '1', 'tsp', 'Freshly crushed', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_70_ing_5', 'recipe_70', 'Slivered pistachios and almonds', '2', 'tbsp', 'For topping', 5);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_70_step_1', 'recipe_70', 1, 'Melt ghee in a heavy kadai, add coarse besan, and roast on low flame for 20-25 minutes until fragrant, nutty, and golden brown.', 1500, 'Roast patiently on low heat; undercooked besan tastes raw.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_70_step_2', 'recipe_70', 2, 'Sprinkle 1 tsp of water onto the roasted besan to create signature grainy ''danedaar'' texture, then remove from heat and cool until lukewarm.', 600, 'Adding sugar to hot besan will melt the sugar and ruin texture.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_70_step_3', 'recipe_70', 3, 'Mix in bura sugar and cardamom powder thoroughly, roll into round ping-pong balls with your hands, and press a pistachio on top.', 300, 'Store in an airtight container for up to 3 weeks.');

DELETE FROM `recipes` WHERE `id` = 'recipe_71';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_71', 'Tapri Masala Chai', 'Robust, spicy Indian street-style milk tea brewed with crushed ginger, green cardamom, cloves, cinnamon, and CTC black tea leaves.', 'Chef Ramesh Rao', 'Indian', 'assets/images/recipes/masala_chai.jpg', 5, 10, 4, 'Easy', 'cat_drinks', 'Drinks,Masala Chai,Tea,Spiced,Street Style,Vegetarian', 1, 0, 1, 4.9, 'All India', 'Tea', '95 kcal | 3g Protein | 12g Carbs | 3g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_71_ing_1', 'recipe_71', 'Water', '2', 'cups', 'Fresh water', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_71_ing_2', 'recipe_71', 'Full fat milk', '2', 'cups', 'Whole milk for rich texture', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_71_ing_3', 'recipe_71', 'CTC strong Assam black tea', '3', 'tbsp', 'Bold tea granules', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_71_ing_4', 'recipe_71', 'Fresh ginger, crushed in mortar', '1.5', 'inch', 'Juicy and aromatic', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_71_ing_5', 'recipe_71', 'Cardamom, cloves & cinnamon stick', '1', 'tbsp', 'Coarsely crushed spices', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_71_ing_6', 'recipe_71', 'Sugar', '2.5', 'tbsp', 'Adjust to preference', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_71_step_1', 'recipe_71', 1, 'Crush ginger, cardamom pods, cinnamon, and cloves in a mortar and pestle; add to boiling water and simmer for 3 minutes.', 180, 'Extracts essential oils and spicy kick.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_71_step_2', 'recipe_71', 2, 'Add strong tea leaves and simmer for 2 minutes until the decoction turns dark red and highly aromatic.', 120, 'Adjust boil time for desired strength.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_71_step_3', 'recipe_71', 3, 'Pour in whole milk and sugar, bring to 3 successive rolling boils on medium flame, strain into cutting glasses, and serve piping hot.', 300, 'Pour from height to aerate and produce frothy foam.');

DELETE FROM `recipes` WHERE `id` = 'recipe_72';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_72', 'South Indian Filter Coffee', 'Frothy, rich South Indian morning nectar brewed with freshly roasted chicory coffee decoction and creamy frothed hot milk in a traditional dabarah.', 'Chef Ananya Iyer', 'South Indian', 'assets/images/recipes/filter_coffee.jpg', 10, 5, 2, 'Easy', 'cat_drinks', 'Drinks,Filter Coffee,Coffee,South Indian,Traditional,Vegetarian', 1, 0, 1, 4.9, 'Karnataka', 'Coffee', '110 kcal | 3g Protein | 14g Carbs | 4g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_72_ing_1', 'recipe_72', 'Freshly ground coffee blend (80% Arabica/Robusta, 20% Chicory)', '4', 'tbsp', 'Medium-dark roast', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_72_ing_2', 'recipe_72', 'Boiling water', '1', 'cup', 'Freshly boiled', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_72_ing_3', 'recipe_72', 'Thick whole milk', '1.5', 'cups', 'Boiled and steaming hot', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_72_ing_4', 'recipe_72', 'Sugar', '2', 'tsp', 'Or brown sugar to taste', 4);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_72_step_1', 'recipe_72', 1, 'Add ground coffee into upper chamber of traditional stainless steel brass filter, press gently with umbrella plunger, pour boiling water, and cover.', 300, 'Let gravity drip a thick, dark first-press decoction for 10 minutes.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_72_step_2', 'recipe_72', 2, 'Boil whole milk until steaming and creamy.', 180, 'Use high-fat milk for optimal froth.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_72_step_3', 'recipe_72', 3, 'Pour 30ml of thick decoction into a dabarah, add sugar, top with boiling milk, and pour back and forth from height into the tumbler to create velvety foam.', 60, 'Enjoy instantly while piping hot.');

DELETE FROM `recipes` WHERE `id` = 'recipe_73';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_73', 'Alphonso Mango Lassi', 'Thick, velvety yogurt smoothie whipped with sweet Ratnagiri Alphonso mango pulp, green cardamom, and a swirl of cream.', 'Chef Sunita Sharma', 'North Indian', 'assets/images/recipes/mango_lassi.jpg', 10, 0, 4, 'Easy', 'cat_drinks', 'Drinks,Mango Lassi,Smoothie,Summer,Yogurt,Vegetarian', 1, 0, 1, 4.9, 'Punjab', 'Lassi', '180 kcal | 5g Protein | 30g Carbs | 4g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_73_ing_1', 'recipe_73', 'Fresh thick Greek yogurt or hung curd', '2', 'cups', 'Chilled, not sour', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_73_ing_2', 'recipe_73', 'Sweet Alphonso mango pulp', '1.5', 'cups', 'Fresh or canned', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_73_ing_3', 'recipe_73', 'Chilled milk', '0.5', 'cup', 'To adjust consistency', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_73_ing_4', 'recipe_73', 'Sugar or honey', '3', 'tbsp', 'Adjust to mango sweetness', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_73_ing_5', 'recipe_73', 'Green cardamom powder', '0.5', 'tsp', 'Aromatic touch', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_73_ing_6', 'recipe_73', 'Slivered pistachios and saffron', '1', 'tbsp', 'Garnish', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_73_step_1', 'recipe_73', 1, 'Place chilled yogurt, mango pulp, milk, cardamom, and sugar into a high-speed blender.', 60, 'Use cold ingredients so ice cubes don''t dilute the drink.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_73_step_2', 'recipe_73', 2, 'Blend on high for 60-90 seconds until frothy, luscious, and ultra-creamy.', 90, 'Check sweetness and consistency.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_73_step_3', 'recipe_73', 3, 'Pour into tall chilled glasses, garnish with slivered pistachios and saffron threads, and serve cold.', 60, 'Refreshing summer cooler.');

DELETE FROM `recipes` WHERE `id` = 'recipe_74';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_74', 'Amritsari Sweet Lassi', 'Rich Punjabi sweet churned yogurt drink served in clay kulhads topped with a thick dollop of fresh malai (clotted cream) and rosewater.', 'Chef Harpreet Singh', 'North Indian', 'assets/images/recipes/sweet_lassi.jpg', 10, 0, 4, 'Easy', 'cat_drinks', 'Drinks,Lassi,Punjab,Kulhad,Yogurt,Vegetarian', 0, 0, 1, 4.8, 'Punjab', 'Lassi', '210 kcal | 6g Protein | 28g Carbs | 8g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_74_ing_1', 'recipe_74', 'Full fat fresh yogurt (dahi)', '3', 'cups', 'Chilled', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_74_ing_2', 'recipe_74', 'Powdered sugar', '0.5', 'cup', 'Dissolves instantly', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_74_ing_3', 'recipe_74', 'Rose water or kewra water', '1', 'tsp', 'Traditional floral scent', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_74_ing_4', 'recipe_74', 'Cardamom powder', '0.5', 'tsp', 'Aromatic spice', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_74_ing_5', 'recipe_74', 'Fresh clotted cream (malai)', '4', 'tbsp', 'To top each glass', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_74_ing_6', 'recipe_74', 'Ice cubes', '1', 'cup', 'Chilled', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_74_step_1', 'recipe_74', 1, 'Add chilled yogurt, powdered sugar, cardamom powder, rosewater, and ice to a blender or churn with traditional wooden madhani.', 120, 'Churn until a thick layer of froth forms on top.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_74_step_2', 'recipe_74', 2, 'Pour the thick, frothy lassi into earthen clay kulhads.', 60, 'Kulhad lends an earthy aroma to the lassi.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_74_step_3', 'recipe_74', 3, 'Crown each glass with a generous spoonful of thick fresh malai and chopped almonds.', 60, 'Serve immediately.');

DELETE FROM `recipes` WHERE `id` = 'recipe_75';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_75', 'Kesar Badam Milk', 'Royal nourishing warm drink prepared with blanched almond paste, simmered milk, fragrant Kashmiri saffron, and green cardamom.', 'Chef Sanjeev Kumar', 'Indian', 'assets/images/recipes/badam_milk.jpg', 15, 15, 4, 'Easy', 'cat_drinks', 'Drinks,Badam Milk,Almonds,Saffron,Immunity,Vegetarian', 0, 0, 1, 4.8, 'North India', 'Milk', '195 kcal | 6g Protein | 20g Carbs | 9g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_75_ing_1', 'recipe_75', 'Raw almonds (badam)', '25', 'pieces', 'Soaked in warm water, peeled', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_75_ing_2', 'recipe_75', 'Full cream milk', '4', 'cups', 'Whole milk', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_75_ing_3', 'recipe_75', 'Saffron threads (kesar)', '1', 'generous pinch', 'Soaked in warm milk', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_75_ing_4', 'recipe_75', 'Sugar', '3', 'tbsp', 'Adjust to taste', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_75_ing_5', 'recipe_75', 'Cardamom powder', '0.5', 'tsp', 'Freshly crushed', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_75_ing_6', 'recipe_75', 'Slivered pistachios and almonds', '2', 'tbsp', 'For garnish', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_75_step_1', 'recipe_75', 1, 'Peel soaked almonds and blend with 0.5 cup of milk into a smooth, creamy paste.', 180, 'Smooth paste prevents graininess in the drink.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_75_step_2', 'recipe_75', 2, 'Bring remaining milk to a boil in a heavy saucepan, reduce flame, stir in badam paste and saffron milk, and simmer for 8 minutes.', 480, 'Stir regularly to prevent milk from sticking to bottom.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_75_step_3', 'recipe_75', 3, 'Add sugar and cardamom powder, simmer for 2 minutes, and serve warm in winter or chilled over ice in summer.', 120, 'Top with crunchy slivered nuts.');

DELETE FROM `recipes` WHERE `id` = 'recipe_76';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_76', 'Tender Coconut Cooler', 'Pure tropical hydrating elixir blending sweet tender coconut water, silky coconut malai, a splash of lime, and a hint of mint.', 'Chef Shwetha Hegde', 'Coastal', 'assets/images/recipes/tender_coconut_drink.jpg', 5, 0, 2, 'Easy', 'cat_drinks', 'Drinks,Coconut,Cooler,Hydrating,Natural,Vegetarian', 0, 0, 1, 4.8, 'Coastal Karnataka', 'Cooler', '85 kcal | 2g Protein | 15g Carbs | 2g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_76_ing_1', 'recipe_76', 'Fresh tender coconut water', '2', 'cups', 'Naturally sweet', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_76_ing_2', 'recipe_76', 'Soft tender coconut flesh (malai)', '0.5', 'cup', 'Silky smooth', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_76_ing_3', 'recipe_76', 'Fresh lime juice', '1', 'tsp', 'Balances natural sweetness', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_76_ing_4', 'recipe_76', 'Honey or sugar syrup (optional)', '1', 'tbsp', 'Optional', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_76_ing_5', 'recipe_76', 'Fresh mint leaves', '4', 'leaves', 'Lightly bruised', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_76_ing_6', 'recipe_76', 'Ice cubes', '4', 'cubes', 'Chilled', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_76_step_1', 'recipe_76', 1, 'Scoop out the soft tender coconut flesh and blend with half the coconut water until smooth and creamy.', 60, 'Creates a luscious velvety base.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_76_step_2', 'recipe_76', 2, 'Stir in the remaining clear coconut water, fresh lime juice, and a splash of honey if desired.', 60, 'Keep it light and hydrating.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_76_step_3', 'recipe_76', 3, 'Pour into glasses over ice cubes, garnish with bruised mint sprigs, and enjoy instantly.', 60, 'Nature''s best isotonic drink.');

DELETE FROM `recipes` WHERE `id` = 'recipe_77';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_77', 'Spiced Masala Chaas', 'Refreshing salted buttermilk whipped with crushed roasted cumin seeds, green chilies, ginger, rock salt, and fresh coriander.', 'Chef Ramesh Rao', 'Indian', 'assets/images/recipes/masala_chaas.jpg', 5, 0, 4, 'Easy', 'cat_drinks', 'Drinks,Chaas,Buttermilk,Digestive,Summer,Vegetarian', 0, 0, 1, 4.7, 'Gujarat', 'Buttermilk', '45 kcal | 2g Protein | 4g Carbs | 2g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_77_ing_1', 'recipe_77', 'Fresh plain curd (yogurt)', '1.5', 'cups', 'Smooth and cold', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_77_ing_2', 'recipe_77', 'Chilled water', '3', 'cups', 'Very cold', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_77_ing_3', 'recipe_77', 'Roasted cumin powder (bhuna jeera)', '1.5', 'tsp', 'Aromatic digestive', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_77_ing_4', 'recipe_77', 'Black salt (kala namak)', '1', 'tsp', 'Signature tang', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_77_ing_5', 'recipe_77', 'Green chili & ginger paste', '0.5', 'tsp', 'Mild warmth', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_77_ing_6', 'recipe_77', 'Finely chopped mint and coriander leaves', '2', 'tbsp', 'Fresh herbs', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_77_step_1', 'recipe_77', 1, 'Whisk yogurt, chilled water, roasted cumin, black salt, and chili-ginger paste together until frothy.', 90, 'Use a wire whisk or blender on low pulse.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_77_step_2', 'recipe_77', 2, 'Stir in finely minced mint and coriander leaves.', 60, 'Let stand 5 minutes for flavors to marry.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_77_step_3', 'recipe_77', 3, 'Pour into tall glasses, dust extra roasted cumin on top, and serve chilled after meals.', 60, 'Superb natural digestive aid.');

DELETE FROM `recipes` WHERE `id` = 'recipe_78';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_78', 'Zesty Mint Lemonade', 'Crisp, effervescent cooler made with freshly squeezed lemon juice, muddled garden mint, black salt, and cracked ice.', 'Chef Sunita Sharma', 'Indian', 'assets/images/recipes/mint_lemonade.jpg', 5, 0, 4, 'Easy', 'cat_drinks', 'Drinks,Lemonade,Mint,Shikanji,Cooler,Vegetarian', 0, 0, 1, 4.7, 'All India', 'Lemonade', '60 kcal | 0g Protein | 15g Carbs | 0g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_78_ing_1', 'recipe_78', 'Fresh lemon juice', '0.5', 'cup', 'Freshly squeezed', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_78_ing_2', 'recipe_78', 'Fresh garden mint leaves', '1', 'cup', 'Muddled', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_78_ing_3', 'recipe_78', 'Sugar syrup or honey', '0.5', 'cup', 'Adjust sweetness', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_78_ing_4', 'recipe_78', 'Black salt (kala namak) & roasted cumin', '1', 'tsp', 'Shikanji masala twist', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_78_ing_5', 'recipe_78', 'Chilled club soda or water', '3', 'cups', 'Sparkling or still', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_78_ing_6', 'recipe_78', 'Crushed ice', '2', 'cups', 'Abundant', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_78_step_1', 'recipe_78', 1, 'Muddle fresh mint leaves gently with lemon juice and sugar syrup in a pitcher to release fragrant herbal oils.', 90, 'Do not shred mint completely to prevent bitterness.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_78_step_2', 'recipe_78', 2, 'Stir in black salt, cumin powder, and lots of crushed ice.', 60, 'Chill thoroughly.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_78_step_3', 'recipe_78', 3, 'Top with sparkling chilled soda or water, stir gently, garnish with lemon wheels, and serve cold.', 60, 'The ultimate thirst quencher.');

DELETE FROM `recipes` WHERE `id` = 'recipe_79';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_79', 'Fresh Watermelon Cooler', 'Vibrant ruby-red cold-pressed watermelon juice infused with fresh lime juice, black salt, and crushed mint leaves.', 'Chef Sunita Sharma', 'Continental', 'assets/images/recipes/watermelon_juice.jpg', 5, 0, 4, 'Easy', 'cat_drinks', 'Drinks,Juice,Watermelon,Summer,Healthy,Vegetarian', 0, 0, 1, 4.7, 'All India', 'Juice', '65 kcal | 1g Protein | 16g Carbs | 0g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_79_ing_1', 'recipe_79', 'Seedless fresh sweet watermelon', '5', 'cups', 'Cubed and chilled', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_79_ing_2', 'recipe_79', 'Fresh lime juice', '2', 'tbsp', 'Bright citrus lift', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_79_ing_3', 'recipe_79', 'Black salt or pink rock salt', '0.5', 'tsp', 'Enhances natural fruit sweetness', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_79_ing_4', 'recipe_79', 'Fresh mint sprigs', '6', 'leaves', 'Garnish', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_79_ing_5', 'recipe_79', 'Ice cubes', '1', 'cup', 'Chilled', 5);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_79_step_1', 'recipe_79', 1, 'Blend chilled watermelon cubes in short pulses until completely liquefied.', 60, 'No need to add any water.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_79_step_2', 'recipe_79', 2, 'Strain through a coarse sieve to remove any pulp or fiber if smooth juice is preferred.', 90, 'Straining yields crystal-clear vibrant juice.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_79_step_3', 'recipe_79', 3, 'Stir in fresh lime juice and black salt, pour over ice in highball glasses, and crown with mint sprigs.', 60, 'Serve immediately.');

DELETE FROM `recipes` WHERE `id` = 'recipe_80';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_80', 'Gulabi Rose Milk', 'Chilled, nostalgic pink summer cooler crafted with cold whole milk, aromatic rose syrup, sabja (sweet basil) seeds, and crushed ice.', 'Chef Ananya Iyer', 'South Indian', 'assets/images/recipes/rose_milk.jpg', 5, 0, 2, 'Easy', 'cat_drinks', 'Drinks,Rose Milk,Summer,Sabja,Sweet,Vegetarian', 0, 0, 1, 4.8, 'Tamil Nadu', 'Milk', '150 kcal | 4g Protein | 24g Carbs | 4g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_80_ing_1', 'recipe_80', 'Cold boiled whole milk', '2', 'cups', 'Chilled thoroughly', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_80_ing_2', 'recipe_80', 'Authentic rose syrup or Rooh Afza', '4', 'tbsp', 'Fragrant and rich', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_80_ing_3', 'recipe_80', 'Sabja seeds (sweet basil seeds)', '1', 'tbsp', 'Soaked in water for 15 minutes', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_80_ing_4', 'recipe_80', 'Pure rose water', '0.5', 'tsp', 'Optional floral boost', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_80_ing_5', 'recipe_80', 'Crushed ice', '0.5', 'cup', 'Chilled', 5);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_80_step_1', 'recipe_80', 1, 'Soak sabja seeds in 0.5 cup of warm water for 15 minutes until they swell into translucent jelly-coated pearls.', 900, 'Sabja seeds provide cooling ayurvedic properties.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_80_step_2', 'recipe_80', 2, 'Whisk chilled milk, rose syrup, and rosewater vigorously until frothy pink.', 60, 'Whisking produces light airy foam.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_80_step_3', 'recipe_80', 3, 'Spoon swollen sabja seeds into serving glasses, pour frothy rose milk, and top with crushed ice.', 60, 'Iconic South Indian cinema hall nostalgia.');

DELETE FROM `recipes` WHERE `id` = 'recipe_81';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_81', 'Moong Sprouts Chaat Salad', 'Power-packed crunchy green moong sprouts tossed with pomegranate arils, diced cucumbers, tomatoes, chaat masala, and lemon juice.', 'Chef Sunita Sharma', 'Indian', 'assets/images/recipes/sprouts_salad.jpg', 15, 0, 4, 'Easy', 'cat_healthy', 'Healthy,Salad,Sprouts,Protein Rich,Weight Loss,Vegetarian', 1, 0, 1, 4.9, 'All India', 'Salad', '130 kcal | 9g Protein | 22g Carbs | 1g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_81_ing_1', 'recipe_81', 'Fresh sprouted green moong beans', '2', 'cups', 'Steamed lightly or raw', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_81_ing_2', 'recipe_81', 'Finely diced cucumber and firm tomatoes', '1', 'cup', 'Crisp', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_81_ing_3', 'recipe_81', 'Fresh sweet pomegranate seeds', '0.5', 'cup', 'Juicy crunch', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_81_ing_4', 'recipe_81', 'Grated carrot & fresh coriander', '0.5', 'cup', 'Color and fiber', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_81_ing_5', 'recipe_81', 'Chaat masala & roasted cumin powder', '1', 'tsp', 'Tangy spice mix', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_81_ing_6', 'recipe_81', 'Fresh lemon juice & extra virgin olive oil', '2', 'tbsp', 'Light dressing', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_81_step_1', 'recipe_81', 1, 'Optionally steam sprouted moong beans for 3 minutes to enhance digestibility, then cool completely.', 180, 'Light steaming retains crunch and nutrients.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_81_step_2', 'recipe_81', 2, 'In a large bowl, combine sprouts, cucumber, tomatoes, pomegranate seeds, and grated carrot.', 120, 'Colorful medley is rich in antioxidants.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_81_step_3', 'recipe_81', 3, 'Toss with chaat masala, roasted cumin, rock salt, lemon juice, and chopped coriander; serve fresh.', 60, 'Excellent pre-workout or clean dinner salad.');

DELETE FROM `recipes` WHERE `id` = 'recipe_82';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_82', 'Fresh Rainbow Fruit Bowl', 'Vibrant antioxidant bowl bursting with seasonal fruits: papaya, kiwi, dragonfruit, apples, and berries dressed with chia seeds and raw honey.', 'Chef Sunita Sharma', 'Continental', 'assets/images/recipes/fruit_bowl.jpg', 10, 0, 2, 'Easy', 'cat_healthy', 'Healthy,Fruit Bowl,Antioxidant,Clean Eating,Detox,Vegetarian', 0, 0, 1, 4.8, 'All India', 'Breakfast Bowl', '145 kcal | 2g Protein | 34g Carbs | 1g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_82_ing_1', 'recipe_82', 'Ripe sweet papaya, cubed', '1', 'cup', 'Digestive enzymes', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_82_ing_2', 'recipe_82', 'Crisp red apple and kiwi slices', '1', 'cup', 'Vitamin C rich', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_82_ing_3', 'recipe_82', 'Fresh blueberries or pomegranate seeds', '0.5', 'cup', 'Antioxidants', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_82_ing_4', 'recipe_82', 'Chia seeds', '1', 'tbsp', 'Omega-3 superfood', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_82_ing_5', 'recipe_82', 'Organic raw honey', '1', 'tbsp', 'Natural sweetener', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_82_ing_6', 'recipe_82', 'Fresh mint leaves & lime zest', '1', 'tsp', 'Zesty aromatic lift', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_82_step_1', 'recipe_82', 1, 'Wash, peel, and bite-size chop fresh seasonal fruits.', 300, 'Use cold fruit for maximum crisp freshness.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_82_step_2', 'recipe_82', 2, 'Arrange in a wide serving bowl to display the vibrant natural rainbow colors.', 120, 'Presentation makes healthy food appealing.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_82_step_3', 'recipe_82', 3, 'Drizzle raw honey and lime zest, sprinkle chia seeds and fresh mint, and enjoy immediately.', 60, 'The best energizing morning boost.');

DELETE FROM `recipes` WHERE `id` = 'recipe_83';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_83', 'Golden Turmeric Oats Porridge', 'Warm, comforting rolled oats porridge simmered in almond milk, flavored with golden turmeric, cinnamon, chia seeds, and sliced almonds.', 'Chef Sunita Sharma', 'Continental', 'assets/images/recipes/oats_porridge.jpg', 5, 10, 2, 'Easy', 'cat_healthy', 'Healthy,Oats,Porridge,Turmeric,Anti-Inflammatory,Vegetarian', 0, 0, 1, 4.7, 'All India', 'Oats', '210 kcal | 7g Protein | 35g Carbs | 5g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_83_ing_1', 'recipe_83', 'Rolled oats (wholegrain)', '1', 'cup', 'High fiber', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_83_ing_2', 'recipe_83', 'Almond milk or skimmed dairy milk', '2.5', 'cups', 'Plant-based or cow''s milk', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_83_ing_3', 'recipe_83', 'Wild turmeric powder (haldi)', '0.5', 'tsp', 'Potent curcumin anti-inflammatory', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_83_ing_4', 'recipe_83', 'Ceylon cinnamon powder', '0.5', 'tsp', 'Regulates blood sugar', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_83_ing_5', 'recipe_83', 'Pure maple syrup or jaggery powder', '2', 'tbsp', 'Natural sweetener', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_83_ing_6', 'recipe_83', 'Sliced almonds and pumpkin seeds', '2', 'tbsp', 'Healthy fats and crunch', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_83_step_1', 'recipe_83', 1, 'Bring milk to a simmer in a small saucepan, add rolled oats, turmeric powder, and cinnamon.', 180, 'Cook on low flame to maintain creamy consistency.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_83_step_2', 'recipe_83', 2, 'Simmer for 6-8 minutes, stirring frequently until the oats become soft and velvety.', 420, 'Add extra warm milk if you prefer a looser consistency.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_83_step_3', 'recipe_83', 3, 'Pour into warm ceramic bowls, drizzle maple syrup, and top with toasted almonds and pumpkin seeds.', 60, 'Nourishing start to any morning.');

DELETE FROM `recipes` WHERE `id` = 'recipe_84';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_84', 'Chia Seed Overnight Oats', 'No-cook grab-and-go breakfast of rolled oats and chia seeds soaked overnight in Greek yogurt and oat milk, topped with fresh berries.', 'Chef Sunita Sharma', 'Continental', 'assets/images/recipes/overnight_oats.jpg', 10, 0, 2, 'Easy', 'cat_healthy', 'Healthy,Overnight Oats,No Cook,Meal Prep,Superfood,Vegetarian', 0, 0, 1, 4.8, 'Continental', 'Oats', '230 kcal | 8g Protein | 36g Carbs | 6g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_84_ing_1', 'recipe_84', 'Rolled old-fashioned oats', '1', 'cup', 'Gluten-free oats', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_84_ing_2', 'recipe_84', 'Oat milk or almond milk', '1', 'cup', 'Unsweetened', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_84_ing_3', 'recipe_84', 'Greek yogurt', '0.5', 'cup', 'High-protein thick yogurt', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_84_ing_4', 'recipe_84', 'Chia seeds', '2', 'tbsp', 'Thickens into pudding overnight', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_84_ing_5', 'recipe_84', 'Pure maple syrup or raw honey', '1.5', 'tbsp', 'Sweetener', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_84_ing_6', 'recipe_84', 'Fresh strawberries and sliced banana', '0.5', 'cup', 'Morning topping', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_84_step_1', 'recipe_84', 1, 'Combine rolled oats, chia seeds, milk, Greek yogurt, and honey in mason jars; stir thoroughly until well mixed.', 180, 'Ensure chia seeds are dispersed evenly.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_84_step_2', 'recipe_84', 2, 'Seal the jars with airtight lids and refrigerate overnight (or at least 6 hours).', 21600, 'Oats and chia seeds absorb the liquid and swell into a creamy pudding.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_84_step_3', 'recipe_84', 3, 'Open jar in the morning, layer fresh sliced berries and banana on top, and enjoy chilled.', 60, 'Ideal nutritious morning meal prep.');

DELETE FROM `recipes` WHERE `id` = 'recipe_85';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_85', 'Crispy Ragi Dosa', 'Calcium-rich, diabetic-friendly South Indian fermented crepes made with nutrient-dense finger millet (ragi) flour and urad dal.', 'Chef Ramesh Rao', 'South Indian', 'assets/images/recipes/ragi_dosa.jpg', 15, 15, 4, 'Medium', 'cat_healthy', 'Healthy,Ragi,Millet,Dosa,Calcium Rich,Gluten Friendly,Vegetarian', 1, 0, 1, 4.8, 'Karnataka', 'Millet', '170 kcal | 5g Protein | 32g Carbs | 3g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_85_ing_1', 'recipe_85', 'Sprouted ragi (finger millet) flour', '1.5', 'cups', 'Calcium powerpack', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_85_ing_2', 'recipe_85', 'Urad dal (fermented batter)', '0.5', 'cup', 'Provides fluffiness and crisp edges', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_85_ing_3', 'recipe_85', 'Finely chopped onion, green chili & curry leaves', '0.5', 'cup', 'For batter seasoning', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_85_ing_4', 'recipe_85', 'Cumin seeds', '1', 'tsp', 'Digestive spice', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_85_ing_5', 'recipe_85', 'Cold-pressed sesame oil', '2', 'tbsp', 'For roasting', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_85_ing_6', 'recipe_85', 'Pink Himalayan salt', '1', 'tsp', 'To taste', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_85_step_1', 'recipe_85', 1, 'Mix ragi flour, urad dal batter, chopped onions, chilies, cumin seeds, and water into a smooth, thin pourable batter.', 300, 'Rest for 15 minutes before pouring.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_85_step_2', 'recipe_85', 2, 'Heat a cast iron tawa until piping hot, grease with sesame oil, and pour a ladle of batter from the outer rim inward.', 120, 'Pouring from outside in creates lace-like crispy pores.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_85_step_3', 'recipe_85', 3, 'Cook on medium flame until edges turn crispy, flip and cook for 1 minute, and serve with flaxseed chutney podi or tomato chutney.', 180, 'Incredible superfood breakfast.');

DELETE FROM `recipes` WHERE `id` = 'recipe_86';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_86', 'Mediterranean Quinoa Pulao', 'Fluffy, protein-packed tri-color quinoa simmered with colorful bell peppers, zucchini, green peas, and fragrant whole garam masala.', 'Chef Sunita Sharma', 'Fusion', 'assets/images/recipes/quinoa_pulao.jpg', 15, 20, 4, 'Easy', 'cat_healthy', 'Healthy,Quinoa,Gluten Free,High Protein,Pulao,Vegetarian', 0, 0, 1, 4.7, 'Fusion', 'Pulao', '210 kcal | 8g Protein | 34g Carbs | 5g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_86_ing_1', 'recipe_86', 'White or tri-color quinoa', '1.5', 'cups', 'Rinsed thoroughly in fine sieve', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_86_ing_2', 'recipe_86', 'Mixed vegetables (diced zucchini, bell peppers, peas, carrots)', '2', 'cups', 'Fresh', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_86_ing_3', 'recipe_86', 'Onion, finely sliced', '1', 'medium', 'Sauteed', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_86_ing_4', 'recipe_86', 'Cumin seeds, bay leaf & cardamom', '1', 'tbsp', 'Whole aromatics', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_86_ing_5', 'recipe_86', 'Vegetable stock or water', '3', 'cups', 'Flavorful broth', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_86_ing_6', 'recipe_86', 'Cold pressed olive oil', '1.5', 'tbsp', 'Healthy fat', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_86_step_1', 'recipe_86', 1, 'Rinse quinoa vigorously in cold running water using a fine-mesh strainer to remove bitter natural saponins.', 180, 'Rinsing is vital for clean nutty flavor.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_86_step_2', 'recipe_86', 2, 'Heat olive oil in a pan, bloom cumin and whole spices, saute onions and colorful vegetables for 3-4 minutes.', 240, 'Keep vegetables crisp-tender.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_86_step_3', 'recipe_86', 3, 'Add drained quinoa and hot vegetable broth, bring to a boil, cover tightly and simmer on low for 15 minutes, then fluff with a fork.', 900, 'Serve warm with minted yogurt dip.');

DELETE FROM `recipes` WHERE `id` = 'recipe_87';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_87', 'Hearty Garden Vegetable Soup', 'Nourishing, warming clear soup simmered with garden-fresh broccoli florets, carrots, beans, baby corn, celery, and cracked black pepper.', 'Chef Sunita Sharma', 'Continental', 'assets/images/recipes/vegetable_soup.jpg', 15, 20, 4, 'Easy', 'cat_healthy', 'Healthy,Soup,Vegetable Soup,Low Calorie,Detox,Vegetarian', 0, 0, 1, 4.7, 'Continental', 'Soup', '75 kcal | 3g Protein | 14g Carbs | 1g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_87_ing_1', 'recipe_87', 'Finely diced vegetables (carrot, French beans, broccoli, baby corn)', '2.5', 'cups', 'Fresh crunchy veg', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_87_ing_2', 'recipe_87', 'Finely minced garlic and celery', '2', 'tbsp', 'Aromatic base', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_87_ing_3', 'recipe_87', 'Fresh vegetable broth', '4', 'cups', 'Simmered vegetable stock', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_87_ing_4', 'recipe_87', 'Cracked black peppercorns', '1', 'tsp', 'Warming spice', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_87_ing_5', 'recipe_87', 'Extra virgin olive oil', '1', 'tbsp', 'For sauteing aromatics', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_87_ing_6', 'recipe_87', 'Fresh parsley or spring onion greens', '2', 'tbsp', 'Finishing herb', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_87_step_1', 'recipe_87', 1, 'Heat olive oil in a soup pot, gently saute minced garlic and celery for 1-2 minutes until fragrant.', 120, 'Do not brown garlic.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_87_step_2', 'recipe_87', 2, 'Add diced carrots, beans, and baby corn; pour in hot vegetable broth, season with salt and simmer for 10 minutes.', 600, 'Cook until vegetables are tender yet crisp.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_87_step_3', 'recipe_87', 3, 'Toss in broccoli florets, simmer for 3 more minutes, season with cracked black pepper, and serve hot.', 180, 'Pure restorative comfort.');

DELETE FROM `recipes` WHERE `id` = 'recipe_88';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_88', 'Sweet Corn Veggie Soup', 'Creamy restaurant-style comfort soup packed with tender sweet corn kernels, finely minced vegetables, and a warming peppery kick.', 'Chef Sunita Sharma', 'Indo-Chinese', 'assets/images/recipes/sweet_corn_soup.jpg', 10, 15, 4, 'Easy', 'cat_healthy', 'Healthy,Soup,Sweet Corn,Indo-Chinese,Warm,Vegetarian', 0, 0, 1, 4.8, 'Indo-Chinese', 'Soup', '95 kcal | 3g Protein | 18g Carbs | 1g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_88_ing_1', 'recipe_88', 'Sweet corn kernels (creamed + whole)', '2', 'cups', 'Fresh or frozen', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_88_ing_2', 'recipe_88', 'Finely diced carrots and cabbage', '0.75', 'cup', 'Crunchy texture', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_88_ing_3', 'recipe_88', 'Vegetable broth or water', '4', 'cups', 'Liquid base', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_88_ing_4', 'recipe_88', 'Cornstarch slurry (cornflour in water)', '2', 'tbsp', 'Natural thickener', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_88_ing_5', 'recipe_88', 'Crushed white pepper & light soy sauce', '1', 'tsp', 'Seasoning', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_88_ing_6', 'recipe_88', 'Spring onion greens', '0.25', 'cup', 'Finely chopped garnish', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_88_step_1', 'recipe_88', 1, 'Puree 1 cup of sweet corn into a smooth cream, leaving the other cup of whole kernels intact.', 180, 'Corn puree provides natural body without excessive starch.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_88_step_2', 'recipe_88', 2, 'Bring broth, corn puree, whole corn kernels, carrots, and cabbage to a simmer in a saucepan for 8 minutes.', 480, 'Skim off any foam from the surface.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_88_step_3', 'recipe_88', 3, 'Stir in cornstarch slurry, simmer for 2 minutes until glossy and thick, season with white pepper and top with spring onions.', 180, 'Serve piping hot.');

DELETE FROM `recipes` WHERE `id` = 'recipe_89';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_89', 'Grilled Paneer Protein Salad', 'Marinated low-fat cottage cheese cubes grilled golden, served over crisp mixed salad greens, bell peppers, walnuts, and balsamic herb dressing.', 'Chef Ramesh Rao', 'Fusion', 'assets/images/recipes/paneer_salad.jpg', 15, 10, 2, 'Easy', 'cat_healthy', 'Healthy,Salad,Paneer,High Protein,Keto,Vegetarian', 1, 0, 1, 4.8, 'Fusion', 'Salad', '260 kcal | 16g Protein | 10g Carbs | 18g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_89_ing_1', 'recipe_89', 'Fresh paneer (cottage cheese), cubed', '200', 'g', 'High calcium protein', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_89_ing_2', 'recipe_89', 'Crisp iceberg lettuce & baby spinach', '3', 'cups', 'Washed and torn', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_89_ing_3', 'recipe_89', 'Cherry tomatoes & tri-color bell peppers', '1', 'cup', 'Sliced', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_89_ing_4', 'recipe_89', 'Walnut halves, lightly toasted', '0.25', 'cup', 'Omega-3 crunch', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_89_ing_5', 'recipe_89', 'Italian herb seasoning & garlic powder', '1', 'tsp', 'Marinade', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_89_ing_6', 'recipe_89', 'Balsamic vinegar & extra virgin olive oil', '2', 'tbsp', 'Emulsified dressing', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_89_step_1', 'recipe_89', 1, 'Toss paneer cubes in olive oil, herb seasoning, garlic powder, and a pinch of black pepper.', 180, 'Let marinate for 10 minutes.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_89_step_2', 'recipe_89', 2, 'Sear paneer on a hot grill pan for 2 minutes on each side until charred with golden grill lines.', 240, 'Do not overcook or paneer will turn rubbery.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_89_step_3', 'recipe_89', 3, 'Arrange torn salad greens, bell peppers, and cherry tomatoes in a wide bowl, place warm grilled paneer on top, scatter walnuts, and drizzle balsamic dressing.', 120, 'Rich, filling, clean high-protein meal.');

DELETE FROM `recipes` WHERE `id` = 'recipe_90';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_90', 'Foxtail Millet Upma', 'Wholesome gluten-free breakfast porridge prepared with fiber-rich foxtail millet grains, garden veggies, crunchy cashews, and mustard tempering.', 'Chef Shwetha Hegde', 'South Indian', 'assets/images/recipes/millet_upma.jpg', 15, 20, 4, 'Easy', 'cat_healthy', 'Healthy,Millet,Foxtail Millet,Gluten Free,Diet Friendly,Vegetarian', 0, 0, 1, 4.7, 'Karnataka', 'Millet', '190 kcal | 6g Protein | 34g Carbs | 4g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_90_ing_1', 'recipe_90', 'Foxtail millet (Navane)', '1.5', 'cups', 'Rinsed and dry-roasted', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_90_ing_2', 'recipe_90', 'Mustard seeds, chana dal & urad dal', '1.5', 'tsp', 'Tempering', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_90_ing_3', 'recipe_90', 'Finely chopped onion, ginger & green chilies', '0.75', 'cup', 'Aromatics', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_90_ing_4', 'recipe_90', 'Diced carrot, French beans & green peas', '1', 'cup', 'Nutrient rich veggies', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_90_ing_5', 'recipe_90', 'Water', '3.5', 'cups', 'Boiling hot', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_90_ing_6', 'recipe_90', 'Ghee and fresh lemon juice', '1', 'tbsp', 'Finishing touch', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_90_step_1', 'recipe_90', 1, 'Rinse foxtail millet and roast in a dry pan for 3 minutes until aromatic.', 180, 'Dry roasting produces separate, non-sticky grains.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_90_step_2', 'recipe_90', 2, 'Heat oil in a pan, crackle mustard seeds and lentils, saute onions, ginger, green chilies, and vegetables for 4 minutes.', 240, 'Cook until vegetables soften slightly.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_90_step_3', 'recipe_90', 3, 'Add boiling water with salt, stir in roasted foxtail millet, cover tightly, and cook on low heat for 12-14 minutes until tender, finish with lemon juice and coriander.', 840, 'A wholesome, diabetic-friendly South Indian classic.');

DELETE FROM `recipes` WHERE `id` = 'recipe_91';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_91', 'Hyderabadi Chicken Dum Biryani', 'World-famous royal Nizami biryani layered with marinated tender chicken, fragrant saffron-infused long-grain basmati rice, and caramelized fried onions.', 'Chef Mohammed Zeeshan', 'Hyderabadi', 'assets/images/recipes/chicken_biryani.jpg', 45, 40, 6, 'Hard', 'cat_non_veg', 'Non-Veg,Biryani,Chicken,Hyderabadi,Royal,Dum Biryani', 1, 0, 0, 4.9, 'Hyderabad', 'Biryani', '480 kcal | 28g Protein | 52g Carbs | 18g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_91_ing_1', 'recipe_91', 'Tender bone-in chicken pieces', '1', 'kg', 'Curry cut pieces', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_91_ing_2', 'recipe_91', 'Aged long-grain Basmati rice', '750', 'g', 'Parboiled with whole spices to 70%', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_91_ing_3', 'recipe_91', 'Thick yogurt (dahi)', '1.5', 'cups', 'Whisked for marinade', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_91_ing_4', 'recipe_91', 'Ginger-garlic paste', '3', 'tbsp', 'Freshly pounded', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_91_ing_5', 'recipe_91', 'Biryani masala, Kashmiri chili, and turmeric', '2.5', 'tbsp', 'Rich spice blend', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_91_ing_6', 'recipe_91', 'Caramelized golden onions (birista) & pure ghee', '1.5', 'cups', 'Essential layering', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_91_step_1', 'recipe_91', 1, 'Marinate chicken with yogurt, ginger-garlic paste, spices, half the fried onions, mint, coriander, and oil for at least 2 hours.', 7200, 'Long marination ensures tender, juicy meat infused with spices.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_91_step_2', 'recipe_91', 2, 'Boil aged basmati rice in heavily salted water with whole spices until 70% cooked; drain quickly.', 600, 'Rice grains should still have a firm core bite.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_91_step_3', 'recipe_91', 3, 'Layer marinated chicken in a heavy handi, top with parboiled rice, fried onions, mint, saffron milk, and ghee; seal lid with dough and cook on ''dum'' for 35 minutes.', 2100, 'Rest for 10 minutes before breaking open to let aromas settle.');

DELETE FROM `recipes` WHERE `id` = 'recipe_92';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_92', 'Restaurant Style Butter Chicken', 'Succulent chargrilled tandoori chicken simmered in an indulgent, velvety tomato-butter gravy infused with dried fenugreek leaves (kasuri methi).', 'Chef Harpreet Singh', 'North Indian', 'assets/images/recipes/butter_chicken.jpg', 30, 35, 4, 'Medium', 'cat_non_veg', 'Non-Veg,Butter Chicken,Murg Makhani,North Indian,Creamy', 1, 0, 0, 4.9, 'Punjab', 'Curry', '440 kcal | 26g Protein | 14g Carbs | 32g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_92_ing_1', 'recipe_92', 'Boneless chicken thighs', '700', 'g', 'Cut into bite-size pieces', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_92_ing_2', 'recipe_92', 'Ripe red tomatoes', '800', 'g', 'Pureed and strained smooth', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_92_ing_3', 'recipe_92', 'Cashew nut paste', '0.5', 'cup', 'For velvety silkiness', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_92_ing_4', 'recipe_92', 'Pure butter (makhan)', '4', 'tbsp', 'Essential richness', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_92_ing_5', 'recipe_92', 'Fresh heavy cream', '0.5', 'cup', 'Silky finish', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_92_ing_6', 'recipe_92', 'Crushed Kasuri methi (fenugreek leaves)', '1.5', 'tbsp', 'Signature restaurant aroma', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_92_step_1', 'recipe_92', 1, 'Marinate chicken in hung curd, ginger-garlic paste, and tandoori spices; grill or sear on high heat until charred.', 900, 'Chargrilled smokiness is the soul of authentic butter chicken.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_92_step_2', 'recipe_92', 2, 'Cook tomato puree with butter, cashew paste, mild Kashmiri chili, and honey until butter separates.', 1200, 'Strain the gravy for an ultra-velvety restaurant texture.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_92_step_3', 'recipe_92', 3, 'Add grilled chicken pieces, simmer for 8 minutes, stir in fresh cream and crushed kasuri methi, and finish with a swirl of butter.', 480, 'Serve warm with garlic butter naan.');

DELETE FROM `recipes` WHERE `id` = 'recipe_93';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_93', 'Crispy South Indian Chicken 65', 'Legendary Chennai street-style deep-fried spicy chicken bites coated in fiery red masala, tempered with curry leaves and green chilies.', 'Chef Ramesh Rao', 'South Indian', 'assets/images/recipes/chicken_65.jpg', 20, 15, 4, 'Easy', 'cat_non_veg', 'Non-Veg,Chicken 65,Starter,Crispy,South Indian,Chennai', 1, 0, 0, 4.8, 'Tamil Nadu', 'Starters', '310 kcal | 24g Protein | 12g Carbs | 18g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_93_ing_1', 'recipe_93', 'Boneless chicken breast or thigh', '500', 'g', 'Cut into bite-sized 1-inch cubes', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_93_ing_2', 'recipe_93', 'Kashmiri red chili powder & black pepper', '2', 'tbsp', 'Fiery crimson seasoning', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_93_ing_3', 'recipe_93', 'Ginger-garlic paste', '1.5', 'tbsp', 'Fresh', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_93_ing_4', 'recipe_93', 'Cornstarch and rice flour', '3', 'tbsp', 'Gives irresistible crunch', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_93_ing_5', 'recipe_93', 'Egg white', '1', 'large', 'Binds the marinade', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_93_ing_6', 'recipe_93', 'Curry leaves and slit green chilies', '20', 'leaves', 'For finishing tempering', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_93_step_1', 'recipe_93', 1, 'Marinate chicken cubes with ginger-garlic paste, chili powder, curd, egg white, cornstarch, rice flour, and salt for 30 minutes.', 1800, 'Rice flour creates extra crispiness that stays crunchy.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_93_step_2', 'recipe_93', 2, 'Deep-fry chicken pieces in batches in hot oil for 5-6 minutes until deep red, cooked through, and super crispy; drain on paper.', 360, 'Do not overcrowd the frying pan.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_93_step_3', 'recipe_93', 3, 'In a wok, heat 1 tbsp oil, flash-fry heaps of curry leaves and slit green chilies, toss the fried chicken briefly, and serve with lemon wedges.', 120, 'Serve hot as a starter.');

DELETE FROM `recipes` WHERE `id` = 'recipe_94';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_94', 'Tandoori Chicken Tikka', 'Juicy chicken leg quarters marinated in spiced yogurt and mustard oil, roasted to smoky charred perfection.', 'Chef Harpreet Singh', 'North Indian', 'assets/images/recipes/tandoori_chicken.jpg', 30, 25, 4, 'Medium', 'cat_non_veg', 'Non-Veg,Tandoori,Chicken,Smoky,Grilled,North Indian', 1, 0, 0, 4.9, 'Punjab', 'Starters', '290 kcal | 32g Protein | 4g Carbs | 16g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_94_ing_1', 'recipe_94', 'Whole chicken leg quarters', '4', 'pieces', 'Deeply scored across the flesh', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_94_ing_2', 'recipe_94', 'Hung curd (thick yogurt)', '1', 'cup', 'Drained of whey', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_94_ing_3', 'recipe_94', 'Pungent mustard oil (kachi ghani)', '3', 'tbsp', 'Imparts authentic smokiness', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_94_ing_4', 'recipe_94', 'Kashmiri chili powder & garam masala', '2.5', 'tbsp', 'Bright natural red color', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_94_ing_5', 'recipe_94', 'Ginger-garlic paste & lemon juice', '2', 'tbsp', 'Tenderizer', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_94_ing_6', 'recipe_94', 'Chaat masala and butter for basting', '2', 'tbsp', 'Finishing touch', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_94_step_1', 'recipe_94', 1, 'First marinade: Rub scored chicken with lemon juice, salt, and chili powder; rest for 20 minutes to draw out excess moisture.', 1200, 'Deep cuts allow flavors to penetrate all the way to the bone.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_94_step_2', 'recipe_94', 2, 'Second marinade: Whisk hung curd, mustard oil, ginger-garlic paste, and spices; coat chicken thoroughly and chill for 4 hours.', 14400, 'Mustard oil and yogurt tenderize the chicken meat.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_94_step_3', 'recipe_94', 3, 'Roast in a preheated 230°C (450°F) oven or charcoal grill for 22-25 minutes, basting with melted butter until charred; sprinkle chaat masala.', 1500, 'Serve hot with mint chutney and pickled onion rings.');

DELETE FROM `recipes` WHERE `id` = 'recipe_95';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_95', 'Chicken Tikka Masala', 'Chargrilled spiced boneless chicken chunks enveloped in a robust, tangy spiced tomato-onion curry loaded with bell peppers.', 'Chef Mohammed Zeeshan', 'North Indian', 'assets/images/recipes/chicken_tikka_masala.jpg', 30, 30, 4, 'Medium', 'cat_non_veg', 'Non-Veg,Chicken Tikka Masala,Curry,North Indian,Spicy', 0, 0, 0, 4.8, 'Punjab', 'Curry', '390 kcal | 28g Protein | 16g Carbs | 24g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_95_ing_1', 'recipe_95', 'Boneless chicken breasts or thighs', '600', 'g', 'Cut into 1.5 inch cubes', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_95_ing_2', 'recipe_95', 'Finely chopped onions & tomato puree', '3', 'cups', 'Curry base', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_95_ing_3', 'recipe_95', 'Ginger-garlic paste', '2', 'tbsp', 'Fresh', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_95_ing_4', 'recipe_95', 'Diced green and red bell peppers', '1', 'cup', 'Added for crunch', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_95_ing_5', 'recipe_95', 'Coriander, cumin, garam masala, paprika', '2', 'tbsp', 'Spice blend', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_95_ing_6', 'recipe_95', 'Heavy cream and fresh cilantro', '0.25', 'cup', 'Garnish', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_95_step_1', 'recipe_95', 1, 'Marinate chicken cubes with yogurt, spices, and oil; thread onto skewers and grill until charred on all sides.', 720, 'Tikka pieces should have nice grill charring.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_95_step_2', 'recipe_95', 2, 'Saute onions in oil until golden brown, add ginger-garlic paste, spices, and tomato puree; cook until oil floats to top.', 900, 'Bhuna stage concentrates rich tomato flavor.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_95_step_3', 'recipe_95', 3, 'Fold in grilled chicken tikka cubes and crunchy bell peppers, simmer for 5 minutes with cream, and garnish with cilantro.', 300, 'Pair with hot naan or jeera rice.');

DELETE FROM `recipes` WHERE `id` = 'recipe_96';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_96', 'Chettinad Chicken Pepper Curry', 'Fiery Tamil delicacy prepared with fresh stone-ground Chettinad masala of black pepper, fennel, poppy seeds, star anise, and toasted coconut.', 'Chef Ananya Iyer', 'South Indian', 'assets/images/recipes/chicken_chettinad.jpg', 25, 30, 4, 'Medium', 'cat_non_veg', 'Non-Veg,Chettinad,Chicken,Spicy,Tamil Nadu,Peppery', 1, 0, 0, 4.9, 'Tamil Nadu', 'Curry', '360 kcal | 27g Protein | 10g Carbs | 23g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_96_ing_1', 'recipe_96', 'Country chicken or tender chicken curry cut', '800', 'g', 'Bone-in pieces', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_96_ing_2', 'recipe_96', 'Chettinad whole spices (black pepper, fennel, coriander, star anise, cloves)', '3', 'tbsp', 'Dry roasted & ground', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_96_ing_3', 'recipe_96', 'Fresh grated coconut', '0.5', 'cup', 'Roasted golden brown', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_96_ing_4', 'recipe_96', 'Small shallots (sambhar onions)', '1.5', 'cups', 'Sliced', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_96_ing_5', 'recipe_96', 'Gingelly (sesame) oil', '3', 'tbsp', 'Authentic Chettinad medium', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_96_ing_6', 'recipe_96', 'Fresh curry leaves and green chilies', '2', 'sprigs', 'Tempering', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_96_step_1', 'recipe_96', 1, 'Dry roast whole spices and grated coconut in a pan until fragrant and golden; grind into a smooth aromatic paste with water.', 480, 'Freshly ground masala makes all the difference.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_96_step_2', 'recipe_96', 2, 'Heat sesame oil, crackle fennel and lots of curry leaves, saute shallots and tomatoes until soft and pulpy.', 360, 'Shallots impart a distinctive sweetness.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_96_step_3', 'recipe_96', 3, 'Add chicken pieces, ground Chettinad paste, and water; cover and cook on medium flame for 20-25 minutes until chicken is tender and oil surfaces.', 1500, 'Serve hot with steaming rice or parotta.');

DELETE FROM `recipes` WHERE `id` = 'recipe_97';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_97', 'Royal Awadhi Mutton Biryani', 'Fragrant Lucknowi-style slow-cooked dum biryani made with succulent young mutton pieces, long-grain basmati, saffron, and sweet rose essence.', 'Chef Mohammed Zeeshan', 'Mughlai', 'assets/images/recipes/mutton_biryani.jpg', 45, 60, 6, 'Hard', 'cat_non_veg', 'Non-Veg,Biryani,Mutton,Awadhi,Royal,Mughlai', 1, 0, 0, 4.9, 'Awadh', 'Biryani', '560 kcal | 32g Protein | 50g Carbs | 24g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_97_ing_1', 'recipe_97', 'Tender goat meat (baby mutton)', '1', 'kg', 'Curry cut with bone', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_97_ing_2', 'recipe_97', 'Royal aged Basmati rice', '750', 'g', 'Soaked for 1 hour', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_97_ing_3', 'recipe_97', 'Mutton stock (yakhni)', '3', 'cups', 'Extracted by simmering meat with spices', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_97_ing_4', 'recipe_97', 'Pure desi ghee', '0.5', 'cup', 'For cooking and layering', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_97_ing_5', 'recipe_97', 'Saffron milk, kewra water, rose water', '2', 'tbsp', 'Signature Awadhi perfumery', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_97_ing_6', 'recipe_97', 'Golden fried onions (birista)', '1.5', 'cups', 'Thinly sliced', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_97_step_1', 'recipe_97', 1, 'Simmer mutton pieces with whole spices, garlic, ginger, and water until 80% tender; separate the cooked meat and strain flavorful yakhni broth.', 2400, 'Awadhi biryani cooks rice in rich yakhni broth for maximum flavor.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_97_step_2', 'recipe_97', 2, 'Cook basmati rice in salted spiced water until 70% done; drain.', 600, 'Ensure rice maintains long distinct grains.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_97_step_3', 'recipe_97', 3, 'Layer braised mutton and rice in a copper handi with ghee, saffron milk, fried onions, and kewra; seal airtight and dum cook on low flame for 25 minutes.', 1500, 'Gentle, non-greasy, intensely fragrant royal feast.');

DELETE FROM `recipes` WHERE `id` = 'recipe_98';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_98', 'Mutton Pepper Sukka Fry', 'Tender pieces of mutton dry-roasted in a spicy gravy of crushed black peppercorns, caramelized shallots, curry leaves, and coconut oil.', 'Chef Ramesh Rao', 'South Indian', 'assets/images/recipes/mutton_pepper_fry.jpg', 25, 40, 4, 'Medium', 'cat_non_veg', 'Non-Veg,Mutton,Pepper Fry,Sukka,South Indian,Spicy', 0, 0, 0, 4.8, 'Tamil Nadu', 'Dry Roast', '410 kcal | 30g Protein | 8g Carbs | 28g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_98_ing_1', 'recipe_98', 'Tender mutton (boneless and bone-in blend)', '750', 'g', 'Small cubes', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_98_ing_2', 'recipe_98', 'Black peppercorns (freshly crushed)', '2.5', 'tbsp', 'Bold pepper heat', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_98_ing_3', 'recipe_98', 'Shallots (sambar onions), finely sliced', '2', 'cups', 'Caramelized sweetness', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_98_ing_4', 'recipe_98', 'Ginger-garlic paste', '2', 'tbsp', 'Fresh', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_98_ing_5', 'recipe_98', 'Curry leaves', '3', 'sprigs', 'Abundant fresh leaves', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_98_ing_6', 'recipe_98', 'Cold pressed coconut oil or ghee', '3', 'tbsp', 'Rich frying base', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_98_step_1', 'recipe_98', 1, 'Pressure cook mutton with turmeric, salt, half the ginger-garlic paste, and 1 cup of water for 4 whistles until fork-tender.', 1200, 'Keep the remaining stock for reduction.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_98_step_2', 'recipe_98', 2, 'Heat coconut oil in an iron kadai, saute shallots, green chilies, and curry leaves until golden brown.', 480, 'Cast iron enhances the deep dark roasted color.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_98_step_3', 'recipe_98', 3, 'Add cooked mutton with its stock, stir in heaps of crushed black pepper and garam masala; roast on high flame until moisture evaporates completely and masala coats each piece.', 900, 'Garnish with fried curry leaves.');

DELETE FROM `recipes` WHERE `id` = 'recipe_99';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_99', 'Goan Coconut Fish Curry', 'Tangy, mildly spicy Goan coastal delicacy made with fresh fish steaks simmered in creamy coconut milk with dried kokum and red chilies.', 'Chef Maria D''Souza', 'Coastal', 'assets/images/recipes/fish_curry.jpg', 20, 20, 4, 'Easy', 'cat_non_veg', 'Non-Veg,Fish Curry,Goan,Coastal,Coconut Milk,Kokum', 1, 0, 0, 4.8, 'Goa', 'Curry', '290 kcal | 24g Protein | 8g Carbs | 18g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_99_ing_1', 'recipe_99', 'Fresh Kingfish (Surmai) or Pomfret steaks', '600', 'g', 'Thick cut pieces', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_99_ing_2', 'recipe_99', 'Fresh grated coconut', '1.5', 'cups', 'Ground into fine paste', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_99_ing_3', 'recipe_99', 'Thick coconut milk', '1', 'cup', 'First press', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_99_ing_4', 'recipe_99', 'Dried kokum petals', '6', 'pieces', 'Soaked in warm water for tang', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_99_ing_5', 'recipe_99', 'Kashmiri whole red chilies, coriander seeds, cumin', '2', 'tbsp', 'Ground curry paste', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_99_ing_6', 'recipe_99', 'Coconut oil and green chilies', '2', 'tbsp', 'Authentic coastal aromatics', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_99_step_1', 'recipe_99', 1, 'Grind grated coconut, soaked red chilies, coriander seeds, cumin, garlic, and turmeric into a velvety smooth orange paste.', 420, 'Smooth paste ensures a luxurious curry broth.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_99_step_2', 'recipe_99', 2, 'Heat coconut oil in an earthen clay pot (chatti), saute sliced onions and green chilies, then stir in the ground paste and water.', 300, 'Earthen cookware brings out coastal authenticity.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_99_step_3', 'recipe_99', 3, 'Add soaked kokum and salt, bring to a simmer, gently lower fish steaks into the bubbling curry, cook for 7-8 minutes, and finish with coconut milk.', 480, 'Do not overcook fish; serve with steaming parboiled rice.');

DELETE FROM `recipes` WHERE `id` = 'recipe_100';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_100', 'Mangalorean Crispy Fish Tawa Fry', 'Succulent Kingfish steaks marinated in a fiery Mangalorean Byadgi chili and tamarind paste, coated with coarse semolina (rava), and shallow fried.', 'Chef Ramesh Rao', 'Coastal', 'assets/images/recipes/fish_fry.jpg', 20, 15, 4, 'Easy', 'cat_non_veg', 'Non-Veg,Fish Fry,Rava Fry,Mangalore,Coastal,Crispy', 1, 0, 0, 4.9, 'Coastal Karnataka', 'Starters', '270 kcal | 26g Protein | 14g Carbs | 12g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_100_ing_1', 'recipe_100', 'Fresh Surmai (Kingfish) steaks', '4', 'thick slices', 'Cleaned and patted dry', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_100_ing_2', 'recipe_100', 'Byadgi red chili powder (vibrant red, mild heat)', '2', 'tbsp', 'Mangalore specialty', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_100_ing_3', 'recipe_100', 'Thick tamarind paste & lemon juice', '1.5', 'tbsp', 'Tangy tenderizer', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_100_ing_4', 'recipe_100', 'Ginger-garlic paste and turmeric', '1.5', 'tbsp', 'Aromatic base', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_100_ing_5', 'recipe_100', 'Fine semolina (chiroti rava) and rice flour', '0.5', 'cup', 'For crispy outer crust', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_100_ing_6', 'recipe_100', 'Coconut oil for shallow frying', '4', 'tbsp', 'Authentic flavor', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_100_step_1', 'recipe_100', 1, 'Mix red chili powder, turmeric, ginger-garlic paste, tamarind pulp, lemon juice, and salt into a thick marinade; coat fish steaks generously and rest for 20 minutes.', 1200, 'Resting allows acidic tamarind to tenderize and flavor the fish.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_100_step_2', 'recipe_100', 2, 'Dredge marinated fish slices in coarse semolina mixed with rice flour, pressing gently so the crust adheres evenly.', 180, 'Rava coating creates a delightfully crunchy outer jacket.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_100_step_3', 'recipe_100', 3, 'Shallow-fry on a medium-hot cast iron tawa with coconut oil for 3-4 minutes per side until golden and crispy; serve with onion rings and lemon.', 360, 'Enjoy hot and fresh off the tawa.');

DELETE FROM `recipes` WHERE `id` = 'recipe_101';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_101', 'Punjabi Samosa', 'Iconic triangular pyramid pastries filled with spiced mashed potatoes, sweet green peas, cashews, and raisins, fried to golden-brown flaky perfection.', 'Chef Harpreet Singh', 'North Indian', 'assets/images/recipes/samosa.jpg', 30, 25, 6, 'Medium', 'cat_snacks', 'Snacks,Samosa,Street Food,Tea Time,Crispy,Vegetarian', 1, 0, 1, 4.9, 'Punjab', 'Street Food', '260 kcal | 4g Protein | 32g Carbs | 13g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_101_ing_1', 'recipe_101', 'All-purpose flour (maida)', '2', 'cups', 'Sifted', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_101_ing_2', 'recipe_101', 'Pure desi ghee or warm oil (moyen)', '4', 'tbsp', 'Rubbed into flour for flaky crust', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_101_ing_3', 'recipe_101', 'Ajwain (carom seeds)', '1', 'tsp', 'Digestive aroma', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_101_ing_4', 'recipe_101', 'Boiled potatoes, coarsely broken', '4', 'medium', 'Not mashed, chunky', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_101_ing_5', 'recipe_101', 'Green peas, cashews & raisins', '0.5', 'cup', 'Rich texture', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_101_ing_6', 'recipe_101', 'Garam masala, dry mango powder (amchur), coriander seeds', '2', 'tbsp', 'Spiced filling', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_101_step_1', 'recipe_101', 1, 'Rub ghee into flour and ajwain until breadcrumb texture forms, then knead with minimal cold water into a very stiff, hard dough; rest 30 minutes.', 1800, 'Stiff dough prevents air bubbles on the samosa crust during frying.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_101_step_2', 'recipe_101', 2, 'Saute crushed spices, green peas, cashews, and chunky potatoes with amchur until fragrant; cool completely.', 480, 'Never fill hot stuffing into raw pastry.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_101_step_3', 'recipe_101', 3, 'Roll oval sheets, cut into halves, form cones, stuff generously, seal base with water, and slow-fry in warm oil on low-medium flame for 20 minutes until crisp.', 1200, 'Slow frying creates signature blister-free bakery crunch.');

DELETE FROM `recipes` WHERE `id` = 'recipe_102';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_102', 'Delhi Street Pani Puri', 'Crispy hollow semolina puris stuffed with spiced boiled potatoes, black chickpeas, sweet tamarind chutney, and dunked into ice-cold spicy mint-coriander water.', 'Chef Sunita Sharma', 'Indian Street Food', 'assets/images/recipes/pani_puri.jpg', 20, 10, 4, 'Medium', 'cat_snacks', 'Snacks,Pani Puri,Golgappa,Chaat,Street Food,Spicy,Vegetarian', 1, 0, 1, 4.9, 'Delhi', 'Chaat', '180 kcal | 3g Protein | 36g Carbs | 3g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_102_ing_1', 'recipe_102', 'Crisp hollow puris', '30', 'pieces', 'Store-bought or freshly fried', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_102_ing_2', 'recipe_102', 'Fresh mint and coriander leaves', '2', 'cups', 'For spicy teekha pani', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_102_ing_3', 'recipe_102', 'Green chilies, ginger, and lemon juice', '2', 'tbsp', 'Zesty kick', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_102_ing_4', 'recipe_102', 'Pani puri masala & black salt (kala namak)', '2', 'tbsp', 'Authentic seasoning', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_102_ing_5', 'recipe_102', 'Boiled potatoes and boiled black chickpeas (kala chana)', '1.5', 'cups', 'Mashed filling', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_102_ing_6', 'recipe_102', 'Sweet jaggery-tamarind saunth chutney', '0.5', 'cup', 'Sweet balance', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_102_step_1', 'recipe_102', 1, 'Blend fresh mint, coriander, green chilies, and ginger into a fine paste; strain into chilled water, stir in black salt, cumin, and lemon juice.', 300, 'Serve pani ice-cold for refreshing crispness.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_102_step_2', 'recipe_102', 2, 'Mash boiled potatoes with boiled black chickpeas, roasted cumin, chili powder, and salt.', 180, 'Classic street-style filling.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_102_step_3', 'recipe_102', 3, 'Crack the top of a puri with your thumb, stuff a spoonful of potato filling, a dab of sweet chutney, fill to the brim with chilled spicy pani, and eat in one bite.', 60, 'Enjoy immediately before puri gets soggy.');

DELETE FROM `recipes` WHERE `id` = 'recipe_103';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_103', 'Mumbai Chowpatty Bhel Puri', 'Famous beachside snack made of crisp puffed rice, sev, crunchy papdi, onions, and boiled potatoes tossed with tangy tamarind and spicy green chutneys.', 'Chef Sunita Sharma', 'Mumbai Street Food', 'assets/images/recipes/bhel_puri.jpg', 10, 0, 4, 'Easy', 'cat_snacks', 'Snacks,Bhel Puri,Mumbai,Chaat,Crispy,Tangy,Vegetarian', 0, 0, 1, 4.8, 'Maharashtra', 'Chaat', '160 kcal | 4g Protein | 28g Carbs | 4g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_103_ing_1', 'recipe_103', 'Crisp puffed rice (kurmura/murmura)', '3', 'cups', 'Lightly dry-roasted for crunch', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_103_ing_2', 'recipe_103', 'Fine gram flour vermicelli (nylon sev)', '1', 'cup', 'Crispy yellow sev', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_103_ing_3', 'recipe_103', 'Crushed flour papdis', '10', 'pieces', 'Crunchy wafers', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_103_ing_4', 'recipe_103', 'Finely chopped onions, tomatoes, boiled potatoes', '1.5', 'cups', 'Fresh toppings', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_103_ing_5', 'recipe_103', 'Spicy green coriander chutney & sweet tamarind date chutney', '4', 'tbsp', 'Chaat dressings', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_103_ing_6', 'recipe_103', 'Chaat masala, lemon juice & roasted peanuts', '2', 'tbsp', 'Zesty flavor', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_103_step_1', 'recipe_103', 1, 'Warm puffed rice in a dry pan for 2 minutes to ensure maximum crispness.', 120, 'Crisp base prevents sogginess.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_103_step_2', 'recipe_103', 2, 'In a large mixing bowl, combine puffed rice, crushed papdis, boiled potatoes, chopped onions, and tomatoes.', 120, 'Work quickly so bhel remains crunchy.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_103_step_3', 'recipe_103', 3, 'Drizzle sweet tamarind chutney, spicy green chutney, chaat masala, and lemon juice; toss vigorously, top with heaps of nylon sev, and serve immediately in paper cones.', 60, 'Must be consumed within minutes of mixing.');

DELETE FROM `recipes` WHERE `id` = 'recipe_104';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_104', 'Street Style Sev Puri', 'Crisp bite-sized flat puris layered with diced potatoes, onions, trio of spicy-sweet-tangy chutneys, smothered under a blanket of golden nylon sev.', 'Chef Sunita Sharma', 'Mumbai Street Food', 'assets/images/recipes/sev_puri.jpg', 15, 0, 4, 'Easy', 'cat_snacks', 'Snacks,Sev Puri,Chaat,Mumbai,Street Food,Vegetarian', 0, 0, 1, 4.8, 'Maharashtra', 'Chaat', '210 kcal | 4g Protein | 32g Carbs | 8g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_104_ing_1', 'recipe_104', 'Crispy flat flour puris (papdi)', '24', 'pieces', 'Bite sized', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_104_ing_2', 'recipe_104', 'Boiled potatoes, finely mashed & seasoned', '2', 'medium', 'Flavored with salt and cumin', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_104_ing_3', 'recipe_104', 'Finely chopped onions and raw mango (kairi)', '1', 'cup', 'Tangy crunch', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_104_ing_4', 'recipe_104', 'Spicy green chutney, red garlic chutney & sweet tamarind chutney', '3', 'tbsp each', 'Trio of chutneys', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_104_ing_5', 'recipe_104', 'Fine nylon sev', '1.5', 'cups', 'Abundant topping', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_104_ing_6', 'recipe_104', 'Chaat masala, roasted cumin & chopped cilantro', '2', 'tbsp', 'Garnish', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_104_step_1', 'recipe_104', 1, 'Arrange flat crisp puris neatly side-by-side on a large platter.', 60, 'Traditional street plating is in rows.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_104_step_2', 'recipe_104', 2, 'Top each puri with a spoonful of seasoned mashed potatoes, chopped onions, and a touch of tangy raw mango.', 120, 'Raw mango gives authentic Mumbai punch.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_104_step_3', 'recipe_104', 3, 'Drizzle red garlic chutney, spicy green chutney, and sweet tamarind chutney; bury completely under mounds of crispy nylon sev and cilantro.', 90, 'Serve immediately.');

DELETE FROM `recipes` WHERE `id` = 'recipe_105';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_105', 'Butter Pav Bhaji', 'Iconic Mumbai street delicacy of spiced mashed mixed vegetables slow-cooked in dollops of butter on a large tawa, served with toasted buttery pav buns.', 'Chef Sunita Sharma', 'Mumbai Street Food', 'assets/images/recipes/pav_bhaji.jpg', 20, 25, 4, 'Medium', 'cat_snacks', 'Snacks,Pav Bhaji,Mumbai,Street Food,Butter,Vegetarian', 1, 0, 1, 4.9, 'Maharashtra', 'Street Food', '380 kcal | 8g Protein | 54g Carbs | 16g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_105_ing_1', 'recipe_105', 'Boiled mixed vegetables (potatoes, cauliflower, green peas, carrot)', '3', 'cups', 'Steamed soft', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_105_ing_2', 'recipe_105', 'Finely chopped red onions & capsicum', '1.5', 'cups', 'Sauteed', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_105_ing_3', 'recipe_105', 'Ripe red tomatoes, finely chopped', '2', 'cups', 'Rich tomato gravy', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_105_ing_4', 'recipe_105', 'Authentic Pav Bhaji masala powder', '2.5', 'tbsp', 'Signature blend', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_105_ing_5', 'recipe_105', 'Pure salted butter (Amul butter)', '100', 'g', 'Generous quantities', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_105_ing_6', 'recipe_105', 'Fresh soft ladi pav buns', '8', 'pieces', 'Slit and butter toasted', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_105_step_1', 'recipe_105', 1, 'Melt butter on a wide tawa, saute onions and capsicum, add tomatoes and cook until soft and pulpy.', 300, 'Capsicum gives the authentic street aroma.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_105_step_2', 'recipe_105', 2, 'Add boiled vegetables, pav bhaji masala, red chili paste, and water; mash vigorously with a potato masher directly on the tawa until smooth and velvety.', 600, 'Continuous tawa mashing creates the perfect texture.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_105_step_3', 'recipe_105', 3, 'Slit pav buns, toast on the buttered tawa until golden and soft, and serve alongside piping hot bhaji garnished with a melting slab of butter, chopped onion, and lime wedges.', 300, 'The definitive Mumbai street feast.');

DELETE FROM `recipes` WHERE `id` = 'recipe_106';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_106', 'Crispy Onion Kanda Bhaji', 'Crunchy Mumbai-style thinly sliced onion fritters coated in seasoned besan and carom seeds, deep-fried until delightfully golden and crispy.', 'Chef Sunita Sharma', 'Maharashtrian', 'assets/images/recipes/onion_pakora.jpg', 15, 15, 4, 'Easy', 'cat_snacks', 'Snacks,Pakora,Onion Pakora,Kanda Bhaji,Monsoon,Vegetarian', 1, 0, 1, 4.8, 'Maharashtra', 'Fritters', '220 kcal | 5g Protein | 26g Carbs | 11g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_106_ing_1', 'recipe_106', 'Onions, thinly sliced lengthwise', '4', 'large', 'Separated into strands', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_106_ing_2', 'recipe_106', 'Gram flour (besan)', '1', 'cup', 'Sifted', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_106_ing_3', 'recipe_106', 'Rice flour', '2', 'tbsp', 'Secret to extra crunch', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_106_ing_4', 'recipe_106', 'Ajwain (carom seeds) & cumin seeds', '1', 'tsp', 'Aromatic digestive', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_106_ing_5', 'recipe_106', 'Finely chopped green chilies and coriander', '3', 'tbsp', 'Fresh herbs', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_106_ing_6', 'recipe_106', 'Oil for deep frying', '500', 'ml', 'Medium high heat', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_106_step_1', 'recipe_106', 1, 'Toss sliced onions with salt, chilies, ajwain, and turmeric; squeeze firmly with hands and rest for 10 minutes until onions sweat natural water.', 600, 'Do NOT add external water; onions release enough moisture for batter.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_106_step_2', 'recipe_106', 2, 'Sprinkle besan and rice flour over the sweaty onions, mixing gently until a dry, lacy batter coats the onion ribbons.', 180, 'Lacy coating ensures maximum crispy edges.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_106_step_3', 'recipe_106', 3, 'Drop loose clusters into hot oil, fry on medium flame for 5-6 minutes until deep golden brown and crispy; drain and serve hot with fried green chilies.', 360, 'Irresistible on a rainy evening.');

DELETE FROM `recipes` WHERE `id` = 'recipe_107';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_107', 'Fiery Andhra Mirchi Bajji', 'Stout green bhavnagri chili peppers stuffed with tangy ajwain-tamarind paste, dipped in spiced gram flour batter, and fried until crispy.', 'Chef Ramesh Rao', 'South Indian', 'assets/images/recipes/mirchi_bajji.jpg', 15, 15, 4, 'Easy', 'cat_snacks', 'Snacks,Mirchi Bajji,Andhra,Street Food,Crispy,Vegetarian', 0, 0, 1, 4.7, 'Andhra Pradesh', 'Fritters', '190 kcal | 4g Protein | 22g Carbs | 10g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_107_ing_1', 'recipe_107', 'Large mild green bajji chilies (Bhavnagri)', '8', 'pieces', 'Slit and deseeded', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_107_ing_2', 'recipe_107', 'Gram flour (besan)', '1.5', 'cups', 'Smooth batter base', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_107_ing_3', 'recipe_107', 'Rice flour', '2', 'tbsp', 'Crispiness', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_107_ing_4', 'recipe_107', 'Ajwain, cumin powder & tamarind pulp', '2', 'tbsp', 'Tangy stuffing for chilies', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_107_ing_5', 'recipe_107', 'Baking soda and turmeric', '0.25', 'tsp', 'For puffed light coating', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_107_ing_6', 'recipe_107', 'Finely chopped onions and lemon juice', '0.5', 'cup', 'To stuff into cut bajjis', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_107_step_1', 'recipe_107', 1, 'Slit chilies lengthwise, remove seeds, and stuff inner cavity with a pinch of ajwain, tamarind pulp, and salt.', 300, 'Tamarind stuffing cuts the sharp chili heat.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_107_step_2', 'recipe_107', 2, 'Whisk besan, rice flour, turmeric, salt, baking soda, and water into a thick lump-free batter.', 180, 'Batter should coat the back of a spoon evenly.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_107_step_3', 'recipe_107', 3, 'Dip stuffed chilies completely into batter, slip into medium-hot oil, fry until golden brown, slice open, fill with chopped raw onions and lemon, and serve.', 360, 'A fiery South Indian street favorite.');

DELETE FROM `recipes` WHERE `id` = 'recipe_108';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_108', 'Mysore Aloo Bonda', 'Golden crispy spiced potato dumplings coated in airy chickpea flour batter, served with spicy green coconut chutney.', 'Chef Shwetha Hegde', 'South Indian', 'assets/images/recipes/aloo_bonda.jpg', 20, 15, 4, 'Easy', 'cat_snacks', 'Snacks,Aloo Bonda,Batata Vada,Karnataka,Crispy,Vegetarian', 0, 0, 1, 4.8, 'Karnataka', 'Bonda', '210 kcal | 4g Protein | 28g Carbs | 9g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_108_ing_1', 'recipe_108', 'Boiled potatoes, peeled & mashed', '4', 'medium', 'Roughly mashed', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_108_ing_2', 'recipe_108', 'Mustard seeds, urad dal & curry leaves', '1.5', 'tsp', 'Potato tempering', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_108_ing_3', 'recipe_108', 'Finely chopped onion, ginger & green chilies', '0.75', 'cup', 'Sauteed aromatics', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_108_ing_4', 'recipe_108', 'Gram flour (besan)', '1.5', 'cups', 'For outer batter', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_108_ing_5', 'recipe_108', 'Rice flour and pinch of hing (asafoetida)', '2', 'tbsp', 'Crispy coating', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_108_ing_6', 'recipe_108', 'Oil for deep frying', '500', 'ml', 'Medium heat', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_108_step_1', 'recipe_108', 1, 'Temper mustard, dal, curry leaves, onions, ginger, and chilies in oil; mix with mashed potatoes, turmeric, and coriander, then shape into round balls.', 420, 'Ensure potato balls are firm and cool.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_108_step_2', 'recipe_108', 2, 'Whisk besan, rice flour, hing, salt, and water into a thick, smooth coating batter.', 180, 'Thick batter clings to potato balls without dripping.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_108_step_3', 'recipe_108', 3, 'Dip each potato ball into batter to coat completely, drop gently into hot oil, and deep-fry until golden yellow and crisp.', 360, 'Serve hot with coconut chutney.');

DELETE FROM `recipes` WHERE `id` = 'recipe_109';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_109', 'Crispy Golden French Fries', 'Hand-cut Idaho Russet potatoes double-fried to crunchy exterior and fluffy interior perfection, seasoned with sea salt and peri-peri.', 'Chef Sanjeev Kumar', 'Continental', 'assets/images/recipes/french_fries.jpg', 20, 15, 4, 'Easy', 'cat_snacks', 'Snacks,French Fries,Crispy,Potato,Continental,Vegetarian', 0, 0, 1, 4.8, 'Continental', 'Fries', '220 kcal | 3g Protein | 32g Carbs | 10g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_109_ing_1', 'recipe_109', 'Starchy Russet or Yukon Gold potatoes', '4', 'large', 'Peeled and cut into 1/4-inch batons', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_109_ing_2', 'recipe_109', 'Ice water', '4', 'cups', 'For soaking excess starch', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_109_ing_3', 'recipe_109', 'Cornstarch', '1', 'tbsp', 'Optional dusting for extra shatter-crunch', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_109_ing_4', 'recipe_109', 'Fine sea salt', '1', 'tsp', 'Flaky salt to taste', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_109_ing_5', 'recipe_109', 'Peri-peri or Cajun spice blend', '1', 'tsp', 'Zesty dusting', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_109_ing_6', 'recipe_109', 'Peanut or canola oil for deep frying', '600', 'ml', 'High smoke point', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_109_step_1', 'recipe_109', 1, 'Cut potatoes into even batons, soak in ice water for 30 minutes to wash away surface starch, and pat completely dry with kitchen towels.', 1800, 'Drying thoroughly prevents oil splatters and ensures crispiness.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_109_step_2', 'recipe_109', 2, 'First fry: Blanch in 160°C (325°F) oil for 5 minutes until tender but not browned; remove and cool on wire rack for 15 minutes.', 300, 'First fry cooks the inside fluffy.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_109_step_3', 'recipe_109', 3, 'Second fry: Flash-fry in hot 190°C (375°F) oil for 3-4 minutes until deeply golden brown and crunchy; drain, toss immediately with salt and peri-peri spice.', 240, 'Double-frying achieves restaurant-quality crunch.');

DELETE FROM `recipes` WHERE `id` = 'recipe_110';
INSERT INTO `recipes` (`id`, `title`, `description`, `chef_name`, `cuisine`, `image_url`, `prep_time_minutes`, `cook_time_minutes`, `servings`, `difficulty`, `category_id`, `tags`, `is_favorite`, `is_custom`, `is_vegetarian`, `rating`, `region`, `subcategory`, `nutrition`) VALUES ('recipe_110', 'Buttery Masala Corn Chaat', 'Steamed tender juicy sweet corn kernels tossed with melted butter, tangy chaat masala, Kashmiri red chili powder, and fresh lime juice.', 'Chef Sunita Sharma', 'Indian Street Food', 'assets/images/recipes/masala_corn.jpg', 5, 10, 2, 'Easy', 'cat_snacks', 'Snacks,Corn Chaat,Masala Corn,Sweet Corn,Quick,Butter,Vegetarian', 0, 0, 1, 4.7, 'All India', 'Street Food', '150 kcal | 4g Protein | 24g Carbs | 5g Fat');
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_110_ing_1', 'recipe_110', 'Sweet corn kernels (fresh or frozen)', '2.5', 'cups', 'Steamed juicy and tender', 1);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_110_ing_2', 'recipe_110', 'Pure salted butter (Amul)', '2', 'tbsp', 'Melted hot', 2);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_110_ing_3', 'recipe_110', 'Chaat masala', '1.5', 'tsp', 'Signature tang', 3);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_110_ing_4', 'recipe_110', 'Kashmiri red chili powder & black pepper', '0.75', 'tsp', 'Mild heat', 4);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_110_ing_5', 'recipe_110', 'Fresh lime juice', '1.5', 'tbsp', 'Citrus zing', 5);
INSERT INTO `recipe_ingredients` (`id`, `recipe_id`, `name`, `amount`, `unit`, `notes`, `sort_order`) VALUES ('recipe_110_ing_6', 'recipe_110', 'Finely chopped fresh cilantro', '2', 'tbsp', 'Fresh garnish', 6);
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_110_step_1', 'recipe_110', 1, 'Steam sweet corn kernels in a steamer or boil in salted water for 5 minutes until plump and tender; drain well.', 300, 'Serve corn piping hot so the butter melts completely.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_110_step_2', 'recipe_110', 2, 'Transfer steaming hot corn to a mixing bowl, immediately add butter, chaat masala, Kashmiri chili powder, and black pepper.', 60, 'Hot corn absorbs the spices and butter deeply.');
INSERT INTO `recipe_instructions` (`id`, `recipe_id`, `step_number`, `instruction`, `timer_seconds`, `tip`) VALUES ('recipe_110_step_3', 'recipe_110', 3, 'Squeeze fresh lime juice, toss vigorously to coat every kernel, garnish with cilantro, and serve in paper cups.', 60, 'The quintessential mall and cinema hall treat.');

