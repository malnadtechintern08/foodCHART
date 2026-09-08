import 'package:cookmate/features/support/data/models/faq_model.dart';
import 'package:cookmate/features/support/data/models/support_page_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Support Feature Models & Defaults Tests', () {
    test('SupportPageModel defaultPrivacyPolicy loads rich content', () {
      final policy = SupportPageModel.defaultPrivacyPolicy();
      expect(policy.id, 'privacy-policy');
      expect(policy.title, 'Privacy Policy');
      expect(policy.slug, 'privacy-policy');
      expect(policy.content, contains('Food CHART Privacy Policy'));
      expect(policy.content, contains('offline-first'));
      expect(policy.isPublished, isTrue);
      expect(policy.meta['contact_email'], 'privacy@cookmate.app');
    });

    test('SupportPageModel defaultContactUs loads contact metadata', () {
      final contact = SupportPageModel.defaultContactUs();
      expect(contact.id, 'contact-us');
      expect(contact.slug, 'contact-us');
      expect(contact.meta['support_email'], 'support@cookmate.app');
      expect(contact.meta['phone'], contains('+91'));
      expect(contact.meta['address'], contains('Bengaluru'));
    });

    test('SupportPageModel defaultHelpCenter loads step guides', () {
      final help = SupportPageModel.defaultHelpCenter();
      expect(help.id, 'help-center');
      expect(help.content, contains('Discovering & Filtering Recipes'));
      expect(help.content, contains('Cooking Mode'));
      expect(help.content, contains('Shopping List'));
    });

    test('SupportPageModel defaultSafetyGuidelines loads safety protocols', () {
      final safety = SupportPageModel.defaultSafetyGuidelines();
      expect(safety.id, 'safety-guidelines');
      expect(safety.content, contains('Food Hygiene'));
      expect(safety.content, contains('Pressure Cooker'));
      expect(safety.content, contains('Allergen'));
    });

    test('FaqModel defaultFaqs contains multiple categories', () {
      final faqs = FaqModel.defaultFaqs();
      expect(faqs, isNotEmpty);
      expect(faqs.length, greaterThanOrEqualTo(10));

      final categories = faqs.map((f) => f.category).toSet();
      expect(categories, contains('General'));
      expect(categories, contains('Recipes & Cooking'));
      expect(categories, contains('Submissions'));
      expect(categories, contains('Dietary & Health'));
      expect(categories, contains('App & Account'));
    });

    test('SupportPageModel parses JSON accurately', () {
      final json = {
        'id': 'custom-terms',
        'title': 'Terms of Service',
        'slug': 'terms',
        'summary': 'App terms',
        'content': 'These are the terms.',
        'meta': {'custom_key': 'custom_val'},
        'is_published': 1,
        'updated_at': '2026-09-05T10:00:00.000Z',
      };

      final model = SupportPageModel.fromJson(json);
      expect(model.id, 'custom-terms');
      expect(model.title, 'Terms of Service');
      expect(model.slug, 'terms');
      expect(model.meta['custom_key'], 'custom_val');
      expect(model.isPublished, isTrue);
      expect(model.updatedAt, isNotNull);
    });

    test('FaqModel parses JSON accurately', () {
      final json = {
        'id': 42,
        'category': 'General',
        'question': 'How do I cook rice?',
        'answer': 'Use 1:2 ratio of rice to water.',
        'sort_order': 5,
        'is_published': 1,
      };

      final model = FaqModel.fromJson(json);
      expect(model.id, 42);
      expect(model.category, 'General');
      expect(model.question, 'How do I cook rice?');
      expect(model.answer, 'Use 1:2 ratio of rice to water.');
      expect(model.sortOrder, 5);
      expect(model.isPublished, isTrue);
    });
  });
}
