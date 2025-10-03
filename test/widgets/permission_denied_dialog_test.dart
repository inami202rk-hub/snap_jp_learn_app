import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_jp_learn_app/widgets/permission_denied_dialog.dart';
import 'package:snap_jp_learn_app/l10n/strings_en.dart';

void main() {
  group('PermissionDeniedDialog Tests', () {
    testWidgets('Camera permission denied dialog shows correct content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedDialog(
              title: AppStrings.cameraPermissionDeniedTitle,
              message: AppStrings.cameraPermissionDeniedMessage,
              permission: Permission.camera,
            ),
          ),
        ),
      );

      // Verify dialog title
      expect(
        find.text(AppStrings.cameraPermissionDeniedTitle),
        findsOneWidget,
      );

      // Verify dialog message
      expect(
        find.text(AppStrings.cameraPermissionDeniedMessage),
        findsOneWidget,
      );

      // Verify Cancel button
      expect(find.text(AppStrings.cancel), findsOneWidget);

      // Verify Open Settings button
      expect(find.text(AppStrings.openSettings), findsOneWidget);
    });

    testWidgets('Photo permission denied dialog shows correct content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionDeniedDialog(
              title: AppStrings.photoPermissionDeniedTitle,
              message: AppStrings.photoPermissionDeniedMessage,
              permission: Permission.photos,
            ),
          ),
        ),
      );

      // Verify dialog title
      expect(
        find.text(AppStrings.photoPermissionDeniedTitle),
        findsOneWidget,
      );

      // Verify dialog message
      expect(
        find.text(AppStrings.photoPermissionDeniedMessage),
        findsOneWidget,
      );

      // Verify buttons are present
      expect(find.text(AppStrings.cancel), findsOneWidget);
      expect(find.text(AppStrings.openSettings), findsOneWidget);
    });

    testWidgets('Cancel button dismisses dialog', (WidgetTester tester) async {
      bool dialogDismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => PermissionDeniedDialog(
                        title: 'Test Title',
                        message: 'Test Message',
                        permission: Permission.camera,
                      ),
                    ).then((_) {
                      dialogDismissed = true;
                    });
                  },
                  child: const Text('Show Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Test Title'), findsOneWidget);

      // Tap Cancel button
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.text('Test Title'), findsNothing);
      expect(dialogDismissed, isTrue);
    });
  });
}
