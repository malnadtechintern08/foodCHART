import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/features/recipes/domain/entities/ingredient.dart';
import 'package:cookmate/features/recipes/domain/entities/instruction_step.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';
import 'package:cookmate/features/recipes/services/recipe_share_service.dart';

void main() {
  group('RecipeShareService Formatting Tests', () {
    final sampleVegRecipe = Recipe(
      id: 'test_veg_1',
      title: 'Bisi Bele Bath',
      description: 'A comforting Karnataka one-pot meal with lentils and rice.',
      chefName: 'Amma',
      cuisine: 'Karnataka',
      imageUrl: 'https://example.com/bbb.jpg',
      prepTimeMinutes: 20,
      cookTimeMinutes: 30,
      servings: 4,
      difficulty: RecipeDifficulty.medium,
      categoryId: 'lunch_dinner',
      tags: const ['traditional', 'malnad'],
      isVegetarian: true,
      rating: 4.9,
      createdAt: DateTime(2026, 1, 1),
      ingredients: const [
        Ingredient(name: 'Rice', amount: 1.0, unit: 'cup'),
        Ingredient(name: 'Toor Dal', amount: 0.5, unit: 'cup'),
        Ingredient(name: 'Ghee', amount: 2.0, unit: 'tbsp'),
      ],
      instructions: const [
        InstructionStep(stepNumber: 1, instruction: 'Wash rice and toor dal.'),
        InstructionStep(stepNumber: 2, instruction: 'Cook in pressure cooker with vegetables.'),
        InstructionStep(stepNumber: 3, instruction: 'Temper with ghee and mustard seeds.'),
      ],
    );

    final sampleNonVegRecipe = Recipe(
      id: 'test_nonveg_1',
      title: 'Mangalore Chicken Curry',
      description: 'Fiery coastal chicken curry flavored with roasted spices.',
      chefName: 'Chef Suresh',
      cuisine: 'Coastal Karnataka',
      imageUrl: 'https://example.com/chicken.jpg',
      prepTimeMinutes: 25,
      cookTimeMinutes: 40,
      servings: 6,
      difficulty: RecipeDifficulty.hard,
      categoryId: 'lunch_dinner',
      tags: const ['coastal', 'spicy'],
      isVegetarian: false,
      rating: 4.8,
      createdAt: DateTime(2026, 1, 1),
      ingredients: const [
        Ingredient(name: 'Chicken', amount: 1.0, unit: 'kg'),
        Ingredient(name: 'Coconut Oil', amount: 2.5, unit: 'tbsp'),
      ],
      instructions: const [
        InstructionStep(stepNumber: 1, instruction: 'Marinate chicken with turmeric and salt.'),
        InstructionStep(stepNumber: 2, instruction: 'Simmer gravy till tender.'),
      ],
    );

    test('formatRecipeForWhatsApp formats vegetarian recipe as limited preview with app download CTA', () {
      final formatted = RecipeShareService.formatRecipeForWhatsApp(sampleVegRecipe);

      expect(formatted, contains('🍛 *Bisi Bele Bath*'));
      expect(formatted, contains('A comforting Karnataka one-pot meal'));
      expect(formatted, contains('Pure Veg 🌱'));
      expect(formatted, contains('⏱ *Prep:* 20 mins | *Cook:* 30 mins'));
      expect(formatted, contains('👥 *Servings:* 4 | ⭐ *Rating:* 4.9/5.0'));
      
      // Key ingredients preview (limited access)
      expect(formatted, contains('🛒 *KEY INGREDIENTS PREVIEW:*'));
      expect(formatted, contains('• 1 cup Rice'));
      expect(formatted, contains('• 0.5 cup Toor Dal'));
      expect(formatted, contains('🔒 _+ 1 more ingredients hidden in Food CHART_'));
      expect(formatted, isNot(contains('• 2 tbsp Ghee'))); // 3rd ingredient locked!

      // Method preview (limited access)
      expect(formatted, contains('👩‍🍳 *METHOD PREVIEW:*'));
      expect(formatted, contains('1. Wash rice and toor dal.'));
      expect(formatted, contains('🔒 _Steps 2 to 3 are locked in the app_'));
      expect(formatted, isNot(contains('2. Cook in pressure cooker with vegetables.'))); // Remaining steps locked!

      // Call to action
      expect(formatted, contains('📲 *Unlock Full Recipe, Ingredients & Cooking Timers:*'));
      expect(formatted, contains('https://play.google.com/store/apps/details?id=com.food.chart'));
    });

    test('formatRecipeForWhatsApp formats non-vegetarian recipe as limited preview correctly', () {
      final formatted = RecipeShareService.formatRecipeForWhatsApp(sampleNonVegRecipe);

      expect(formatted, contains('🍛 *Mangalore Chicken Curry*'));
      expect(formatted, contains('Non-Veg 🍗'));
      expect(formatted, contains('• 1 kg Chicken'));
      expect(formatted, contains('🔒 _+ 1 more ingredients hidden in Food CHART_'));
      expect(formatted, isNot(contains('• 2.5 tbsp Coconut Oil'))); // 2nd ingredient locked!
      expect(formatted, contains('1. Marinate chicken with turmeric and salt.'));
      expect(formatted, contains('🔒 _Steps 2 to 2 are locked in the app_'));
      expect(formatted, isNot(contains('2. Simmer gravy till tender.'))); // Step 2 locked!
      expect(formatted, contains('https://play.google.com/store/apps/details?id=com.food.chart'));
    });

    test('Generates valid WhatsApp URL encoding without unencoded control characters', () {
      final formatted = RecipeShareService.formatRecipeForWhatsApp(sampleVegRecipe);
      final encoded = Uri.encodeComponent(formatted);

      final whatsappUri = Uri.parse('whatsapp://send?text=$encoded');
      final webUri = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

      expect(whatsappUri.scheme, equals('whatsapp'));
      expect(whatsappUri.queryParameters['text'], equals(formatted));
      expect(webUri.scheme, equals('https'));
      expect(webUri.host, equals('api.whatsapp.com'));
      expect(webUri.queryParameters['text'], equals(formatted));
    });

    test('Handles recipes with empty ingredients or instructions gracefully', () {
      final minimalRecipe = Recipe(
        id: 'min_1',
        title: 'Simple Lemon Water',
        description: 'Quick refreshing beverage.',
        chefName: 'CookMate',
        cuisine: 'Quick',
        imageUrl: '',
        prepTimeMinutes: 2,
        cookTimeMinutes: 0,
        servings: 1,
        difficulty: RecipeDifficulty.easy,
        categoryId: 'drinks',
        tags: const [],
        createdAt: DateTime(2026, 1, 1),
      );

      final formatted = RecipeShareService.formatRecipeForWhatsApp(minimalRecipe);
      expect(formatted, contains('🍛 *Simple Lemon Water*'));
      expect(formatted, isNot(contains('🛒 *KEY INGREDIENTS PREVIEW:*')));
      expect(formatted, isNot(contains('👩‍🍳 *METHOD PREVIEW:*')));
      expect(formatted, contains('https://play.google.com/store/apps/details?id=com.food.chart'));
    });
  });
}
