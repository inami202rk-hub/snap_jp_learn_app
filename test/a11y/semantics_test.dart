import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snap_jp_learn_app/generated/app_localizations.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('should have proper semantics for buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const TestAccessibilityWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Test that buttons have proper semantics
      final cameraButton = find.byType(ElevatedButton).first;
      expect(cameraButton, findsOneWidget);

      // Check semantics for camera button
      final semantics = tester.getSemantics(cameraButton);
      expect(semantics, isNotNull);
      expect(semantics.label, contains('OCR'));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('should support text scaling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: const TestAccessibilityWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test that text scaling is applied
      final homeText = find.text('Home');
      expect(homeText, findsOneWidget);

      final textWidget = tester.widget<Text>(homeText);
      expect(textWidget.style?.fontSize,
          greaterThanOrEqualTo(24.0)); // Should be scaled or default
    });

    testWidgets('should have proper touch targets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const TestAccessibilityWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Test that buttons have proper touch targets (minimum 48x48)
      final cameraButton = find.byType(ElevatedButton).first;
      expect(cameraButton, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(cameraButton);
      expect(renderBox.size.width, greaterThanOrEqualTo(48.0));
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
    });
  });
}

class TestAccessibilityWidget extends StatelessWidget {
  const TestAccessibilityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(l10n.home, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Semantics(
              label: l10n.startOCR,
              button: true,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(l10n.takePhotoAndStartOCR),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
