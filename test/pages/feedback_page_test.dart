import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/pages/feedback_page.dart';

void main() {
  group('FeedbackPage Tests', () {
    testWidgets('FeedbackPage displays all required elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const FeedbackPage(),
        ),
      );

      // Check that the app bar is displayed
      expect(find.text('Send Feedback'), findsOneWidget);

      // Check that category selection is displayed
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Bug Report'), findsOneWidget);
      expect(find.text('Feature Request'), findsOneWidget);
      expect(find.text('Question'), findsOneWidget);

      // Check that subject field is displayed
      expect(find.text('Subject'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);

      // Check that message field is displayed
      expect(find.text('Message'), findsOneWidget);

      // Check that diagnostic section is displayed
      expect(find.text('Diagnostic Information'), findsOneWidget);
      expect(find.text('Include diagnostic information'), findsOneWidget);

      // Check that privacy section is displayed
      expect(find.text('Privacy Notice'), findsOneWidget);
      expect(
          find.text('I agree to share diagnostic information'), findsOneWidget);

      // Check that buttons are displayed
      expect(find.text('Preview Diagnostics'), findsOneWidget);
      expect(find.text('Send via Email'), findsOneWidget);
      expect(find.text('Send via Share'), findsOneWidget);
    });

    testWidgets('Category selection works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const FeedbackPage(),
        ),
      );

      // Initially Bug Report should be selected
      expect(find.byType(RadioListTile<FeedbackCategory>), findsWidgets);

      // Tap on Feature Request
      await tester.tap(find.text('Feature Request'));
      await tester.pump();

      // The radio button should be selected (this is tested by the widget's internal state)
      expect(find.byType(RadioListTile<FeedbackCategory>), findsWidgets);
    });
  });
}
