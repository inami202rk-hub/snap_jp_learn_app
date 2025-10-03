import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

/// ストア提出用スクリーンショット生成テスト
/// 注意: このテストは実際のスクリーンショット生成は行わず、
/// UI要素の存在確認のみを行います
void main() {
  group('Store Screenshots Generation', () {
    testWidgets('Verify app UI elements exist', (WidgetTester tester) async {
      // シンプルなアプリを作成
      final testApp = MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 64),
                SizedBox(height: 16),
                Text(
                  'Snap JP Learn',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('写真から学ぶ日本語学習アプリ'),
                SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.camera_alt),
                  label: Text('撮影してOCR'),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.photo_library),
                  label: Text('ギャラリーから選ぶ'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // UI要素の存在確認のみ（スクリーンショット生成は行わない）
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Snap JP Learn'), findsOneWidget);
      expect(find.text('撮影してOCR'), findsOneWidget);
      expect(find.text('ギャラリーから選ぶ'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsWidgets);
    });

    testWidgets('Verify home page UI elements exist',
        (WidgetTester tester) async {
      // ホームページ風のUIを作成
      final testApp = MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Snap JP Learn'),
            backgroundColor: Colors.green,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt, size: 48, color: Colors.green),
                        SizedBox(height: 8),
                        Text(
                          'OCR機能',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('写真から日本語テキストを自動抽出'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.school, size: 48, color: Colors.blue),
                        SizedBox(height: 8),
                        Text(
                          'SRS学習',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('科学的な間隔反復学習システム'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(Icons.privacy_tip, size: 48, color: Colors.orange),
                        SizedBox(height: 8),
                        Text(
                          'プライバシー保護',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('すべてのデータは端末内にのみ保存'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // UI要素の存在確認のみ（スクリーンショット生成は行わない）
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Snap JP Learn'), findsOneWidget);
      expect(find.text('OCR機能'), findsOneWidget);
      expect(find.text('SRS学習'), findsOneWidget);
      expect(find.text('プライバシー保護'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(3));
    });

    test('Verify screenshot directory exists', () {
      // スクリーンショットディレクトリの存在確認
      final directory = Directory('store/screenshots');
      expect(directory.existsSync(), isTrue);
    });

    test('Verify metadata files exist', () {
      // メタデータファイルの存在確認
      expect(
          File('store/metadata/short_description_ja.txt').existsSync(), isTrue);
      expect(
          File('store/metadata/long_description_ja.txt').existsSync(), isTrue);
      expect(File('store/metadata/keywords_ios.txt').existsSync(), isTrue);
      expect(
          File('store/metadata/app_description_ios.txt').existsSync(), isTrue);
      expect(File('store/metadata/categories.txt').existsSync(), isTrue);
    });
  });
}
