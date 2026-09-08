<?php
/**
 * Food CHART - Hashtag Helper Functions
 * Reusable normalization, validation, and relational synchronization.
 */

if (!defined('COOKMATE_TAG_FUNCTIONS')) {
    define('COOKMATE_TAG_FUNCTIONS', true);

    /**
     * Normalizes any input hashtag into a clean database-friendly tag.
     * 
     * Examples:
     *   "#Rice"         -> "rice"
     *   "  #RICE  "     -> "rice"
     *   "#SouthIndian"  -> "southindian"
     *   "#south_indian" -> "south_indian"
     *   "South Indian"  -> "south_indian"
     *   "###spicy###"   -> "spicy"
     * 
     * @param string $rawTag
     * @return string Normalized tag or empty string if invalid
     */
    function normalize_tag($rawTag) {
        if (!is_string($rawTag)) {
            return '';
        }

        // 1. Trim whitespace
        $tag = trim($rawTag);

        // 2. Remove leading/trailing '#' characters
        $tag = ltrim($tag, '#');
        $tag = rtrim($tag, '#');
        $tag = trim($tag);

        // 3. Lowercase
        $tag = mb_strtolower($tag, 'UTF-8');

        // 4. Replace whitespace or hyphens with single underscores
        $tag = preg_replace('/[\s\-]+/', '_', $tag);

        // 5. Keep only lowercase letters, numbers, and underscores
        $tag = preg_replace('/[^a-z0-9_]/', '', $tag);

        // 6. Collapse multiple underscores
        $tag = preg_replace('/_+/', '_', $tag);
        $tag = trim($tag, '_');

        // 7. Limit length (max 50 chars)
        if (strlen($tag) > 50) {
            $tag = substr($tag, 0, 50);
            $tag = rtrim($tag, '_');
        }

        return $tag;
    }

    /**
     * Splits a comma or space-separated list of raw tags and returns an array of unique normalized tags.
     *
     * @param string|array $input
     * @return array
     */
    function parse_and_normalize_tags($input) {
        if (is_array($input)) {
            $rawList = $input;
        } else {
            // Split by comma or hashtag delimiter
            $cleanInput = str_replace('#', ' #', (string)$input);
            $rawList = preg_split('/[,]+/', $cleanInput);
        }

        $result = [];
        foreach ($rawList as $item) {
            // If item has space-separated tags (e.g. "#rice #veg")
            $subItems = preg_split('/\s+/', trim((string)$item));
            foreach ($subItems as $sub) {
                $norm = normalize_tag($sub);
                if ($norm !== '' && !in_array($norm, $result, true)) {
                    $result[] = $norm;
                }
            }
        }
        return $result;
    }

    /**
     * Atomically synchronizes a recipe's tags in the database.
     * 
     * @param PDO $pdo
     * @param string $recipeId
     * @param array|string $tags Array of tags or comma-separated string
     * @return array The final list of normalized tags associated with the recipe
     */
    function sync_recipe_tags(PDO $pdo, $recipeId, $tags) {
        $normalizedTags = parse_and_normalize_tags($tags);

        // 1. Ensure tags exist in `tags` table and retrieve their IDs
        $tagIds = [];
        $insertTagStmt = $pdo->prepare("INSERT INTO tags (name, slug) VALUES (?, ?) ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id)");
        $selectTagStmt = $pdo->prepare("SELECT id FROM tags WHERE name = ? LIMIT 1");

        foreach ($normalizedTags as $tagName) {
            $slug = $tagName;
            $insertTagStmt->execute([$tagName, $slug]);
            $tagId = $pdo->lastInsertId();
            if (!$tagId) {
                $selectTagStmt->execute([$tagName]);
                $tagId = $selectTagStmt->fetchColumn();
            }
            if ($tagId) {
                $tagIds[] = (int)$tagId;
            }
        }

        // 2. Fetch existing tag associations for this recipe
        $currentStmt = $pdo->prepare("SELECT tag_id FROM recipe_tags WHERE recipe_id = ?");
        $currentStmt->execute([$recipeId]);
        $existingTagIds = $currentStmt->fetchAll(PDO::FETCH_COLUMN);
        $existingTagIds = array_map('intval', $existingTagIds);

        // 3. Determine additions and deletions
        $toAdd = array_diff($tagIds, $existingTagIds);
        $toRemove = array_diff($existingTagIds, $tagIds);

        // Insert new relations
        if (!empty($toAdd)) {
            $linkStmt = $pdo->prepare("INSERT IGNORE INTO recipe_tags (recipe_id, tag_id) VALUES (?, ?)");
            foreach ($toAdd as $addId) {
                $linkStmt->execute([$recipeId, $addId]);
            }
        }

        // Delete removed relations
        if (!empty($toRemove)) {
            $unlinkStmt = $pdo->prepare("DELETE FROM recipe_tags WHERE recipe_id = ? AND tag_id = ?");
            foreach ($toRemove as $remId) {
                $unlinkStmt->execute([$recipeId, $remId]);
            }
        }

        // 4. Update usage_count for affected tags
        $affectedTagIds = array_unique(array_merge($toAdd, $toRemove));
        if (!empty($affectedTagIds)) {
            $updateUsageStmt = $pdo->prepare("
                UPDATE tags 
                SET usage_count = (SELECT COUNT(*) FROM recipe_tags WHERE tag_id = ?) 
                WHERE id = ?
            ");
            foreach ($affectedTagIds as $affId) {
                $updateUsageStmt->execute([$affId, $affId]);
            }
        }

        // 5. Update cached tags column in recipes table
        $cachedTagsStr = implode(', ', $normalizedTags);
        $updateRecipeStmt = $pdo->prepare("UPDATE recipes SET tags = ? WHERE id = ?");
        $updateRecipeStmt->execute([$cachedTagsStr, $recipeId]);

        return $normalizedTags;
    }

    /**
     * Gets all tags for a recipe as an array of tag detail objects.
     *
     * @param PDO $pdo
     * @param string $recipeId
     * @return array
     */
    function get_recipe_tags(PDO $pdo, $recipeId) {
        $stmt = $pdo->prepare("
            SELECT t.id, t.name, t.slug, t.usage_count 
            FROM tags t
            INNER JOIN recipe_tags rt ON rt.tag_id = t.id
            WHERE rt.recipe_id = ?
            ORDER BY t.usage_count DESC, t.name ASC
        ");
        $stmt->execute([$recipeId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Recalculates all tag usage counts in the system.
     *
     * @param PDO $pdo
     */
    function recalculate_all_tag_usage_counts(PDO $pdo) {
        $pdo->exec("
            UPDATE tags t
            SET t.usage_count = (
                SELECT COUNT(*) FROM recipe_tags rt WHERE rt.tag_id = t.id
            )
        ");
    }

    /**
     * Analyzes recipe title, category, and ingredients to suggest relevant hashtags for Admin review.
     *
     * @param PDO $pdo
     * @param string $title
     * @param string $category
     * @param array $ingredientNames
     * @return array List of suggested normalized tags (strings)
     */
    function auto_suggest_recipe_tags(PDO $pdo, $title, $category = '', array $ingredientNames = []) {
        $candidates = [];

        $titleLower = strtolower($title);
        $catLower = strtolower($category);

        // Core food keyword mappings
        $keywords = [
            'rice' => ['rice', 'biryani', 'pulao', 'bath', 'puliyogare', 'chitranna', 'curd_rice'],
            'chicken' => ['chicken', 'koli', 'murgh'],
            'biryani' => ['biryani'],
            'breakfast' => ['dosa', 'idli', 'upma', 'poha', 'puri', 'paratha', 'vada', 'appam'],
            'malnad' => ['malnad', 'akki_roti', 'kadabu', 'havyaka', 'thili_saaru', 'patrode', 'halasina'],
            'spicy' => ['spicy', 'masala', 'pepper', 'mirchi', 'chilli', 'sukka'],
            'healthy' => ['salad', 'soup', 'ragi', 'millet', 'diet', 'sprouts', 'healthy', 'boiled'],
            'snacks' => ['snack', 'bonda', 'bajji', 'samosa', 'pakoda', 'chips', 'crispy'],
            'sweet' => ['sweet', 'payasa', 'halwa', 'ladoo', 'kesari', 'holige', 'gulab_jamun'],
            'paneer' => ['paneer'],
            'curry' => ['curry', 'gravy', 'kurma', 'sambar', 'saaru', 'dal'],
            'veg' => ['veg', 'vegetarian', 'palya', 'gobi'],
        ];

        foreach ($keywords as $tag => $triggers) {
            foreach ($triggers as $trig) {
                if (strpos($titleLower, str_replace('_', ' ', $trig)) !== false || strpos($catLower, str_replace('_', ' ', $trig)) !== false) {
                    $candidates[] = $tag;
                    break;
                }
            }
        }

        // Ingredient inspection
        foreach ($ingredientNames as $ing) {
            $ingLower = strtolower(trim((string)$ing));
            if (empty($ingLower)) continue;

            if (strpos($ingLower, 'rice') !== false) $candidates[] = 'rice';
            if (strpos($ingLower, 'chicken') !== false) $candidates[] = 'chicken';
            if (strpos($ingLower, 'paneer') !== false) $candidates[] = 'paneer';
            if (strpos($ingLower, 'mushroom') !== false) $candidates[] = 'mushroom';
            if (strpos($ingLower, 'ragi') !== false) $candidates[] = 'ragi';
            if (strpos($ingLower, 'fish') !== false || strpos($ingLower, 'prawn') !== false) $candidates[] = 'seafood';
            if (strpos($ingLower, 'jaggery') !== false) $candidates[] = 'sweet';
        }

        // Fallbacks based on category
        if ($catLower === 'cat_breakfast' || strpos($catLower, 'breakfast') !== false) {
            $candidates[] = 'breakfast';
        }
        if ($catLower === 'cat_malnad' || strpos($catLower, 'malnad') !== false) {
            $candidates[] = 'malnad';
        }

        $result = [];
        foreach ($candidates as $cand) {
            $norm = normalize_tag($cand);
            if ($norm !== '' && !in_array($norm, $result, true)) {
                $result[] = $norm;
            }
        }

        return $result;
    }
}
