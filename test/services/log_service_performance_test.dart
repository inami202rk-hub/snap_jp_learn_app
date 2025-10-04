import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/log_service.dart';

void main() {
  group('LogService Performance Marker Tests', () {
    late LogService logService;

    setUp(() {
      logService = LogService();
      logService.clearLogs();
      logService.clearPerformanceHistory();
    });

    test('performance marker start and end', () {
      // マーカーを開始
      logService.markStart('test_operation', metadata: {'type': 'unit_test'});

      // 少し待機
      Future.delayed(const Duration(milliseconds: 10));

      // マーカーを終了
      logService
          .markEnd('test_operation', additionalData: {'result': 'success'});

      // アクティブなマーカーが存在しないことを確認
      final activeMarkers = logService.getActiveMarkers();
      expect(activeMarkers.containsKey('test_operation'), isFalse);

      // パフォーマンス統計を確認
      final stats = logService.getMarkerStatistics('test_operation');
      expect(stats, isNotNull);
      expect(stats!['count'], equals(1));
      expect(stats['avgMs'], isNotNull);
      expect(stats['minMs'], isNotNull);
      expect(stats['maxMs'], isNotNull);
    });

    test('multiple performance markers', () {
      // 複数のマーカーを実行
      for (int i = 0; i < 3; i++) {
        logService.markStart('test_operation_$i');
        Future.delayed(const Duration(milliseconds: 5));
        logService.markEnd('test_operation_$i');
      }

      // 各マーカーの統計を確認
      for (int i = 0; i < 3; i++) {
        final stats = logService.getMarkerStatistics('test_operation_$i');
        expect(stats, isNotNull);
        expect(stats!['count'], equals(1));
      }
    });

    test('performance statistics aggregation', () {
      // 同じ名前のマーカーを複数回実行
      for (int i = 0; i < 5; i++) {
        logService.markStart('repeated_operation');
        Future.delayed(const Duration(milliseconds: 2));
        logService.markEnd('repeated_operation');
      }

      // 統計を確認
      final stats = logService.getMarkerStatistics('repeated_operation');
      expect(stats, isNotNull);
      expect(stats!['count'], equals(5));
      expect(stats['recentTimes'], isA<List>());
      expect(stats['recentTimes'].length, lessThanOrEqualTo(10));
    });

    test('performance marker without start throws warning', () {
      // 開始していないマーカーを終了
      logService.markEnd('non_existent_marker');

      // 警告ログが記録されることを確認
      final logs = logService.getLogs(tag: 'perf');
      final warningLogs = logs
          .where((log) =>
              log.level == LogLevel.warning &&
              log.message.contains('Performance marker not found'))
          .toList();

      expect(warningLogs.isNotEmpty, isTrue);
    });

    test('active markers tracking', () {
      // 複数のアクティブなマーカーを開始
      logService.markStart('operation_1');
      logService.markStart('operation_2');
      logService.markStart('operation_3');

      // アクティブなマーカーを確認
      final activeMarkers = logService.getActiveMarkers();
      expect(activeMarkers.length, equals(3));
      expect(activeMarkers.containsKey('operation_1'), isTrue);
      expect(activeMarkers.containsKey('operation_2'), isTrue);
      expect(activeMarkers.containsKey('operation_3'), isTrue);

      // 1つを終了
      logService.markEnd('operation_1');

      // アクティブなマーカーが減ることを確認
      final activeMarkersAfter = logService.getActiveMarkers();
      expect(activeMarkersAfter.length, equals(2));
      expect(activeMarkersAfter.containsKey('operation_1'), isFalse);
    });

    test('performance history limit', () {
      // 51回実行して履歴の上限をテスト
      for (int i = 0; i < 51; i++) {
        logService.markStart('limited_operation');
        logService.markEnd('limited_operation');
      }

      // 履歴が50件に制限されることを確認
      final stats = logService.getMarkerStatistics('limited_operation');
      expect(stats, isNotNull);
      expect(stats!['count'], equals(50)); // 最大50件
    });

    test('performance statistics overview', () {
      // 複数の異なるマーカーを実行
      logService.markStart('operation_a');
      logService.markEnd('operation_a');

      logService.markStart('operation_b');
      logService.markEnd('operation_b');

      logService.markStart('operation_c');
      logService.markEnd('operation_c');

      // 全体の統計を取得
      final allStats = logService.getPerformanceStatistics();

      expect(allStats.containsKey('operation_a'), isTrue);
      expect(allStats.containsKey('operation_b'), isTrue);
      expect(allStats.containsKey('operation_c'), isTrue);

      // 各統計に必要なフィールドがあることを確認
      for (final operation in ['operation_a', 'operation_b', 'operation_c']) {
        final stats = allStats[operation] as Map<String, dynamic>;
        expect(stats.containsKey('count'), isTrue);
        expect(stats.containsKey('avgMs'), isTrue);
        expect(stats.containsKey('minMs'), isTrue);
        expect(stats.containsKey('maxMs'), isTrue);
        expect(stats.containsKey('medianMs'), isTrue);
        expect(stats.containsKey('recentTimes'), isTrue);
      }
    });

    test('performance history cleanup', () {
      // いくつかのマーカーを実行
      logService.markStart('cleanup_test');
      logService.markEnd('cleanup_test');

      // 履歴をクリア
      logService.clearPerformanceHistory();

      // 統計が空になることを確認
      final stats = logService.getMarkerStatistics('cleanup_test');
      expect(stats, isNull);

      // アクティブなマーカーもクリアされることを確認
      final activeMarkers = logService.getActiveMarkers();
      expect(activeMarkers.isEmpty, isTrue);
    });
  });
}
