import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/core/services/app_share_service.dart';

void main() {
  group('AppShareService Tests', () {
    test('getShareMessage contains correct branding and download link', () {
      final message = AppShareService.getShareMessage();

      expect(message, contains('Food CHART'));
      expect(message, contains('Google Play'));
      expect(message, contains(AppShareService.playStoreUrl));
      expect(message, contains('🍲'));
      expect(message, contains('offline'));
    });

    test('playStoreUrl is a valid HTTPS URI', () {
      final uri = Uri.parse(AppShareService.playStoreUrl);
      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('play.google.com'));
      expect(uri.queryParameters['id'], equals('com.food.chart'));
    });

    test('Encodes share message properly for WhatsApp deep links', () {
      final message = AppShareService.getShareMessage();
      final encoded = Uri.encodeComponent(message);

      final whatsappUri = Uri.parse('whatsapp://send?text=$encoded');
      final webUri = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

      expect(whatsappUri.scheme, equals('whatsapp'));
      expect(whatsappUri.queryParameters['text'], equals(message));

      expect(webUri.scheme, equals('https'));
      expect(webUri.host, equals('api.whatsapp.com'));
      expect(webUri.queryParameters['text'], equals(message));
    });
  });
}
