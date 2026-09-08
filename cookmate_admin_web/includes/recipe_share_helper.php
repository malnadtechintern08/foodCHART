<?php
/**
 * Food CHART Web Admin - WhatsApp Recipe Share Helper
 * 
 * Generates promotional teaser messages with recipe name, category,
 * prep time, servings, limited-access previews, and app download links.
 */

if (!function_exists('ensure_custom_share_text_column')) {
    /**
     * Safely ensures the custom_share_text column exists in the recipes table.
     */
    function ensure_custom_share_text_column(PDO $pdo): void {
        static $checked = false;
        if ($checked) return;
        try {
            $cols = $pdo->query("SHOW COLUMNS FROM recipes LIKE 'custom_share_text'")->fetchAll();
            if (empty($cols)) {
                $pdo->exec("ALTER TABLE recipes ADD COLUMN custom_share_text TEXT DEFAULT NULL AFTER nutrition");
            }
            $checked = true;
        } catch (Throwable $e) {
            // Silently fallback if table alteration is restricted
        }
    }
}

if (!function_exists('build_recipe_whatsapp_share_text')) {
    /**
     * Build WhatsApp promotional text for a recipe.
     * 
     * Format:
     * 1. Recipe Name & Description
     * 2. Category & Diet
     * 3. Prep & Cook Times
     * 4. Servings & Rating
     * 5. Key Ingredients Preview & Method Preview (Locked)
     * 6. Download Link of the CookMate App
     *
     * @param array $recipe
     * @param array $ingredients
     * @param array $instructions
     * @param string $mode 'teaser' | 'compact' | 'full'
     * @return string
     */
    function build_recipe_whatsapp_share_text(array $recipe, array $ingredients = [], array $instructions = [], string $mode = 'teaser'): string {
        $title = trim($recipe['title'] ?? 'Delicious Recipe');
        $desc = trim($recipe['description'] ?? '');
        $cat = trim($recipe['category_name'] ?? $recipe['category_id'] ?? 'Malnad Special');
        $isVeg = !empty($recipe['is_vegetarian']);
        $prep = (int)($recipe['prep_time_minutes'] ?? 15);
        $cook = (int)($recipe['cook_time_minutes'] ?? 20);
        $servings = (int)($recipe['servings'] ?? 4);
        $rating = number_format((float)($recipe['rating'] ?? 4.8), 1);
        $playStoreUrl = "https://play.google.com/store/apps/details?id=com.food.chart";

        $lines = [];

        // 1. Recipe Name
        $lines[] = "🍛 *" . $title . "*";
        if (!empty($desc)) {
            $lines[] = $desc;
        }
        $lines[] = "";

        // 2. Category & Diet
        $dietBadge = $isVeg ? "Pure Veg 🌱" : "Non-Veg 🍗";
        $lines[] = "🏷 *Category:* {$cat} • {$dietBadge}";

        // 3. Prep & Cook Time
        $lines[] = "⏱ *Prep:* {$prep} mins | *Cook:* {$cook} mins";

        // 4. Servings & Rating
        $lines[] = "👥 *Servings:* {$servings} | ⭐ *Rating:* {$rating}/5.0";
        $lines[] = "";

        // Mode: Compact (Name, Category, Prep, Servings, Download link)
        if ($mode === 'compact') {
            $lines[] = "━━━━━━━━━━━━━━━━━━━━━━";
            $lines[] = "📲 *Get full recipe, ingredients & step-by-step cooking timers:*";
            $lines[] = "👉 Download *Food CHART* (100% Free & Offline):";
            $lines[] = $playStoreUrl;
            $lines[] = "━━━━━━━━━━━━━━━━━━━━━━";
            return implode("\n", $lines);
        }

        // Mode: Full Recipe (Un-locked)
        if ($mode === 'full') {
            if (!empty($ingredients)) {
                $lines[] = "🛒 *INGREDIENTS (" . count($ingredients) . "):*";
                foreach ($ingredients as $ing) {
                    $amt = (!empty($ing['amount']) ? rtrim(rtrim(number_format((float)$ing['amount'], 2), '0'), '.') : '');
                    $unit = (!empty($ing['unit']) ? ' ' . trim($ing['unit']) : '');
                    $notes = (!empty($ing['notes']) ? ' (' . trim($ing['notes']) . ')' : '');
                    $lines[] = "• {$amt}{$unit} " . trim($ing['name']) . $notes;
                }
                $lines[] = "";
            }

            if (!empty($instructions)) {
                $lines[] = "👩‍🍳 *METHOD & INSTRUCTIONS:*";
                foreach ($instructions as $ins) {
                    $stepNum = $ins['step_number'] ?? 1;
                    $stepText = trim($ins['instruction'] ?? '');
                    $timer = !empty($ins['timer_seconds']) && $ins['timer_seconds'] > 0 ? " [⏱ " . round($ins['timer_seconds'] / 60, 1) . "m]" : "";
                    $tip = !empty($ins['tip']) ? " (Tip: " . trim($ins['tip']) . ")" : "";
                    $lines[] = "{$stepNum}. {$stepText}{$timer}{$tip}";
                }
                $lines[] = "";
            }

            $lines[] = "━━━━━━━━━━━━━━━━━━━━━━";
            $lines[] = "📲 Shared from *Food CHART* App (100% Free & Offline):";
            $lines[] = "👉 Download: " . $playStoreUrl;
            $lines[] = "━━━━━━━━━━━━━━━━━━━━━━";
            return implode("\n", $lines);
        }

        // Default Mode: Teaser (Limited preview with locked elements)
        if (!empty($ingredients)) {
            $lines[] = "🛒 *KEY INGREDIENTS PREVIEW:*";
            $previewCount = count($ingredients) > 2 ? 2 : count($ingredients);
            for ($i = 0; $i < $previewCount; $i++) {
                $ing = $ingredients[$i];
                $amt = (!empty($ing['amount']) ? rtrim(rtrim(number_format((float)$ing['amount'], 2), '0'), '.') : '');
                $unit = (!empty($ing['unit']) ? ' ' . trim($ing['unit']) : '');
                $lines[] = "• {$amt}{$unit} " . trim($ing['name']);
            }
            $hiddenCount = count($ingredients) - $previewCount;
            if ($hiddenCount > 0) {
                $lines[] = "🔒 _+ {$hiddenCount} more ingredients hidden in Food CHART_";
            }
            $lines[] = "";
        }

        if (!empty($instructions)) {
            $lines[] = "👩‍🍳 *METHOD PREVIEW:*";
            $firstStep = $instructions[0];
            $stepText = trim($firstStep['instruction'] ?? '');
            if (mb_strlen($stepText) > 90) {
                $stepText = mb_substr($stepText, 0, 87) . "...";
            }
            $lines[] = "1. " . $stepText;
            if (count($instructions) > 1) {
                $lines[] = "🔒 _Steps 2 to " . count($instructions) . " are locked in the app_";
            }
            $lines[] = "";
        }

        // App Download Link / Universal Custom CTA
        $universalCta = get_universal_whatsapp_cta();
        if (!empty($universalCta)) {
            $lines[] = $universalCta;
        } else {
            $lines[] = "━━━━━━━━━━━━━━━━━━━━━━";
            $lines[] = "📲 *Unlock Full Recipe, Ingredients & Cooking Timers:*";
            $lines[] = "👉 Download *Food CHART* (100% Free & Offline):";
            $lines[] = $playStoreUrl;
            $lines[] = "━━━━━━━━━━━━━━━━━━━━━━";
        }

        return implode("\n", $lines);
    }
}

