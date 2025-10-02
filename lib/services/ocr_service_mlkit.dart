import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'ocr_service.dart';

/// ML Kitを使用したOCRサービスの実装
class OcrServiceMlkit implements OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.japanese,
  );
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Future<String> extractTextFromXFile(XFile image) async {
    try {
      // 別Isolateで処理してUIブロックを防ぐ
      return await compute(_processImageInIsolate, image.path);
    } catch (e) {
      throw OcrException('OCR処理中にエラーが発生しました: $e');
    }
  }

  @override
  Future<String> extractTextFromImage({
    ImageSource source = ImageSource.camera,
  }) async {
    try {
      // 画像を取得
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85, // 品質を調整してファイルサイズを最適化
      );

      if (image == null) {
        throw OcrException('画像が選択されませんでした');
      }

      return await extractTextFromXFile(image);
    } catch (e) {
      if (e is OcrException) {
        rethrow;
      }
      throw OcrException('画像選択中にエラーが発生しました: $e');
    }
  }

  /// 別Isolateで実行されるOCR処理
  static Future<String> _processImageInIsolate(String imagePath) async {
    try {
      // ファイルの存在確認
      final file = File(imagePath);
      if (!await file.exists()) {
        throw OcrException('画像ファイルが見つかりません');
      }

      // ファイルサイズチェック（10MB制限）
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw OcrException('画像ファイルが大きすぎます（10MB以下にしてください）');
      }

      // ML Kitでテキスト認識
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.japanese,
      );

      try {
        final inputImage = InputImage.fromFilePath(imagePath);
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );

        // テキストを抽出
        final StringBuffer extractedText = StringBuffer();
        for (final TextBlock block in recognizedText.blocks) {
          for (final TextLine line in block.lines) {
            if (line.text.trim().isNotEmpty) {
              extractedText.writeln(line.text.trim());
            }
          }
        }

        final result = extractedText.toString().trim();
        return result.isEmpty ? 'テキストが検出されませんでした' : result;
      } finally {
        await textRecognizer.close();
      }
    } catch (e) {
      if (e is OcrException) {
        rethrow;
      }
      throw OcrException('OCR処理中にエラーが発生しました: $e');
    }
  }

  /// カメラから撮影してOCR処理を行う
  Future<String> captureAndExtractText() async {
    try {
      // カメラで撮影
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear, // 背面カメラを優先
      );

      if (image == null) {
        throw OcrException('撮影がキャンセルされました');
      }

      return await extractTextFromXFile(image);
    } catch (e) {
      if (e is OcrException) {
        rethrow;
      }
      throw OcrException('撮影中にエラーが発生しました: $e');
    }
  }

  /// ギャラリーから画像を選択してOCR処理を行う
  Future<String> selectFromGalleryAndExtractText() async {
    try {
      // ギャラリーから選択
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        throw OcrException('画像の選択がキャンセルされました');
      }

      return await extractTextFromXFile(image);
    } catch (e) {
      if (e is OcrException) {
        rethrow;
      }
      throw OcrException('画像選択中にエラーが発生しました: $e');
    }
  }

  @override
  void dispose() {
    _textRecognizer.close();
  }
}
