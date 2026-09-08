import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/services/app_share_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../notes/presentation/providers/notes_providers.dart';
import '../../../shopping/presentation/providers/shopping_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_card.dart';

class MyRecipesScreen extends ConsumerStatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  ConsumerState<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends ConsumerState<MyRecipesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customRecipesAsync = ref.watch(customRecipesProvider);
    final favoritesAsync = ref.watch(favoriteRecipesProvider);
    final recentlyViewedAsync = ref.watch(recentlyViewedRecipesProvider);
    final shoppingItems = ref.watch(shoppingListProvider);
    final notesAsync = ref.watch(allNotesRawProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myKitchenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: l10n.shareApp,
            onPressed: () => AppShareService.showShareAppModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.pushNamed(RouteNames.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async {
          try {
            await ref.read(syncRecipesWithServerProvider.future);
          } catch (_) {}
          ref.invalidate(customRecipesProvider);
          ref.invalidate(favoriteRecipesProvider);
        },
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Kitchen Hub Header Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    // Stats Row - 4 Cards Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            l10n.myRecipes,
                            '${customRecipesAsync.value?.length ?? 0}',
                            Icons.menu_book_rounded,
                            AppColors.primaryOrange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            l10n.favorites,
                            '${favoritesAsync.value?.length ?? 0}',
                            Icons.favorite_rounded,
                            AppColors.nonVegRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            l10n.shopping,
                            '${shoppingItems.where((i) => !i.isCompleted).length}',
                            Icons.shopping_bag_rounded,
                            AppColors.accentGold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => context.pushNamed(RouteNames.notes),
                            borderRadius: BorderRadius.circular(12),
                            child: _buildStatCard(
                              context,
                              l10n.notes,
                              '${notesAsync.value?.length ?? 0}',
                              Icons.edit_note_rounded,
                              const Color(0xFFAB47BC),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick Shortcut to Notes, Taste of Malnad & Create Recipe
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFAB47BC), width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.note_alt_outlined, color: Color(0xFFAB47BC), size: 18),
                            label: Text(
                              '📝 ${l10n.notes}',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF6A1B9A),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () => context.pushNamed(RouteNames.notes),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2E7D32), width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.eco_rounded, color: Color(0xFF4CAF50), size: 18),
                            label: Text(
                              l10n.tasteOfMalnad,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF1B5E20),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () => context.pushNamed(RouteNames.malnad),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                            label: Text(
                              l10n.addRecipe,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () => context.pushNamed(RouteNames.recipeCreate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Community Recipe Submissions Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.cloud_upload_rounded, color: AppColors.primaryOrange, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Community Recipe Submissions',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Submit recipes to CookMate & track review status.',
                                  style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMuted : AppColors.lightTextMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            onPressed: () => context.push('/my-submissions'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryOrange),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryOrange)),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: () => context.push('/submit-recipe'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Submit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryOrange,
                  indicatorWeight: 3,
                  labelColor: AppColors.primaryOrange,
                  unselectedLabelColor: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  tabs: [
                    Tab(text: l10n.myCreatedRecipes, icon: const Icon(Icons.restaurant_menu_rounded, size: 18)),
                    Tab(text: l10n.recentlyViewed, icon: const Icon(Icons.history_rounded, size: 18)),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Custom Recipes
            customRecipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.menu_book_rounded,
                    title: l10n.noCustomTitle,
                    description: l10n.noCustomDesc,
                    actionLabel: l10n.createNewRecipe,
                    onAction: () => context.pushNamed(RouteNames.recipeCreate),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: MediaQuery.sizeOf(context).width < 360 ? 0.70 : 0.76,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onTap: () {
                        context.pushNamed(
                          RouteNames.recipeDetail,
                          pathParameters: {'id': recipe.id},
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),

            // Tab 2: Recently Viewed
            recentlyViewedAsync.when(
              data: (recent) {
                if (recent.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.history_rounded,
                    title: l10n.noRecentTitle,
                    description: l10n.noRecentDesc,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: MediaQuery.sizeOf(context).width < 360 ? 0.70 : 0.76,
                  ),
                  itemCount: recent.length,
                  itemBuilder: (context, index) {
                    final recipe = recent[index];
                    return RecipeCard(
                      recipe: recipe,
                      onTap: () {
                        context.pushNamed(
                          RouteNames.recipeDetail,
                          pathParameters: {'id': recipe.id},
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String count, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.background : AppColors.lightBackground,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
