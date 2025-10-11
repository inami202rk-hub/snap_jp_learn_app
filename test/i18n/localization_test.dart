import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:snap_jp_learn_app/generated/app_localizations.dart';

void main() {
  group('Localization Tests', () {
    testWidgets('should load English localizations',
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
          home: const TestLocalizationWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Check that English text is displayed
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Extract Text'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should load Japanese localizations',
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
          locale: const Locale('ja'),
          home: const TestLocalizationWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Check that Japanese text is displayed
      expect(find.text('ホーム'), findsOneWidget);
      expect(find.text('設定'), findsOneWidget);
      expect(find.text('カメラ'), findsOneWidget);
      expect(find.text('ギャラリー'), findsOneWidget);
      expect(find.text('文字を抽出'), findsOneWidget);
      expect(find.text('再試行'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
    });

    testWidgets('should fallback to English for unsupported locale',
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
          locale: const Locale('fr'), // Unsupported locale
          home: const TestLocalizationWidget(),
        ),
      );

      await tester.pumpAndSettle();

      // Should fallback to English
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    test('should have correct supported locales', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('ja')));
      expect(AppLocalizations.supportedLocales.length, equals(2));
    });

    testWidgets('should have correct pluralization for days',
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
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              expect(l10n.days(0), equals('0 days'));
              expect(l10n.days(1), equals('1 day'));
              expect(l10n.days(2), equals('2 days'));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should have correct pluralization for cards',
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
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              expect(l10n.cards(0), equals('0 cards'));
              expect(l10n.cards(1), equals('1 card'));
              expect(l10n.cards(2), equals('2 cards'));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should have correct pluralization for reviews',
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
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              expect(l10n.reviews(0), equals('0 reviews'));
              expect(l10n.reviews(1), equals('1 review'));
              expect(l10n.reviews(2), equals('2 reviews'));
              return Container();
            },
          ),
        ),
      );
    });

    testWidgets('should have correct Japanese counters',
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
          locale: const Locale('ja'),
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              expect(l10n.days(0), equals('0日'));
              expect(l10n.days(1), equals('1日'));
              expect(l10n.days(2), equals('2日'));
              expect(l10n.cards(0), equals('0枚のカード'));
              expect(l10n.cards(1), equals('1枚のカード'));
              expect(l10n.cards(2), equals('2枚のカード'));
              expect(l10n.reviews(0), equals('0回のレビュー'));
              expect(l10n.reviews(1), equals('1回のレビュー'));
              expect(l10n.reviews(2), equals('2回のレビュー'));
              return Container();
            },
          ),
        ),
      );
    });
  });
}

class TestLocalizationWidget extends StatelessWidget {
  const TestLocalizationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          Text(l10n.home),
          Text(l10n.settings),
          Text(l10n.camera),
          Text(l10n.gallery),
          Text(l10n.ocr),
          Text(l10n.retry),
          Text(l10n.cancel),
        ],
      ),
    );
  }
}
