import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_card.dart';

class MalnadScreen extends ConsumerStatefulWidget {
  const MalnadScreen({super.key});

  @override
  ConsumerState<MalnadScreen> createState() => _MalnadScreenState();
}

class _MalnadScreenState extends ConsumerState<MalnadScreen> {
  String _selectedSubcategoryKey = 'all';

  final List<Map<String, String>> _subcategories = [
    {'key': 'all'},
    {'key': 'breads'},
    {'key': 'curries'},
    {'key': 'rice'},
    {'key': 'snacks'},
    {'key': 'chutneys'},
    {'key': 'drinks'},
  ];

  String _getSubcategoryLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'all': return l10n.subcatAll;
      case 'breads': return l10n.subcatBreads;
      case 'curries': return l10n.subcatCurries;
      case 'rice': return l10n.subcatRice;
      case 'snacks': return l10n.subcatSnacks;
      case 'chutneys': return l10n.subcatChutneys;
      case 'drinks': return l10n.subcatDrinks;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRecipesAsync = ref.watch(allRecipesProvider);
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
          // Hero Heritage Header Sliver App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.45),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '🌿 ${l10n.tasteOfMalnad}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1B4D2E),
                          Color(0xFF0D2818),
                          Color(0xFF0E0E0E),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 60,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            l10n.malnadHeritageTag,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryOrange,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.malnadSub,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Subcategory Filter Chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: _subcategories.map((subcat) {
                  final key = subcat['key']!;
                  final isSelected = _selectedSubcategoryKey == key;
                  final label = _getSubcategoryLabel(key, l10n);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(label),
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                      labelStyle: TextStyle(
                        fontSize: 13,
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
                            _selectedSubcategoryKey = key;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Malnad Recipe Grid
          allRecipesAsync.when(
            data: (recipes) {
              final malnadRecipes = recipes.where((r) {
                if (r.categoryId != 'cat_malnad' && !r.tags.contains('Malnad Special')) {
                  return false;
                }

                if (_selectedSubcategoryKey == 'all') return true;
                if (_selectedSubcategoryKey == 'breads') {
                  return r.title.contains('Kadubu') || r.title.contains('Rotti') || r.title.contains('Dosa') || r.title.contains('Idli');
                }
                if (_selectedSubcategoryKey == 'curries') {
                  return r.title.contains('Curry') || r.title.contains('Saaru') || r.title.contains('Huli') || r.title.contains('Rasam') || r.title.contains('Sambar') || r.title.contains('Sukka');
                }
                if (_selectedSubcategoryKey == 'rice') {
                  return r.title.contains('Bath') || r.title.contains('Rice') || r.title.contains('Chitranna') || r.title.contains('Puliyogare');
                }
                if (_selectedSubcategoryKey == 'snacks') {
                  return r.title.contains('Kadubu') || r.title.contains('Uppittu') || r.title.contains('Vada') || r.title.contains('Rotti');
                }
                if (_selectedSubcategoryKey == 'chutneys') {
                  return r.title.contains('Tambli') || r.title.contains('Chutney') || r.title.contains('Gojju') || r.title.contains('Pachadi');
                }
                if (_selectedSubcategoryKey == 'drinks') {
                  return r.title.contains('Kashaya') || r.title.contains('Halwa') || r.title.contains('Payasa') || r.title.contains('Coffee') || r.title.contains('Chai');
                }
                return true;
              }).toList();

              if (malnadRecipes.isEmpty) {
                return SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.eco_outlined,
                    title: l10n.noMatchingTitle,
                    description: l10n.noMatchingDesc,
                  ),
                );
              }

              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryOrange.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.eco_rounded,
                                  size: 13,
                                  color: AppColors.primaryOrange,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${malnadRecipes.length} Recipes',
                                  style: const TextStyle(
                                    fontSize: 11.5,
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
                              _selectedSubcategoryKey == 'all'
                                  ? 'Authentic Malnad Heritage Collection'
                                  : 'Showing ${_getSubcategoryLabel(_selectedSubcategoryKey, l10n)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.paddingOf(context).bottom),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: MediaQuery.sizeOf(context).width < 360 ? 0.70 : 0.76,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final recipe = malnadRecipes[index];
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
                        childCount: malnadRecipes.length,
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SliverFillRemaining(
              child: AppLoadingIndicator(),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
