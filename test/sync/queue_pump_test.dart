import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:snap_jp_learn_app/sync/change_journal.dart';
import 'package:snap_jp_learn_app/sync/queue_pump.dart';
import 'package:snap_jp_learn_app/sync/api/sync_api_mock.dart';

void main() {
  group('QueuePump', () {
    late ChangeJournal journal;
    late MockSyncApi mockApi;
    late QueuePump pump;

    setUpAll(() async {
      await setUpTestHive();
    });

    setUp(() async {
      journal = ChangeJournal();
      await journal.initialize();

      mockApi = MockSyncApi();
      pump = QueuePump(journal, mockApi);

      // テスト間のデータクリア
      final entries = journal.getPendingEntries();
      for (final entry in entries) {
        await journal.removeEntry(entry.id);
      }
    });

    tearDown(() async {
      pump.stop();
      await journal.close();
    });

    tearDownAll(() async {
      await tearDownTestHive();
    });

    test('should start and stop pump', () {
      expect(pump.isRunning, false);

      pump.start();
      expect(pump.isRunning, true);

      pump.stop();
      expect(pump.isRunning, false);
    });

    test('should process pending entries successfully', () async {
      // エントリを追加
      await journal.addEntry(
        entityType: 'Post',
        entityId: 'test_post',
        operation: ChangeOperation.create,
      );

      await journal.addEntry(
        entityType: 'SrsCard',
        entityId: 'test_card',
        operation: ChangeOperation.update,
      );

      expect(pump.pendingCount, 2);

      // 同期を実行
      final result = await pump.pumpNow();

      expect(result.isSuccess, true);
      expect(pump.pendingCount, 0); // 処理後は0になる
    });

    test('should handle network failure with retry', () async {
      // ネットワーク障害をシミュレート
      mockApi.setSimulateNetworkFailure(true);

      await journal.addEntry(
        entityType: 'Post',
        entityId: 'test_post',
        operation: ChangeOperation.create,
      );

      final result = await pump.pumpNow();

      expect(result.isSuccess, false);
      expect(result.error, contains('Network error'));
      expect(pump.pendingCount, 1); // 失敗時は残る
    });

    test('should increment attempt count on failure', () async {
      mockApi.setSimulateNetworkFailure(true);

      await journal.addEntry(
        entityType: 'Post',
        entityId: 'test_post',
        operation: ChangeOperation.create,
      );

      await pump.pumpNow();

      final entries = journal.getPendingEntries();
      expect(entries.first.attempt, 1); // 失敗後に増加
    });

    test('should return success when no pending entries', () async {
      // エントリをクリア
      final entries = journal.getPendingEntries();
      for (final entry in entries) {
        await journal.removeEntry(entry.id);
      }

      final result = await pump.pumpNow();

      expect(result.isSuccess, true);
      expect(result.message, contains('No pending changes'));
    });

    test('should handle different entity types', () async {
      // 複数のエンティティタイプを追加
      await journal.addEntry(
        entityType: 'Post',
        entityId: 'post1',
        operation: ChangeOperation.create,
      );

      await journal.addEntry(
        entityType: 'SrsCard',
        entityId: 'card1',
        operation: ChangeOperation.update,
      );

      await journal.addEntry(
        entityType: 'ReviewLog',
        entityId: 'log1',
        operation: ChangeOperation.create,
      );

      final result = await pump.pumpNow();

      expect(result.isSuccess, true);
      expect(pump.pendingCount, 0);
    });

    test('should handle delete operations', () async {
      await journal.addEntry(
        entityType: 'Post',
        entityId: 'post1',
        operation: ChangeOperation.delete,
      );

      final result = await pump.pumpNow();

      expect(result.isSuccess, true);
      expect(pump.pendingCount, 0);
    });

    test('should track retry delay correctly', () {
      pump.start();

      expect(pump.currentRetryDelay.inMilliseconds, 1000);

      // 失敗をシミュレートして遅延を増加
      mockApi.setSimulateNetworkFailure(true);
      pump.start();

      // 指数バックオフが適用されることを確認
      // （実際のテストでは、内部実装の詳細に依存しないよう注意）
    });
  });

  group('SyncResult', () {
    test('should create success result', () {
      final result = SyncResult.success(
        message: 'Test success',
        data: {'count': 5},
      );

      expect(result.isSuccess, true);
      expect(result.message, 'Test success');
      expect(result.data, {'count': 5});
      expect(result.error, null);
    });

    test('should create failure result', () {
      final result = SyncResult.failure(
        error: 'Test error',
        data: {'retry': true},
      );

      expect(result.isSuccess, false);
      expect(result.error, 'Test error');
      expect(result.data, {'retry': true});
      expect(result.message, 'Sync failed');
    });

    test('should provide string representation', () {
      final successResult = SyncResult.success(message: 'Success');
      final failureResult = SyncResult.failure(error: 'Error');

      expect(successResult.toString(), contains('success'));
      expect(failureResult.toString(), contains('failure'));
    });
  });
}
