import '../../data/models/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationModel>> getNotifications({int page = 1, int limit = 20, String? filter});
  Future<int> getUnreadCount();
  Future<bool> markAsRead(int notificationId);
  Future<int> markAllAsRead();
  Future<bool> markAsUnread(int notificationId);
  Future<NotificationModel> getNotificationDetails(int notificationId);
  Future<bool> deleteNotification(int notificationId);
  Future<int> clearAllNotifications();
}
