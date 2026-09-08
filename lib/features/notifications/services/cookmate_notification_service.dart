import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/router/app_router.dart';
import '../../../app/router/route_names.dart';
import '../../../app/router/route_paths.dart';
import '../data/models/notification_model.dart';

/// Top-level background notification tap handler required by flutter_local_notifications
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Handled on app launch via CookMateNotificationService.handleLaunchDetails
}

class CookMateNotificationService {
  CookMateNotificationService._();
  static final CookMateNotificationService instance = CookMateNotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String channelId = 'cookmate_notifications';
  static const String channelName = 'Food CHART Notifications';
  static const String channelDescription =
      'High-priority Food CHART updates, recipe approvals, and culinary announcements';

  static const String keyShownIds = 'cookmate_shown_notification_ids';
  static const String keyPermissionRequested = 'cookmate_notification_permission_requested';

  final Set<int> _shownNotificationIds = {};
  bool _isInitialized = false;

  FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;
  Set<int> get shownNotificationIds => Set.unmodifiable(_shownNotificationIds);

  /// Initializes the local notification plugin, high-priority Android channel,
  /// and tap callbacks.
  Future<void> init({bool requestPermission = true}) async {
    if (_isInitialized) return;

    await _loadShownNotificationIds();

    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Darwin (iOS / macOS) settings
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: requestPermission,
      requestBadgePermission: requestPermission,
      requestSoundPermission: requestPermission,
    );

    // Linux settings
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open Food CHART',
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Create high-priority notification channel for Android
    if (Platform.isAndroid) {
      await _createAndroidChannel();
      if (requestPermission) {
        await requestPermissionsOnce();
      }
    }

    _isInitialized = true;

