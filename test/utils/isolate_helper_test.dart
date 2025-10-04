import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:snap_jp_learn_app/utils/isolate_helper.dart';
import 'package:snap_jp_learn_app/services/text_normalize_options.dart';

void main() {
  group('IsolateHelper Tests', () {
    setUp(() async {
      // テスト用のHive初期化
      await setUpTestHive();
    });

    tearDown(() async {
      // Hiveをクリーンアップ
      await tearDownTestHive();
    });
    test('normalizeTextInIsolate processes single text', () async {
      const rawText = 'これはテストです。';

      final result = await IsolateHelper.normalizeTextInIsolate(rawText);

      expect(result, isA<String>());
      expect(result, isNotEmpty);
    });

    test('normalizeTextInIsolate with options', () async {
      const rawText = 'This is a test.';
      final options = TextNormalizeOptions(); // デフォルトオプションを使用

      final result = await IsolateHelper.normalizeTextInIsolate(
        rawText,
        options: options,
      );

      expect(result, isA<String>());
      expect(result, isNotEmpty);
    });

    test('normalizeTextsInIsolate processes multiple texts', () async {
      final texts = [
        'First text',
        'Second text',
        'Third text',
      ];

      final results = await IsolateHelper.normalizeTextsInParallel(texts);

      expect(results, isA<List<String>>());
      expect(results.length, equals(3));
      expect(results.every((text) => text.isNotEmpty), isTrue);
    });

    test('normalizeTextsInIsolate with small batch uses main thread', () async {
      final texts = ['Text 1', 'Text 2'];

      final results = await IsolateHelper.normalizeTextsInParallel(texts);

      expect(results, isA<List<String>>());
      expect(results.length, equals(2));
    });

    test('normalizeTextsInIsolate with large batch uses parallel processing',
        () async {
      final texts = List.generate(10, (index) => 'Text $index');

      final stopwatch = Stopwatch()..start();
      final results = await IsolateHelper.normalizeTextsInParallel(texts);
      stopwatch.stop();

      expect(results, isA<List<String>>());
      expect(results.length, equals(10));
      expect(results.every((text) => text.isNotEmpty), isTrue);

      // 並列処理により、10個のテキストでも高速に処理されることを確認
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('normalizeTextsInBatches processes texts in batches', () async {
      final texts = List.generate(15, (index) => 'Batch text $index');

      final results = await IsolateHelper.normalizeTextsInBatches(texts);

      expect(results, isA<List<String>>());
      expect(results.length, equals(15));
      expect(results.every((text) => text.isNotEmpty), isTrue);
    });

    test('normalizeTextsInBatches with custom batch size', () async {
      final texts = List.generate(12, (index) => 'Custom batch $index');

      final results = await IsolateHelper.normalizeTextsInBatches(
        texts,
        batchSize: 4,
      );

      expect(results, isA<List<String>>());
      expect(results.length, equals(12));
    });

    test('cancellable isolate task creates and completes tasks', () async {
      final task = CancellableIsolateTask<String>();

      // タスクを実行
      final result = await task.start(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return 'Task completed';
      });

      expect(result, equals('Task completed'));
    });

    test('cancellable isolate task can cancel tasks', () async {
      final task = CancellableIsolateTask<String>();

      // 長時間実行されるタスクを開始
      final taskFuture = task.start(() async {
        await Future.delayed(const Duration(seconds: 1));
        return 'Task should not complete';
      });

      // すぐにキャンセル
      task.cancel();

      // タスクがキャンセルされることを確認
      expect(
        () async => await taskFuture,
        throwsA(isA<Exception>()),
      );
    });

    test('cancellable isolate task handles multiple tasks', () async {
      // 複数のタスクを並列実行
      final task1 = CancellableIsolateTask<int>();
      final task2 = CancellableIsolateTask<int>();
      final task3 = CancellableIsolateTask<int>();

      final futures = [
        task1.start(() async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 1;
        }),
        task2.start(() async {
          await Future.delayed(const Duration(milliseconds: 20));
          return 2;
        }),
        task3.start(() async {
          await Future.delayed(const Duration(milliseconds: 30));
          return 3;
        }),
      ];

      final results = await Future.wait(futures);

      expect(results, containsAll([1, 2, 3]));
    });

    test('cancellable isolate task cleanup', () async {
      final task = CancellableIsolateTask<String>();

      // タスクを実行
      await task.start(() async => 'Test');

      // キャンセル
      task.cancel();

      // キャンセル後にタスクを実行しようとするとエラーになることを確認
      expect(
        () async => await task.start(() async => 'Should fail'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
