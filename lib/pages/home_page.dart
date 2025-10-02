import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/settings/services/settings_service.dart';
import '../widgets/srs_preview_card.dart';
import '../services/ocr_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OcrService _ocrService = OcrService();

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  /// OCRテスト用メソッド
  Future<void> _testOcr(BuildContext context) async {
    try {
      // ローディング表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // OCR処理実行（モック）
      final extractedText = await _ocrService.extractTextFromImage();

      // ローディング終了
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // 結果をダイアログで表示
        _showOcrResultDialog(context, extractedText);
      }
    } catch (e) {
      // エラー処理
      if (context.mounted) {
        Navigator.of(context).pop(); // ローディング終了
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OCRエラー: $e')),
        );
      }
    }
  }

  /// OCR結果表示ダイアログ
  void _showOcrResultDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.text_fields, color: Colors.blue),
            SizedBox(width: 8),
            Text('OCR結果'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '抽出されたテキスト:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  text.isEmpty ? 'テキストが検出されませんでした' : text,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          if (text.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                // TODO: 将来的にSRS学習に追加する機能
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('学習リストへの追加機能は今後実装予定です')),
                );
              },
              child: const Text('学習に追加'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Icon(
                  Icons.home,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'ホーム画面',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                const Text(
                  'スナップ日記と日本語学習のメイン画面',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                if (settingsService.srsPreviewEnabled) ...[
                  const SrsPreviewCard(),
                  const SizedBox(height: 16),
                ],
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.camera_alt, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              '今日のスナップ',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('写真を撮って日本語学習を始めましょう！'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _testOcr(context),
                                icon: const Icon(Icons.text_fields),
                                label: const Text('OCRテスト'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: 実際のカメラ機能の実装
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('カメラ機能は今後実装予定です')),
                                  );
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('写真を撮る'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
