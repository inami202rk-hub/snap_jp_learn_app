import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_jp_learn_app/pages/onboarding_page.dart';
import 'package:snap_jp_learn_app/services/onboarding_service.dart';

void main() {
  group('OnboardingPage Widget Tests', () {
    setUp(() {
      // テスト前にSharedPreferencesをクリア
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should display onboarding steps correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingPage(),
        ),
      );

      // 最初のステップが表示されることを確認
      expect(find.text('📸 写真を撮ってOCR'), findsOneWidget);
      expect(
          find.text('日本語のテキストが含まれた写真を撮影すると、自動的にテキストを抽出します。'), findsOneWidget);

      // スキップボタンが表示されることを確認
      expect(find.text('スキップ'), findsOneWidget);

      // 次へボタンが表示されることを確認
      expect(find.text('次へ'), findsOneWidget);
    });

    testWidgets('should navigate between pages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingPage(),
        ),
      );

      // 最初のステップを確認
      expect(find.text('📸 写真を撮ってOCR'), findsOneWidget);

      // 次へボタンをタップ
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();

      // 2番目のステップを確認
      expect(find.text('📝 学習カードを作成'), findsOneWidget);
      expect(
          find.text('抽出したテキストから重要な単語やフレーズを選んで、学習カードを作成できます。'), findsOneWidget);

      // 次へボタンをタップ
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();

      // 3番目のステップを確認
      expect(find.text('📊 SRSで継続学習'), findsOneWidget);
      expect(
          find.text('スペースドリピティションシステムで効率的に学習し、統計で進捗を確認できます。'), findsOneWidget);

      // 最後のステップでは「はじめる」ボタンが表示される
      expect(find.text('はじめる'), findsOneWidget);
    });

    testWidgets('should show back button on second and later pages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingPage(),
        ),
      );

      // 最初のページでは戻るボタンは表示されない
      expect(find.text('戻る'), findsNothing);

      // 次へボタンをタップ
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();

      // 2番目のページでは戻るボタンが表示される
      expect(find.text('戻る'), findsOneWidget);

      // 戻るボタンをタップ
      await tester.tap(find.text('戻る'));
      await tester.pumpAndSettle();

      // 最初のページに戻る
      expect(find.text('📸 写真を撮ってOCR'), findsOneWidget);
    });

    testWidgets('should complete onboarding when skip is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingPage(),
        ),
      );

      // スキップボタンをタップ
      await tester.tap(find.text('スキップ'));
      await tester.pumpAndSettle();

      // オンボーディングが完了状態になることを確認
      final isCompleted = await OnboardingService.isOnboardingCompleted();
      expect(isCompleted, isTrue);
    });

    testWidgets('should complete onboarding when start button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingPage(),
        ),
      );

      // 最後のページまで進む
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('次へ'));
      await tester.pumpAndSettle();

      // はじめるボタンをタップ
      await tester.tap(find.text('はじめる'));
      await tester.pumpAndSettle();

      // オンボーディングが完了状態になることを確認
      final isCompleted = await OnboardingService.isOnboardingCompleted();
      expect(isCompleted, isTrue);
    });

    testWidgets('should show page indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const OnboardingPage(),
        ),
      );

      // ページインジケーターが表示されることを確認
      expect(find.byType(Container), findsWidgets);

      // 最初のページでは最初のインジケーターがアクティブ
      // （具体的なインジケーターのテストは実装の詳細に依存するため、基本的な存在確認のみ）
    });
  });
}
