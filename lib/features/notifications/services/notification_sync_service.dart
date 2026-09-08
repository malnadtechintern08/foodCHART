import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import '../data/datasources/notification_remote_datasource.dart';
import '../presentation/providers/notification_providers.dart';
import 'cookmate_notification_service.dart';

const String kCookMatePeriodicNotificationTask = 'cookmate_periodic_notification_sync';

/// Background task dispatcher executed by WorkManager when CookMate is closed.
@pragma('vm:entry-point')
void notificationWorkManagerDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final notifService = CookMateNotificationService.instance;
      await notifService.init(requestPermission: false);

      final dataSource = NotificationRemoteDataSourceImpl();
      final notifications = await dataSource.getNotifications(page: 1, limit: 10);

      for (final n in notifications) {
        if (!n.isRead && !notifService.shownNotificationIds.contains(n.id)) {
          await notifService.showHeadsUpNotification(n);
        }
      }
      return true;
    } catch (_) {
      return true;
    }
  });
}

class NotificationSyncService with WidgetsBindingObserver {
  NotificationSyncService._();
  static final NotificationSyncService instance = NotificationSyncService._();

  Timer? _pollingTimer;
  NotificationRemoteDataSource? _remoteDataSource;
  WidgetRef? _ref;
  bool _isStarted = false;

  /// Starts foreground sync and registers WorkManager for closed-app notifications.
  Future<void> start({
    NotificationRemoteDataSource? remoteDataSource,
    WidgetRef? ref,
    bool enableWorkmanager = true,
  }) async {
    if (_isStarted) return;
    _isStarted = true;

    _remoteDataSource = remoteDataSource ?? NotificationRemoteDataSourceImpl();
    _ref = ref;

    WidgetsBinding.instance.addObserver(this);

    // Initial check
    await syncNotifications();

    // Foreground periodic polling (every 30 seconds)
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      syncNotifications();
    });

    // Register Android WorkManager for closed-app execution
    if (enableWorkmanager) {
      try {
        await Workmanager().initialize(
          notificationWorkManagerDispatcher,
        );

        await Workmanager().registerPeriodicTask(
          kCookMatePeriodicNotificationTask,
          kCookMatePeriodicNotificationTask,
          frequency: const Duration(minutes: 15), // Android minimum periodic interval
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        );
      } catch (_) {}
    }
  }

  void updateRef(WidgetRef ref) {
    _ref = ref;
  }

  /// Immediately synchronizes notifications and triggers heads-up popups for any new items.
  Future<void> syncNotifications() async {
    try {
      final ds = _remoteDataSource ?? NotificationRemoteDataSourceImpl();
      final notifService = CookMateNotificationService.instance;

      final notifications = await ds.getNotifications(page: 1, limit: 10);
      int unreadCount = 0;

      for (final n in notifications) {
        if (!n.isRead) {
          unreadCount++;
          // Trigger Heads-Up Notification if not previously shown
          if (!notifService.shownNotificationIds.contains(n.id)) {
            await notifService.showHeadsUpNotification(n);
          }
        }
      }

      // Update in-app badge count
      if (_ref != null) {
        try {
          _ref!.read(unreadNotificationCountProvider.notifier).setCount(unreadCount);
        } catch (_) {}
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User brought app back to foreground -> check immediately!
      syncNotifications();
    }
  }

  /// Disposes polling timers and observers.
  void stop() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    _isStarted = false;
  }
}
