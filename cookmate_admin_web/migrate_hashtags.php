<?php
/**
 * CookMate Hashtag Database Migration & Seeder Script
 * 
 * Creates tags, recipe_tags, product_tags tables and populates
 * hashtags from existing recipe data with accurate usage counts.
 */

require_once __DIR__ . '/config/db.php';
require_once __DIR__ . '/includes/tag_functions.php';

$isCli = (php_sapi_name() === 'cli');
if (!$isCli) {
    header('Content-Type: text/html; charset=utf-8');
}

try {
    $pdo = get_db_connection();

    // 1. Create tables
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS tags (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL UNIQUE,
            slug VARCHAR(100) NOT NULL UNIQUE,
            usage_count INT NOT NULL DEFAULT 0,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_tag_name (name),
            INDEX idx_tag_slug (slug),
            INDEX idx_tag_usage (usage_count)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    $pdo->exec("
        CREATE TABLE IF NOT EXISTS recipe_tags (
            id INT AUTO_INCREMENT PRIMARY KEY,
            recipe_id VARCHAR(64) NOT NULL,
            tag_id INT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_recipe_tag (recipe_id, tag_id),
            INDEX idx_rt_recipe_id (recipe_id),
            INDEX idx_rt_tag_id (tag_id),
            CONSTRAINT fk_rt_recipe FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT fk_rt_tag FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    $pdo->exec("
        CREATE TABLE IF NOT EXISTS product_tags (
            id INT AUTO_INCREMENT PRIMARY KEY,
            product_id VARCHAR(64) NOT NULL,
            tag_id INT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY uq_product_tag (product_id, tag_id),
            INDEX idx_pt_product_id (product_id),
            INDEX idx_pt_tag_id (tag_id),
            CONSTRAINT fk_pt_tag FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ");

    // 2. Fetch all recipes
    $recipes = $pdo->query("SELECT id, title, category_id, tags, cuisine, is_vegetarian FROM recipes")->fetchAll();
    
    $tagInsertStmt = $pdo->prepare("INSERT INTO tags (name, slug) VALUES (?, ?) ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id)");
    $tagSelectStmt = $pdo->prepare("SELECT id FROM tags WHERE name = ? LIMIT 1");
    $linkStmt = $pdo->prepare("INSERT IGNORE INTO recipe_tags (recipe_id, tag_id) VALUES (?, ?)");

    $migratedCount = 0;
    $linksCount = 0;

    foreach ($recipes as $r) {
        $rawTagsList = [];
        if (!empty($r['tags'])) {
            $rawTagsList = array_merge($rawTagsList, explode(',', $r['tags']));
        }

        // Context-aware food tag enrichment for rich initial search experience:
        $titleLower = strtolower($r['title']);
        if (strpos($titleLower, 'rice') !== false || strpos($titleLower, 'biryani') !== false || strpos($titleLower, 'pulao') !== false || strpos($titleLower, 'bath') !== false) {
            $rawTagsList[] = 'rice';
        }
        if (strpos($titleLower, 'chicken') !== false) {
            $rawTagsList[] = 'chicken';
        }
        if (strpos($titleLower, 'biryani') !== false) {
            $rawTagsList[] = 'biryani';
        }
        if (strpos($titleLower, 'dosa') !== false || strpos($titleLower, 'idli') !== false || $r['category_id'] === 'cat_breakfast') {
            $rawTagsList[] = 'breakfast';
        }
        if ($r['category_id'] === 'cat_malnad' || strpos($titleLower, 'malnad') !== false || strpos($titleLower, 'akki') !== false || strpos($titleLower, 'kadabu') !== false) {
            $rawTagsList[] = 'malnad';
        }
        if (!empty($r['is_vegetarian'])) {
            $rawTagsList[] = 'veg';
        } else {
            $rawTagsList[] = 'nonveg';
        }

        $cleanTags = [];
        foreach ($rawTagsList as $rt) {
            $norm = normalize_tag($rt);
            if ($norm !== '' && !in_array($norm, $cleanTags, true)) {
                $cleanTags[] = $norm;
            }
        }

        foreach ($cleanTags as $tagName) {
            $tagSlug = $tagName;
            $tagInsertStmt->execute([$tagName, $tagSlug]);
            $tagId = $pdo->lastInsertId();
            if (!$tagId) {
                $tagSelectStmt->execute([$tagName]);
                $tagId = $tagSelectStmt->fetchColumn();
            }

            if ($tagId) {
                $linkStmt->execute([$r['id'], $tagId]);
                $linksCount++;
            }
        }

        // Update the cached comma tags on recipe row
        if (!empty($cleanTags)) {
            $updateRecipeTags = $pdo->prepare("UPDATE recipes SET tags = ? WHERE id = ?");
            $updateRecipeTags->execute([implode(', ', $cleanTags), $r['id']]);
        }

        $migratedCount++;
    }

    // 3. Recalculate usage_count for all tags
    $pdo->exec("
        UPDATE tags t
        SET t.usage_count = (
            SELECT COUNT(*) FROM recipe_tags rt WHERE rt.tag_id = t.id
        )
    ");

    // Fetch top 15 tags to verify
    $topTags = $pdo->query("SELECT name, usage_count FROM tags ORDER BY usage_count DESC LIMIT 15")->fetchAll();

    if ($isCli) {
        echo "=== FOOD CHART HASHTAG MIGRATION SUCCESS ===\n";
        echo "Processed Recipes: $migratedCount\n";
        echo "Created Links: $linksCount\n";
        echo "\nTop Popular Hashtags:\n";
        foreach ($topTags as $t) {
            echo "  #" . $t['name'] . " (" . $t['usage_count'] . " recipes)\n";
        }
    } else {
        echo "<div style='font-family:sans-serif;padding:30px;background:#111;color:#fff;'>";
        echo "<h2 style='color:#4CAF50;'>✓ Hashtag Database Migration Complete</h2>";
        echo "<p>Processed Recipes: <strong>$migratedCount</strong> | Tag Links: <strong>$linksCount</strong></p>";
        echo "<h3>Top Popular Hashtags</h3><ul>";
        foreach ($topTags as $t) {
            echo "<li><strong>#" . htmlspecialchars($t['name']) . "</strong> (" . (int)$t['usage_count'] . " recipes)</li>";
        }
        echo "</ul>";
        echo "<p><a href='" . BASE_URL . "/hashtags.php' style='color:#E50915;'>Go to Hashtag Management &rarr;</a></p>";
        echo "</div>";
    }

} catch (Throwable $e) {
    if ($isCli) {
        echo "Migration Error: " . $e->getMessage() . "\n";
    } else {
        echo "<div style='color:red;padding:20px;background:#222;'>Migration Error: " . htmlspecialchars($e->getMessage()) . "</div>";
    }
    exit(1);
}
