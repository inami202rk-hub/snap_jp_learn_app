import 'dart:io';
// import 'dart:typed_data'; // 未使用のためコメントアウト
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:image/image.dart' as img;
import 'package:snap_jp_learn_app/services/image_store.dart';
import 'package:snap_jp_learn_app/services/log_service.dart';
import 'package:snap_jp_learn_app/utils/isolate_helper.dart';

/// パフォーマンスベンチマークテスト
///
/// このテストは手動実行用で、CIではスキップされます。
/// ローカル環境でパフォーマンス測定を行う際に使用してください。
void main() {
  group('Performance Benchmarks', () {
    setUp(() async {
      // テスト用のHive初期化
      await setUpTestHive();
    });

    tearDown(() async {
      // Hiveをクリーンアップ
      await tearDownTestHive();
    });
    late Directory tempDir;
    late List<File> testImages;

    setUpAll(() async {
      // テスト用の一時ディレクトリを作成
      tempDir = await Directory.systemTemp.createTemp('benchmark_test_');

      // テスト用の画像ファイルを作成（複数サイズ）
      testImages = [];
      for (int i = 0; i < 20; i++) {
        final imageFile = File('${tempDir.path}/test_image_$i.png');
        final testImage = img.Image(width: 200 + i * 10, height: 200 + i * 10);
        img.fill(testImage, color: img.ColorRgb8(255 - i * 10, i * 10, 128));
        final pngBytes = img.encodePng(testImage);
        await imageFile.writeAsBytes(pngBytes);
        testImages.add(imageFile);
      }
    });

    tearDownAll(() async {
      // 一時ディレクトリを削除
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('thumbnail generation benchmark', () async {
      final stopwatch = Stopwatch()..start();

      // 20枚の画像でサムネイル生成をテスト
      for (final imageFile in testImages) {
        await ImageStore.getOrCreateThumbnail(
          imageFile.path,
          maxWidth: 100,
          maxHeight: 100,
        );
      }

      stopwatch.stop();

      print('📊 Thumbnail Generation Benchmark:');
      print('   - Images processed: ${testImages.length}');
      print('   - Total time: ${stopwatch.elapsedMilliseconds}ms');
      print(
          '   - Average per image: ${(stopwatch.elapsedMilliseconds / testImages.length).toStringAsFixed(1)}ms');
      print(
          '   - Throughput: ${(testImages.length * 1000 / stopwatch.elapsedMilliseconds).toStringAsFixed(1)} images/sec');

      // ベンチマーク結果をファイルに出力
      final results = {
        'benchmark': 'thumbnail_generation',
        'timestamp': DateTime.now().toIso8601String(),
        'images_count': testImages.length,
        'total_time_ms': stopwatch.elapsedMilliseconds,
        'avg_time_ms': stopwatch.elapsedMilliseconds / testImages.length,
        'throughput_images_per_sec':
            testImages.length * 1000 / stopwatch.elapsedMilliseconds,
      };

      final resultsFile = File('${tempDir.path}/thumbnail_benchmark.json');
      await resultsFile.writeAsString(results.toString());

      // パフォーマンス要件を満たしているかチェック
      expect(stopwatch.elapsedMilliseconds / testImages.length,
          lessThan(200)); // 200ms/image以下
    }, skip: true); // CIではスキップ

    test('thumbnail cache hit benchmark', () async {
      // 最初の画像でサムネイルを生成
      final firstImage = testImages.first;
      await ImageStore.getOrCreateThumbnail(
        firstImage.path,
        maxWidth: 150,
        maxHeight: 150,
      );

      // キャッシュヒット時の性能を測定
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        await ImageStore.getThumbnailBytes(
          firstImage.path,
          maxWidth: 150,
          maxHeight: 150,
        );
      }

      stopwatch.stop();

      print('📊 Thumbnail Cache Hit Benchmark:');
      print('   - Cache hits: 100');
      print('   - Total time: ${stopwatch.elapsedMilliseconds}ms');
      print(
          '   - Average per hit: ${(stopwatch.elapsedMilliseconds / 100).toStringAsFixed(1)}ms');

      // キャッシュヒット時の目標値（120ms以下）
      expect(stopwatch.elapsedMilliseconds / 100, lessThan(120));
    }, skip: true);

    test('text normalization benchmark', () async {
      final testTexts = List.generate(
          50,
          (index) =>
              'This is test text number $index with some Japanese characters これはテストテキストです。');

      final stopwatch = Stopwatch()..start();

      // 並列処理でのテキスト正規化
      final results = await IsolateHelper.normalizeTextsInParallel(testTexts);

      stopwatch.stop();

      print('📊 Text Normalization Benchmark:');
      print('   - Texts processed: ${testTexts.length}');
      print('   - Total time: ${stopwatch.elapsedMilliseconds}ms');
      print(
          '   - Average per text: ${(stopwatch.elapsedMilliseconds / testTexts.length).toStringAsFixed(1)}ms');
      print('   - Results count: ${results.length}');

      expect(results.length, equals(testTexts.length));
      expect(stopwatch.elapsedMilliseconds / testTexts.length,
          lessThan(100)); // 100ms/text以下
    }, skip: true);

    test('performance marker benchmark', () async {
      final logService = LogService();
      logService.clearPerformanceHistory();

      // 複数のパフォーマンスマーカーをテスト
      for (int i = 0; i < 10; i++) {
        logService.markStart('benchmark_operation_$i');

        // 模擬的な処理時間
        await Future.delayed(Duration(milliseconds: 10 + i));

        logService.markEnd('benchmark_operation_$i');
      }

      // 統計を取得
      final stats = logService.getPerformanceStatistics();

      print('📊 Performance Marker Benchmark:');
      print('   - Markers recorded: ${stats.length}');

      for (final entry in stats.entries) {
        final markerName = entry.key;
        final markerStats = entry.value as Map<String, dynamic>;
        print(
            '   - $markerName: avg=${markerStats['avgMs']}ms, count=${markerStats['count']}');
      }

      expect(stats.length, equals(10));
    }, skip: true);

    test('memory usage benchmark', () async {
      // メモリ使用量のベンチマーク
      final stopwatch = Stopwatch()..start();

      // 大量のサムネイルを生成してメモリ使用量をテスト
      final futures = <Future>[];
      for (int i = 0; i < testImages.length; i++) {
        futures.add(ImageStore.getOrCreateThumbnail(
          testImages[i].path,
          maxWidth: 50 + i * 5,
          maxHeight: 50 + i * 5,
        ));
      }

      await Future.wait(futures);
      stopwatch.stop();

      // サムネイルディレクトリのサイズを取得
      final thumbnailsSize = await ImageStore.getThumbnailsDirectorySize();

      print('📊 Memory Usage Benchmark:');
      print('   - Thumbnails generated: ${testImages.length}');
      print('   - Generation time: ${stopwatch.elapsedMilliseconds}ms');
      print(
          '   - Thumbnails directory size: ${(thumbnailsSize / 1024 / 1024).toStringAsFixed(2)}MB');

      // メモリ効率のチェック（1MB以下）
      expect(thumbnailsSize, lessThan(1024 * 1024));
    }, skip: true);

    test('comprehensive performance benchmark', () async {
      print('🚀 Starting Comprehensive Performance Benchmark...');

      final logService = LogService();
      logService.clearPerformanceHistory();

      // 全体のベンチマークを開始
      logService.markStart('comprehensive_benchmark');

      // 1. 画像処理ベンチマーク
      logService.markStart('image_processing');
      for (final imageFile in testImages.take(10)) {
        await ImageStore.getOrCreateThumbnail(
          imageFile.path,
          maxWidth: 100,
          maxHeight: 100,
        );
      }
      logService.markEnd('image_processing');

      // 2. テキスト処理ベンチマーク
      logService.markStart('text_processing');
      final testTexts =
          List.generate(20, (index) => 'Test text $index テストテキスト$index');
      await IsolateHelper.normalizeTextsInParallel(testTexts);
      logService.markEnd('text_processing');

      // 3. キャッシュヒットベンチマーク
      logService.markStart('cache_hits');
      for (int i = 0; i < 50; i++) {
        await ImageStore.getThumbnailBytes(
          testImages.first.path,
          maxWidth: 100,
          maxHeight: 100,
        );
      }
      logService.markEnd('cache_hits');

      // 全体のベンチマークを終了
      logService.markEnd('comprehensive_benchmark');

      // 結果を出力
      final stats = logService.getPerformanceStatistics();

      print('📊 Comprehensive Benchmark Results:');
      print('=====================================');

      for (final entry in stats.entries) {
        final markerName = entry.key;
        final markerStats = entry.value as Map<String, dynamic>;
        print('$markerName:');
        print('  - Count: ${markerStats['count']}');
        print('  - Average: ${markerStats['avgMs']}ms');
        print('  - Min: ${markerStats['minMs']}ms');
        print('  - Max: ${markerStats['maxMs']}ms');
        print('  - Median: ${markerStats['medianMs']}ms');
        print('');
      }

      // ベンチマーク結果をJSONファイルに保存
      final benchmarkResults = {
        'timestamp': DateTime.now().toIso8601String(),
        'benchmark_type': 'comprehensive',
        'performance_stats': stats,
        'test_images_count': testImages.length,
        'test_texts_count': testTexts.length,
      };

      final resultsFile = File('${tempDir.path}/comprehensive_benchmark.json');
      await resultsFile.writeAsString(benchmarkResults.toString());

      print('📁 Benchmark results saved to: ${resultsFile.path}');

      // パフォーマンス要件の確認
      expect(stats.containsKey('image_processing'), isTrue);
      expect(stats.containsKey('text_processing'), isTrue);
      expect(stats.containsKey('cache_hits'), isTrue);
    }, skip: true);
  });
}
