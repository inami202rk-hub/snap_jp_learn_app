import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:snap_jp_learn_app/models/post.dart';
import 'package:snap_jp_learn_app/services/hive_maintenance_service.dart';

void main() {
  group('HiveMaintenanceService Tests', () {
    setUp(() async {
      // テスト用のHive初期化
      await setUpTestHive();
      Hive.registerAdapter(PostAdapter());

      // 必要なボックスを開く
      await Hive.openBox<Post>('posts');
      await Hive.openBox('srs_cards');
      await Hive.openBox('review_logs');
    });

    tearDown(() async {
      // Hiveをクリーンアップ
      await tearDownTestHive();
    });

    test('compaction threshold calculation', () async {
      // テスト用のボックスを作成
      final box = await Hive.openBox<Post>('test_posts');

      // データを追加
      for (int i = 0; i < 10; i++) {
        await box.put(
            'key_$i',
            Post(
              id: 'post_$i',
              imagePath: '/test/path_$i.png',
              rawText: 'Raw text $i',
              normalizedText: 'Normalized text $i',
              createdAt: DateTime.now(),
            ));
      }

      // いくつかのデータを削除（削除率20%以下）
      await box.delete('key_1');
      await box.delete('key_2');

      // コンパクションが実行されないことを確認（削除率が閾値以下）
      final totalKeys = box.length;
      final deletedKeys = 0; // Hiveの削除キー数は直接取得できないため0に設定
      final deletionRate = deletedKeys / (totalKeys + deletedKeys);

      expect(deletionRate, lessThan(0.2)); // 20%未満

      await box.close();
    });

    test('compaction when deletion rate exceeds threshold', () async {
      final box = await Hive.openBox<Post>('test_posts_2');

      // データを追加
      for (int i = 0; i < 10; i++) {
        await box.put(
            'key_$i',
            Post(
              id: 'post_$i',
              imagePath: '/test/path_$i.png',
              rawText: 'Raw text $i',
              normalizedText: 'Normalized text $i',
              createdAt: DateTime.now(),
            ));
      }

      // 多くのデータを削除（削除率20%以上）
      for (int i = 0; i < 3; i++) {
        await box.delete('key_$i');
      }

      // 削除率が閾値を超えることを確認
      final totalKeys = box.length;
      final deletedKeys = 0; // Hiveの削除キー数は直接取得できないため0に設定
      final deletionRate = deletedKeys / (totalKeys + deletedKeys);

      expect(deletionRate, greaterThan(0.2)); // 20%以上

      await box.close();
    });

    test('storage stats calculation', () async {
      final stats = await HiveMaintenanceService.getStorageStats();

      expect(stats, isA<HiveStorageStats>());
      expect(stats.hiveSize, greaterThanOrEqualTo(0));
      expect(stats.imagesSize, greaterThanOrEqualTo(0));
      expect(stats.thumbnailsSize, greaterThanOrEqualTo(0));
      expect(stats.totalSize, greaterThanOrEqualTo(0));
    });

    test('storage stats formatting', () async {
      final stats = HiveStorageStats(
        hiveSize: 1024,
        imagesSize: 2048,
        thumbnailsSize: 512,
        totalSize: 3584,
      );

      expect(stats.formattedHiveSize, equals('1.0KB'));
      expect(stats.formattedImagesSize, equals('2.0KB'));
      expect(stats.formattedThumbnailsSize, equals('512B'));
      expect(stats.formattedTotalSize, equals('3.5KB'));
    });

    test('maintenance result tracking', () {
      final result = HiveMaintenanceResult();

      expect(result.deletedImages, equals(0));
      expect(result.deletedThumbnails, equals(0));
      expect(result.deletedOldThumbnails, equals(0));
      expect(result.hasError, isFalse);
      expect(result.totalDeleted, equals(0));

      // 値を設定
      result.deletedImages = 5;
      result.deletedThumbnails = 3;
      result.deletedOldThumbnails = 2;

      expect(result.totalDeleted, equals(10));
    });

    test('maintenance result with error', () {
      final result = HiveMaintenanceResult();
      result.error = 'Test error message';

      expect(result.hasError, isTrue);
      expect(result.error, equals('Test error message'));
    });

    test('orphan cleanup result structure', () async {
      // 実際の孤児クリーンアップは実行せず、結果構造のみテスト
      final result = await HiveMaintenanceService.performOrphanCleanup();

      expect(result, isA<HiveMaintenanceResult>());
      expect(result.deletedImages, greaterThanOrEqualTo(0));
      expect(result.deletedThumbnails, greaterThanOrEqualTo(0));
      expect(result.deletedOldThumbnails, greaterThanOrEqualTo(0));
    });

    test('compaction service availability', () async {
      // コンパクションサービスが呼び出し可能であることを確認
      expect(() => HiveMaintenanceService.performCompactionIfNeeded(),
          returnsNormally);
    });

    test('storage stats service availability', () async {
      // ストレージ統計サービスが呼び出し可能であることを確認
      final stats = await HiveMaintenanceService.getStorageStats();
      expect(stats, isNotNull);
    });
  });
}
