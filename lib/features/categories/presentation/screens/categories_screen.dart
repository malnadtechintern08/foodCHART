import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/presentation/providers/recipe_providers.dart';

import '../providers/category_providers.dart';
import '../widgets/category_card_widget.dart';


class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories & Cuisines'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const AppEmptyState(
              icon: Icons.category_rounded,
              title: 'No Categories Available',
              description: 'Categories will appear here once loaded.',
            );
          }

          final totalRecipes = categories.fold<int>(0, (sum, cat) => sum + cat.recipeCount);

          return RefreshIndicator(
            color: AppColors.primaryOrange,
            onRefresh: () async {
              await ref.read(syncRecipesWithServerProvider.future).catchError((_) => <Recipe>[]);
              ref.invalidate(categoriesProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primaryOrange.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.restaurant_menu_rounded,
                            color: AppColors.primaryOrange,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '$totalRecipes Recipes across ${categories.length} Categories',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: MediaQuery.sizeOf(context).width < 360 ? 0.94 : 1.05,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return CategoryCardWidget(
                          category: category,
                          onTap: () {
                            context.pushNamed(
                              RouteNames.categoryRecipes,
                              pathParameters: {'id': category.id},
                            );
                          },
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const AppLoadingIndicator(message: 'Loading categories...'),
        error: (err, _) => AppErrorState(
          message: err.toString(),
          onRetry: () {
            ref.read(syncRecipesWithServerProvider.future).catchError((_) => <Recipe>[]);
            ref.refresh(categoriesProvider);
          },
        ),

      ),
    );
  }
}
