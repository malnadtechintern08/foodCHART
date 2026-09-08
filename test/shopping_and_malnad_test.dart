import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/core/database/seed_data.dart';
import 'package:cookmate/features/shopping/domain/entities/shopping_item.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';

void main() {
  group('CookMate 50 Recipes & Malnad Special Tests', () {
    test('SeedData contains exactly 120 recipes with unique IDs', () {
      final recipes = SeedData.recipes;
      expect(recipes.length, equals(120));

      final ids = recipes.map((r) => r['id'] as String).toSet();
      expect(ids.length, equals(120), reason: 'All recipe IDs must be unique');
    });


    test('SeedData contains 50 authentic Malnad Special recipes', () {
      final recipes = SeedData.recipes;
      final malnadRecipes = recipes.where((r) {
        return r['category_id'] == 'cat_malnad' || (r['tags'] as String).contains('Malnad Special');
      }).toList();

      expect(malnadRecipes.length, equals(50));
      expect(malnadRecipes.any((r) => r['title'] == 'Akki Rotti'), isTrue);
      expect(malnadRecipes.any((r) => r['title'] == 'Kotte Kadubu'), isTrue);
      expect(malnadRecipes.any((r) => r['title'] == 'Kesuvina Pathrode'), isTrue);
      expect(malnadRecipes.any((r) => r['title'] == 'Kanile Palya'), isTrue);
      expect(malnadRecipes.any((r) => r['title'] == 'Malnad Chicken Curry'), isTrue);
    });

    test('SeedData recipes contain valid required properties', () {
      for (final r in SeedData.recipes) {
        expect(r['title'], isNotEmpty);
        expect(r['description'], isNotEmpty);
        expect(r['image_url'], startsWith('assets/images/recipes/'));
        expect(r['prep_time_minutes'], isNonNegative);
        expect(r['cook_time_minutes'], isNonNegative);
        expect(r['servings'], isPositive);
        expect(r['difficulty'], isIn(['Easy', 'Medium', 'Hard']));
        expect(r['ingredients'], isNotEmpty);
        expect(r['instructions'], isNotEmpty);
      }
    });

    test('ShoppingItem quantity formatting and toggling works as expected', () {
      final item = ShoppingItem(
        id: 'item_1',
        name: 'Dosa Rice',
        amount: 2.0,
        unit: 'cups',
        recipeName: 'Masala Dosa',
        createdAt: DateTime.now(),
      );

      expect(item.formattedQuantity, equals('2 cups'));
      expect(item.isCompleted, isFalse);

      final completed = item.copyWith(isCompleted: true);
      expect(completed.isCompleted, isTrue);
    });

    test('Recipe entity aliases work seamlessly', () {
      final recipe = Recipe(
        id: 'test_1',
        title: 'Masala Dosa',
        description: 'Crispy dosa with potato masala',
        chefName: 'Chef Ustaad',
        cuisine: 'South Indian',
        imageUrl: 'assets/images/recipes/masala_dosa.jpg',
        prepTimeMinutes: 15,
        cookTimeMinutes: 20,
        servings: 2,
        difficulty: RecipeDifficulty.medium,
        categoryId: 'cat_breakfast',
        tags: ['South Indian', 'Breakfast'],
        isVegetarian: true,
        rating: 4.9,
        region: 'Karnataka',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(recipe.name, equals('Masala Dosa'));
      expect(recipe.image, equals('assets/images/recipes/masala_dosa.jpg'));
      expect(recipe.prepTime, equals(15));
      expect(recipe.cookTime, equals(20));
      expect(recipe.totalTime, equals(35));
      expect(recipe.isVegetarian, isTrue);
    });
  });
}
