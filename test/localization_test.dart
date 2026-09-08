import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/core/localization/app_language.dart';
import 'package:cookmate/core/localization/recipe_translations.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';
import 'package:cookmate/l10n/app_localizations_en.dart';
import 'package:cookmate/l10n/app_localizations_hi.dart';
import 'package:cookmate/l10n/app_localizations_kn.dart';

void main() {
  group('Multilingual Localization Engine Tests', () {
    test('Supported languages are English, Kannada, and Hindi', () {
      expect(AppLanguage.values.length, equals(3));
      expect(AppLanguage.fromCode('en'), equals(AppLanguage.en));
      expect(AppLanguage.fromCode('kn'), equals(AppLanguage.kn));
      expect(AppLanguage.fromCode('hi'), equals(AppLanguage.hi));
      expect(AppLanguage.fromCode('unknown'), equals(AppLanguage.en));

      expect(AppLanguage.en.locale, equals(const Locale('en')));
      expect(AppLanguage.kn.locale, equals(const Locale('kn')));
      expect(AppLanguage.hi.locale, equals(const Locale('hi')));
    });

    test('English AppLocalizations resolve keys and parameter interpolation', () {
      final loc = AppLocalizationsEn();
      expect(loc.appName, equals('Food CHART'));
      expect(loc.whatsCookingToday, equals("What's cooking today?"));
      expect(loc.stepOf(2, 5), equals('Step 2 of 5'));
      expect(loc.itemsToBuy(4), equals('4 items to buy'));
      expect(loc.deleteRecipeConfirm('Masala Dosa'), equals('Are you sure you want to delete "Masala Dosa"? This cannot be undone.'));
      expect(loc.addedToShoppingSnackBar(4), equals('Added 4 ingredients to Shopping List! 🛒'));
      expect(loc.bonAppetit, equals('Bon Appétit! 🎉'));
      expect(loc.databaseResetSuccess, equals('Database reset to Indian & world recipes successfully! 🎉'));
    });

    test('Kannada AppLocalizations resolve authentic Kannada text', () {
      final loc = AppLocalizationsKn();
      expect(loc.appName, equals('Food CHART'));
      expect(loc.whatsCookingToday, equals('ಇಂದು ಏನು ಅಡುಗೆ ಮಾಡಬೇಕು?'));
      expect(loc.stepOf(1, 4), equals('ಹಂತ 1 / 4'));
      expect(loc.itemsToBuy(3), equals('3 ವಸ್ತುಗಳು ಖರೀದಿಸಬೇಕಿದೆ'));
      expect(loc.deleteRecipeTitle, equals('ಪಾಕವಿಧಾನ ಅಳಿಸುವುದೇ?'));
      expect(loc.bonAppetit, equals('ಸವಿಯಿರಿ! 🎉'));
      expect(loc.navHome, equals('ಮುಖಪುಟ'));
      expect(loc.navExplore, equals('ಅನ್ವೇಷಿಸಿ'));
      expect(loc.navFavorites, equals('ಮೆಚ್ಚಿನವು'));
      expect(loc.navShopping, equals('ಖರೀದಿ ಪಟ್ಟಿ'));
      expect(loc.navMyKitchen, equals('ನನ್ನ ಅಡುಗೆಮನೆ'));
    });

    test('Hindi AppLocalizations resolve authentic Hindi text', () {
      final loc = AppLocalizationsHi();
      expect(loc.appName, equals('Food CHART'));
      expect(loc.whatsCookingToday, equals('आज क्या बनाना है?'));
      expect(loc.stepOf(3, 6), equals('चरण 3 / 6'));
      expect(loc.itemsToBuy(5), equals('5 सामान खरीदना है'));
      expect(loc.deleteRecipeTitle, equals('रेसिपी हटाएं?'));
      expect(loc.bonAppetit, equals('स्वाद का आनंद लें! 🎉'));
      expect(loc.navHome, equals('होम'));
      expect(loc.navExplore, equals('खोजें'));
      expect(loc.navFavorites, equals('पसंदीदा'));
      expect(loc.navShopping, equals('खरीदारी'));
      expect(loc.navMore, equals('अधिक'));
      expect(loc.navMyKitchen, equals('मेरी रसोई'));
    });

    test('RecipeTranslations provides category translations', () {
      expect(RecipeTranslations.getCategoryName('Breakfast', 'kn'), equals('ಉಪಹಾರ'));
      expect(RecipeTranslations.getCategoryName('Breakfast', 'hi'), equals('नाश्ता'));
      expect(RecipeTranslations.getCategoryName('Breakfast', 'en'), equals('Breakfast'));

      expect(RecipeTranslations.getCategoryName('Lunch & Dinner', 'kn'), equals('ಊಟ ಮತ್ತು ಭೋಜನ'));
      expect(RecipeTranslations.getCategoryName('Lunch & Dinner', 'hi'), equals('दोपहर व रात का खाना'));

      expect(RecipeTranslations.getCategoryName('Malnad Special', 'kn'), equals('ಮಲೆನಾಡು ವಿಶೇಷ'));
      expect(RecipeTranslations.getCategoryName('Malnad Special', 'hi'), equals('मलनाड विशेष'));
    });

    test('RecipeTranslations provides recipe dish translations with fallback', () {
      expect(RecipeTranslations.getRecipeTitle('Masala Dosa', 'kn'), equals('ಮಸಾಲೆ ದೋಸೆ'));
      expect(RecipeTranslations.getRecipeTitle('Masala Dosa', 'hi'), equals('मसाला डोसा'));
      expect(RecipeTranslations.getRecipeTitle('Masala Dosa', 'en'), equals('Masala Dosa'));

      expect(RecipeTranslations.getRecipeTitle('Hyderabadi Chicken Biryani', 'kn'), equals('ಹೈದರಾಬಾದಿ ಚಿಕನ್ ಬಿರಿಯಾನಿ'));
      expect(RecipeTranslations.getRecipeTitle('Hyderabadi Chicken Biryani', 'hi'), equals('हैदराबादी चिकन बिरयानी'));

      // Fallback for untranslated title returns original English title
      expect(RecipeTranslations.getRecipeTitle('Unique Custom Family Dish', 'kn'), equals('Unique Custom Family Dish'));
    });

    test('RecipeTranslations multilingual search matches Kannada and Hindi queries', () {
      final sampleRecipe = Recipe(
        id: 'rec_dosa',
        title: 'Crispy Masala Dosa',
        description: 'Iconic South Indian fermented crepe',
        categoryId: 'cat_breakfast',
        prepTimeMinutes: 20,
        cookTimeMinutes: 15,
        servings: 4,
        difficulty: RecipeDifficulty.medium,
        isVegetarian: true,
        cuisine: 'South Indian',
        region: 'Karnataka',
        chefName: 'Chef Anita',
        imageUrl: 'assets/images/dosa.jpg',
        createdAt: DateTime(2026, 1, 1),
        tags: const ['Dosa', 'Breakfast', 'Malnad Special'],
      );

      // Search in English
      expect(RecipeTranslations.matchesQuery(sampleRecipe, 'masala'), isTrue);
      expect(RecipeTranslations.matchesQuery(sampleRecipe, 'dosa'), isTrue);

      // Search in Kannada
      expect(RecipeTranslations.matchesQuery(sampleRecipe, 'ದೋಸೆ'), isTrue);

      // Search in Hindi
      expect(RecipeTranslations.matchesQuery(sampleRecipe, 'डोसा'), isTrue);

      // Non-matching query
      expect(RecipeTranslations.matchesQuery(sampleRecipe, 'pizza'), isFalse);
    });
  });
}
