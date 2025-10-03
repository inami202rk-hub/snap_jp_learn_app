import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'package:snap_jp_learn_app/pages/home_page.dart';
import 'package:snap_jp_learn_app/services/ocr_service.dart';
import 'package:snap_jp_learn_app/features/settings/services/settings_service.dart';

/// OCRテキスト整形機能のモックサービス
class MockOcrServiceWithNormalization implements OcrService {
  @override
  Future<String> extractTextFromXFile(XFile image) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'Ｔｅｓｔ１２３,今日は晴れ.'; // 整形が必要なテキスト
  }

  @override
  Future<String> extractTextFromImage({
    ImageSource source = ImageSource.camera,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'Ｔｅｓｔ１２３,今日は晴れ.'; // 整形が必要なテキスト
  }

  @override
  void dispose() {
    // Mock service has no resources to dispose
  }
}

void main() {
  group('HomePage Normalized View Tests', () {
    late MockOcrServiceWithNormalization mockOcrService;
    late SettingsService settingsService;

    setUp(() async {
      // SharedPreferencesのモック化
      SharedPreferences.setMockInitialValues({});

      mockOcrService = MockOcrServiceWithNormalization();
      settingsService = SettingsService();
      await settingsService.initialize();
    });

    testWidgets('OCR結果ダイアログにRaw/Normalized切替が表示される', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsService>.value(
          value: settingsService,
          child: MaterialApp(home: HomePage(ocrService: mockOcrService)),
        ),
      );
      await tester.pumpAndSettle();

      // スクロールしてテストボタンを表示
      await tester.scrollUntilVisible(
        find.text('テスト'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      // テストボタンをタップ
      await tester.tap(find.text('テスト'), warnIfMissed: false);
      await tester.pump();

      // OCR処理完了まで待機
      await tester.pump(const Duration(milliseconds: 400));

      // OCR結果ダイアログが表示されることを確認
      expect(find.text('OCR結果'), findsOneWidget);

      // Raw/Normalized切替タブが表示されることを確認
      expect(find.text('Raw'), findsOneWidget);
      expect(find.text('Normalized'), findsOneWidget);

      // 整形されたテキストが表示されることを確認
      expect(find.text('整形されたテキスト:'), findsOneWidget);
      expect(find.textContaining('Test123'), findsOneWidget);
      expect(find.textContaining('今日は晴れ。'), findsOneWidget);
    });

    testWidgets('Raw/Normalized切替が動作する', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsService>.value(
          value: settingsService,
          child: MaterialApp(home: HomePage(ocrService: mockOcrService)),
        ),
      );
      await tester.pumpAndSettle();

      // スクロールしてテストボタンを表示
      await tester.scrollUntilVisible(
        find.text('テスト'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      // テストボタンをタップ
      await tester.tap(find.text('テスト'), warnIfMissed: false);
      await tester.pump();

      // OCR処理完了まで待機
      await tester.pump(const Duration(milliseconds: 400));

      // 初期状態でNormalizedが表示されていることを確認
      expect(find.text('整形されたテキスト:'), findsOneWidget);
      expect(find.textContaining('Test123'), findsOneWidget);

      // Rawタブをタップ
      await tester.tap(find.text('Raw'));
      await tester.pump();

      // Raw表示に切り替わることを確認
      expect(find.text('生のテキスト:'), findsOneWidget);
      expect(find.textContaining('Ｔｅｓｔ１２３'), findsOneWidget);
      expect(find.textContaining('今日は晴れ.'), findsOneWidget);

      // Normalizedタブをタップ
      await tester.tap(find.text('Normalized'));
      await tester.pump();

      // Normalized表示に戻ることを確認
      expect(find.text('整形されたテキスト:'), findsOneWidget);
      expect(find.textContaining('Test123'), findsOneWidget);
    });

    testWidgets('コピーボタンが動作する', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsService>.value(
          value: settingsService,
          child: MaterialApp(home: HomePage(ocrService: mockOcrService)),
        ),
      );
      await tester.pumpAndSettle();

      // スクロールしてテストボタンを表示
      await tester.scrollUntilVisible(
        find.text('テスト'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      // テストボタンをタップ
      await tester.tap(find.text('テスト'), warnIfMissed: false);
      await tester.pump();

      // OCR処理完了まで待機
      await tester.pump(const Duration(milliseconds: 400));

      // コピーボタンが表示されることを確認
      expect(find.text('コピー'), findsOneWidget);

      // コピーボタンをタップ
      await tester.tap(find.text('コピー'));
      await tester.pump();

      // コピー完了のSnackBarが表示されることを確認
      expect(find.textContaining('整形されたテキストをコピーしました'), findsOneWidget);
    });

    testWidgets('整形情報が表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsService>.value(
          value: settingsService,
          child: MaterialApp(home: HomePage(ocrService: mockOcrService)),
        ),
      );
      await tester.pumpAndSettle();

      // スクロールしてテストボタンを表示
      await tester.scrollUntilVisible(
        find.text('テスト'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      // テストボタンをタップ
      await tester.tap(find.text('テスト'), warnIfMissed: false);
      await tester.pump();

      // OCR処理完了まで待機
      await tester.pump(const Duration(milliseconds: 400));

      // 整形情報が表示されることを確認
      expect(find.text('テキストが整形されました'), findsOneWidget);
    });

    testWidgets('テキストが選択可能である', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsService>.value(
          value: settingsService,
          child: MaterialApp(home: HomePage(ocrService: mockOcrService)),
        ),
      );
      await tester.pumpAndSettle();

      // スクロールしてテストボタンを表示
      await tester.scrollUntilVisible(
        find.text('テスト'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      // テストボタンをタップ
      await tester.tap(find.text('テスト'), warnIfMissed: false);
      await tester.pump();

      // OCR処理完了まで待機
      await tester.pump(const Duration(milliseconds: 400));

      // SelectableTextが使用されていることを確認
      expect(find.byType(SelectableText), findsOneWidget);
    });

    tearDown(() {
      mockOcrService.dispose();
    });
  });
}
