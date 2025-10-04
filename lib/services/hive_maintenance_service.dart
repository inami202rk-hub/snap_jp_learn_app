import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../services/log_service.dart';
import '../services/image_store.dart';

/// Hiveデータベースのメンテナンス機能を提供するサービス
class HiveMaintenanceService {
  static const int _compactionKeyThreshold = 1000; // 1000キー以上でコンパクション実行
  static const int _maxOrphanCleanupAge = 7; // 7日以上古い孤児ファイルを削除

  /// 必要に応じてHiveコンパクションを実行
  ///
  /// 削除率が閾値を超えた場合にコンパクションを実行します。
  /// 各ボックスに対して個別にコンパクションを実行します。
  static Future<void> performCompactionIfNeeded() async {
    try {
      LogService().logInfo('Hive maintenance: Starting compaction check');

      final boxes = ['posts', 'srs_cards', 'review_logs'];
      bool compactionPerformed = false;

      for (final boxName in boxes) {
        try {
          final box = Hive.box(boxName);
          if (!box.isOpen) continue;

          final totalKeys = box.length;

          LogService().logInfo(
              'Hive maintenance: Box $boxName - Total keys: $totalKeys');

          // 定期的なコンパクション（キー数が多い場合）
          if (totalKeys > _compactionKeyThreshold) {
            LogService().logInfo(
                'Hive maintenance: Compacting box $boxName (large size: $totalKeys keys)');
            await box.compact();
            compactionPerformed = true;
          }
        } catch (e) {
          LogService()
              .logError('Hive maintenance: Failed to compact box $boxName: $e');
        }
      }

      if (compactionPerformed) {
        LogService().logInfo('Hive maintenance: Compaction completed');
      } else {
        LogService().logInfo('Hive maintenance: No compaction needed');
      }
    } catch (e) {
      LogService().logError('Hive maintenance: Compaction failed: $e');
    }
  }

  /// 孤児ファイルのクリーンアップを実行
  ///
  /// データベースに存在しない画像ファイルとサムネイルを削除します。
  /// 週1回のメンテナンスとして実行されることを想定しています。
  static Future<HiveMaintenanceResult> performOrphanCleanup() async {
    try {
      LogService().logInfo('Hive maintenance: Starting orphan cleanup');

      final result = HiveMaintenanceResult();

      // 1. データベースから有効な画像パスを取得
      final validImagePaths = await _getValidImagePaths();
      LogService().logInfo(
          'Hive maintenance: Found ${validImagePaths.length} valid image paths');

      // 2. Documents/images ディレクトリから孤児ファイルを検出・削除
      final documentsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${documentsDir.path}/images');

      if (await imagesDir.exists()) {
        final imageFiles = await imagesDir.list().toList();
        for (final file in imageFiles) {
          if (file is File) {
            final relativePath =
                file.path.replaceFirst('${documentsDir.path}/', '');
            if (!validImagePaths.contains(relativePath)) {
              try {
                await file.delete();
                result.deletedImages++;
                LogService().logInfo(
                    'Hive maintenance: Deleted orphan image: ${file.path}');
              } catch (e) {
                LogService().logError(
                    'Hive maintenance: Failed to delete orphan image ${file.path}: $e');
              }
            }
          }
        }
      }

      // 3. 孤児サムネイルのクリーンアップ
      final thumbnailCleanupResult = await ImageStore.cleanupOrphanThumbnails();
      result.deletedThumbnails = thumbnailCleanupResult;

      // 4. 古いサムネイルファイルの削除（7日以上古い）
      await _cleanupOldThumbnails(result);

      LogService().logInfo('Hive maintenance: Orphan cleanup completed - '
          'Images: ${result.deletedImages}, Thumbnails: ${result.deletedThumbnails}, '
          'Old thumbnails: ${result.deletedOldThumbnails}');

      return result;
    } catch (e) {
      LogService().logError('Hive maintenance: Orphan cleanup failed: $e');
      return HiveMaintenanceResult()..error = e.toString();
    }
  }

