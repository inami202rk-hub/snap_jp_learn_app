import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStore {
  static const String _imagesDirectoryName = 'images';
  static final Uuid _uuid = const Uuid();

  /// 画像ファイルをアプリのDocuments配下に保存
  /// 
  /// [xfile] 保存する画像ファイル
  /// 
  /// Returns: 保存されたファイルの絶対パス
  /// 
  /// Throws: [ImageStoreException] 保存に失敗した場合
  static Future<String> saveImageFile(XFile xfile) async {
    try {
      // Documentsディレクトリを取得
      final documentsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${documentsDir.path}/$_imagesDirectoryName');
      
      // imagesディレクトリが存在しない場合は作成
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // ファイル拡張子を決定
      final extension = _getFileExtension(xfile.name);
      
      // ユニークなファイル名を生成
      final fileName = '${_uuid.v4()}$extension';
      final filePath = '${imagesDir.path}/$fileName';

      // ファイルをコピー
      final file = File(filePath);
      await xfile.saveTo(filePath);

      // ファイルが正常に保存されたか確認
      if (!await file.exists()) {
        throw ImageStoreException('Failed to save image file');
      }

      return filePath;
    } catch (e) {
      throw ImageStoreException('Failed to save image: $e');
    }
  }

  /// 画像ファイルを削除
  /// 
  /// [filePath] 削除するファイルのパス
  /// 
  /// Throws: [ImageStoreException] 削除に失敗した場合
  static Future<void> deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw ImageStoreException('Failed to delete image: $e');
    }
  }

  /// ファイルが存在するかチェック
  /// 
  /// [filePath] チェックするファイルのパス
  /// 
  /// Returns: ファイルが存在する場合true
  static Future<bool> imageFileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// ファイル名から拡張子を取得
  /// 
  /// [fileName] ファイル名
  /// 
  /// Returns: 拡張子（.jpg, .png等）
  static String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < fileName.length - 1) {
      return fileName.substring(lastDotIndex);
    }
    
    // 拡張子が不明な場合は.jpgをデフォルトとする
    return '.jpg';
  }

  /// 画像ディレクトリのパスを取得
  /// 
  /// Returns: imagesディレクトリの絶対パス
  static Future<String> getImagesDirectoryPath() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    return '${documentsDir.path}/$_imagesDirectoryName';
  }

  /// 画像ディレクトリ内の全ファイルを取得
  /// 
  /// Returns: 画像ファイルのパスのリスト
  static Future<List<String>> getAllImageFiles() async {
    try {
      final imagesDir = Directory(await getImagesDirectoryPath());
      if (!await imagesDir.exists()) {
        return [];
      }

      final files = await imagesDir.list().toList();
      return files
          .whereType<File>()
          .map((file) => file.path)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 画像ディレクトリの使用容量を取得（バイト単位）
  /// 
  /// Returns: 使用容量（バイト）
  static Future<int> getImagesDirectorySize() async {
    try {
      final imagesDir = Directory(await getImagesDirectoryPath());
      if (!await imagesDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final file in imagesDir.list(recursive: true)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }
}

/// 画像保存関連の例外
class ImageStoreException implements Exception {
  final String message;
  
  const ImageStoreException(this.message);
  
  @override
  String toString() => 'ImageStoreException: $message';
}
