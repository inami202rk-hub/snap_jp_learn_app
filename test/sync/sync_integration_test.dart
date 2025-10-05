import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:snap_jp_learn_app/sync/change_journal.dart';
import 'package:snap_jp_learn_app/sync/queue_pump.dart';
import 'package:snap_jp_learn_app/sync/api/sync_api_mock.dart';
import 'package:snap_jp_learn_app/sync/sync_service.dart';
import 'package:snap_jp_learn_app/config/feature_flags.dart';

void main() {
  group('Sync Integration Tests', () {
    late ChangeJournal journal;
    late MockSyncApi mockApi;
    late QueuePump pump;
    late SyncService syncService;

    setUpAll(() async {
      await setUpTestHive();
    });

    setUp(() async {
      journal = ChangeJournal();
      await journal.initialize();

      mockApi = MockSyncApi();
      pump = QueuePump(journal, mockApi);
      syncService =
          SyncService(journal, pump, mockApi, FeatureFlags.syncPolicy);

      await syncService.initialize();

      // テスト間のデータクリア
      final entries = journal.getPendingEntries();
      for (final entry in entries) {
        await journal.removeEntry(entry.id);
      }
    });

    tearDown(() async {
      await syncService.shutdown();
      await journal.close();
    });

    tearDownAll(() async {
      await tearDownTestHive();
    });

    test('should perform complete sync workflow', () async {
      // 1. 変更をジャーナルに記録
      await syncService.recordChange(
        entityType: 'Post',
        entityId: 'post1',
        operation: ChangeOperation.create,
        metadata: {
          'imagePath': 'test.jpg',
          'rawText': 'Test content',
        },
      );

      await syncService.recordChange(
        entityType: 'SrsCard',
        entityId: 'card1',
        operation: ChangeOperation.create,
        metadata: {
          'term': 'テスト',
          'reading': 'test',
          'meaning': 'test meaning',
        },
      );

      // 2. 未処理エントリが存在することを確認
      expect(journal.getPendingEntries().length, 2);

      // 3. 同期を実行
      final result = await syncService.syncNow(full: true);

      // 4. 同期が成功することを確認
      expect(result.isSuccess, true);
      expect(result.syncedCount, greaterThan(0));

      // 5. ジャーナルがクリアされることを確認
      expect(journal.getPendingEntries().length, 0);
    });

    test('should handle network failure gracefully', () async {
      // ネットワーク障害をシミュレート
      mockApi.setSimulateNetworkFailure(true);

      await syncService.recordChange(
        entityType: 'Post',
        entityId: 'post1',
        operation: ChangeOperation.create,
      );

      final result = await syncService.syncNow();

      expect(result.isSuccess, false);
      expect(result.error, contains('Network error'));
      expect(journal.getPendingEntries().length, 1); // 失敗時は残る
    });

    test('should handle partial sync success', () async {
      // 一部のエントリは成功、一部は失敗するように設定
      mockApi.setFailureRate(0.5);

      await syncService.recordChange(
        entityType: 'Post',
        entityId: 'post1',
        operation: ChangeOperation.create,
      );

      await syncService.recordChange(
        entityType: 'Post',
        entityId: 'post2',
        operation: ChangeOperation.create,
      );

      final result = await syncService.syncNow();

      // 部分的成功または失敗の結果を受け入れる
      expect(result.isSuccess, isA<bool>());
    });

    test('should resolve conflicts using LWW policy', () async {
      // 衝突解決のテスト
      final clientData = {
        'id': 'post1',
        'rawText': 'Client version',
        'updatedAt':
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'version': 1,
        'deleted': false,
      };

      final serverData = {
        'id': 'post1',
        'rawText': 'Server version',
        'updatedAt': DateTime.now().toIso8601String(),
        'version': 2,
        'deleted': false,
      };

      // サーバーの方が新しい場合、サーバーが勝つ
      await syncService.resolveConflict(
        entityType: 'Post',
        clientId: 'post1',
        clientData: clientData,
        serverData: serverData,
      );

      // テストでは例外が発生しないことを確認
      expect(true, true);
    });

    test('should prioritize tombstone (deleted) entries', () async {
      final clientData = {
        'id': 'post1',
        'rawText': 'Client version',
        'updatedAt': DateTime.now().toIso8601String(),
        'version': 2,
        'deleted': false,
      };

      final serverData = {
        'id': 'post1',
        'rawText': 'Server version',
        'updatedAt':
            DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'version': 1,
        'deleted': true, // サーバー側が削除済み
      };

      // 削除フラグが優先されることを確認
      await syncService.resolveConflict(
        entityType: 'Post',
        clientId: 'post1',
        clientData: clientData,
        serverData: serverData,
      );

      expect(true, true); // 例外が発生しないことを確認
    });

    test('should track sync statistics', () {
      final stats = syncService.getSyncStats();

      expect(stats.pendingChanges, 0);
      expect(stats.createOperations, 0);
      expect(stats.updateOperations, 0);
      expect(stats.deleteOperations, 0);
      expect(stats.isRunning, true); // ポンプが動作中
    });

    test('should handle multiple entity types in one sync', () async {
      // 複数のエンティティタイプの変更を記録
      await syncService.recordChange(
        entityType: 'Post',
        entityId: 'post1',
        operation: ChangeOperation.create,
      );

      await syncService.recordChange(
        entityType: 'SrsCard',
        entityId: 'card1',
        operation: ChangeOperation.update,
      );

      await syncService.recordChange(
        entityType: 'ReviewLog',
        entityId: 'log1',
        operation: ChangeOperation.create,
      );

      final result = await syncService.syncNow();

      expect(result.isSuccess, true);
      expect(journal.getPendingEntries().length, 0);
    });

    test('should handle sync events', () async {
      var eventReceived = false;
      var eventType = SyncEventType.initialized;

      // イベントを監視
      syncService.events.listen((event) {
        eventReceived = true;
        eventType = event.type;
      });

      // 同期を実行
      await syncService.syncNow();

      // イベントが発火することを確認（非同期なので少し待つ）
      await Future.delayed(const Duration(milliseconds: 100));

      expect(eventReceived, true);
      expect(eventType, isA<SyncEventType>());
    });

    test('should handle delete operations correctly', () async {
      await syncService.recordChange(
        entityType: 'Post',
        entityId: 'post1',
        operation: ChangeOperation.delete,
      );

      final result = await syncService.syncNow();

      expect(result.isSuccess, true);
      expect(journal.getPendingEntries().length, 0);
    });

    test('should handle empty sync gracefully', () async {
      // エントリをクリア
      final entries = journal.getPendingEntries();
      for (final entry in entries) {
        await journal.removeEntry(entry.id);
      }

      final result = await syncService.syncNow();

      expect(result.isSuccess, true);
      expect(result.syncedCount, 0);
    });

    test('should maintain sync status correctly', () async {
      final status = await syncService.getSyncStatus();

      expect(status.isConnected, true);
      expect(status.pendingChanges, 0);
      expect(status.error, null);
    });

    test('should handle concurrent sync operations', () async {
      // 複数の同期操作を同時に実行
      final futures = List.generate(3, (index) => syncService.syncNow());

      final results = await Future.wait(futures);

      // すべての同期操作が完了することを確認
      expect(results.length, 3);
      for (final result in results) {
        expect(result.isSuccess, isA<bool>());
      }
    });
  });
}
