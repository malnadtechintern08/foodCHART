import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cookmate/app/router/route_names.dart';
import 'package:cookmate/core/theme/app_colors.dart';
import 'package:cookmate/core/widgets/app_empty_state.dart';
import 'package:cookmate/core/widgets/app_error_state.dart';
import 'package:cookmate/core/widgets/app_loading_indicator.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';
import 'package:cookmate/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:cookmate/features/recipes/presentation/widgets/recipe_card.dart';
import '../providers/category_providers.dart';

class CategoryRecipesScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryRecipesScreen({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(selectedCategoryByIdProvider(categoryId));
    final recipesAsync = ref.watch(categoryRecipesProvider(categoryId));

    return Scaffold(
      appBar: AppBar(
        title: categoryAsync.when(
          data: (category) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category?.name ?? 'Category Recipes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              recipesAsync.maybeWhen(
                data: (recipes) => Text(
                  '${recipes.length} Recipes',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          loading: () => const Text('Loading...'),
          error: (error, stack) => const Text('Category Recipes'),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async {
          await ref.read(syncRecipesWithServerProvider.future).catchError((_) => <Recipe>[]);
          ref.invalidate(categoryRecipesProvider(categoryId));
        },
        child: recipesAsync.when(
          data: (recipes) {
            if (recipes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  AppEmptyState(
                    icon: Icons.restaurant_menu_rounded,
                    title: 'No Recipes in this Category',
                    description: 'Try checking other categories or add a recipe here!',
                  ),
                ],
              );
            }

            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.paddingOf(context).bottom),
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
                  onToggleFavorite: () {
                    ref.read(recipeControllerProvider.notifier).toggleFavorite(recipe.id);
                  },
                );
              },
            );
          },
          loading: () => const AppLoadingIndicator(message: 'Loading recipes...'),
          error: (err, _) => AppErrorState(
            message: err.toString(),
            onRetry: () => ref.refresh(categoryRecipesProvider(categoryId)),
          ),
        ),
      ),
    );
  }
}
