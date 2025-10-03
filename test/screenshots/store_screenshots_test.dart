import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

/// ストア提出用スクリーンショット生成テスト
void main() {
  group('Store Screenshots Generation', () {
    testWidgets('Generate basic app screenshot', (WidgetTester tester) async {
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

      // スクリーンショットディレクトリを作成
      final directory = Directory('store/screenshots');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // アプリのスクリーンショットを生成
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('store/screenshots/app_overview.png'),
      );
    });

    testWidgets('Generate home page screenshot', (WidgetTester tester) async {
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

      // ホームページのスクリーンショットを生成
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('store/screenshots/home_page.png'),
      );
    });
  });
}