  /// データベースから有効な画像パスを取得
  static Future<Set<String>> _getValidImagePaths() async {
    final validPaths = <String>{};

    try {
      // Posts から画像パスを取得
      final postsBox = Hive.box('posts');
      for (final post in postsBox.values) {
        if (post.imagePath.isNotEmpty) {
          // 絶対パスから相対パスに変換
          final documentsDir = await getApplicationDocumentsDirectory();
          final relativePath =
              post.imagePath.replaceFirst('${documentsDir.path}/', '');
          validPaths.add(relativePath);
        }
      }

      // SRSカードから画像パスを取得（もしあれば）
      final srsBox = Hive.box('srs_cards');
      for (final _ in srsBox.values) {
        // SRSカードに画像パスがある場合は追加
        // 現在のモデルには画像パスがないため、将来の拡張に対応
      }
    } catch (e) {
      LogService()
          .logError('Hive maintenance: Failed to get valid image paths: $e');
    }

    return validPaths;
  }

  /// 古いサムネイルファイルを削除
  static Future<void> _cleanupOldThumbnails(
      HiveMaintenanceResult result) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory('${documentsDir.path}/thumbnails');

      if (!await thumbnailsDir.exists()) return;

      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: _maxOrphanCleanupAge));

      final thumbnailFiles = await thumbnailsDir.list().toList();
      for (final file in thumbnailFiles) {
        if (file is File) {
          try {
            final stat = await file.stat();
            if (stat.modified.isBefore(cutoffDate)) {
              await file.delete();
              result.deletedOldThumbnails++;
              LogService().logInfo(
                  'Hive maintenance: Deleted old thumbnail: ${file.path}');
            }
          } catch (e) {
            LogService().logError(
                'Hive maintenance: Failed to delete old thumbnail ${file.path}: $e');
          }
        }
      }
    } catch (e) {
      LogService()
          .logError('Hive maintenance: Failed to cleanup old thumbnails: $e');
    }
  }

  /// ストレージ使用量の統計を取得
  static Future<HiveStorageStats> getStorageStats() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();

      // Hiveファイルのサイズを取得
      int hiveSize = 0;
      final hiveFiles = ['posts.hive', 'srs_cards.hive', 'review_logs.hive'];

      for (final fileName in hiveFiles) {
        final file = File('${documentsDir.path}/$fileName');
        if (await file.exists()) {
          final stat = await file.stat();
          hiveSize += stat.size;
        }
      }

      // 画像ディレクトリのサイズを取得
      int imagesSize = 0;
      final imagesDir = Directory('${documentsDir.path}/images');
      if (await imagesDir.exists()) {
        final files = await imagesDir.list().toList();
        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            imagesSize += stat.size;
          }
        }
      }

      // サムネイルディレクトリのサイズを取得
      final thumbnailsSize = await ImageStore.getThumbnailsDirectorySize();

      return HiveStorageStats(
        hiveSize: hiveSize,
        imagesSize: imagesSize,
        thumbnailsSize: thumbnailsSize,
        totalSize: hiveSize + imagesSize + thumbnailsSize,
      );
    } catch (e) {
      LogService()
          .logError('Hive maintenance: Failed to get storage stats: $e');
      return HiveStorageStats();
    }
  }
}

/// Hiveメンテナンスの結果
class HiveMaintenanceResult {
  int deletedImages = 0;
  int deletedThumbnails = 0;
  int deletedOldThumbnails = 0;
  String? error;

  bool get hasError => error != null;

  int get totalDeleted =>
      deletedImages + deletedThumbnails + deletedOldThumbnails;
}

/// ストレージ使用量の統計
class HiveStorageStats {
  final int hiveSize;
  final int imagesSize;
  final int thumbnailsSize;
  final int totalSize;

  HiveStorageStats({
    this.hiveSize = 0,
    this.imagesSize = 0,
    this.thumbnailsSize = 0,
    this.totalSize = 0,
  });

  String get formattedHiveSize => _formatBytes(hiveSize);
  String get formattedImagesSize => _formatBytes(imagesSize);
  String get formattedThumbnailsSize => _formatBytes(thumbnailsSize);
  String get formattedTotalSize => _formatBytes(totalSize);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
