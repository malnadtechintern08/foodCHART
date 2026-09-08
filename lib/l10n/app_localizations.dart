import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Food CHART'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Offline Master Culinary Companion'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// No description provided for @navShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @navMyKitchen.
  ///
  /// In en, this message translates to:
  /// **'My Kitchen'**
  String get navMyKitchen;

  /// No description provided for @whatsCookingToday.
  ///
  /// In en, this message translates to:
  /// **'What\'s cooking today?'**
  String get whatsCookingToday;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes, chai, biryani, dosa...'**
  String get searchHint;

  /// No description provided for @chefSpotlight.
  ///
  /// In en, this message translates to:
  /// **'CHEF SPOTLIGHT'**
  String get chefSpotlight;

  /// No description provided for @quickLaunch.
  ///
  /// In en, this message translates to:
  /// **'Quick Launch (< 25 min)'**
  String get quickLaunch;

  /// No description provided for @fastAndDelicious.
  ///
  /// In en, this message translates to:
  /// **'Fast & Delicious'**
  String get fastAndDelicious;

  /// No description provided for @exploreCuisines.
  ///
  /// In en, this message translates to:
  /// **'Explore Indian Cuisines & Drinks'**
  String get exploreCuisines;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @tasteOfMalnad.
  ///
  /// In en, this message translates to:
  /// **'Taste of Malnad'**
  String get tasteOfMalnad;

  /// No description provided for @tasteOfMalnadSpecial.
  ///
  /// In en, this message translates to:
  /// **'🌿 Taste of Malnad Special'**
  String get tasteOfMalnadSpecial;

  /// No description provided for @malnadHeritageBannerSub.
  ///
  /// In en, this message translates to:
  /// **'50 Traditional recipes from the Western Ghats'**
  String get malnadHeritageBannerSub;

  /// No description provided for @popularRecipes.
  ///
  /// In en, this message translates to:
  /// **'Popular Recipes'**
  String get popularRecipes;

  /// No description provided for @quickRecipes.
  ///
  /// In en, this message translates to:
  /// **'Quick Recipes'**
  String get quickRecipes;

  /// No description provided for @healthyRecipes.
  ///
  /// In en, this message translates to:
  /// **'Healthy Recipes'**
  String get healthyRecipes;

  /// No description provided for @recentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get recentlyViewed;

  /// No description provided for @allRecipes.
  ///
  /// In en, this message translates to:
  /// **'All Recipes'**
  String get allRecipes;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryMalnadSpecial.
  ///
  /// In en, this message translates to:
  /// **'Malnad Special'**
  String get categoryMalnadSpecial;

  /// No description provided for @categoryBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get categoryBreakfast;

  /// No description provided for @categoryLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get categoryLunch;

  /// No description provided for @categoryDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get categoryDinner;

  /// No description provided for @categorySnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get categorySnacks;

  /// No description provided for @categoryDesserts.
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get categoryDesserts;

  /// No description provided for @categoryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get categoryDrinks;

  /// No description provided for @categoryHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get categoryHealthy;

  /// No description provided for @categoryVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get categoryVegetarian;

  /// No description provided for @categoryNonVeg.
  ///
  /// In en, this message translates to:
  /// **'Non-Veg'**
  String get categoryNonVeg;

  /// No description provided for @categoryLunchDinner.
  ///
  /// In en, this message translates to:
  /// **'Lunch & Dinner'**
  String get categoryLunchDinner;

  /// No description provided for @veg.
  ///
  /// In en, this message translates to:
  /// **'VEG'**
  String get veg;

  /// No description provided for @nonVeg.
  ///
  /// In en, this message translates to:
  /// **'NON-VEG'**
  String get nonVeg;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep Time'**
  String get prepTime;

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook Time'**
  String get cookTime;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @servingsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String servingsCount(int count);

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @recipesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String recipesCount(int count);

  /// No description provided for @itemsNeeded.
  ///
  /// In en, this message translates to:
  /// **'{count} items needed'**
  String itemsNeeded(int count);

  /// No description provided for @aboutDish.
  ///
  /// In en, this message translates to:
  /// **'About this dish'**
  String get aboutDish;

  /// No description provided for @addIngredientsToShopping.
  ///
  /// In en, this message translates to:
  /// **'🛒 Add Ingredients to Shopping List'**
  String get addIngredientsToShopping;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @instructionsOverview.
  ///
  /// In en, this message translates to:
  /// **'Instructions Overview'**
  String get instructionsOverview;

  /// No description provided for @startCooking.
  ///
  /// In en, this message translates to:
  /// **'Start Interactive Cooking Mode'**
  String get startCooking;

  /// No description provided for @deleteRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Recipe?'**
  String get deleteRecipeTitle;

  /// No description provided for @deleteRecipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"? This cannot be undone.'**
  String deleteRecipeConfirm(String title);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addedToShoppingSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Added {count} ingredients to Shopping List! 🛒'**
  String addedToShoppingSnackBar(int count);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @recipeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipe Not Found'**
  String get recipeNotFound;

  /// No description provided for @recipeNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'This recipe may have been removed.'**
  String get recipeNotFoundDesc;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOf(int current, int total);

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark Done'**
  String get markDone;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @finishCooking.
  ///
  /// In en, this message translates to:
  /// **'Finish Cooking 🥳'**
  String get finishCooking;

  /// No description provided for @bonAppetit.
  ///
  /// In en, this message translates to:
  /// **'Bon Appétit! 🎉'**
  String get bonAppetit;

  /// No description provided for @celebrationSub.
  ///
  /// In en, this message translates to:
  /// **'You\'ve successfully prepared this dish. Time to plate and enjoy!'**
  String get celebrationSub;

  /// No description provided for @backToDetails.
  ///
  /// In en, this message translates to:
  /// **'Back to Recipe Details'**
  String get backToDetails;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @addGroceryItem.
  ///
  /// In en, this message translates to:
  /// **'Add Grocery Item'**
  String get addGroceryItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @itemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sona Masoori Rice, Ghee'**
  String get itemNameHint;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unitHint.
  ///
  /// In en, this message translates to:
  /// **'kg / bunch / cup'**
  String get unitHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @clearDone.
  ///
  /// In en, this message translates to:
  /// **'Clear Done'**
  String get clearDone;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All Items'**
  String get clearAll;

  /// No description provided for @toBuy.
  ///
  /// In en, this message translates to:
  /// **'TO BUY'**
  String get toBuy;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completed;

  /// No description provided for @itemsToBuy.
  ///
  /// In en, this message translates to:
  /// **'{count} items to buy'**
  String itemsToBuy(int count);

  /// No description provided for @purchasedCount.
  ///
  /// In en, this message translates to:
  /// **'{purchased} of {total} purchased'**
  String purchasedCount(int purchased, int total);

  /// No description provided for @emptyShoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your shopping list is empty'**
  String get emptyShoppingTitle;

  /// No description provided for @emptyShoppingDesc.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients directly from any recipe or tap + to create your personal grocery items.'**
  String get emptyShoppingDesc;

  /// No description provided for @addFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add First Item'**
  String get addFirstItem;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @customItem.
  ///
  /// In en, this message translates to:
  /// **'Custom Item'**
  String get customItem;

  /// No description provided for @myKitchenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Kitchen & More'**
  String get myKitchenTitle;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get myRecipes;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @cookingHistory.
  ///
  /// In en, this message translates to:
  /// **'Cooking History'**
  String get cookingHistory;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipe;

  /// No description provided for @myCreatedRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Created Recipes'**
  String get myCreatedRecipes;

  /// No description provided for @noCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'No custom recipes yet'**
  String get noCustomTitle;

  /// No description provided for @noCustomDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your secret family recipes, notes, and photos to keep them safe locally.'**
  String get noCustomDesc;

  /// No description provided for @createNewRecipe.
  ///
  /// In en, this message translates to:
  /// **'Create New Recipe'**
  String get createNewRecipe;

  /// No description provided for @noRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'No recently viewed recipes'**
  String get noRecentTitle;

  /// No description provided for @noRecentDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore our 200+ recipe catalog and your history will be recorded here.'**
  String get noRecentDesc;

  /// No description provided for @favoriteRecipes.
  ///
  /// In en, this message translates to:
  /// **'Favorite Recipes'**
  String get favoriteRecipes;

  /// No description provided for @noFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesDesc.
  ///
  /// In en, this message translates to:
  /// **'Save recipes you love and they will appear here.'**
  String get noFavoritesDesc;

  /// No description provided for @exploreRecipesBtn.
  ///
  /// In en, this message translates to:
  /// **'Explore Recipes'**
  String get exploreRecipesBtn;

  /// No description provided for @exploreRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Recipes'**
  String get exploreRecipesTitle;

  /// No description provided for @tagTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get tagTrending;

  /// No description provided for @tagUnder20m.
  ///
  /// In en, this message translates to:
  /// **'Under 20m'**
  String get tagUnder20m;

  /// No description provided for @tagMalnadHeritage.
  ///
  /// In en, this message translates to:
  /// **'Malnad Heritage'**
  String get tagMalnadHeritage;

  /// No description provided for @tagBreakfastHits.
  ///
  /// In en, this message translates to:
  /// **'Breakfast Hits'**
  String get tagBreakfastHits;

  /// No description provided for @tagBiryaniRice.
  ///
  /// In en, this message translates to:
  /// **'Biryani & Rice'**
  String get tagBiryaniRice;

  /// No description provided for @tagHealthyChoice.
  ///
  /// In en, this message translates to:
  /// **'Healthy Choice'**
  String get tagHealthyChoice;

  /// No description provided for @malnadTitle.
  ///
  /// In en, this message translates to:
  /// **'Taste of Malnad'**
  String get malnadTitle;

  /// No description provided for @malnadHeritageTag.
  ///
  /// In en, this message translates to:
  /// **'WESTERN GHATS CULINARY HERITAGE'**
  String get malnadHeritageTag;

  /// No description provided for @malnadSub.
  ///
  /// In en, this message translates to:
  /// **'Traditional flavours from the Western Ghats of Karnataka'**
  String get malnadSub;

  /// No description provided for @subcatAll.
  ///
  /// In en, this message translates to:
  /// **'All Malnad'**
  String get subcatAll;

  /// No description provided for @subcatBreads.
  ///
  /// In en, this message translates to:
  /// **'Traditional Breads'**
  String get subcatBreads;

  /// No description provided for @subcatCurries.
  ///
  /// In en, this message translates to:
  /// **'Curries & Sambar'**
  String get subcatCurries;

  /// No description provided for @subcatRice.
  ///
  /// In en, this message translates to:
  /// **'Rice Dishes'**
  String get subcatRice;

  /// No description provided for @subcatSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks & Steamed'**
  String get subcatSnacks;

  /// No description provided for @subcatChutneys.
  ///
  /// In en, this message translates to:
  /// **'Chutneys & Tambli'**
  String get subcatChutneys;

  /// No description provided for @subcatDrinks.
  ///
  /// In en, this message translates to:
  /// **'Herbal Drinks & Sweets'**
  String get subcatDrinks;

  /// No description provided for @filterRecipes.
  ///
  /// In en, this message translates to:
  /// **'Filter Recipes'**
  String get filterRecipes;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'DIFFICULTY'**
  String get difficultyLabel;

  /// No description provided for @maxTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'MAX TIME'**
  String get maxTimeLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get categoryLabel;

  /// No description provided for @anyTime.
  ///
  /// In en, this message translates to:
  /// **'Any Time'**
  String get anyTime;

  /// No description provided for @under15m.
  ///
  /// In en, this message translates to:
  /// **'⚡ Under 15m'**
  String get under15m;

  /// No description provided for @under30m.
  ///
  /// In en, this message translates to:
  /// **'🕒 Under 30m'**
  String get under30m;

  /// No description provided for @under60m.
  ///
  /// In en, this message translates to:
  /// **'🍲 Under 60m'**
  String get under60m;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @noMatchingTitle.
  ///
  /// In en, this message translates to:
  /// **'No Matching Recipes Found'**
  String get noMatchingTitle;

  /// No description provided for @noMatchingDesc.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search query, clearing filters, or searching for other ingredients.'**
  String get noMatchingDesc;

  /// No description provided for @filterDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {diff}'**
  String filterDifficulty(String diff);

  /// No description provided for @filterMaxTime.
  ///
  /// In en, this message translates to:
  /// **'Max Time: <{mins}m'**
  String filterMaxTime(int mins);

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category Filter'**
  String get filterCategory;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllFilters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @highestRating.
  ///
  /// In en, this message translates to:
  /// **'Highest Rating'**
  String get highestRating;

  /// No description provided for @lowestCookingTime.
  ///
  /// In en, this message translates to:
  /// **'Lowest Cooking Time'**
  String get lowestCookingTime;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Preferences'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get chooseLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme Mode'**
  String get chooseTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @offlineStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE STORAGE & PERSISTENCE'**
  String get offlineStorageTitle;

  /// No description provided for @offlineModeDesc.
  ///
  /// In en, this message translates to:
  /// **'100% Offline-First. All recipes, drinks, and timers operate without internet.'**
  String get offlineModeDesc;

  /// No description provided for @resetCatalog.
  ///
  /// In en, this message translates to:
  /// **'Reset Recipe Database'**
  String get resetCatalog;

  /// No description provided for @resetCatalogDesc.
  ///
  /// In en, this message translates to:
  /// **'Re-seed built-in catalog to original state. Retains custom notes.'**
  String get resetCatalogDesc;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Catalog?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This will restore all default recipes to original values.'**
  String get resetConfirmDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get about;

  /// No description provided for @aboutCookMate.
  ///
  /// In en, this message translates to:
  /// **'About Food CHART'**
  String get aboutCookMate;

  /// No description provided for @versionText.
  ///
  /// In en, this message translates to:
  /// **'Version 2.0.0 • Indian Culinary Edition'**
  String get versionText;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @kannada.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ'**
  String get kannada;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @newRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'New Custom Recipe ✍️'**
  String get newRecipeTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'BASIC INFORMATION'**
  String get basicInfo;

  /// No description provided for @recipeTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe Title *'**
  String get recipeTitleLabel;

  /// No description provided for @recipeTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Grandma\'s Secret Sambar'**
  String get recipeTitleHint;

  /// No description provided for @recipeTitleReq.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get recipeTitleReq;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description / Story'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe flavors, textures, or history...'**
  String get descriptionHint;

  /// No description provided for @cuisineLabel.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get cuisineLabel;

  /// No description provided for @cuisineHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., South Indian, Malnad'**
  String get cuisineHint;

  /// No description provided for @chefLabel.
  ///
  /// In en, this message translates to:
  /// **'Chef / Author'**
  String get chefLabel;

  /// No description provided for @chefHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get chefHint;

  /// No description provided for @imageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrlLabel;

  /// No description provided for @categoryAndSpecs.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY & SPECS'**
  String get categoryAndSpecs;

  /// No description provided for @prepTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Prep Time (m)'**
  String get prepTimeLabel;

  /// No description provided for @cookTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cook Time (m)'**
  String get cookTimeLabel;

  /// No description provided for @servingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servingsLabel;

  /// No description provided for @ingredientsSection.
  ///
  /// In en, this message translates to:
  /// **'INGREDIENTS'**
  String get ingredientsSection;

  /// No description provided for @addItemBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItemBtn;

  /// No description provided for @instructionsSection.
  ///
  /// In en, this message translates to:
  /// **'INSTRUCTIONS'**
  String get instructionsSection;

  /// No description provided for @addStepBtn.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get addStepBtn;

  /// No description provided for @recipeCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recipe created successfully! 🎉'**
  String get recipeCreatedSuccess;

  /// No description provided for @databaseResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Database reset to Indian & world recipes successfully! 🎉'**
  String get databaseResetSuccess;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get myNotes;

  /// No description provided for @notesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your cooking ideas and kitchen reminders'**
  String get notesSubtitle;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteConfirm;

  /// No description provided for @searchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes by title, content, tag...'**
  String get searchNotesHint;

  /// No description provided for @noNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotesTitle;

  /// No description provided for @noNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'Save recipe ideas, kitchen tips, and reminders here.'**
  String get noNotesDesc;

  /// No description provided for @createFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Create First Note'**
  String get createFirstNote;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note Title'**
  String get noteTitle;

  /// No description provided for @noteTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Ideas for Sunday Breakfast'**
  String get noteTitleHint;

  /// No description provided for @noteTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a note title'**
  String get noteTitleRequired;

  /// No description provided for @noteContent.
  ///
  /// In en, this message translates to:
  /// **'Note Content'**
  String get noteContent;

  /// No description provided for @noteContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your thoughts, tips, or ingredient reminders...'**
  String get noteContentHint;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Breakfast, South Indian (comma separated)'**
  String get tagsHint;

  /// No description provided for @pinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get pinned;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @relatedRecipe.
  ///
  /// In en, this message translates to:
  /// **'Related Recipe'**
  String get relatedRecipe;

  /// No description provided for @selectRecipe.
  ///
  /// In en, this message translates to:
  /// **'Select Recipe (Optional)'**
  String get selectRecipe;

  /// No description provided for @noRecipeSelected.
  ///
  /// In en, this message translates to:
  /// **'None (No recipe linked)'**
  String get noRecipeSelected;

  /// No description provided for @allNotes.
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get allNotes;

  /// No description provided for @sortNotes.
  ///
  /// In en, this message translates to:
  /// **'Sort Notes'**
  String get sortNotes;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get sortOldest;

  /// No description provided for @sortAlpha.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAlpha;

  /// No description provided for @sortPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned First'**
  String get sortPinned;

  /// No description provided for @noteSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Note saved successfully! 📝'**
  String get noteSavedSuccess;

  /// No description provided for @noteDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Note deleted successfully!'**
  String get noteDeletedSuccess;

  /// No description provided for @catRecipeIdea.
  ///
  /// In en, this message translates to:
  /// **'Recipe Idea'**
  String get catRecipeIdea;

  /// No description provided for @catShoppingReminder.
  ///
  /// In en, this message translates to:
  /// **'Shopping Reminder'**
  String get catShoppingReminder;

  /// No description provided for @catMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get catMealPlan;

  /// No description provided for @catKitchenTip.
  ///
  /// In en, this message translates to:
  /// **'Kitchen Tip'**
  String get catKitchenTip;

  /// No description provided for @catIngredientNote.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Note'**
  String get catIngredientNote;

  /// No description provided for @catMalnadRecipe.
  ///
  /// In en, this message translates to:
  /// **'Malnad Recipe'**
  String get catMalnadRecipe;

  /// No description provided for @catPersonalNote.
  ///
  /// In en, this message translates to:
  /// **'Personal Note'**
  String get catPersonalNote;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @shareRecipe.
  ///
  /// In en, this message translates to:
  /// **'Share Recipe'**
  String get shareRecipe;

  /// No description provided for @shareToWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get shareToWhatsApp;

  /// No description provided for @shareMoreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Sharing Options'**
  String get shareMoreOptions;

  /// No description provided for @copyRecipeText.
  ///
  /// In en, this message translates to:
  /// **'Copy Recipe Text'**
  String get copyRecipeText;

  /// No description provided for @recipeCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Recipe copied to clipboard! 📋'**
  String get recipeCopiedToClipboard;

  /// No description provided for @shareRecipeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share this delicious dish with family & friends on WhatsApp'**
  String get shareRecipeSubtitle;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share Food CHART App'**
  String get shareApp;

  /// No description provided for @shareAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share via WhatsApp, Quick Share, Bluetooth & more'**
  String get shareAppSubtitle;

  /// No description provided for @shareAppQuickShareBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Quick Share, Bluetooth & More'**
  String get shareAppQuickShareBluetooth;

  /// No description provided for @shareAppLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Food CHART app link copied to clipboard! 📋'**
  String get shareAppLinkCopied;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'kn'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
