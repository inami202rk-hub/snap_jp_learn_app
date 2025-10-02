import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  /// 写真からテキストを抽出する（モック実装）
  /// 実際のOCR処理の代わりに、テスト用のモック文字列を返す
  Future<String> extractTextFromImage({ImageSource source = ImageSource.camera}) async {
    try {
      // 現在はモック実装：実際の画像処理は行わず、テスト用文字列を返す
      await Future.delayed(const Duration(milliseconds: 500)); // 処理時間をシミュレート
      
      return _getMockText();
    } catch (e) {
      throw OcrException('OCR処理中にエラーが発生しました: $e');
    }
  }

  /// 実際のOCR処理（将来の実装用）
  /// 現在はコメントアウトしているが、実際の画像処理を行う際に使用
  // ignore: unused_element
  Future<String> _performActualOcr(ImageSource source) async {
    try {
      // 画像を取得
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) {
        throw OcrException('画像が選択されませんでした');
      }

      // ML Kitでテキスト認識
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // テキストを抽出
      String extractedText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += '${line.text}\n';
        }
      }

      return extractedText.trim();
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

  /// リソースを解放
  void dispose() {
    _textRecognizer.close();
  }
}

/// OCR処理で発生する例外
class OcrException implements Exception {
  final String message;
  
  const OcrException(this.message);
  
  @override
  String toString() => 'OcrException: $message';
}
