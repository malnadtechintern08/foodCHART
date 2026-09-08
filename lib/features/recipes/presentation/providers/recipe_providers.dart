import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../data/datasources/recipe_local_datasource.dart';
import '../../data/datasources/recipe_remote_datasource.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/recipe_usecases.dart';

// Local Data Source Provider
final recipeLocalDataSourceProvider = Provider<RecipeLocalDataSource>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return RecipeLocalDataSourceImpl(dbService);
});

// Remote Data Source Provider
final recipeRemoteDataSourceProvider = Provider<RecipeRemoteDataSource>((ref) {
  return RecipeRemoteDataSourceImpl();
});

// Repository Provider (combines local SQLite cache & live remote API)
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final localDataSource = ref.watch(recipeLocalDataSourceProvider);
  final remoteDataSource = ref.watch(recipeRemoteDataSourceProvider);
  return RecipeRepositoryImpl(localDataSource, remoteDataSource);
});

// Use Cases Providers
final getAllRecipesUseCaseProvider = Provider<GetAllRecipesUseCase>((ref) {
  return GetAllRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final getRecipeByIdUseCaseProvider = Provider<GetRecipeByIdUseCase>((ref) {
  return GetRecipeByIdUseCase(ref.watch(recipeRepositoryProvider));
});

final getRecipesByCategoryUseCaseProvider = Provider<GetRecipesByCategoryUseCase>((ref) {
  return GetRecipesByCategoryUseCase(ref.watch(recipeRepositoryProvider));
});

final getQuickLaunchRecipesUseCaseProvider = Provider<GetQuickLaunchRecipesUseCase>((ref) {
  return GetQuickLaunchRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final getFavoriteRecipesUseCaseProvider = Provider<GetFavoriteRecipesUseCase>((ref) {
  return GetFavoriteRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final getCustomRecipesUseCaseProvider = Provider<GetCustomRecipesUseCase>((ref) {
  return GetCustomRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final searchRecipesUseCaseProvider = Provider<SearchRecipesUseCase>((ref) {
  return SearchRecipesUseCase(ref.watch(recipeRepositoryProvider));
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(ref.watch(recipeRepositoryProvider));
});

final createRecipeUseCaseProvider = Provider<CreateRecipeUseCase>((ref) {
  return CreateRecipeUseCase(ref.watch(recipeRepositoryProvider));
});

final updateRecipeUseCaseProvider = Provider<UpdateRecipeUseCase>((ref) {
  return UpdateRecipeUseCase(ref.watch(recipeRepositoryProvider));
});

final deleteRecipeUseCaseProvider = Provider<DeleteRecipeUseCase>((ref) {
  return DeleteRecipeUseCase(ref.watch(recipeRepositoryProvider));
});

// Presentation Async Data Providers
final allRecipesProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final useCase = ref.watch(getAllRecipesUseCaseProvider);
  return await useCase.execute();
});

// Background / Manual sync with live production server (https://cookmate.free.nf)
final syncRecipesWithServerProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  final updatedRecipes = await repository.syncRecipesWithServer();
  ref.invalidate(allRecipesProvider);
  ref.invalidate(quickLaunchRecipesProvider);
  ref.invalidate(favoriteRecipesProvider);
  ref.invalidate(categoriesProvider);
  ref.invalidate(categoryRecipesProvider);
  return updatedRecipes;
});


final quickLaunchRecipesProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final useCase = ref.watch(getQuickLaunchRecipesUseCaseProvider);
  return await useCase.execute(maxMinutes: 25);
});

final favoriteRecipesProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final useCase = ref.watch(getFavoriteRecipesUseCaseProvider);
  return await useCase.execute();
});

final customRecipesProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final useCase = ref.watch(getCustomRecipesUseCaseProvider);
  return await useCase.execute();
});

