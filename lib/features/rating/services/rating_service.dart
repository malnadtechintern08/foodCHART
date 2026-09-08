import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/router/app_router.dart';
import '../presentation/widgets/rating_popup_dialog.dart';

class RatingService {
  RatingService({
    InAppReview? inAppReview,
    SharedPreferences? prefs,
  })  : _inAppReview = inAppReview ?? InAppReview.instance,
        _injectedPrefs = prefs;

  static RatingService? _instance;
  static RatingService get instance => _instance ??= RatingService();

  @visibleForTesting
  static void setMockInstance(RatingService? mockInstance) {
    _instance = mockInstance;
  }

  final InAppReview _inAppReview;
  final SharedPreferences? _injectedPrefs;

  // SharedPreferences Keys
  static const String keyHasSeenRatingPopup = 'hasSeenRatingPopup';
  static const String keyHasRatedCookMate = 'hasRatedCookMate';
  static const String keyRatingPopupLastShown = 'ratingPopupLastShown';
  static const String keyMeaningfulActionCount = 'meaningfulActionCount';
  static const String keyUserRatedStars = 'userRatedStars';

  // In-memory Session & Collision Controls
  bool _popupShownThisSession = false;
  bool isDialogShowing = false;

  bool get popupShownThisSession => _popupShownThisSession;

  @visibleForTesting
  void resetSessionState() {
    _popupShownThisSession = false;
    isDialogShowing = false;
  }

  void markPopupShownThisSession() {
    _popupShownThisSession = true;
  }

  Future<SharedPreferences> get _prefs async {
    if (_injectedPrefs != null) return _injectedPrefs;
    return await SharedPreferences.getInstance();
  }

  /// Increments user action counter (e.g. completed recipe, saved recipe, favorite toggle).
  Future<int> recordMeaningfulAction() async {
    final prefs = await _prefs;
    final current = prefs.getInt(keyMeaningfulActionCount) ?? 0;
    final updated = current + 1;
    await prefs.setInt(keyMeaningfulActionCount, updated);
    return updated;
  }

  /// Determines whether the automatic rating popup should be politely displayed.
  /// 
  /// Checks:
  /// 1. Not currently showing any dialog.
  /// 2. Not already shown in this app session (unless [ignoreSession] is true).
  /// 3. User has NOT already permanently rated on Play Store (`hasRatedCookMate == false`).
  /// 4. User has NOT already responded (`hasSeenRatingPopup == false`).
  /// 5. User has completed at least [actionThreshold] actions.
  /// 6. At least [cooldownDays] have elapsed since last prompt.
  Future<bool> shouldShowAutomaticRatingPopup({
    int actionThreshold = 3,
    int cooldownDays = 7,
    bool ignoreSession = false,
  }) async {
    return canShowAutomaticPopup(
      actionThreshold: actionThreshold,
      cooldownDays: cooldownDays,
      ignoreSession: ignoreSession,
    );
  }

  /// Evaluates all conditions required to show an automatic rating popup.
  Future<bool> canShowAutomaticPopup({
    int actionThreshold = 0,
    int cooldownDays = 7,
    bool ignoreSession = false,
  }) async {
    if (isDialogShowing) return false;
    if (!ignoreSession && _popupShownThisSession) return false;

    final prefs = await _prefs;
    final hasRated = prefs.getBool(keyHasRatedCookMate) ?? false;
    if (hasRated) return false;

    final hasSeen = prefs.getBool(keyHasSeenRatingPopup) ?? false;
    if (hasSeen) return false;

    if (actionThreshold > 0) {
      final actionCount = prefs.getInt(keyMeaningfulActionCount) ?? 0;
      if (actionCount < actionThreshold) return false;
    }

    final lastShownStr = prefs.getString(keyRatingPopupLastShown);
    if (lastShownStr != null) {
      final lastShown = DateTime.tryParse(lastShownStr);
      if (lastShown != null) {
        final daysSinceLast = DateTime.now().difference(lastShown).inDays;
        if (daysSinceLast < cooldownDays) {
          return false;
        }
      }
    }

    return true;
  }

