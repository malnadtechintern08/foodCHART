import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';

// Data Source Provider
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSourceImpl();
});

// Repository Provider
final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  final remote = ref.watch(notificationRemoteDataSourceProvider);
  return NotificationRepositoryImpl(remote);
});

// Unread Count Notifier & Provider
final unreadNotificationCountProvider =
    StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return UnreadCountNotifier(repo);
});

class UnreadCountNotifier extends StateNotifier<int> {
  final NotificationRepository _repository;

  UnreadCountNotifier(this._repository) : super(0) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final count = await _repository.getUnreadCount();
      state = count;
    } catch (_) {}
  }

  void setCount(int count) {
    state = count >= 0 ? count : 0;
  }

  void decrement() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void increment() {
    state = state + 1;
  }

  void reset() {
    state = 0;
  }
}

// Notification Filter State Provider ('all' or 'unread')
final notificationFilterProvider = StateProvider<String>((ref) => 'all');

// Notifications List Notifier & Provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final unreadNotifier = ref.read(unreadNotificationCountProvider.notifier);
  return NotificationsNotifier(repo, unreadNotifier);
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;
  final UnreadCountNotifier _unreadNotifier;

  NotificationsNotifier(this._repository, this._unreadNotifier)
      : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications({String? filter, bool isRefresh = false}) async {
    if (!isRefresh && state is! AsyncData) {
      state = const AsyncValue.loading();
    }

    try {
      final list = (await _repository.getNotifications(page: 1, limit: 50, filter: filter))
          .where((n) => !n.isExpired)
          .toList();
      state = AsyncValue.data(list);
      // Synchronize unread count
      final unreadCount = list.where((n) => !n.isRead).length;
      _unreadNotifier.setCount(unreadCount);

    } catch (e, stack) {
      if (isRefresh && state.hasValue) {
        // Keep existing list on transient network error during pull-to-refresh
      } else {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    final targetIndex = currentList.indexWhere((n) => n.id == notificationId);
    if (targetIndex != -1 && !currentList[targetIndex].isRead) {
      // Optimistic in-place update
      final updatedList = List<NotificationModel>.from(currentList);
      final item = updatedList[targetIndex];
      updatedList[targetIndex] = item.copyWith(
        isRead: true,
        readAt: item.readAt ?? DateTime.now(),
      );
      state = AsyncValue.data(updatedList);
      _unreadNotifier.decrement();

      try {
        await _repository.markAsRead(notificationId);
      } catch (_) {}
    }
  }

  Future<void> markAllAsRead() async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    final now = DateTime.now();
    final updatedList = currentList.map((n) {
      if (!n.isRead) {
        return n.copyWith(isRead: true, readAt: n.readAt ?? now);
      }
      return n;
    }).toList();

    state = AsyncValue.data(updatedList);
    _unreadNotifier.reset();

    try {
      await _repository.markAllAsRead();
    } catch (_) {}
  }

  Future<void> markAsUnread(int notificationId) async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    final targetIndex = currentList.indexWhere((n) => n.id == notificationId);
    if (targetIndex != -1 && currentList[targetIndex].isRead) {
      final updatedList = List<NotificationModel>.from(currentList);
      final item = updatedList[targetIndex];
      updatedList[targetIndex] = item.copyWith(
        isRead: false,
        readAt: null,
      );
      state = AsyncValue.data(updatedList);
      _unreadNotifier.increment();

      try {
        await _repository.markAsUnread(notificationId);
      } catch (_) {}
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final currentList = state.valueOrNull;
    if (currentList == null) return;

    final targetIndex = currentList.indexWhere((n) => n.id == notificationId);
    if (targetIndex != -1) {
      final item = currentList[targetIndex];
      final updatedList = List<NotificationModel>.from(currentList)..removeAt(targetIndex);
      state = AsyncValue.data(updatedList);
      if (!item.isRead) {
        _unreadNotifier.decrement();
      }

      try {
        await _repository.deleteNotification(notificationId);
      } catch (_) {}
    }
  }

  Future<void> clearAllNotifications() async {
    final currentList = state.valueOrNull;
    if (currentList == null || currentList.isEmpty) return;

    state = const AsyncValue.data(<NotificationModel>[]);
    _unreadNotifier.reset();

    try {
      await _repository.clearAllNotifications();
    } catch (_) {}
  }
}

// Single Notification Details Provider
final notificationDetailsProvider =
    FutureProvider.autoDispose.family<NotificationModel, int>((ref, id) async {
  final repo = ref.watch(notificationRepositoryProvider);
  return await repo.getNotificationDetails(id);
});