final recipeDetailProvider = FutureProvider.family.autoDispose<Recipe?, String>((ref, id) async {
  final useCase = ref.watch(getRecipeByIdUseCaseProvider);
  return await useCase.execute(id);
});

final categoryRecipesProvider = FutureProvider.family.autoDispose<List<Recipe>, String>((ref, categoryId) async {
  final useCase = ref.watch(getRecipesByCategoryUseCaseProvider);
  return await useCase.execute(categoryId);
});

// Search & Filter State
class RecipeFilterState {
  final String query;
  final String? categoryId;
  final String? difficulty;
  final int? maxTimeMinutes;

  const RecipeFilterState({
    this.query = '',
    this.categoryId,
    this.difficulty,
    this.maxTimeMinutes,
  });

  RecipeFilterState copyWith({
    String? query,
    String? categoryId,
    String? difficulty,
    int? maxTimeMinutes,
    bool clearCategory = false,
    bool clearDifficulty = false,
    bool clearMaxTime = false,
  }) {
    return RecipeFilterState(
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      maxTimeMinutes: clearMaxTime ? null : (maxTimeMinutes ?? this.maxTimeMinutes),
    );
  }

  bool get hasActiveFilters =>
      query.isNotEmpty ||
      (categoryId != null && categoryId != 'all') ||
      (difficulty != null && difficulty != 'all') ||
      (maxTimeMinutes != null && maxTimeMinutes! > 0);
}

class RecipeSearchNotifier extends StateNotifier<RecipeFilterState> {
  RecipeSearchNotifier() : super(const RecipeFilterState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setCategory(String? categoryId) {
    if (categoryId == 'all' || categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(categoryId: categoryId);
    }
  }

  void setDifficulty(String? difficulty) {
    if (difficulty == 'all' || difficulty == null) {
      state = state.copyWith(clearDifficulty: true);
    } else {
      state = state.copyWith(difficulty: difficulty);
    }
  }

  void setMaxTime(int? maxMinutes) {
    if (maxMinutes == null || maxMinutes == 0) {
      state = state.copyWith(clearMaxTime: true);
    } else {
      state = state.copyWith(maxTimeMinutes: maxMinutes);
    }
  }

  void resetFilters() {
    state = const RecipeFilterState();
  }
}

final recipeFilterProvider = StateNotifierProvider<RecipeSearchNotifier, RecipeFilterState>((ref) {
  return RecipeSearchNotifier();
});

final searchResultsProvider = FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final filter = ref.watch(recipeFilterProvider);
  final useCase = ref.watch(searchRecipesUseCaseProvider);
  return await useCase.execute(
    query: filter.query,
    categoryId: filter.categoryId,
    difficulty: filter.difficulty,
    maxTimeMinutes: filter.maxTimeMinutes,
  );
});

// Recipe Actions Controller (Mutations)
class RecipeController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  RecipeController(this.ref) : super(const AsyncValue.data(null));

  Future<void> toggleFavorite(String recipeId) async {
    try {
      final useCase = ref.read(toggleFavoriteUseCaseProvider);
      await useCase.execute(recipeId);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createRecipe(Recipe recipe) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(createRecipeUseCaseProvider);
      await useCase.execute(recipe);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateRecipe(Recipe recipe) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(updateRecipeUseCaseProvider);
      await useCase.execute(recipe);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(deleteRecipeUseCaseProvider);
      await useCase.execute(recipeId);
      state = const AsyncValue.data(null);
      _invalidateAll();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void _invalidateAll() {
    ref.invalidate(allRecipesProvider);
    ref.invalidate(quickLaunchRecipesProvider);
    ref.invalidate(favoriteRecipesProvider);
    ref.invalidate(customRecipesProvider);
    ref.invalidate(searchResultsProvider);
    ref.invalidate(categoriesProvider);
  }
}

final recipeControllerProvider = StateNotifierProvider<RecipeController, AsyncValue<void>>((ref) {
  return RecipeController(ref);
});