    // Check if app was launched by tapping a notification while terminated
    await checkLaunchDetails();
  }

  /// Creates the high-importance notification channel on Android for heads-up banners.
  Future<void> _createAndroidChannel() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max, // Enables Heads-Up Banner on Android!
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
        showBadge: true,
      );

      await androidPlugin.createNotificationChannel(channel);
    }
  }

  /// Requests notification permission on Android 13+ (API 33+) once without repeatedly nagging.
  Future<bool> requestPermissionsOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyRequested = prefs.getBool(keyPermissionRequested) ?? false;

      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        final areEnabled = await androidPlugin.areNotificationsEnabled() ?? false;
        if (areEnabled) {
          return true;
        }

        if (!alreadyRequested) {
          await prefs.setBool(keyPermissionRequested, true);
          final granted = await androidPlugin.requestNotificationsPermission() ?? false;
          return granted;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Loads cached notification IDs to prevent duplicate notifications.
  Future<void> _loadShownNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(keyShownIds) ?? [];
      _shownNotificationIds.clear();
      for (final idStr in list) {
        final id = int.tryParse(idStr);
        if (id != null) {
          _shownNotificationIds.add(id);
        }
      }
    } catch (_) {}
  }

  /// Saves shown notification IDs into persistent storage.
  Future<void> _saveShownNotificationIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep up to 200 recent IDs to avoid infinite growth
      final recentIds = _shownNotificationIds.toList();
      if (recentIds.length > 200) {
        recentIds.removeRange(0, recentIds.length - 200);
      }
      await prefs.setStringList(
        keyShownIds,
        recentIds.map((id) => id.toString()).toList(),
      );
    } catch (_) {}
  }

  /// Shows an Instagram/WhatsApp style Heads-Up popup notification on Android.
  ///
  /// Guarantees that:
  /// - A notification ID is shown at most once (no duplicate spam).
  /// - Heads-up banner pops at top of phone with sound & vibration.
  /// - Notification stays in drawer until clicked or dismissed.
  Future<bool> showHeadsUpNotification(NotificationModel notification) async {
    // 1. Anti-duplicate safeguard
    if (_shownNotificationIds.contains(notification.id)) {
      return false;
    }

    _shownNotificationIds.add(notification.id);
    await _saveShownNotificationIds();

    final payload = json.encode({
      'notification_id': notification.id,
      'type': notification.type.dbValue,
      'related_type': notification.relatedType,
      'related_id': notification.relatedId,
      'title': notification.title,
      'message': notification.message,
    });

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max, // High-priority popup banner
      priority: Priority.high, // Heads-up display
      ticker: 'Food CHART Notification',
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFE50914), // Food CHART Brand Crimson Red
      styleInformation: BigTextStyleInformation(
        notification.message,
        contentTitle: notification.title,
        summaryText: 'Food CHART 🍳',
        htmlFormatContent: false,
        htmlFormatContentTitle: false,
      ),
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      fullScreenIntent: false,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: notification.id,
      title: notification.title,
      body: notification.message,
      notificationDetails: details,
      payload: payload,
    );

    return true;
  }

  /// Trigger a live heads-up notification for immediate test / demonstration.
  Future<void> showTestNotification({
    String title = 'Food CHART 🍳',
    String message = 'Your recipe "Masala Dosa" was approved! ✅',
  }) async {
    final testId = DateTime.now().millisecondsSinceEpoch % 100000;

    final payload = json.encode({
      'notification_id': testId,
      'type': 'recipe_approved',
      'related_type': 'recipe',
      'related_id': 'recipe_masala_dosa',
      'title': title,
      'message': message,
    });

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Food CHART Test',
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFE50914),
      styleInformation: BigTextStyleInformation(
        message,
        contentTitle: title,
        summaryText: 'Food CHART 🍳',
      ),
      category: AndroidNotificationCategory.status,
      visibility: NotificationVisibility.public,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: testId,
      title: title,
      body: message,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Checks if the app was launched by tapping an OS notification from terminated state.
  Future<void> checkLaunchDetails() async {
    try {
      final details = await _notificationsPlugin.getNotificationAppLaunchDetails();
      if (details != null && details.didNotificationLaunchApp) {
        final payload = details.notificationResponse?.payload;
        if (payload != null && payload.isNotEmpty) {
          // Delay briefly to allow router initialization
          Future.delayed(const Duration(milliseconds: 600), () {
            _handleNotificationTap(payload);
          });
        }
      }
    } catch (_) {}
  }

  DateTime? _lastNotificationTapTime;

  /// Handles notification click and navigates to the appropriate screen.
  void _handleNotificationTap(String? payloadStr) {
    final now = DateTime.now();
    if (_lastNotificationTapTime != null && now.difference(_lastNotificationTapTime!).inMilliseconds < 800) {
      return; // Debounce rapid multi-triggers
    }
    _lastNotificationTapTime = now;

    if (payloadStr == null || payloadStr.isEmpty) {
      _safeNavigateToNotifications();
      return;
    }

    try {
      final payload = json.decode(payloadStr) as Map<String, dynamic>;
      final type = payload['type']?.toString();
      final relatedType = payload['related_type']?.toString();
      final relatedId = payload['related_id']?.toString();
      final notifId = payload['notification_id'];

      if (relatedType == 'recipe' && relatedId != null && relatedId.isNotEmpty) {
        _safeNavigateToRecipe(relatedId);
        return;
      }

      if (type == 'recipe_approved') {
        if (relatedId != null && relatedId.isNotEmpty) {
          _safeNavigateToRecipe(relatedId);
        } else {
          _safeNavigateToSubmissions();
        }
        return;
      }

      if (type == 'new_recipe' && relatedId != null && relatedId.isNotEmpty) {
        _safeNavigateToRecipe(relatedId);
        return;
      }

      if (notifId != null && notifId is int) {
        _safeNavigateToNotificationDetail(notifId);
        return;
      }

      // Default route
      _safeNavigateToNotifications();
    } catch (_) {
      _safeNavigateToNotifications();
    }
  }

  void _safeNavigateToNotifications() {
    try {
      final currentLoc = AppRouter.router.routerDelegate.currentConfiguration.uri.path;
      if (currentLoc == RoutePaths.notifications) return;
      AppRouter.router.pushNamed(RouteNames.notifications);
    } catch (_) {
      try {
        AppRouter.router.pushNamed(RouteNames.notifications);
      } catch (_) {}
    }
  }

  void _safeNavigateToRecipe(String recipeId) {
    try {
      final currentLoc = AppRouter.router.routerDelegate.currentConfiguration.uri.path;
      if (currentLoc == '/recipe/$recipeId') return;
      AppRouter.router.push('/recipe/$recipeId');
    } catch (_) {
      try {
        AppRouter.router.push('/recipe/$recipeId');
      } catch (_) {}
    }
  }

  void _safeNavigateToNotificationDetail(int notifId) {
    try {
      final currentLoc = AppRouter.router.routerDelegate.currentConfiguration.uri.path;
      if (currentLoc == '/notification/$notifId') return;
      AppRouter.router.push('/notification/$notifId');
    } catch (_) {
      try {
        AppRouter.router.push('/notification/$notifId');
      } catch (_) {}
    }
  }

  void _safeNavigateToSubmissions() {
    try {
      final currentLoc = AppRouter.router.routerDelegate.currentConfiguration.uri.path;
      if (currentLoc == RoutePaths.mySubmissions) return;
      AppRouter.router.pushNamed(RouteNames.mySubmissions);
    } catch (_) {
      try {
        AppRouter.router.pushNamed(RouteNames.mySubmissions);
      } catch (_) {}
    }
  }

  /// Resets de-duplication cache (useful for testing).
  void clearShownCache() {
    _shownNotificationIds.clear();
  }
}
