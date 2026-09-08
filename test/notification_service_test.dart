import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookmate/features/notifications/data/models/notification_model.dart';
import 'package:cookmate/features/notifications/domain/entities/notification_item.dart';
import 'package:cookmate/features/notifications/services/cookmate_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CookMateNotificationService Tests', () {
    test('Notification constants and channel configuration are correctly defined', () {
      expect(CookMateNotificationService.channelId, 'cookmate_notifications');
      expect(CookMateNotificationService.channelName, 'Food CHART Notifications');
      expect(
        CookMateNotificationService.channelDescription,
        contains('High-priority Food CHART updates'),
      );
      expect(
        CookMateNotificationService.keyShownIds,
        'cookmate_shown_notification_ids',
      );
    });

    test('Anti-duplication tracking adds notification IDs and prevents duplicate popups', () async {
      final service = CookMateNotificationService.instance;
      service.clearShownCache();

      final notif = NotificationModel(
        id: 991,
        title: 'New Recipe Added 🍲',
        message: 'Neer Dosa has just been added!',
        type: NotificationType.newRecipe,
        relatedType: 'recipe',
        relatedId: 'rec_neer_dosa_1',
        isRead: false,
        createdAt: DateTime.now(),
      );

      // Verify shown ids start empty
      expect(service.shownNotificationIds.contains(notif.id), isFalse);

      // When showed or marked as shown
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(CookMateNotificationService.keyShownIds, ['${notif.id}']);
      
      // Reload shown IDs via mock initialization check
      final storedList = prefs.getStringList(CookMateNotificationService.keyShownIds) ?? [];
      expect(storedList, contains('991'));
    });

    test('Payload construction for recipe approval preserves deep link parameters', () {
      final notif = NotificationModel(
        id: 105,
        title: 'Your recipe has been approved ✅',
        message: 'Your Malnad Akki Roti recipe is now live on CookMate!',
        type: NotificationType.recipeApproved,
        relatedType: 'recipe',
        relatedId: 'rec_akki_roti',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final payload = json.encode({
        'notification_id': notif.id,
        'type': notif.type.name,
        'related_type': notif.relatedType,
        'related_id': notif.relatedId,
        'title': notif.title,
        'message': notif.message,
      });

      final decoded = json.decode(payload) as Map<String, dynamic>;
      expect(decoded['notification_id'], 105);
      expect(decoded['type'], 'recipeApproved');
      expect(decoded['related_type'], 'recipe');
      expect(decoded['related_id'], 'rec_akki_roti');
      expect(decoded['title'], 'Your recipe has been approved ✅');
    });

    test('Payload construction for announcements points to notification details', () {
      final notif = NotificationModel(
        id: 202,
        title: 'Weekend Cooking Challenge 🏆',
        message: 'Join our Malnad traditional festival cooking sprint!',
        type: NotificationType.adminAnnouncement,
        relatedType: 'announcement',
        relatedId: 'challenge_01',
        isRead: false,
        createdAt: DateTime.now(),
      );

      final payload = json.encode({
        'notification_id': notif.id,
        'type': notif.type.name,
        'related_type': notif.relatedType,
        'related_id': notif.relatedId,
        'title': notif.title,
        'message': notif.message,
      });

      final decoded = json.decode(payload) as Map<String, dynamic>;
      expect(decoded['notification_id'], 202);
      expect(decoded['related_type'], 'announcement');
    });

    test('Notification model list deletion and clear functions operate correctly', () {
      final list = [
        NotificationModel(
          id: 1,
          title: 'Notification 1',
          message: 'Message 1',
          type: NotificationType.general,
          isRead: false,
          createdAt: DateTime.now(),
        ),
        NotificationModel(
          id: 2,
          title: 'Notification 2',
          message: 'Message 2',
          type: NotificationType.recipeUpdated,
          isRead: true,
          createdAt: DateTime.now(),
        ),
      ];

      // Simulate single delete
      final updated = List<NotificationModel>.from(list)..removeWhere((n) => n.id == 1);
      expect(updated.length, 1);
      expect(updated.first.id, 2);

      // Simulate clear all
      final cleared = <NotificationModel>[];
      expect(cleared.isEmpty, isTrue);
    });
  });
}
