import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/localization/recipe_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shopping/presentation/providers/shopping_provider.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recently_viewed_provider.dart';
import '../providers/recipe_providers.dart';
import '../../../rating/services/rating_service.dart';
import '../../../tags/presentation/providers/tag_providers.dart';
import '../../services/recipe_share_service.dart';
import '../widgets/ingredient_list_widget.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically record this view in Recently Viewed history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentlyViewedIdsProvider.notifier).recordView(widget.recipeId);
    });
  }

  Color _getDifficultyColor(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return AppColors.vegGreen;
      case RecipeDifficulty.medium:
        return AppColors.warning;
      case RecipeDifficulty.hard:
        return AppColors.nonVegRed;
    }
  }

  String _getDifficultyLabel(RecipeDifficulty difficulty, AppLocalizations l10n) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return l10n.easy;
      case RecipeDifficulty.medium:
        return l10n.medium;
      case RecipeDifficulty.hard:
        return l10n.hard;
    }
  }

  void _showDeleteDialog(BuildContext context, Recipe recipe) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.deleteRecipeTitle),
        content: Text(l10n.deleteRecipeConfirm(recipe.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.nonVegRed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(recipeControllerProvider.notifier).deleteRecipe(recipe.id);
              if (context.mounted) {
                context.pop();
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _addIngredientsToShopping(Recipe recipe) {
    if (recipe.ingredients.isEmpty) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    ref.read(shoppingListProvider.notifier).addIngredientsFromRecipe(
          ingredients: recipe.ingredients,
          recipeTitle: recipe.title,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.primaryOrange, width: 1.2),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.vegGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.addedToShoppingSnackBar(recipe.ingredients.length),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: l10n.view,
          textColor: AppColors.primaryOrange,
          onPressed: () {
            context.goNamed(RouteNames.shopping);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(recipeDetailProvider(widget.recipeId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final viewPaddingBottom = MediaQuery.viewPaddingOf(context).bottom;
    final paddingBottom = MediaQuery.paddingOf(context).bottom;
    final systemBottomInset = viewPaddingBottom > 0 ? viewPaddingBottom : paddingBottom;

    return recipeAsync.when(
      data: (recipe) {
        if (recipe == null) {
          return Scaffold(
            body: AppEmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.recipeNotFound,
              description: l10n.recipeNotFoundDesc,
            ),
          );
        }

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              RatingService.instance.triggerBackNavigationRating();
            }
          },
          child: Scaffold(
            body: CustomScrollView(
            slivers: [
              // Hero Image Sliver App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.55),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                actions: [
                  if (recipe.isCustom)
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.55),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
                          onPressed: () => _showDeleteDialog(context, recipe),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.55),
                      child: IconButton(
                        icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                        tooltip: l10n.shareRecipe,
                        onPressed: () => RecipeShareService.showShareModal(context, recipe),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.55),
                      child: IconButton(
                        icon: Icon(
                          recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: recipe.isFavorite ? AppColors.nonVegRed : Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          ref.read(recipeControllerProvider.notifier).toggleFavorite(recipe.id);
                          RatingService.instance.recordMeaningfulAction();
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppCachedImage(
                        imageUrl: recipe.imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              (isDark ? AppColors.background : AppColors.lightBackground).withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Veg / Non-Veg Indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: (recipe.isVegetarian ? AppColors.vegGreen : AppColors.nonVegRed)
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: recipe.isVegetarian ? AppColors.vegGreen : AppColors.nonVegRed,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        recipe.isVegetarian ? Icons.circle : Icons.square,
                                        size: 8,
                                        color: recipe.isVegetarian ? AppColors.vegGreen : AppColors.nonVegRed,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        recipe.isVegetarian ? l10n.veg : l10n.nonVeg,
                                        style: TextStyle(
                                          color: recipe.isVegetarian ? AppColors.vegGreen : AppColors.nonVegRed,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOrange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        recipe.cuisine.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 18, color: AppColors.accentGold),
                                    const SizedBox(width: 3),
                                    Text(
                                      recipe.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recipe.localizedTitle(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chef / Community Contributor Attribution
                      if (recipe.chefName.isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surface : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isDark ? AppColors.border : Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.primaryOrange),
                              Flexible(
                                child: Text(
                                  recipe.chefName.toLowerCase().contains('community')
                                      ? recipe.chefName
                                      : 'Recipe by ${recipe.chefName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Region and Nutrition Tag Row
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 15, color: AppColors.primaryOrange),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              recipe.region,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                          if (recipe.nutrition.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.fitness_center_rounded,
                              size: 14,
                              color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                recipe.nutrition,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Quick Recipe Stats Grid
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                context,
                                Icons.timer_outlined,
                                l10n.prepTime,
                                '${recipe.prepTimeMinutes}m',
                                AppColors.primaryOrange,
                              ),
                            ),
                            _buildDivider(context),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                Icons.local_fire_department_outlined,
                                l10n.cookTime,
                                '${recipe.cookTimeMinutes}m',
                                AppColors.warning,
                              ),
                            ),
                            _buildDivider(context),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                Icons.speed_rounded,
                                l10n.difficulty,
                                _getDifficultyLabel(recipe.difficulty, l10n),
                                _getDifficultyColor(recipe.difficulty),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        l10n.aboutDish,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recipe.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.55,
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Add to Shopping List Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.primaryOrange),
                          label: Text(
                            l10n.addIngredientsToShopping,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                          onPressed: () => _addIngredientsToShopping(recipe),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Share to WhatsApp Direct Button
                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => RecipeShareService.shareToWhatsApp(context, recipe),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF25D366), Color(0xFF1EBE5D)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF25D366).withValues(alpha: 0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    l10n.shareToWhatsApp,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Ingredients Section with Portions Scaler
                      IngredientListWidget(
                        ingredients: recipe.ingredients,
                        baseServings: recipe.servings,
                      ),
                      const SizedBox(height: 32),

                      // Instructions Overview
                      Text(
                        l10n.instructionsOverview,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Step by step instructions
                      ...recipe.instructions.map((step) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: AppColors.primaryOrange,
                                child: Text(
                                  '${step.stepNumber}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step.instruction,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.45,
                                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    if (step.timerSeconds != null && step.timerSeconds! > 0) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryOrange.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.timer_outlined,
                                                size: 13, color: AppColors.primaryOrange),
                                            const SizedBox(width: 4),
                                            Text(
                                              TimeFormatter.formatSeconds(step.timerSeconds!),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primaryOrange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      if (recipe.tags.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.tag_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            const Text(
                              'Tags & Hashtags',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recipe.tags.map((rawTag) {
                            final clean = rawTag.trim().toLowerCase().replaceAll('#', '').replaceAll(' ', '_');
                            if (clean.isEmpty) return const SizedBox.shrink();
                            return InkWell(
                              onTap: () {
                                ref.read(recentSearchesProvider.notifier).addSearch('#$clean');
                                context.pushNamed(
                                  RouteNames.hashtagResults,
                                  pathParameters: {'tag': clean},
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '#',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      clean,
                                      style: TextStyle(
                                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Action Bar to launch interactive cooking mode
          bottomSheet: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
              border: Border(
                top: BorderSide(color: isDark ? AppColors.border : AppColors.lightBorder),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + systemBottomInset),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.restaurant_rounded, color: Colors.white),
                label: Text(
                  l10n.startCooking,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                onPressed: () {
                  context.pushNamed(
                    RouteNames.cookingMode,
                    extra: recipe,
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
      loading: () => const Scaffold(
        body: Center(child: AppLoadingIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: AppErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(recipeDetailProvider(widget.recipeId)),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.border : AppColors.lightBorder,
    );
  }
}
