import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 20, String? filter}) {
    return _remoteDataSource.getNotifications(page: page, limit: limit, filter: filter);
  }

  @override
  Future<int> getUnreadCount() {
    return _remoteDataSource.getUnreadCount();
  }

  @override
  Future<bool> markAsRead(int notificationId) {
    return _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<int> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }

  @override
  Future<bool> markAsUnread(int notificationId) {
    return _remoteDataSource.markAsUnread(notificationId);
  }

  @override
  Future<NotificationModel> getNotificationDetails(int notificationId) {
    return _remoteDataSource.getNotificationDetails(notificationId);
  }

  @override
  Future<bool> deleteNotification(int notificationId) {
    return _remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<int> clearAllNotifications() {
    return _remoteDataSource.clearAllNotifications();
  }
}
