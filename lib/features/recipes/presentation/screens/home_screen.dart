import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/services/app_share_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../../categories/presentation/widgets/category_card_widget.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recently_viewed_provider.dart';
import '../providers/recipe_providers.dart';
import '../../../tags/presentation/providers/tag_providers.dart';
import '../widgets/featured_recipe_card.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_bottom_sheet.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../rating/presentation/widgets/rating_popup_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  String _selectedCategoryKey = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(syncRecipesWithServerProvider.future);
      } catch (_) {}
      if (mounted) {
        showCookMateRatingPopup(context, isManual: false);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh notifications and sync recipes when returning from background (Section 14, 36)
      ref.read(unreadNotificationCountProvider.notifier).refresh();
      ref.read(syncRecipesWithServerProvider.future);
    }
  }

  final List<Map<String, dynamic>> _chipDefs = [
    {'key': 'all', 'icon': Icons.apps_rounded},
    {'key': 'malnad', 'icon': Icons.eco_rounded},
    {'key': 'breakfast', 'icon': Icons.breakfast_dining_rounded},
    {'key': 'lunch', 'icon': Icons.lunch_dining_rounded},
    {'key': 'dinner', 'icon': Icons.dinner_dining_rounded},
    {'key': 'vegetarian', 'icon': Icons.spa_rounded},
    {'key': 'non_veg', 'icon': Icons.kebab_dining_rounded},
    {'key': 'snacks', 'icon': Icons.fastfood_rounded},
    {'key': 'desserts', 'icon': Icons.cake_rounded},
    {'key': 'drinks', 'icon': Icons.local_cafe_rounded},
    {'key': 'healthy', 'icon': Icons.favorite_rounded},
  ];

  String _getChipLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'all': return l10n.categoryAll;
      case 'malnad': return l10n.categoryMalnadSpecial;
      case 'breakfast': return l10n.categoryBreakfast;
      case 'lunch': return l10n.categoryLunch;
      case 'dinner': return l10n.categoryDinner;
      case 'vegetarian': return l10n.categoryVegetarian;
      case 'non_veg': return l10n.categoryNonVeg;
      case 'snacks': return l10n.categorySnacks;
      case 'desserts': return l10n.categoryDesserts;
      case 'drinks': return l10n.categoryDrinks;
      case 'healthy': return l10n.categoryHealthy;
      default: return key;
    }
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const RecipeFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allRecipesAsync = ref.watch(allRecipesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final filterState = ref.watch(recipeFilterProvider);
    final recentlyViewedAsync = ref.watch(recentlyViewedRecipesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async {
          try {
            await ref.read(syncRecipesWithServerProvider.future);
          } catch (_) {}
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // Top Header App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            expandedHeight: 140,
            backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: AppColors.primaryOrange,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RichText(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.3,
                                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                        ),
                                        children: [
                                          TextSpan(text: 'Food ', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w900)),
                                          const TextSpan(text: 'CHART', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      l10n.whatsCookingToday,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => context.push('/submit-recipe'),
                              icon: const Icon(Icons.post_add_rounded, color: AppColors.primaryOrange, size: 22),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              tooltip: 'Submit Recipe for Review',
                            ),
                            const NotificationBell(),
                            IconButton(
                              onPressed: () => AppShareService.showShareAppModal(context),
                              icon: const Icon(Icons.share_rounded, size: 21),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              tooltip: l10n.shareApp,
                            ),
                            IconButton(
                              onPressed: () => context.pushNamed(RouteNames.settings),
                              icon: const Icon(Icons.settings_outlined, size: 22),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              tooltip: l10n.settingsTitle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.pushNamed(RouteNames.search),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryOrange),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  l10n.searchHint,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: filterState.hasActiveFilters
                            ? AppColors.primaryOrange
                            : (isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: filterState.hasActiveFilters
                              ? AppColors.primaryOrange
                              : (isDark ? AppColors.border : AppColors.lightBorder),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          size: 22,
                          color: filterState.hasActiveFilters
                              ? Colors.white
                              : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
                        ),
                        onPressed: () => _showFilterModal(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Horizontally Scrollable Category Chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: _chipDefs.map((chip) {
                  final key = chip['key'] as String;
                  final isSelected = _selectedCategoryKey == key;
                  final label = _getChipLabel(key, l10n);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      avatar: Icon(
                        chip['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primaryOrange,
                      ),
                      label: Text(label),
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : (isDark ? AppColors.border : AppColors.lightBorder),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategoryKey = key;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Live Recipe Catalog Counter Banner
          SliverToBoxAdapter(
            child: allRecipesAsync.maybeWhen(
              data: (recipes) {
                final isFiltered = _selectedCategoryKey != 'all';
                final totalCount = recipes.length;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryOrange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.restaurant_menu_rounded,
                              size: 14,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$totalCount Recipes',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isFiltered
                              ? 'Viewing ${_getChipLabel(_selectedCategoryKey, l10n)}'
                              : 'Authentic Kitchen Collection',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),

          // Main Home Sections
          allRecipesAsync.when(
            data: (recipes) {
              // If a specific category chip is selected (other than 'all'), show filtered grid/list
              if (_selectedCategoryKey != 'all') {
                List<Recipe> filtered;
                switch (_selectedCategoryKey) {
                  case 'malnad':
                    filtered = recipes.where((r) => r.categoryId == 'cat_malnad' || r.tags.contains('Malnad Special')).toList();
                    break;
                  case 'breakfast':
                    filtered = recipes.where((r) => r.categoryId == 'cat_breakfast').toList();
                    break;
                  case 'lunch':
                  case 'dinner':
                    filtered = recipes.where((r) => r.categoryId == 'cat_lunch_dinner').toList();
                    break;
                  case 'vegetarian':
                    filtered = recipes.where((r) => r.isVegetarian).toList();
                    break;
                  case 'non_veg':
                    filtered = recipes.where((r) => !r.isVegetarian).toList();
                    break;
                  case 'snacks':
                    filtered = recipes.where((r) => r.categoryId == 'cat_snacks').toList();
                    break;
                  case 'desserts':
                    filtered = recipes.where((r) => r.categoryId == 'cat_desserts').toList();
                    break;
                  case 'drinks':
                    filtered = recipes.where((r) => r.categoryId == 'cat_drinks').toList();
                    break;
                  case 'healthy':
                    filtered = recipes.where((r) => r.categoryId == 'cat_healthy').toList();
                    break;
                  default:
                    filtered = recipes;
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: MediaQuery.sizeOf(context).width < 360 ? 0.70 : 0.76,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, idx) => RecipeCard(
                        recipe: filtered[idx],
                        onTap: () => _openRecipe(filtered[idx].id),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                );
              }

              // 1. Featured spotlight recipes
              final featuredRecipes = recipes.where((r) => r.isFavorite || r.rating >= 4.9).take(6).toList();

              // 2. Malnad Special Recipes (50 items)
              final malnadRecipes = recipes.where((r) => r.categoryId == 'cat_malnad' || r.tags.contains('Malnad Special')).toList();

              // 3. Quick Recipes (<= 30 min)
              final quickRecipes = recipes.where((r) => r.totalTimeMinutes <= 30).toList();

              // 4. Breakfast recipes
              final breakfastRecipes = recipes.where((r) => r.categoryId == 'cat_breakfast').toList();

              // 5. South Indian favorites
              final southIndianRecipes = recipes.where((r) => r.cuisine == 'South Indian' || r.region.contains('South Indian') || r.tags.contains('South Indian')).toList();

              // 6. Karnataka specials
              final karnatakaRecipes = recipes.where((r) => r.region.contains('Karnataka') || r.tags.contains('Karnataka')).toList();

              // 7. Vegetarian recipes
              final vegRecipes = recipes.where((r) => r.isVegetarian).toList();

              // 8. Non-Vegetarian recipes
              final nonVegRecipes = recipes.where((r) => !r.isVegetarian).toList();

              // 9. Snacks
              final snackRecipes = recipes.where((r) => r.categoryId == 'cat_snacks').toList();

              // 10. Desserts
              final dessertRecipes = recipes.where((r) => r.categoryId == 'cat_desserts').toList();

              // 11. Drinks
              final drinkRecipes = recipes.where((r) => r.categoryId == 'cat_drinks').toList();

              // 12. Saved Favorites
              final favoriteRecipes = recipes.where((r) => r.isFavorite).toList();

              return SliverList(
                delegate: SliverChildListDelegate([
                  // SECTION 1: Featured Recipes Carousel
                  if (featuredRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '✨ ${l10n.chefSpotlight}',
                      l10n.popularRecipes,
                      null,
                    ),
                    SizedBox(
                      height: 240,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 0.92),
                        itemCount: featuredRecipes.length,
                        itemBuilder: (ctx, idx) {
                          final recipe = featuredRecipes[idx];
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: FeaturedRecipeCard(
                              recipe: recipe,
                              onTap: () => _openRecipe(recipe.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // SECTION 2: Categories Grid
                  categoriesAsync.when(
                    data: (cats) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          context,
                          '🗂 ${l10n.exploreCuisines}',
                          l10n.viewAll,
                          () => context.pushNamed(RouteNames.categories),
                        ),
                        SizedBox(
                          height: 105,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: cats.length,
                            itemBuilder: (ctx, idx) {
                              final cat = cats[idx];
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: CategoryCardWidget(
                                  category: cat,
                                  isCompact: true,
                                  onTap: () {
                                    context.pushNamed(
                                      RouteNames.categoryRecipes,
                                      pathParameters: {'id': cat.id},
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),

                  // SECTION: 🏷️ Trending Hashtags Discovery (Instagram-Style)
                  _buildExploreByHashtagSection(context, ref, isDark),

                  // SECTION 3: 🌿 Taste of Malnad (Dedicated Special Section)
                  if (malnadRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      l10n.tasteOfMalnadSpecial,
                      l10n.malnadHeritageBannerSub,
                      () => context.pushNamed(RouteNames.malnad),
                    ),
                    _buildHorizontalRecipeList(malnadRecipes),
                  ],

                  // SECTION 4: ⚡ Quick & Easy (<= 30 min)
                  if (quickRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '⚡ ${l10n.quickRecipes}',
                      l10n.fastAndDelicious,
                      null,
                    ),
                    _buildHorizontalRecipeList(quickRecipes),
                  ],

                  // SECTION 5: 🍳 Breakfast Ideas
                  if (breakfastRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '🍳 ${l10n.categoryBreakfast}',
                      l10n.popularRecipes,
                      () => context.pushNamed(
                        RouteNames.categoryRecipes,
                        pathParameters: {'id': 'cat_breakfast'},
                      ),
                    ),
                    _buildHorizontalRecipeList(breakfastRecipes),
                  ],

                  // SECTION 6: 🥥 South Indian Favorites
                  if (southIndianRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '🥥 South Indian Classics',
                      l10n.popularRecipes,
                      null,
                    ),
                    _buildHorizontalRecipeList(southIndianRecipes),
                  ],

                  // SECTION 7: 🥘 Karnataka Specials
                  if (karnatakaRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '🥘 Karnataka Specials',
                      l10n.popularRecipes,
                      null,
                    ),
                    _buildHorizontalRecipeList(karnatakaRecipes),
                  ],

                  // SECTION 8: 🥗 Vegetarian Recipes
                  if (vegRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '🥗 ${l10n.categoryVegetarian}',
                      l10n.healthyRecipes,
                      null,
                    ),
                    _buildHorizontalRecipeList(vegRecipes),
                  ],

                  // SECTION 9: 🍗 Non-Vegetarian Recipes
                  if (nonVegRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '🍗 ${l10n.categoryNonVeg}',
                      l10n.popularRecipes,
                      () => context.pushNamed(
                        RouteNames.categoryRecipes,
                        pathParameters: {'id': 'cat_non_veg'},
                      ),
                    ),
                    _buildHorizontalRecipeList(nonVegRecipes),
                  ],

                  // SECTION 10: 🍟 Snacks & Street Food
                  if (snackRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '🍟 ${l10n.categorySnacks}',
                      l10n.popularRecipes,
                      () => context.pushNamed(
                        RouteNames.categoryRecipes,
                        pathParameters: {'id': 'cat_snacks'},
                      ),
                    ),
                    _buildHorizontalRecipeList(snackRecipes),
                  ],

                  // SECTION 11: 🍰 Desserts & Mithai
                  if (dessertRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '🍰 ${l10n.categoryDesserts}',
                      l10n.popularRecipes,
                      () => context.pushNamed(
                        RouteNames.categoryRecipes,
                        pathParameters: {'id': 'cat_desserts'},
                      ),
                    ),
                    _buildHorizontalRecipeList(dessertRecipes),
                  ],

                  // SECTION 12: 🥤 Drinks & Beverages
                  if (drinkRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '🥤 ${l10n.categoryDrinks}',
                      l10n.popularRecipes,
                      () => context.pushNamed(
                        RouteNames.categoryRecipes,
                        pathParameters: {'id': 'cat_drinks'},
                      ),
                    ),
                    _buildHorizontalRecipeList(drinkRecipes),
                  ],

                  // SECTION 13: 🍽 Recently Viewed
                  recentlyViewedAsync.when(
                    data: (recent) {
                      if (recent.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context,
                            '🍽 ${l10n.recentlyViewed}',
                            l10n.whatsCookingToday,
                            null,
                          ),
                          _buildHorizontalRecipeList(recent),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),

                  // SECTION 14: ❤️ Saved Favorites
                  if (favoriteRecipes.isNotEmpty) ...[
                    _buildSectionHeader(
                      context,
                      '❤️ ${l10n.favorites}',
                      l10n.popularRecipes,
                      () => context.goNamed(RouteNames.favorites),
                    ),
                    _buildHorizontalRecipeList(favoriteRecipes),
                  ],

                  const SizedBox(height: 100),
                ]),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: AppLoadingIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error loading recipes: $err')),
            ),
          ),
        ],
      ),
      ),
    );
  }

  void _openRecipe(String id) {
    context.pushNamed(
      RouteNames.recipeDetail,
      pathParameters: {'id': id},
    );
  }

  Widget _buildExploreByHashtagSection(BuildContext context, WidgetRef ref, bool isDark) {
    final popularTagsAsync = ref.watch(popularTagsProvider);

    return popularTagsAsync.when(
      data: (tags) {
        if (tags.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tag_rounded, size: 20, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'Trending Hashtags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.pushNamed(RouteNames.search),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      'Search #',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tags.length,
                itemBuilder: (ctx, idx) {
                  final tag = tags[idx];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () {
                        ref.read(recentSearchesProvider.notifier).addSearch('#${tag.name}');
                        context.pushNamed(
                          RouteNames.hashtagResults,
                          pathParameters: {'tag': tag.name},
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
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
                              tag.name,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            if (tag.usageCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${tag.usageCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback? onViewAll,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(
                l10n.viewAll,
                style: const TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHorizontalRecipeList(List<Recipe> recipes) {
    return SizedBox(
      height: 232,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: recipes.length,
        itemBuilder: (ctx, idx) {
          final recipe = recipes[idx];
          return Container(
            width: 155,
            margin: const EdgeInsets.only(right: 12),
            child: RecipeCard(
              recipe: recipe,
              onTap: () => _openRecipe(recipe.id),
            ),
          );
        },
      ),
    );
  }
}
