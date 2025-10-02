import 'package:image_picker/image_picker.dart';
import 'ocr_service.dart';

/// OCRサービスのモック実装（テスト用）
class OcrServiceMock implements OcrService {
  @override
  Future<String> extractTextFromXFile(XFile image) async {
    try {
      // モック実装：実際の画像処理は行わず、テスト用文字列を返す
      await Future.delayed(const Duration(milliseconds: 500)); // 処理時間をシミュレート
      
      return _getMockText();
    } catch (e) {
      throw OcrException('OCR処理中にエラーが発生しました: $e');
    }
  }

  @override
  Future<String> extractTextFromImage({ImageSource source = ImageSource.camera}) async {
    try {
      // モック実装：画像選択をスキップしてテスト用文字列を返す
      await Future.delayed(const Duration(milliseconds: 500)); // 処理時間をシミュレート
      
      return _getMockText();
    } catch (e) {
      throw OcrException('OCR処理中にエラーが発生しました: $e');
    }
  }

  /// モック用のテスト文字列を返す
  String _getMockText() {
    final mockTexts = [
      '今日は良い天気ですね。\n桜が綺麗に咲いています。',
      'こんにちは！\n日本語の勉強を頑張りましょう。',
      '美味しいラーメンを食べました。\n醤油味が最高でした。',
      '図書館で本を読んでいます。\n静かで集中できます。',
      '友達と映画を見に行きました。\nとても面白かったです。',
    ];
    
    // ランダムにモックテキストを選択
    final randomIndex = DateTime.now().millisecondsSinceEpoch % mockTexts.length;
    return mockTexts[randomIndex];
  }

  @override
  void dispose() {
    // モック実装では何もしない
  }
}
