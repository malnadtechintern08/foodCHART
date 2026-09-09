import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tags/presentation/providers/tag_providers.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    final filter = ref.read(recipeFilterProvider);
    _searchController = TextEditingController(text: filter.query);
    _currentQuery = filter.query.trim();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentQuery = val.trim();
        });
        ref.read(recipeFilterProvider.notifier).setQuery(val);
      }
    });
  }

  void _submitSearch(String query) {
    final clean = query.trim();
    if (clean.isEmpty) return;

    ref.read(recentSearchesProvider.notifier).addSearch(clean);

    if (clean.startsWith('#')) {
      final tag = clean.replaceFirst(RegExp(r'^#+'), '');
      context.pushNamed(RouteNames.hashtagResults, pathParameters: {'tag': tag});
    } else {
      _searchController.text = clean;
      setState(() => _currentQuery = clean);
      ref.read(recipeFilterProvider.notifier).setQuery(clean);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(recipeFilterProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isTypingHashtag = _currentQuery.contains('#');
    final hasNoQuery = _currentQuery.isEmpty;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search recipes, ingredients or #hashtags',
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _currentQuery = '');
                        ref.read(recipeFilterProvider.notifier).setQuery('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: _onQueryChanged,
            onSubmitted: _submitSearch,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: filterState.hasActiveFilters ? AppColors.primary : null,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const RecipeFilterBottomSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Active filter badges
          if (filterState.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (filterState.difficulty != null)
                      _buildFilterBadge(l10n.filterDifficulty(filterState.difficulty!), () {
                        ref.read(recipeFilterProvider.notifier).setDifficulty(null);
                      }),
                    if (filterState.maxTimeMinutes != null)
                      _buildFilterBadge(l10n.filterMaxTime(filterState.maxTimeMinutes!), () {
                        ref.read(recipeFilterProvider.notifier).setMaxTime(null);
                      }),
                    if (filterState.categoryId != null)
                      _buildFilterBadge(l10n.filterCategory, () {
                        ref.read(recipeFilterProvider.notifier).setCategory(null);
                      }),
                    TextButton(
                      onPressed: () {
                        ref.read(recipeFilterProvider.notifier).resetFilters();
                        _searchController.clear();
                        setState(() => _currentQuery = '');
                      },
                      child: Text(l10n.clearAllFilters, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

          // Main body switch: Has Query vs Empty State (Recent & Popular)
          Expanded(
            child: hasNoQuery
                ? _buildEmptyStateContent(isDark)
                : isTypingHashtag
                    ? _buildHashtagSuggestionsOrResults(searchResultsAsync, isDark)
                    : _buildSearchResults(searchResultsAsync, l10n),
          ),
        ],
      ),
    );
  }

  /// When search input is empty: Shows Recent Searches and Popular Hashtags
  Widget _buildEmptyStateContent(bool isDark) {
    final recentSearches = ref.watch(recentSearchesProvider);
    final popularTagsAsync = ref.watch(popularTagsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Recent Searches
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(recentSearchesProvider.notifier).clearAll(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Clear All', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches.map((item) {
                final isTag = item.startsWith('#');
                return InkWell(
                  onTap: () => _submitSearch(item),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surface : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isTag
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : (isDark ? AppColors.border : Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTag ? Icons.tag_rounded : Icons.history_rounded,
                          size: 14,
                          color: isTag ? AppColors.primary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isTag ? FontWeight.w700 : FontWeight.w500,
                            color: isTag
                                ? AppColors.primary
                                : (isDark ? Colors.white : AppColors.lightTextPrimary),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => ref.read(recentSearchesProvider.notifier).removeSearch(item),
                          child: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // 2. Popular Hashtags Section
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text(
                'Popular Hashtags',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          popularTagsAsync.when(
            data: (tags) {
              if (tags.isEmpty) return const SizedBox.shrink();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tags.map((tag) {
                  return InkWell(
                    onTap: () {
                      ref.read(recentSearchesProvider.notifier).addSearch('#${tag.name}');
                      context.pushNamed(
                        RouteNames.hashtagResults,
                        pathParameters: {'tag': tag.name},
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )),
            error: (err, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// When query contains '#': shows live hashtag suggestions + matching recipe cards
  Widget _buildHashtagSuggestionsOrResults(AsyncValue<List<dynamic>> searchResultsAsync, bool isDark) {
    final cleanTag = _currentQuery.replaceFirst(RegExp(r'^#+'), '');
    final suggestionsAsync = ref.watch(tagSuggestionsProvider(cleanTag));

    return Column(
      children: [
        // Live suggestions bar
        suggestionsAsync.when(
          data: (suggestions) {
            if (suggestions.isEmpty) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBackground : Colors.grey[50],
                border: Border(bottom: BorderSide(color: isDark ? AppColors.border : Colors.grey[200]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      'Hashtag Suggestions',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: suggestions.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            avatar: const Icon(Icons.tag_rounded, size: 14, color: Colors.white),
                            label: Text('#${tag.name} (${tag.usageCount})'),
                            backgroundColor: AppColors.primary,
                            labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                            onPressed: () {
                              ref.read(recentSearchesProvider.notifier).addSearch('#${tag.name}');
                              context.pushNamed(
                                RouteNames.hashtagResults,
                                pathParameters: {'tag': tag.name},
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const LinearProgressIndicator(minHeight: 2),
          error: (err, stack) => const SizedBox.shrink(),
        ),

        // Result recipes
        Expanded(
          child: _buildSearchResults(searchResultsAsync, AppLocalizations.of(context)!),
        ),
      ],
    );
  }

  Widget _buildSearchResults(AsyncValue<List<dynamic>> searchResultsAsync, AppLocalizations l10n) {
    return searchResultsAsync.when(
      data: (recipes) {
        if (recipes.isEmpty) {
          return AppEmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.noMatchingTitle,
            description: l10n.noMatchingDesc,
          );
        }

        final bottomPadding = MediaQuery.paddingOf(context).bottom;
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomPadding),
          itemCount: recipes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return RecipeCard(
              recipe: recipe,
              isHorizontal: true,
              onTap: () {
                if (_currentQuery.isNotEmpty) {
                  ref.read(recentSearchesProvider.notifier).addSearch(_currentQuery);
                }
                context.pushNamed(
                  RouteNames.recipeDetail,
                  pathParameters: {'id': recipe.id},
                );
              },
              onToggleFavorite: () {
                ref.read(recipeControllerProvider.notifier).toggleFavorite(recipe.id);
              },
            );
          },
        );
      },
      loading: () => const AppLoadingIndicator(),
      error: (err, stack) => Center(
        child: Text('Search Error: $err'),
      ),
    );
  }

  Widget _buildFilterBadge(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
