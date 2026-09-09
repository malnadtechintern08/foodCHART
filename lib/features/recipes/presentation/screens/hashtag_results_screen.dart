import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../tags/presentation/providers/tag_providers.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_card.dart';

class HashtagResultsScreen extends ConsumerStatefulWidget {
  final String tag;

  const HashtagResultsScreen({
    super.key,
    required this.tag,
  });

  @override
  ConsumerState<HashtagResultsScreen> createState() => _HashtagResultsScreenState();
}

class _HashtagResultsScreenState extends ConsumerState<HashtagResultsScreen> {
  late final ScrollController _scrollController;
  final List<Recipe> _recipes = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecipes = 0;

  String get _normalizedTag => widget.tag.trim().replaceFirst(RegExp(r'^#+'), '');

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadInitialPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _currentPage < _totalPages) {
        _loadNextPage();
      }
    }
  }

  Future<void> _loadInitialPage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _recipes.clear();
    });

    try {
      final repo = ref.read(tagRepositoryProvider);
      final result = await repo.getRecipesByTag(
        tag: _normalizedTag,
        page: 1,
        limit: 20,
      );

      final List<Recipe> fetched = (result['recipes'] as List<dynamic>?)?.cast<Recipe>() ?? [];
      final int total = (result['total'] as int?) ?? fetched.length;
      final int totalPages = (result['totalPages'] as int?) ?? 1;

      if (mounted) {
        setState(() {
          _recipes.addAll(fetched);
          _totalRecipes = total;
          _totalPages = totalPages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNextPage() async {
    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final repo = ref.read(tagRepositoryProvider);
      final result = await repo.getRecipesByTag(
        tag: _normalizedTag,
        page: nextPage,
        limit: 20,
      );

      final List<Recipe> fetched = (result['recipes'] as List<dynamic>?)?.cast<Recipe>() ?? [];

      if (mounted) {
        setState(() {
          _recipes.addAll(fetched);
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '#',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _normalizedTag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (!_isLoading && _totalRecipes > 0)
              Text(
                '($_totalRecipes)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    if (_errorMessage != null && _recipes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 54, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Unable to load hashtag recipes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadInitialPage,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_recipes.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.tag_rounded,
          title: 'No recipes found for #$_normalizedTag',
          description: 'Try searching for other popular hashtags like #rice, #chicken, or #malnad.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitialPage,
      color: AppColors.primary,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.paddingOf(context).bottom),
        itemCount: _recipes.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == _recipes.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            );
          }

          final recipe = _recipes[index];
          return RecipeCard(
            recipe: recipe,
            isHorizontal: true,
            onTap: () {
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
      ),
    );
  }
}
