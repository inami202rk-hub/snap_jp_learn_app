import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:snap_jp_learn_app/pages/home_page.dart';
import 'package:snap_jp_learn_app/services/ocr_service.dart';
import 'package:snap_jp_learn_app/features/settings/services/settings_service.dart';

/// ギャラリーOCR用のモックサービス
class MockOcrServiceForGallery implements OcrService {
  @override
  Future<String> extractTextFromXFile(XFile image) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'ギャラリーから選択された画像のテキスト: こんにちは、世界！';
  }

  @override
  Future<String> extractTextFromImage({
    ImageSource source = ImageSource.camera,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (source == ImageSource.gallery) {
      return 'ギャラリーOCR: 成功しました！\n日本語テキストが抽出されました。';
    } else {
      return 'カメラOCR: テストテキスト';
    }
  }

  @override
  void dispose() {
    // Mock service has no resources to dispose
  }
}

void main() {
  group('HomePage Gallery OCR Tests', () {
    late MockOcrServiceForGallery mockOcrService;
    late SettingsService settingsService;

    setUp(() async {
      // SharedPreferencesのモック化
      SharedPreferences.setMockInitialValues({});
      
      mockOcrService = MockOcrServiceForGallery();
      settingsService = SettingsService();
      await settingsService.initialize();
    });

    testWidgets('ギャラリーボタンが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsService>.value(
          value: settingsService,
          child: MaterialApp(home: HomePage(ocrService: mockOcrService)),
        ),
      );
      await tester.pumpAndSettle();

      // ギャラリーボタンが存在することを確認
      expect(find.text('ギャラリー'), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('ギャラリーから選ぶ→OCR→結果表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsService>.value(
          value: settingsService,
          child: MaterialApp(home: HomePage(ocrService: mockOcrService)),
        ),
      );
      await tester.pumpAndSettle();

      // スクロールしてギャラリーボタンを表示
      await tester.scrollUntilVisible(
        find.text('ギャラリー'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      // ギャラリーボタンをタップ
      await tester.tap(find.text('ギャラリー'), warnIfMissed: false);
      await tester.pump();

      // ローディングインジケータが表示されることを確認
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('画像選択中...'), findsOneWidget);

      // OCR処理完了まで待機
      await tester.pump(const Duration(milliseconds: 400));

      // 結果ダイアログが表示されることを確認
      expect(find.text('OCR結果'), findsOneWidget);
      expect(find.text('抽出されたテキスト:'), findsOneWidget);
      expect(find.textContaining('ギャラリーOCR'), findsOneWidget);

      // ダイアログを閉じる
      await tester.tap(find.text('閉じる'));
      await tester.pump();

      // ダイアログが閉じられることを確認
      expect(find.text('OCR結果'), findsNothing);
    });

    testWidgets('複数のOCRボタンが正しく動作する', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<SettingsService>.value(
          value: settingsService,
          child: MaterialApp(home: HomePage(ocrService: mockOcrService)),
        ),
      );
      await tester.pumpAndSettle();

      // スクロールしてボタンを表示
      await tester.scrollUntilVisible(
        find.text('撮影してOCR'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      // 撮影ボタンが存在することを確認
      expect(find.text('撮影してOCR'), findsOneWidget);

      // ギャラリーボタンが存在することを確認
      expect(find.text('ギャラリー'), findsOneWidget);

      // テストボタンが存在することを確認
      expect(find.text('テスト'), findsOneWidget);
    });

    tearDown(() {
      mockOcrService.dispose();
    });
  });
}
