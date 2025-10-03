import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/widgets/error_toast.dart';
import 'package:snap_jp_learn_app/l10n/strings_en.dart';

void main() {
  group('ErrorToast Tests', () {
    testWidgets('Network error toast shows correct content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorToast.showNetworkError(context);
                  },
                  child: const Text('Show Network Error'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger network error toast
      await tester.tap(find.text('Show Network Error'));
      await tester.pumpAndSettle();

      // Verify snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);

      // Verify error title and message
      expect(find.text(AppStrings.networkErrorTitle), findsOneWidget);
      expect(find.text(AppStrings.networkErrorMessage), findsOneWidget);

      // Verify retry button
      expect(find.text(AppStrings.retry), findsOneWidget);
    });

    testWidgets('OCR error toast shows correct content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorToast.showOcrError(context);
                  },
                  child: const Text('Show OCR Error'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger OCR error toast
      await tester.tap(find.text('Show OCR Error'));
      await tester.pumpAndSettle();

      // Verify snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);

      // Verify error title and message
      expect(find.text(AppStrings.ocrErrorTitle), findsOneWidget);
      expect(find.text(AppStrings.ocrErrorMessage), findsOneWidget);
    });

    testWidgets('Save error toast shows correct content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorToast.showSaveError(context);
                  },
                  child: const Text('Show Save Error'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger save error toast
      await tester.tap(find.text('Show Save Error'));
      await tester.pumpAndSettle();

      // Verify snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);

      // Verify error title and message
      expect(find.text(AppStrings.saveErrorTitle), findsOneWidget);
      expect(find.text(AppStrings.saveErrorMessage), findsOneWidget);
    });

    testWidgets('Image too large error toast shows correct content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorToast.showImageTooLarge(context);
                  },
                  child: const Text('Show Image Too Large Error'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger image too large error toast
      await tester.tap(find.text('Show Image Too Large Error'));
      await tester.pumpAndSettle();

      // Verify snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);

      // Verify error title and message
      expect(find.text(AppStrings.imageTooLargeTitle), findsOneWidget);
      expect(find.text(AppStrings.imageTooLargeMessage), findsOneWidget);
    });

    testWidgets('Success toast shows correct content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorToast.showSuccess(context, 'Test success message');
                  },
                  child: const Text('Show Success'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger success toast
      await tester.tap(find.text('Show Success'));
      await tester.pumpAndSettle();

      // Verify snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);

      // Verify success message
      expect(find.text('Test success message'), findsOneWidget);
    });

    testWidgets('Custom error toast shows correct content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ErrorToast.show(
                      context,
                      'Custom Error',
                      'This is a custom error message',
                    );
                  },
                  child: const Text('Show Custom Error'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger custom error toast
      await tester.tap(find.text('Show Custom Error'));
      await tester.pumpAndSettle();

      // Verify snackbar is shown
      expect(find.byType(SnackBar), findsOneWidget);

      // Verify custom error title and message
      expect(find.text('Custom Error'), findsOneWidget);
      expect(find.text('This is a custom error message'), findsOneWidget);
    });
  });
}
