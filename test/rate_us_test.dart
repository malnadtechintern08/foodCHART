import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookmate/app/router/route_names.dart';
import 'package:cookmate/app/router/route_paths.dart';
import 'package:cookmate/features/rating/data/datasources/rating_remote_datasource.dart';
import 'package:cookmate/features/rating/presentation/screens/rate_us_screen.dart';
import 'package:cookmate/features/rating/presentation/widgets/rating_popup_dialog.dart';
import 'package:cookmate/features/rating/services/rating_service.dart';

class FakeRatingService extends RatingService {
  FakeRatingService({super.prefs});
  int? submittedStars;

  @override
  Future<void> recordRatingSubmitted(int stars) async {
    submittedStars = stars;
    await super.recordRatingSubmitted(stars);
  }
}

class FakeRatingRemoteDataSource implements RatingRemoteDataSource {
  bool submitted = false;
  @override
  Future<bool> submitRating({
    required int stars,
    required String category,
    required String feedbackText,
    String? userName,
    String? userEmail,
    String? deviceInfo,
    String appVersion = '2.0.0',
  }) async {
    submitted = true;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('RateUsScreen Widget Tests', () {
    testWidgets('Renders with initial stars and UI components', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RateUsScreen(initialStars: 2),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rate Food CHART'), findsOneWidget);
      expect(find.text('Help Us Improve Food CHART'), findsOneWidget);
      expect(find.text('2 Stars • Could be better'), findsOneWidget);

      // Verify category chips
      expect(find.text('App Performance'), findsOneWidget);
      expect(find.text('Recipe Instructions'), findsOneWidget);
      expect(find.text('Missing Features'), findsOneWidget);
      expect(find.text('App Bug / Error'), findsOneWidget);

      // Verify text inputs
      expect(find.byKey(const Key('rate_us_feedback_input')), findsOneWidget);
      expect(find.byKey(const Key('rate_us_name_input')), findsOneWidget);
      expect(find.byKey(const Key('rate_us_email_input')), findsOneWidget);
      expect(find.byKey(const Key('rate_us_submit_button')), findsOneWidget);
    });

    testWidgets('Can change star rating dynamically', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RateUsScreen(initialStars: 1),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 Star • Needs major improvement'), findsOneWidget);

      // Tap 3rd star
      await tester.tap(find.byKey(const Key('rate_us_star_3')));
      await tester.pumpAndSettle();

      expect(find.text('3 Stars • Average experience'), findsOneWidget);
    });

    testWidgets('Validates empty feedback on submit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RateUsScreen(initialStars: 3),
        ),
      );
      await tester.pumpAndSettle();

      final submitFinder = find.byKey(const Key('rate_us_submit_button'));
      await tester.ensureVisible(submitFinder);
      await tester.pumpAndSettle();

      // Tap submit without typing feedback
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please write a brief feedback message.'), findsOneWidget);
    });

    testWidgets('Submitting feedback displays thank you dialog', (tester) async {
      final fakeRemote = FakeRatingRemoteDataSource();
      await tester.pumpWidget(
        MaterialApp(
          home: RateUsScreen(initialStars: 2, remoteDataSource: fakeRemote),
        ),
      );
      await tester.pumpAndSettle();

      final feedbackFinder = find.byKey(const Key('rate_us_feedback_input'));
      await tester.ensureVisible(feedbackFinder);
      await tester.pumpAndSettle();

      // Enter valid feedback
      await tester.enterText(
        feedbackFinder,
        'The timer in cooking mode sometimes pauses when screen locks.',
      );

      final submitFinder = find.byKey(const Key('rate_us_submit_button'));
      await tester.ensureVisible(submitFinder);
      await tester.pumpAndSettle();

      // Tap submit
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(fakeRemote.submitted, isTrue);

      // Verify Thank You dialog appears
      expect(find.text('Thank You for Your Feedback! ❤️'), findsOneWidget);
      expect(find.byKey(const Key('rate_us_thank_you_button')), findsOneWidget);
    });
  });

  group('RatingPopupDialog 1-3 Stars to RateUsScreen Navigation Tests', () {
    testWidgets('Selecting 1, 2, or 3 stars navigates to /rate-us with selected stars', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      final fakeService = FakeRatingService(prefs: prefs);

      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showCookMateRatingPopup(
                    context,
                    isManual: true,
                    ratingService: fakeService,
                  ),
                  child: const Text('Launch Popup'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: RoutePaths.rateUs,
            name: RouteNames.rateUs,
            builder: (context, state) {
              final stars = (state.extra as Map<String, dynamic>?)?['stars'] ?? 3;
              return RateUsScreen(initialStars: stars as int);
            },
          ),
          GoRoute(
            path: RoutePaths.contactUs,
            name: RouteNames.contactUs,
            builder: (context, state) => const Scaffold(body: Text('Contact Us Screen')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Open popup
      await tester.tap(find.text('Launch Popup'));
      await tester.pumpAndSettle();

      // Select 2 stars
      await tester.tap(find.byKey(const Key('star_2')));
      await tester.pumpAndSettle();

      // Tap Send Feedback
      await tester.tap(find.byKey(const Key('send_feedback_button')));
      await tester.pumpAndSettle();

      // Should be on Rate Us screen, NOT Contact Us screen!
      expect(find.text('Rate Food CHART'), findsOneWidget);
      expect(find.text('2 Stars • Could be better'), findsOneWidget);
      expect(find.text('Contact Us Screen'), findsNothing);
    });
  });
}
