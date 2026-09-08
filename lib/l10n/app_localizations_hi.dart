// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Food CHART';

  @override
  String get appTagline => 'आपका ऑफलाइन मास्टर कुकिंग साथी';

  @override
  String get navHome => 'होम';

  @override
  String get navExplore => 'खोजें';

  @override
  String get navFavorites => 'पसंदीदा';

  @override
  String get navShopping => 'खरीदारी';

  @override
  String get navMore => 'अधिक';

  @override
  String get navMyKitchen => 'मेरी रसोई';

  @override
  String get whatsCookingToday => 'आज क्या बनाना है?';

  @override
  String get searchHint => 'रेसिपी, चाय, बिरयानी, डोसा खोजें...';

  @override
  String get chefSpotlight => 'शेफ की पसंद';

  @override
  String get quickLaunch => 'झटपट रेसिपी (< 25 मिनट)';

  @override
  String get fastAndDelicious => 'तेज़ और स्वादिष्ट';

  @override
  String get exploreCuisines => 'भारतीय व्यंजन और पेय';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get tasteOfMalnad => 'मलनाड का स्वाद';

  @override
  String get tasteOfMalnadSpecial => '🌿 मलनाड स्पेशल रेसिपी';

  @override
  String get malnadHeritageBannerSub => 'पश्चिमी घाट की 50 पारंपरिक रेसिपी';

  @override
  String get popularRecipes => 'लोकप्रिय रेसिपी';

  @override
  String get quickRecipes => 'झटपट रेसिपी';

  @override
  String get healthyRecipes => 'स्वास्थ्यवर्धक रेसिपी';

  @override
  String get recentlyViewed => 'हाल ही में देखी गई';

  @override
  String get allRecipes => 'सभी रेसिपी';

  @override
  String get categoryAll => 'सभी';

  @override
  String get categoryMalnadSpecial => 'मलनाड विशेष';

  @override
  String get categoryBreakfast => 'नाश्ता';

  @override
  String get categoryLunch => 'दोपहर का खाना';

  @override
  String get categoryDinner => 'रात का खाना';

  @override
  String get categorySnacks => 'स्नैक्स';

  @override
  String get categoryDesserts => 'मिठाइयाँ';

  @override
  String get categoryDrinks => 'पेय';

  @override
  String get categoryHealthy => 'स्वास्थ्यवर्धक';

  @override
  String get categoryVegetarian => 'शाकाहारी';

  @override
  String get categoryNonVeg => 'मांसाहारी';

  @override
  String get categoryLunchDinner => 'दोपहर व रात का खाना';

  @override
  String get veg => 'शाकाहारी';

  @override
  String get nonVeg => 'मांसाहारी';

  @override
  String get prepTime => 'तैयारी का समय';

  @override
  String get cookTime => 'पकाने का समय';

  @override
  String get totalTime => 'कुल समय';

  @override
  String get servings => 'लोगों के लिए';

  @override
  String servingsCount(int count) {
    return '$count लोगों के लिए';
  }

  @override
  String get difficulty => 'कठिनाई';

  @override
  String get easy => 'सरल';

  @override
  String get medium => 'मध्यम';

  @override
  String get hard => 'कठिन';

  @override
  String get rating => 'रेटिंग';

  @override
  String recipesCount(int count) {
    return '$count रेसिपी';
  }

  @override
  String itemsNeeded(int count) {
    return '$count सामग्री चाहिए';
  }

  @override
  String get aboutDish => 'व्यंजन के बारे में';

  @override
  String get addIngredientsToShopping =>
      '🛒 सामग्री को खरीदारी सूची में जोड़ें';

  @override
  String get ingredients => 'सामग्री';

  @override
  String get instructions => 'बनाने की विधि';

  @override
  String get instructionsOverview => 'विधि विवरण';

  @override
  String get startCooking => 'कुकिंग मोड शुरू करें';

  @override
  String get deleteRecipeTitle => 'रेसिपी हटाएं?';

  @override
  String deleteRecipeConfirm(String title) {
    return 'क्या आप \"$title\" को हटाना चाहते हैं? इसे वापस नहीं लाया जा सकता।';
  }

  @override
  String get delete => 'हटाएं';

  @override
  String get cancel => 'रद्द करें';

  @override
  String addedToShoppingSnackBar(int count) {
    return '$count सामग्री खरीदारी सूची में जोड़ी गई! 🛒';
  }

  @override
  String get view => 'देखें';

  @override
  String get recipeNotFound => 'रेसिपी नहीं मिली';

  @override
  String get recipeNotFoundDesc => 'यह रेसिपी शायद हटा दी गई है।';

  @override
  String stepOf(int current, int total) {
    return 'चरण $current / $total';
  }

  @override
  String get markDone => 'पूरा हुआ चिह्नित करें';

  @override
  String get done => 'पूर्ण';

  @override
  String get start => 'शुरू करें';

  @override
  String get pause => 'रोकें';

  @override
  String get restart => 'पुनः शुरू करें';

  @override
  String get previous => 'पिछला';

  @override
  String get nextStep => 'अगला चरण';

  @override
  String get finishCooking => 'कुकिंग समाप्त करें 🥳';

  @override
  String get bonAppetit => 'स्वाद का आनंद लें! 🎉';

  @override
  String get celebrationSub =>
      'आपने इस व्यंजन को सफलतापूर्वक तैयार किया है। परोसें और आनंद लें!';

  @override
  String get backToDetails => 'विवरण पर वापस जाएं';

  @override
  String get exit => 'बाहर निकलें';

  @override
  String get shoppingList => 'खरीदारी सूची';

  @override
  String get addItem => 'सामग्री जोड़ें';

  @override
  String get addGroceryItem => 'किराना सामान जोड़ें';

  @override
  String get itemName => 'सामान का नाम';

  @override
  String get itemNameHint => 'जैसे: बासमती चावल, घी';

  @override
  String get qty => 'मात्रा';

  @override
  String get unit => 'इकाई';

  @override
  String get unitHint => 'किलो / गुच्छा / कप';

  @override
  String get add => 'जोड़ें';

  @override
  String get clearDone => 'पूर्ण सामान हटाएं';

  @override
  String get clearAll => 'सभी हटाएं';

  @override
  String get toBuy => 'खरीदने के लिए';

  @override
  String get completed => 'खरीदा गया';

  @override
  String itemsToBuy(int count) {
    return '$count सामान खरीदना है';
  }

  @override
  String purchasedCount(int purchased, int total) {
    return '$total में से $purchased खरीदा गया';
  }

  @override
  String get emptyShoppingTitle => 'आपकी खरीदारी सूची खाली है';

  @override
  String get emptyShoppingDesc =>
      'किसी भी रेसिपी से सामग्री जोड़ें या नया सामान दर्ज करें।';

  @override
  String get addFirstItem => 'पहला सामान जोड़ें';

  @override
  String get quantity => 'मात्रा';

  @override
  String get customItem => 'कस्टम सामान';

  @override
  String get myKitchenTitle => 'मेरी रसोई और अन्य';

  @override
  String get myRecipes => 'मेरी रेसिपी';

  @override
  String get favorites => 'पसंदीदा';

  @override
  String get shopping => 'खरीदारी';

  @override
  String get cookingHistory => 'कुकिंग इतिहास';

  @override
  String get addRecipe => 'रेसिपी जोड़ें';

  @override
  String get myCreatedRecipes => 'मेरी बनाई गई रेसिपी';

  @override
  String get noCustomTitle => 'अभी कोई कस्टम रेसिपी नहीं है';

  @override
  String get noCustomDesc =>
      'अपनी गुप्त पारिवारिक रेसिपी और नोट्स यहाँ सुरक्षित रखें।';

  @override
  String get createNewRecipe => 'नई रेसिपी बनाएं';

  @override
  String get noRecentTitle => 'हाल ही में कोई रेसिपी नहीं देखी गई';

  @override
  String get noRecentDesc =>
      'हमारी 200+ रेसिपी देखें, आपका इतिहास यहाँ दिखाई देगा।';

  @override
  String get favoriteRecipes => 'पसंदीदा रेसिपी';

  @override
  String get noFavoritesTitle => 'अभी कोई पसंदीदा रेसिपी नहीं है';

  @override
  String get noFavoritesDesc =>
      'अपनी पसंद की रेसिपी सेव करें, वे यहाँ दिखाई देंगी।';

  @override
  String get exploreRecipesBtn => 'रेसिपी खोजें';

  @override
  String get exploreRecipesTitle => 'रेसिपी खोजें';

  @override
  String get tagTrending => 'ट्रेंडिंग';

  @override
  String get tagUnder20m => '20 मिनट से कम';

  @override
  String get tagMalnadHeritage => 'मलनाड धरोहर';

  @override
  String get tagBreakfastHits => 'नाश्ता हिट्स';

  @override
  String get tagBiryaniRice => 'बिरयानी व चावल';

  @override
  String get tagHealthyChoice => 'हेल्दी चॉइस';

  @override
  String get malnadTitle => 'मलनाड का स्वाद';

  @override
  String get malnadHeritageTag => 'पश्चिमी घाट की पारंपरिक खान-पान धरोहर';

  @override
  String get malnadSub => 'कर्नाटक के पश्चिमी घाट के पारंपरिक स्वाद';

  @override
  String get subcatAll => 'सभी मलनाड';

  @override
  String get subcatBreads => 'पारंपरिक रोटियां';

  @override
  String get subcatCurries => 'सब्जी व सांभर';

  @override
  String get subcatRice => 'चावल के व्यंजन';

  @override
  String get subcatSnacks => 'स्नैक्स व कडुबू';

  @override
  String get subcatChutneys => 'चटनी व तंबुली';

  @override
  String get subcatDrinks => 'काढ़ा व मिठाइयाँ';

  @override
  String get filterRecipes => 'फ़िल्टर करें';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get reset => 'रीसेट';

  @override
  String get applyFilters => 'लागू करें';

  @override
  String get difficultyLabel => 'कठिनाई';

  @override
  String get maxTimeLabel => 'अधिकतम समय';

  @override
  String get categoryLabel => 'श्रेणी';

  @override
  String get anyTime => 'कोई भी समय';

  @override
  String get under15m => '⚡ 15 मिनट से कम';

  @override
  String get under30m => '🕒 30 मिनट से कम';

  @override
  String get under60m => '🍲 60 मिनट से कम';

  @override
  String get allCategories => 'सभी श्रेणियां';

  @override
  String get noMatchingTitle => 'कोई मेल खाती रेसिपी नहीं मिली';

  @override
  String get noMatchingDesc =>
      'सर्च शब्द बदलें या फ़िल्टर साफ़ करके पुनः प्रयास करें।';

  @override
  String filterDifficulty(String diff) {
    return 'कठिनाई: $diff';
  }

  @override
  String filterMaxTime(int mins) {
    return 'समय: <$mins मिनट';
  }

  @override
  String get filterCategory => 'श्रेणी फ़िल्टर';

  @override
  String get clearAllFilters => 'सभी साफ़ करें';

  @override
  String get sortBy => 'क्रमबद्ध करें';

  @override
  String get highestRating => 'उच्चतम रेटिंग';

  @override
  String get lowestCookingTime => 'कम पकाने का समय';

  @override
  String get mostPopular => 'सबसे लोकप्रिय';

  @override
  String get settingsTitle => 'सेटिंग्स और प्राथमिकताएं';

  @override
  String get language => 'भाषा';

  @override
  String get currentLanguage => 'वर्तमान भाषा';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get theme => 'थीम';

  @override
  String get chooseTheme => 'थीम मोड चुनें';

  @override
  String get systemTheme => 'सिस्टम';

  @override
  String get lightTheme => 'लाइट मोड';

  @override
  String get darkTheme => 'डार्क मोड';

  @override
  String get offlineStorageTitle => 'ऑफलाइन स्टोरेज';

  @override
  String get offlineModeDesc =>
      '100% ऑफलाइन। सभी रेसिपी, ड्रिंक्स और टाइमर बिना इंटरनेट काम करते हैं।';

  @override
  String get resetCatalog => 'डेटाबेस रीसेट करें';

  @override
  String get resetCatalogDesc =>
      'मूल रेसिपी पुनः लोड करें। आपके नोट्स सुरक्षित रहेंगे।';

  @override
  String get resetConfirmTitle => 'रीसेट करें?';

  @override
  String get resetConfirmDesc =>
      'यह सभी डिफ़ॉल्ट रेसिपी को मूल स्थिति में ले आएगा।';

  @override
  String get about => 'परिचय';

  @override
  String get aboutCookMate => 'Food CHART के बारे में';

  @override
  String get versionText => 'संस्करण 2.0.0 • भारतीय पाक संस्करण';

  @override
  String get selectLanguageTitle => 'भाषा चुनें';

  @override
  String get english => 'English';

  @override
  String get kannada => 'ಕನ್ನಡ';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get newRecipeTitle => 'नई कस्टम रेसिपी ✍️';

  @override
  String get save => 'सेव करें';

  @override
  String get basicInfo => 'मूल जानकारी';

  @override
  String get recipeTitleLabel => 'रेसिपी का नाम *';

  @override
  String get recipeTitleHint => 'जैसे: दादी माँ का सांभर';

  @override
  String get recipeTitleReq => 'नाम आवश्यक है';

  @override
  String get descriptionLabel => 'विवरण';

  @override
  String get descriptionHint => 'स्वाद, इतिहास या खास बातें लिखें...';

  @override
  String get cuisineLabel => 'व्यंजन शैली';

  @override
  String get cuisineHint => 'जैसे: दक्षिण भारतीय, मलनाड';

  @override
  String get chefLabel => 'शेफ';

  @override
  String get chefHint => 'आपका नाम';

  @override
  String get imageUrlLabel => 'फोटो URL';

  @override
  String get categoryAndSpecs => 'श्रेणी और विवरण';

  @override
  String get prepTimeLabel => 'तैयारी का समय (मिनट)';

  @override
  String get cookTimeLabel => 'पकाने का समय (मिनट)';

  @override
  String get servingsLabel => 'लोगों के लिए';

  @override
  String get ingredientsSection => 'सामग्री';

  @override
  String get addItemBtn => 'सामान जोड़ें';

  @override
  String get instructionsSection => 'विधि';

  @override
  String get addStepBtn => 'चरण जोड़ें';

  @override
  String get recipeCreatedSuccess => 'व्यंजन सफलतापूर्वक बनाया गया! 🎉';

  @override
  String get databaseResetSuccess =>
      'डेटाबेस सफलतापूर्वक रीसेट कर दिया गया! 🎉';

  @override
  String get notes => 'नोट्स';

  @override
  String get myNotes => 'मेरे नोट्स';

  @override
  String get notesSubtitle =>
      'अपने खाना पकाने के विचार और रसोई के रिमाइंडर सहेजें';

  @override
  String get addNote => 'नोट जोड़ें';

  @override
  String get newNote => 'नया नोट';

  @override
  String get editNote => 'नोट संपादित करें';

  @override
  String get deleteNote => 'नोट हटाएं';

  @override
  String get deleteNoteConfirm => 'क्या आप वाकई इस नोट को हटाना चाहते हैं?';

  @override
  String get searchNotesHint => 'शीर्षक, सामग्री, टैग से खोजें...';

  @override
  String get noNotesTitle => 'अभी कोई नोट नहीं है';

  @override
  String get noNotesDesc =>
      'रेसिपी के विचार, रसोई के सुझाव और रिमाइंडर यहाँ सहेजें।';

  @override
  String get createFirstNote => 'पहला नोट बनाएं';

  @override
  String get noteTitle => 'नोट का शीर्षक';

  @override
  String get noteTitleHint => 'उदा: रविवार के नाश्ते के विचार';

  @override
  String get noteTitleRequired => 'कृपया नोट का शीर्षक दर्ज करें';

  @override
  String get noteContent => 'नोट की सामग्री';

  @override
  String get noteContentHint =>
      'अपने विचार, सुझाव या सामग्री के रिमाइंडर लिखें...';

  @override
  String get category => 'श्रेणी';

  @override
  String get tags => 'टैग';

  @override
  String get tagsHint => 'उदा: नाश्ता, दक्षिण भारतीय (अल्पविराम से अलग करें)';

  @override
  String get pinned => 'पिन किया गया';

  @override
  String get unpin => 'पिन हटाएं';

  @override
  String get pin => 'पिन करें';

  @override
  String get favorite => 'पसंदीदा';

  @override
  String get relatedRecipe => 'संबंधित रेसिपी';

  @override
  String get selectRecipe => 'रेसिपी चुनें (वैकल्पिक)';

  @override
  String get noRecipeSelected => 'कोई नहीं (जुड़ा नहीं है)';

  @override
  String get allNotes => 'सभी नोट्स';

  @override
  String get sortNotes => 'क्रमबद्ध करें';

  @override
  String get sortNewest => 'नवीनतम पहले';

  @override
  String get sortOldest => 'पुराना पहले';

  @override
  String get sortAlpha => 'A-Z';

  @override
  String get sortPinned => 'पिन किया पहले';

  @override
  String get noteSavedSuccess => 'नोट सफलतापूर्वक सहेजा गया! 📝';

  @override
  String get noteDeletedSuccess => 'नोट हटा दिया गया!';

  @override
  String get catRecipeIdea => 'रेसिपी विचार';

  @override
  String get catShoppingReminder => 'खरीदारी रिमाइंडर';

  @override
  String get catMealPlan => 'भोजन योजना';

  @override
  String get catKitchenTip => 'रसोई का सुझाव';

  @override
  String get catIngredientNote => 'सामग्री नोट';

  @override
  String get catMalnadRecipe => 'मलनाड रेसिपी';

  @override
  String get catPersonalNote => 'व्यक्तिगत नोट';

  @override
  String get catOther => 'अन्य';

  @override
  String get shareRecipe => 'रेसिपी शेयर करें';

  @override
  String get shareToWhatsApp => 'WhatsApp पर शेयर करें';

  @override
  String get shareMoreOptions => 'अन्य शेयर विकल्प';

  @override
  String get copyRecipeText => 'रेसिपी टेक्स्ट कॉपी करें';

  @override
  String get recipeCopiedToClipboard => 'रेसिपी क्लिपबोर्ड पर कॉपी की गई! 📋';

  @override
  String get shareRecipeSubtitle =>
      'इस स्वादिष्ट डिश को WhatsApp पर परिवार और दोस्तों के साथ शेयर करें';

  @override
  String get shareApp => 'Food CHART ऐप शेयर करें';

  @override
  String get shareAppSubtitle =>
      'WhatsApp, Quick Share, Bluetooth और अन्य माध्यमों से शेयर करें';

  @override
  String get shareAppQuickShareBluetooth => 'Quick Share, Bluetooth और अन्य';

  @override
  String get shareAppLinkCopied =>
      'Food CHART लिंक क्लिपबोर्ड पर कॉपी किया गया! 📋';
}
