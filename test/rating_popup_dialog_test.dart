import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookmate/features/rating/presentation/widgets/rating_popup_dialog.dart';
import 'package:cookmate/features/rating/services/rating_service.dart';

class FakeRatingService extends RatingService {
  FakeRatingService({
    super.prefs,
    this.openPlayStoreSuccess = true,
  });

  final bool openPlayStoreSuccess;
  int? submittedStars;
  bool playStoreCalled = false;
  bool dismissedCalled = false;

  @override
  Future<void> recordRatingSubmitted(int stars) async {
    submittedStars = stars;
    await super.recordRatingSubmitted(stars);
  }

  @override
  Future<void> recordDismissed() async {
    dismissedCalled = true;
    await super.recordDismissed();
  }

  @override
  Future<bool> openPlayStoreReview({String appPackageName = 'com.cookmate.cookmate'}) async {
    playStoreCalled = true;
    return openPlayStoreSuccess;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget(RatingService service, {VoidCallback? onSendFeedback}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showCookMateRatingPopup(
                context,
                isManual: true,
                ratingService: service,
                onSendFeedback: onSendFeedback,
              ),
              child: const Text('Open Rating Popup'),
            ),
          ),
        ),
      ),
    );
  }

  group('RatingPopupDialog Widget Tests', () {
    late FakeRatingService fakeService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      fakeService = FakeRatingService(prefs: prefs);
    });

    testWidgets('Renders popup with title, message, 5 stars, and Maybe Later', (tester) async {
      await tester.pumpWidget(createTestWidget(fakeService));

      // Tap button to open popup
      await tester.tap(find.text('Open Rating Popup'));
      await tester.pumpAndSettle();

      // Check title and description
      expect(find.text('Enjoying Food CHART? 🍳❤️'), findsOneWidget);
      expect(
        find.text("We hope you're enjoying Food CHART. Your feedback helps us make the app better!"),
        findsOneWidget,
      );

      // Check 5 stars
      for (int i = 1; i <= 5; i++) {
        expect(find.byKey(Key('star_$i')), findsOneWidget);
      }

      // Check Maybe Later button
      expect(find.byKey(const Key('maybe_later_button')), findsOneWidget);
      expect(find.text('Tap a star to rate'), findsOneWidget);
    });

    testWidgets('Selecting 5 stars displays celebration message and Rate us on Play Store button', (tester) async {
      await tester.pumpWidget(createTestWidget(fakeService));

      await tester.tap(find.text('Open Rating Popup'));
      await tester.pumpAndSettle();

      // Tap 5th star
      await tester.tap(find.byKey(const Key('star_5')));
      await tester.pumpAndSettle();

      // Should show 4-5 stars message
      expect(find.text("We're glad you're enjoying Food CHART! ❤️"), findsOneWidget);
      expect(find.byKey(const Key('rate_playstore_button')), findsOneWidget);
      expect(find.text('⭐ Rate Food CHART on Play Store'), findsOneWidget);

      // Tap Rate us on Play Store
      await tester.tap(find.byKey(const Key('rate_playstore_button')));
      await tester.pumpAndSettle();

      expect(fakeService.submittedStars, 5);
      expect(fakeService.playStoreCalled, isTrue);
    });

    testWidgets('Selecting 4 stars also displays Play Store flow', (tester) async {
      await tester.pumpWidget(createTestWidget(fakeService));

      await tester.tap(find.text('Open Rating Popup'));
      await tester.pumpAndSettle();

      // Tap 4th star
      await tester.tap(find.byKey(const Key('star_4')));
      await tester.pumpAndSettle();

      expect(find.text("We're glad you're enjoying Food CHART! ❤️"), findsOneWidget);
      expect(find.byKey(const Key('rate_playstore_button')), findsOneWidget);
    });

    testWidgets('Selecting 1, 2, or 3 stars displays improvement message and Send Feedback button', (tester) async {
      bool feedbackTapped = false;
      await tester.pumpWidget(createTestWidget(fakeService, onSendFeedback: () {
        feedbackTapped = true;
      }));

      await tester.tap(find.text('Open Rating Popup'));
      await tester.pumpAndSettle();

      // Tap 2nd star
      await tester.tap(find.byKey(const Key('star_2')));
      await tester.pumpAndSettle();

      // Should show 1-3 stars message
      expect(
        find.text('Thanks for your feedback. Tell us how we can improve Food CHART.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('send_feedback_button')), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
      // Play Store button should NOT be present
      expect(find.byKey(const Key('rate_playstore_button')), findsNothing);

      // Tap Send Feedback button
      await tester.tap(find.byKey(const Key('send_feedback_button')));
      await tester.pumpAndSettle();

      expect(feedbackTapped, isTrue);
      expect(fakeService.submittedStars, 2);
    });

    testWidgets('Maybe Later button dismisses the popup and records dismissal', (tester) async {
      await tester.pumpWidget(createTestWidget(fakeService));

      await tester.tap(find.text('Open Rating Popup'));
      await tester.pumpAndSettle();

      expect(find.text('Enjoying Food CHART? 🍳❤️'), findsOneWidget);

      // Tap Maybe Later
      await tester.tap(find.byKey(const Key('maybe_later_button')));
      await tester.pumpAndSettle();

      // Popup is dismissed
      expect(find.text('Enjoying Food CHART? 🍳❤️'), findsNothing);
      expect(fakeService.dismissedCalled, isTrue);
    });

    testWidgets('Shows error SnackBar when Play Store cannot be opened', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final failingService = FakeRatingService(prefs: prefs, openPlayStoreSuccess: false);

      await tester.pumpWidget(createTestWidget(failingService));

      await tester.tap(find.text('Open Rating Popup'));
      await tester.pumpAndSettle();

      // Tap 5 stars
      await tester.tap(find.byKey(const Key('star_5')));
      await tester.pumpAndSettle();

      // Tap Rate us on Play Store
      await tester.tap(find.byKey(const Key('rate_playstore_button')));
      await tester.pumpAndSettle();

      // SnackBar with required exact error text appears
      expect(find.text('Unable to open Play Store. Please try again later.'), findsOneWidget);
    });
  });
}
