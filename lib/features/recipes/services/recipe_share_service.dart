import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../rating/services/rating_service.dart';
import '../domain/entities/recipe.dart';

/// Service responsible for formatting and sharing recipes to WhatsApp
/// and other external communication channels.
class RecipeShareService {
  static const String appDownloadUrl =
      'https://play.google.com/store/apps/details?id=com.food.chart';

  /// Generates a limited-access teaser representation of the recipe.
  /// Shows key dish info, previews up to 2 ingredients, and Step 1,
  /// while locking the remaining ingredients and instructions behind downloading Food CHART.
  static String formatRecipeForWhatsApp(Recipe recipe) {
    final buffer = StringBuffer();

    // Title & Header
    buffer.writeln('🍛 *${recipe.title.trim()}*');
    if (recipe.description.trim().isNotEmpty) {
      buffer.writeln(recipe.description.trim());
    }
    buffer.writeln();

    // Quick Stats & Dietary
    final vegTag = recipe.isVegetarian ? 'Pure Veg 🌱' : 'Non-Veg 🍗';
    final cuisineText = recipe.cuisine.trim().isNotEmpty ? recipe.cuisine.trim() : 'Food CHART';
    buffer.writeln('🏷 *Category:* $cuisineText • $vegTag');
    buffer.writeln('⏱ *Prep:* ${recipe.prepTimeMinutes} mins | *Cook:* ${recipe.cookTimeMinutes} mins');
    buffer.writeln('👥 *Servings:* ${recipe.servings} | ⭐ *Rating:* ${recipe.rating.toStringAsFixed(1)}/5.0');
    buffer.writeln();

    // Ingredients Preview (Limited access: preview up to 2 items, rest locked)
    if (recipe.ingredients.isNotEmpty) {
      buffer.writeln('🛒 *KEY INGREDIENTS PREVIEW:*');
      final previewCount = recipe.ingredients.length > 2 ? 2 : 1;
      for (int i = 0; i < previewCount; i++) {
        final ing = recipe.ingredients[i];
        final amt = _formatAmount(ing.amount);
        final unit = ing.unit.trim().isNotEmpty ? ' ${ing.unit.trim()}' : '';
        buffer.writeln('• $amt$unit ${ing.name.trim()}');
      }
      final hiddenCount = recipe.ingredients.length - previewCount;
      if (hiddenCount > 0) {
        buffer.writeln('🔒 _+ $hiddenCount more ingredients hidden in Food CHART_');
      }
      buffer.writeln();
    }

    // Instructions Preview (Limited access: Step 1 preview, remaining steps locked)
    if (recipe.instructions.isNotEmpty) {
      buffer.writeln('👩‍🍳 *METHOD PREVIEW:*');
      final firstStep = recipe.instructions.first;
      var stepPreview = firstStep.instruction.trim();
      if (stepPreview.length > 90) {
        stepPreview = '${stepPreview.substring(0, 87)}...';
      }
      buffer.writeln('1. $stepPreview');
      if (recipe.instructions.length > 1) {
        buffer.writeln('🔒 _Steps 2 to ${recipe.instructions.length} are locked in the app_');
      }
      buffer.writeln();
    }

    // Call To Action to download the app to unlock the complete recipe
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📲 *Unlock Full Recipe, Ingredients & Cooking Timers:*');
    buffer.writeln('👉 Download *Food CHART* (100% Free & Offline):');
    buffer.writeln(appDownloadUrl);
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━');

    return buffer.toString().trim();
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(1);
  }

  /// Directly launches WhatsApp with the pre-filled recipe text.
  /// Falls back to WhatsApp web and native share sheet if necessary.
  static Future<bool> shareToWhatsApp(BuildContext context, Recipe recipe) async {
    RatingService.instance.recordMeaningfulAction();

    final text = formatRecipeForWhatsApp(recipe);
    final encoded = Uri.encodeComponent(text);

    // Deep link protocol for mobile apps
    final appUri = Uri.parse('whatsapp://send?text=$encoded');
    // Universal web link fallback
    final webUri = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

    try {
      if (await canLaunchUrl(appUri)) {
        final launched = await launchUrl(appUri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      }
    } catch (_) {
      // Continue to fallback
    }

    try {
      if (await canLaunchUrl(webUri)) {
        final launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      }
    } catch (_) {
      // Continue to fallback
    }

    // If direct WhatsApp launch is unavailable, invoke the system share sheet
    try {
      await Share.share(text, subject: recipe.title);
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  /// Opens the system sharing dialog with pre-formatted recipe text.
  static Future<void> shareGeneral(BuildContext context, Recipe recipe) async {
    RatingService.instance.recordMeaningfulAction();
    final text = formatRecipeForWhatsApp(recipe);
    await Share.share(text, subject: recipe.title);
  }

  /// Copies formatted recipe text to clipboard and shows feedback.
  static Future<void> copyToClipboard(BuildContext context, Recipe recipe) async {
    final text = formatRecipeForWhatsApp(recipe);
    await Clipboard.setData(ClipboardData(text: text));

    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.whatsappGreen, width: 1.2),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.whatsappGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.recipeCopiedToClipboard,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Displays an interactive, polished bottom sheet modal with WhatsApp
  /// direct sharing, system sharing, and clipboard copy actions.
  static void showShareModal(BuildContext context, Recipe recipe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Grab Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header: Dish Preview
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: AppCachedImage(
                        imageUrl: recipe.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.shareRecipe,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          recipe.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // WhatsApp Primary Action Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    shareToWhatsApp(context, recipe);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF1EBE5D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF25D366).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.shareToWhatsApp,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.shareRecipeSubtitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary Actions Row: Other Apps & Copy Text
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: isDark ? AppColors.border : AppColors.lightBorder,
                        ),
                      ),
                      icon: Icon(
                        Icons.share_rounded,
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        size: 18,
                      ),
                      label: Text(
                        l10n.shareMoreOptions,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        shareGeneral(context, recipe);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: isDark ? AppColors.border : AppColors.lightBorder,
                        ),
                      ),
                      icon: Icon(
                        Icons.copy_rounded,
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        size: 18,
                      ),
                      label: Text(
                        l10n.copyRecipeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        copyToClipboard(context, recipe);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