  /// Records that the popup was presented to the user.
  Future<void> recordPopupShown() async {
    _popupShownThisSession = true;
    final prefs = await _prefs;
    await prefs.setString(keyRatingPopupLastShown, DateTime.now().toIso8601String());
  }

  /// Records that the user has rated or submitted feedback.
  Future<void> recordRatingSubmitted(int stars) async {
    _popupShownThisSession = true;
    final prefs = await _prefs;
    await prefs.setBool(keyHasSeenRatingPopup, true);
    if (stars >= 4) {
      // User chose 4 or 5 stars to rate on Play Store
      await prefs.setBool(keyHasRatedCookMate, true);
    }
    await prefs.setInt(keyUserRatedStars, stars);
    await prefs.setString(keyRatingPopupLastShown, DateTime.now().toIso8601String());
  }

  /// Records that the user selected "Maybe Later".
  Future<void> recordDismissed() async {
    _popupShownThisSession = true;
    final prefs = await _prefs;
    await prefs.setString(keyRatingPopupLastShown, DateTime.now().toIso8601String());
  }

  /// Trigger 1: After a recipe has been successfully uploaded/submitted.
  /// 
  /// Waits 1.5 seconds following the confirmation message, then checks
  /// conditions before presenting the rating popup.
  Future<void> triggerPostUploadRating(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!context.mounted) return;

    final canShow = await canShowAutomaticPopup(actionThreshold: 0, cooldownDays: 5);
    if (!canShow) return;

    if (context.mounted) {
      await showCookMateRatingPopup(context, isManual: false, ratingService: this);
    }
  }

  /// Trigger 2: When the user navigates one step back after completing an
  /// important recipe activity (e.g. Recipe Detail view, Cooking Mode, Recipe Submit).
  ///
  /// Waits 400ms for screen pop transition to complete, then uses the active
  /// root navigator context to present the popup if conditions are met.
  Future<void> triggerBackNavigationRating() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final canShow = await canShowAutomaticPopup(actionThreshold: 0, cooldownDays: 5);
    if (!canShow) return;

    final navContext = AppRouter.rootNavigatorKey.currentContext;
    if (navContext != null && navContext.mounted) {
      await showCookMateRatingPopup(navContext, isManual: false, ratingService: this);
    }
  }

  /// Attempts to open Google Play Store listing via in_app_review.
  /// Returns `true` on success, `false` on failure.
  Future<bool> openPlayStoreReview({String appPackageName = 'com.food.chart'}) async {
    try {
      await _inAppReview.openStoreListing(appStoreId: appPackageName);
      return true;
    } catch (e) {
      debugPrint('Error opening Play Store review: $e');
      return false;
    }
  }

  /// Checks if user has already rated on Play Store or permanently responded.
  Future<bool> hasResponded() async {
    final prefs = await _prefs;
    return (prefs.getBool(keyHasRatedCookMate) ?? false) ||
        (prefs.getBool(keyHasSeenRatingPopup) ?? false);
  }

  /// Checks specifically if the user has rated on Play Store.
  Future<bool> hasRated() async {
    final prefs = await _prefs;
    return prefs.getBool(keyHasRatedCookMate) ?? false;
  }

  /// Resets rating state (useful for diagnostics or testing).
  Future<void> resetRatingState() async {
    _popupShownThisSession = false;
    isDialogShowing = false;
    final prefs = await _prefs;
    await prefs.remove(keyHasSeenRatingPopup);
    await prefs.remove(keyHasRatedCookMate);
    await prefs.remove(keyRatingPopupLastShown);
    await prefs.remove(keyMeaningfulActionCount);
    await prefs.remove(keyUserRatedStars);
  }
}
