import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_jp_learn_app/pages/onboarding_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snap_jp_learn_app/generated/app_localizations.dart';

void main() {
  group('OnboardingPage', () {
    testWidgets('should display onboarding slides',
        (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: const OnboardingPage(),
        ),
      );

      // Assert
      expect(find.text('Learn Japanese from Photos'), findsOneWidget);
      expect(
          find.text(
              'Take photos of Japanese text and turn them into learning cards instantly'),
          findsOneWidget);
    });

    testWidgets('should show skip and next buttons',
        (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: const OnboardingPage(),
        ),
      );

      // Assert
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('should show done button on last slide',
        (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: const OnboardingPage(),
        ),
      );

      // Navigate through all slides
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      // Assert - Done button should be visible on last slide
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('should show skip button on first slide',
        (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: const OnboardingPage(),
        ),
      );

      // Assert - Skip button should be visible on first slide
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('should have done button on last slide',
        (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: const OnboardingPage(),
        ),
      );

      // Navigate to last slide
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      // Assert - Done button should be visible on last slide
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('should display all four slides', (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: const OnboardingPage(),
        ),
      );

      // Assert - Check first slide
      expect(find.text('Learn Japanese from Photos'), findsOneWidget);
      expect(
          find.text(
              'Take photos of Japanese text and turn them into learning cards instantly'),
          findsOneWidget);

      // Navigate to second slide
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert - Check second slide
      expect(find.text('Extract Text with OCR'), findsOneWidget);
      expect(
          find.text(
              'Our smart OCR technology recognizes Japanese characters accurately'),
          findsOneWidget);

      // Navigate to third slide
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert - Check third slide
      expect(find.text('Study with SRS Cards'), findsOneWidget);
      expect(
          find.text(
              'Review your cards using spaced repetition for effective learning'),
          findsOneWidget);

      // Navigate to fourth slide
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Assert - Check fourth slide
      expect(find.text('Track Your Progress'), findsOneWidget);
      expect(
          find.text(
              'Monitor your learning journey with detailed statistics and insights'),
          findsOneWidget);
    });

    testWidgets('should display icons for each slide',
        (WidgetTester tester) async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ja', ''),
          ],
          home: const OnboardingPage(),
        ),
      );

      // Assert - Check that icons are displayed
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);

      // Navigate through slides and check icons
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.text_fields), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.school), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });
  });
}
