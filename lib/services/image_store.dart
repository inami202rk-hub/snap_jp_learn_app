import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStore {
  static const String _imagesDirectoryName = 'images';
  static const String _thumbnailsDirectoryName = 'thumbnails';
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
      return files.whereType<File>().map((file) => file.path).toList();
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

  /// サムネイルを取得または生成
  ///
  /// [imagePath] 元画像のパス
  /// [maxWidth] サムネイルの最大幅（デフォルト: 512）
  /// [maxHeight] サムネイルの最大高さ（デフォルト: 512）
  ///
  /// Returns: サムネイルファイルのパス
  /// Throws: [ImageStoreException] 生成に失敗した場合
  static Future<String> getOrCreateThumbnail(
    String imagePath, {
    int maxWidth = 512,
    int maxHeight = 512,
  }) async {
    try {
      // サムネイルディレクトリを取得
      final documentsDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir =
          Directory('${documentsDir.path}/$_thumbnailsDirectoryName');

      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }

      // サムネイルファイル名を生成（元画像のハッシュベース）
      final originalFile = File(imagePath);
      final originalStat = await originalFile.stat();
      final thumbnailFileName =
          '${originalFile.path.hashCode}_${originalStat.modified.millisecondsSinceEpoch}_${maxWidth}x$maxHeight.jpg';
      final thumbnailPath = '${thumbnailsDir.path}/$thumbnailFileName';

      // 既にサムネイルが存在する場合はそれを返す
      final thumbnailFile = File(thumbnailPath);
      if (await thumbnailFile.exists()) {
        return thumbnailPath;
      }

      // サムネイルを生成
      await _generateThumbnail(imagePath, thumbnailPath, maxWidth, maxHeight);

      return thumbnailPath;
    } catch (e) {
      throw ImageStoreException('Failed to create thumbnail: $e');
    }
  }

  /// サムネイルを生成
  static Future<void> _generateThumbnail(
    String imagePath,
    String thumbnailPath,
    int maxWidth,
    int maxHeight,
  ) async {
    try {
      // 元画像を読み込み
      final imageBytes = await File(imagePath).readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw ImageStoreException('Failed to decode image');
      }

      // リサイズ計算
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (newWidth > maxWidth || newHeight > maxHeight) {
        final aspectRatio = newWidth / newHeight;

        if (newWidth > newHeight) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
          if (newHeight > maxHeight) {
            newHeight = maxHeight;
            newWidth = (maxHeight * aspectRatio).round();
          }
        } else {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
          if (newWidth > maxWidth) {
            newWidth = maxWidth;
            newHeight = (maxWidth / aspectRatio).round();
          }
        }
      }

      // サムネイルを生成
      final thumbnail = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // JPEGとして保存（品質85%でバランス取る）
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 85);
      await File(thumbnailPath).writeAsBytes(thumbnailBytes);
    } catch (e) {
      throw ImageStoreException('Failed to generate thumbnail: $e');
    }
  }

  /// サムネイルのバイトデータを取得
  ///
  /// [imagePath] 元画像のパス
  /// [maxWidth] サムネイルの最大幅
  /// [maxHeight] サムネイルの最大高さ
  ///
  /// Returns: サムネイルのバイトデータ
  static Future<Uint8List> getThumbnailBytes(
    String imagePath, {
    int maxWidth = 512,
    int maxHeight = 512,
  }) async {
    try {
      final thumbnailPath = await getOrCreateThumbnail(
        imagePath,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      return await File(thumbnailPath).readAsBytes();
    } catch (e) {
      // 大画像処理失敗時は縮小再試行（1回）
      try {
        final reducedThumbnailPath = await getOrCreateThumbnail(
          imagePath,
          maxWidth: maxWidth ~/ 2,
          maxHeight: maxHeight ~/ 2,
        );
        return await File(reducedThumbnailPath).readAsBytes();
      } catch (retryError) {
        throw ImageStoreException(
            'Failed to get thumbnail bytes (retry failed): $retryError');
      }
    }
  }

  /// サムネイルファイルを削除
  ///
  /// [imagePath] 元画像のパス
  static Future<void> deleteThumbnail(String imagePath) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir =
          Directory('${documentsDir.path}/$_thumbnailsDirectoryName');

      if (!await thumbnailsDir.exists()) {
        return;
      }

      // この画像に関連する全てのサムネイルを削除
      final files = await thumbnailsDir.list().toList();
      final originalFileHash = imagePath.hashCode;

      for (final file in files) {
        if (file is File && file.path.contains(originalFileHash.toString())) {
          await file.delete();
        }
      }
    } catch (e) {
      // サムネイル削除の失敗は無視（元画像は残る）
    }
  }

  /// 孤児サムネイルを掃除（元画像が存在しないサムネイルを削除）
  ///
  /// Returns: 削除されたサムネイルの数
  static Future<int> cleanupOrphanThumbnails() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir =
          Directory('${documentsDir.path}/$_thumbnailsDirectoryName');

      if (!await thumbnailsDir.exists()) {
        return 0;
      }

      int deletedCount = 0;
      final files = await thumbnailsDir.list().toList();

      for (final file in files) {
        if (file is File) {
          // サムネイルファイル名から元画像のパスを推測
          final fileName = file.path.split('/').last;
          final parts = fileName.split('_');
          if (parts.length >= 2) {
            // ハッシュ値から元画像を探す（簡易実装）
            final hashString = parts[0];
            final allImages = await getAllImageFiles();
            bool found = false;

            for (final imagePath in allImages) {
              if (imagePath.hashCode.toString() == hashString) {
                found = true;
                break;
              }
            }

            if (!found) {
              await file.delete();
              deletedCount++;
            }
          }
        }
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }

  /// サムネイルディレクトリの使用容量を取得（バイト単位）
  ///
  /// Returns: 使用容量（バイト）
  static Future<int> getThumbnailsDirectorySize() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir =
          Directory('${documentsDir.path}/$_thumbnailsDirectoryName');

      if (!await thumbnailsDir.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final file in thumbnailsDir.list(recursive: true)) {
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
