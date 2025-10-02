import 'package:image_picker/image_picker.dart';

/// OCR処理のインターフェース
abstract class OcrService {
  /// XFileから直接テキストを抽出する
  Future<String> extractTextFromXFile(XFile image);
  
  /// 画像選択からテキスト抽出まで行う（後方互換性のため）
  Future<String> extractTextFromImage({ImageSource source = ImageSource.camera});
  
  /// リソースを解放
  void dispose();
}

/// OCR処理で発生する例外
class OcrException implements Exception {
  final String message;
  
  const OcrException(this.message);
  
  @override
  String toString() => 'OcrException: $message';
}