if (!function_exists('get_universal_whatsapp_cta')) {
    /**
     * Retrieves the custom universal CTA / marketing text if configured.
     */
    function get_universal_whatsapp_cta(): ?string {
        $file = __DIR__ . '/../config/universal_wa_template.json';
        if (file_exists($file)) {
            $json = @json_decode(file_get_contents($file), true);
            if (!empty($json['custom_cta'])) {
                return trim($json['custom_cta']);
            }
        }
        return null;
    }
}

if (!function_exists('has_universal_whatsapp_template')) {
    /**
     * Checks if a universal WhatsApp template has been applied.
     */
    function has_universal_whatsapp_template(): bool {
        $file = __DIR__ . '/../config/universal_wa_template.json';
        return file_exists($file);
    }
}

if (!function_exists('apply_universal_whatsapp_template_to_all')) {
    /**
     * 1-Click Universal Apply: Saves universal template and updates ALL recipes in database.
     */
    function apply_universal_whatsapp_template_to_all(PDO $pdo, string $sampleText, ?string $currentRecipeId = null): array {
        ensure_custom_share_text_column($pdo);

        // 1. Extract custom CTA block if present (e.g. from divider or download line onwards)
        $ctaPart = "";
        if (preg_match('/(━+.*)/su', $sampleText, $matches)) {
            $ctaPart = trim($matches[1]);
        } elseif (preg_match('/((?:📲|👉|Download|Unlock|http|www\.).*)/su', $sampleText, $matches)) {
            $ctaPart = trim($matches[1]);
        }

        // Ensure config directory exists
        $configDir = __DIR__ . '/../config';
        if (!is_dir($configDir)) {
            @mkdir($configDir, 0755, true);
        }

        // Save persistent universal template configuration
        $templateConfigFile = $configDir . '/universal_wa_template.json';
        $configData = [
            'updated_at' => date('Y-m-d H:i:s'),
            'sample_template' => $sampleText,
            'custom_cta' => $ctaPart
        ];
        @file_put_contents($templateConfigFile, json_encode($configData, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

        // 2. Fetch all recipes
        $allRecipes = $pdo->query("
            SELECT r.*, c.name AS category_name 
            FROM recipes r 
            LEFT JOIN categories c ON r.category_id = c.id
        ")->fetchAll();

        $recipeIds = array_column($allRecipes, 'id');
        $recipeIngredientsMap = [];
        $recipeInstructionsMap = [];

        if (!empty($recipeIds)) {
            $inPlaceholders = implode(',', array_fill(0, count($recipeIds), '?'));
            $bIngStmt = $pdo->prepare("SELECT * FROM recipe_ingredients WHERE recipe_id IN ($inPlaceholders) ORDER BY sort_order ASC, id ASC");
            $bIngStmt->execute($recipeIds);
            while ($row = $bIngStmt->fetch()) {
                $recipeIngredientsMap[$row['recipe_id']][] = $row;
            }

            $bInsStmt = $pdo->prepare("SELECT * FROM recipe_instructions WHERE recipe_id IN ($inPlaceholders) ORDER BY step_number ASC");
            $bInsStmt->execute($recipeIds);
            while ($row = $bInsStmt->fetch()) {
                $recipeInstructionsMap[$row['recipe_id']][] = $row;
            }
        }

        // 3. Batch-update all recipes in database in one transaction
        $pdo->beginTransaction();
        $updateStmt = $pdo->prepare("UPDATE recipes SET custom_share_text = ? WHERE id = ?");
        $count = 0;

        foreach ($allRecipes as $r) {
            if ($currentRecipeId && $r['id'] === $currentRecipeId) {
                $updateStmt->execute([$sampleText, $r['id']]);
            } else {
                $rIngs = $recipeIngredientsMap[$r['id']] ?? [];
                $rIns = $recipeInstructionsMap[$r['id']] ?? [];
                $generatedText = build_recipe_whatsapp_share_text($r, $rIngs, $rIns, 'teaser');
                $updateStmt->execute([$generatedText, $r['id']]);
            }
            $count++;
        }

        $pdo->commit();

        return [
            'success' => true,
            'total_updated' => $count,
            'message' => "Universal WhatsApp template applied to all {$count} recipes in 1 click!"
        ];
    }
}
