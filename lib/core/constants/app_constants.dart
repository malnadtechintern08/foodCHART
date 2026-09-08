class AppConstants {
  static const String appName = 'Food CHART';
  static const String appTagline = 'Your Personal Kitchen Companion';
  static const String dbName = 'cookmate.db';
  static const int dbVersion = 6;


  // Shared Preferences Keys
  static const String keyThemeMode = 'cookmate_theme_mode';
  static const String keyFirstLaunch = 'cookmate_first_launch_done';
  static const String keyDefaultServings = 'cookmate_default_servings';
  static const String keyLanguageCode = 'cookmate_language_code';
  static const String keyRecentlyViewed = 'cookmate_recently_viewed_recipes';
  static const String keyShoppingList = 'cookmate_shopping_list_items';

  // Recipe Difficulty Levels
  static const String difficultyEasy = 'Easy';
  static const String difficultyMedium = 'Medium';
  static const String difficultyHard = 'Hard';

  // Quick Launch Filter threshold
  static const int quickLaunchMaxMinutes = 30;
  static const int maxRecentlyViewed = 10;

  // Live Backend Server API Configuration
  static const String apiBaseUrl = 'https://foodchart.free.nf';
  static const String apiRecipesEndpoint = '$apiBaseUrl/api/recipes.php';
  static const String apiCategoriesEndpoint = '$apiBaseUrl/api/categories.php';
  static const String apiTagsPopularEndpoint = '$apiBaseUrl/api/tags/popular.php';
  static const String apiTagsSearchEndpoint = '$apiBaseUrl/api/tags/search.php';
  static const String apiTagsRecipesEndpoint = '$apiBaseUrl/api/tags/recipes.php';
  static const String apiSearchEndpoint = '$apiBaseUrl/api/search.php';
  static const String keyRecentSearches = 'cookmate_recent_searches';
  static const String keyUserAuthToken = 'cookmate_user_auth_token';
  static const String keyUserDisplayName = 'cookmate_user_display_name';

  // Submissions & Moderation APIs
  static const String apiSessionEndpoint = '$apiBaseUrl/api/auth/session.php';
  static const String apiSubmissionsCreateEndpoint = '$apiBaseUrl/api/recipe-submissions/create.php';
  static const String apiSubmissionsMyEndpoint = '$apiBaseUrl/api/recipe-submissions/my-submissions.php';
  static const String apiSubmissionsDetailsEndpoint = '$apiBaseUrl/api/recipe-submissions/details.php';
  static const String apiSubmissionsUpdateEndpoint = '$apiBaseUrl/api/recipe-submissions/update.php';
  static const String apiSubmissionsWithdrawEndpoint = '$apiBaseUrl/api/recipe-submissions/withdraw.php';

  // Notifications APIs
  static const String apiNotificationsEndpoint = '$apiBaseUrl/api/notifications/index.php';
  static const String apiNotificationsUnreadCountEndpoint = '$apiBaseUrl/api/notifications/unread-count.php';
  static const String apiNotificationsMarkReadEndpoint = '$apiBaseUrl/api/notifications/mark-read.php';
  static const String apiNotificationsMarkAllReadEndpoint = '$apiBaseUrl/api/notifications/mark-all-read.php';
  static const String apiNotificationsMarkUnreadEndpoint = '$apiBaseUrl/api/notifications/mark-unread.php';
  static const String apiNotificationsDetailsEndpoint = '$apiBaseUrl/api/notifications/details.php';
  static const String apiNotificationsDeleteEndpoint = '$apiBaseUrl/api/notifications/delete.php';

  // Support, FAQs & Policy APIs
  static const String apiSupportPageEndpoint = '$apiBaseUrl/api/support/page.php';
  static const String apiFaqsEndpoint = '$apiBaseUrl/api/support/faqs.php';
  static const String apiContactSubmitEndpoint = '$apiBaseUrl/api/support/contact.php';
  static const String apiRatingsSubmitEndpoint = '$apiBaseUrl/api/ratings/submit.php';
}
