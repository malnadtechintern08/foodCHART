// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Food CHART';

  @override
  String get appTagline => 'Your Offline Master Culinary Companion';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navMore => 'More';

  @override
  String get navMyKitchen => 'My Kitchen';

  @override
  String get whatsCookingToday => 'What\'s cooking today?';

  @override
  String get searchHint => 'Search recipes, chai, biryani, dosa...';

  @override
  String get chefSpotlight => 'CHEF SPOTLIGHT';

  @override
  String get quickLaunch => 'Quick Launch (< 25 min)';

  @override
  String get fastAndDelicious => 'Fast & Delicious';

  @override
  String get exploreCuisines => 'Explore Indian Cuisines & Drinks';

  @override
  String get viewAll => 'View All';

  @override
  String get tasteOfMalnad => 'Taste of Malnad';

  @override
  String get tasteOfMalnadSpecial => '🌿 Taste of Malnad Special';

  @override
  String get malnadHeritageBannerSub =>
      '50 Traditional recipes from the Western Ghats';

  @override
  String get popularRecipes => 'Popular Recipes';

  @override
  String get quickRecipes => 'Quick Recipes';

  @override
  String get healthyRecipes => 'Healthy Recipes';

  @override
  String get recentlyViewed => 'Recently Viewed';

  @override
  String get allRecipes => 'All Recipes';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryMalnadSpecial => 'Malnad Special';

  @override
  String get categoryBreakfast => 'Breakfast';

  @override
  String get categoryLunch => 'Lunch';

  @override
  String get categoryDinner => 'Dinner';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryDesserts => 'Desserts';

  @override
  String get categoryDrinks => 'Drinks';

  @override
  String get categoryHealthy => 'Healthy';

  @override
  String get categoryVegetarian => 'Vegetarian';

  @override
  String get categoryNonVeg => 'Non-Veg';

  @override
  String get categoryLunchDinner => 'Lunch & Dinner';

  @override
  String get veg => 'VEG';

  @override
  String get nonVeg => 'NON-VEG';

  @override
  String get prepTime => 'Prep Time';

  @override
  String get cookTime => 'Cook Time';

  @override
  String get totalTime => 'Total Time';

  @override
  String get servings => 'Servings';

  @override
  String servingsCount(int count) {
    return '$count servings';
  }

  @override
  String get difficulty => 'Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get rating => 'Rating';

  @override
  String recipesCount(int count) {
    return '$count recipes';
  }

  @override
  String itemsNeeded(int count) {
    return '$count items needed';
  }

  @override
  String get aboutDish => 'About this dish';

  @override
  String get addIngredientsToShopping => '🛒 Add Ingredients to Shopping List';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get instructions => 'Instructions';

  @override
  String get instructionsOverview => 'Instructions Overview';

  @override
  String get startCooking => 'Start Interactive Cooking Mode';

  @override
  String get deleteRecipeTitle => 'Delete Recipe?';

  @override
  String deleteRecipeConfirm(String title) {
    return 'Are you sure you want to delete \"$title\"? This cannot be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String addedToShoppingSnackBar(int count) {
    return 'Added $count ingredients to Shopping List! 🛒';
  }

  @override
  String get view => 'View';

  @override
  String get recipeNotFound => 'Recipe Not Found';

  @override
  String get recipeNotFoundDesc => 'This recipe may have been removed.';

  @override
  String stepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get markDone => 'Mark Done';

  @override
  String get done => 'Done';

  @override
  String get start => 'Start';

  @override
  String get pause => 'Pause';

  @override
  String get restart => 'Restart';

  @override
  String get previous => 'Previous';

  @override
  String get nextStep => 'Next Step';

  @override
  String get finishCooking => 'Finish Cooking 🥳';

  @override
  String get bonAppetit => 'Bon Appétit! 🎉';

  @override
  String get celebrationSub =>
      'You\'ve successfully prepared this dish. Time to plate and enjoy!';

  @override
  String get backToDetails => 'Back to Recipe Details';

  @override
  String get exit => 'Exit';

  @override
  String get shoppingList => 'Shopping List';

  @override
  String get addItem => 'Add Item';

  @override
  String get addGroceryItem => 'Add Grocery Item';

  @override
  String get itemName => 'Item Name';

  @override
  String get itemNameHint => 'e.g. Sona Masoori Rice, Ghee';

  @override
  String get qty => 'Qty';

  @override
  String get unit => 'Unit';

  @override
  String get unitHint => 'kg / bunch / cup';

  @override
  String get add => 'Add';

  @override
  String get clearDone => 'Clear Done';

  @override
  String get clearAll => 'Clear All Items';

  @override
  String get toBuy => 'TO BUY';

  @override
  String get completed => 'COMPLETED';

  @override
  String itemsToBuy(int count) {
    return '$count items to buy';
  }

  @override
  String purchasedCount(int purchased, int total) {
    return '$purchased of $total purchased';
  }

  @override
  String get emptyShoppingTitle => 'Your shopping list is empty';

  @override
  String get emptyShoppingDesc =>
      'Add ingredients directly from any recipe or tap + to create your personal grocery items.';

  @override
  String get addFirstItem => 'Add First Item';

  @override
  String get quantity => 'Quantity';

  @override
  String get customItem => 'Custom Item';

  @override
  String get myKitchenTitle => 'My Kitchen & More';

  @override
  String get myRecipes => 'My Recipes';

  @override
  String get favorites => 'Favorites';

  @override
  String get shopping => 'Shopping';

  @override
  String get cookingHistory => 'Cooking History';

  @override
  String get addRecipe => 'Add Recipe';

  @override
  String get myCreatedRecipes => 'My Created Recipes';

  @override
  String get noCustomTitle => 'No custom recipes yet';

  @override
  String get noCustomDesc =>
      'Add your secret family recipes, notes, and photos to keep them safe locally.';

  @override
  String get createNewRecipe => 'Create New Recipe';

  @override
  String get noRecentTitle => 'No recently viewed recipes';

  @override
  String get noRecentDesc =>
      'Explore our 200+ recipe catalog and your history will be recorded here.';

  @override
  String get favoriteRecipes => 'Favorite Recipes';

  @override
  String get noFavoritesTitle => 'No favorites yet';

  @override
  String get noFavoritesDesc =>
      'Save recipes you love and they will appear here.';

  @override
  String get exploreRecipesBtn => 'Explore Recipes';

  @override
  String get exploreRecipesTitle => 'Explore Recipes';

  @override
  String get tagTrending => 'Trending';

  @override
  String get tagUnder20m => 'Under 20m';

  @override
  String get tagMalnadHeritage => 'Malnad Heritage';

  @override
  String get tagBreakfastHits => 'Breakfast Hits';

  @override
  String get tagBiryaniRice => 'Biryani & Rice';

  @override
  String get tagHealthyChoice => 'Healthy Choice';

  @override
  String get malnadTitle => 'Taste of Malnad';

  @override
  String get malnadHeritageTag => 'WESTERN GHATS CULINARY HERITAGE';

  @override
  String get malnadSub =>
      'Traditional flavours from the Western Ghats of Karnataka';

  @override
  String get subcatAll => 'All Malnad';

  @override
  String get subcatBreads => 'Traditional Breads';

  @override
  String get subcatCurries => 'Curries & Sambar';

  @override
  String get subcatRice => 'Rice Dishes';

  @override
  String get subcatSnacks => 'Snacks & Steamed';

  @override
  String get subcatChutneys => 'Chutneys & Tambli';

  @override
  String get subcatDrinks => 'Herbal Drinks & Sweets';

  @override
  String get filterRecipes => 'Filter Recipes';

  @override
  String get filters => 'Filters';

  @override
  String get reset => 'Reset';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get difficultyLabel => 'DIFFICULTY';

  @override
  String get maxTimeLabel => 'MAX TIME';

  @override
  String get categoryLabel => 'CATEGORY';

  @override
  String get anyTime => 'Any Time';

  @override
  String get under15m => '⚡ Under 15m';

  @override
  String get under30m => '🕒 Under 30m';

  @override
  String get under60m => '🍲 Under 60m';

  @override
  String get allCategories => 'All Categories';

  @override
  String get noMatchingTitle => 'No Matching Recipes Found';

  @override
  String get noMatchingDesc =>
      'Try adjusting your search query, clearing filters, or searching for other ingredients.';

  @override
  String filterDifficulty(String diff) {
    return 'Difficulty: $diff';
  }

  @override
  String filterMaxTime(int mins) {
    return 'Max Time: <${mins}m';
  }

  @override
  String get filterCategory => 'Category Filter';

  @override
  String get clearAllFilters => 'Clear All';

  @override
  String get sortBy => 'Sort By';

  @override
  String get highestRating => 'Highest Rating';

  @override
  String get lowestCookingTime => 'Lowest Cooking Time';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String get settingsTitle => 'Settings & Preferences';

  @override
  String get language => 'Language';

  @override
  String get currentLanguage => 'Current Language';

  @override
  String get chooseLanguage => 'Select Language';

  @override
  String get theme => 'Theme';

  @override
  String get chooseTheme => 'Choose Theme Mode';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get offlineStorageTitle => 'OFFLINE STORAGE & PERSISTENCE';

  @override
  String get offlineModeDesc =>
      '100% Offline-First. All recipes, drinks, and timers operate without internet.';

  @override
  String get resetCatalog => 'Reset Recipe Database';

  @override
  String get resetCatalogDesc =>
      'Re-seed built-in catalog to original state. Retains custom notes.';

  @override
  String get resetConfirmTitle => 'Reset Catalog?';

  @override
  String get resetConfirmDesc =>
      'This will restore all default recipes to original values.';

  @override
  String get about => 'ABOUT';

  @override
  String get aboutCookMate => 'About Food CHART';

  @override
  String get versionText => 'Version 2.0.0 • Indian Culinary Edition';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get kannada => 'ಕನ್ನಡ';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get newRecipeTitle => 'New Custom Recipe ✍️';

  @override
  String get save => 'Save';

  @override
  String get basicInfo => 'BASIC INFORMATION';

  @override
  String get recipeTitleLabel => 'Recipe Title *';

  @override
  String get recipeTitleHint => 'e.g., Grandma\'s Secret Sambar';

  @override
  String get recipeTitleReq => 'Title is required';

  @override
  String get descriptionLabel => 'Description / Story';

  @override
  String get descriptionHint => 'Describe flavors, textures, or history...';

  @override
  String get cuisineLabel => 'Cuisine';

  @override
  String get cuisineHint => 'e.g., South Indian, Malnad';

  @override
  String get chefLabel => 'Chef / Author';

  @override
  String get chefHint => 'Your name';

  @override
  String get imageUrlLabel => 'Image URL';

  @override
  String get categoryAndSpecs => 'CATEGORY & SPECS';

  @override
  String get prepTimeLabel => 'Prep Time (m)';

  @override
  String get cookTimeLabel => 'Cook Time (m)';

  @override
  String get servingsLabel => 'Servings';

  @override
  String get ingredientsSection => 'INGREDIENTS';

  @override
  String get addItemBtn => 'Add Item';

  @override
  String get instructionsSection => 'INSTRUCTIONS';

  @override
  String get addStepBtn => 'Add Step';

  @override
  String get recipeCreatedSuccess => 'Recipe created successfully! 🎉';

  @override
  String get databaseResetSuccess =>
      'Database reset to Indian & world recipes successfully! 🎉';

  @override
  String get notes => 'Notes';

  @override
  String get myNotes => 'My Notes';

  @override
  String get notesSubtitle => 'Save your cooking ideas and kitchen reminders';

  @override
  String get addNote => 'Add Note';

  @override
  String get newNote => 'New Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get deleteNoteConfirm => 'Are you sure you want to delete this note?';

  @override
  String get searchNotesHint => 'Search notes by title, content, tag...';

  @override
  String get noNotesTitle => 'No notes yet';

  @override
  String get noNotesDesc =>
      'Save recipe ideas, kitchen tips, and reminders here.';

  @override
  String get createFirstNote => 'Create First Note';

  @override
  String get noteTitle => 'Note Title';

  @override
  String get noteTitleHint => 'e.g., Ideas for Sunday Breakfast';

  @override
  String get noteTitleRequired => 'Please enter a note title';

  @override
  String get noteContent => 'Note Content';

  @override
  String get noteContentHint =>
      'Write your thoughts, tips, or ingredient reminders...';

  @override
  String get category => 'Category';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHint => 'e.g., Breakfast, South Indian (comma separated)';

  @override
  String get pinned => 'Pinned';

  @override
  String get unpin => 'Unpin';

  @override
  String get pin => 'Pin';

  @override
  String get favorite => 'Favorite';

  @override
  String get relatedRecipe => 'Related Recipe';

  @override
  String get selectRecipe => 'Select Recipe (Optional)';

  @override
  String get noRecipeSelected => 'None (No recipe linked)';

  @override
  String get allNotes => 'All Notes';

  @override
  String get sortNotes => 'Sort Notes';

  @override
  String get sortNewest => 'Newest First';

  @override
  String get sortOldest => 'Oldest First';

  @override
  String get sortAlpha => 'A-Z';

  @override
  String get sortPinned => 'Pinned First';

  @override
  String get noteSavedSuccess => 'Note saved successfully! 📝';

  @override
  String get noteDeletedSuccess => 'Note deleted successfully!';

  @override
  String get catRecipeIdea => 'Recipe Idea';

  @override
  String get catShoppingReminder => 'Shopping Reminder';

  @override
  String get catMealPlan => 'Meal Plan';

  @override
  String get catKitchenTip => 'Kitchen Tip';

  @override
  String get catIngredientNote => 'Ingredient Note';

  @override
  String get catMalnadRecipe => 'Malnad Recipe';

  @override
  String get catPersonalNote => 'Personal Note';

  @override
  String get catOther => 'Other';

  @override
  String get shareRecipe => 'Share Recipe';

  @override
  String get shareToWhatsApp => 'Share on WhatsApp';

  @override
  String get shareMoreOptions => 'More Sharing Options';

  @override
  String get copyRecipeText => 'Copy Recipe Text';

  @override
  String get recipeCopiedToClipboard => 'Recipe copied to clipboard! 📋';

  @override
  String get shareRecipeSubtitle =>
      'Share this delicious dish with family & friends on WhatsApp';

  @override
  String get shareApp => 'Share Food CHART App';

  @override
  String get shareAppSubtitle =>
      'Share via WhatsApp, Quick Share, Bluetooth & more';

  @override
  String get shareAppQuickShareBluetooth => 'Quick Share, Bluetooth & More';

  @override
  String get shareAppLinkCopied =>
      'Food CHART app link copied to clipboard! 📋';
}
