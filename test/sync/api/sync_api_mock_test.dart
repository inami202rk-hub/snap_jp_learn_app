import 'package:flutter_test/flutter_test.dart';
import 'package:hive_test/hive_test.dart';
import 'package:snap_jp_learn_app/sync/api/sync_api_mock.dart';
import 'package:snap_jp_learn_app/sync/change_journal.dart';

void main() {
  group('MockSyncApi', () {
    late MockSyncApi mockApi;

    setUpAll(() async {
      await setUpTestHive();
    });

    setUp(() {
      mockApi = MockSyncApi();
    });

    tearDown(() {
      mockApi.clearMockData();
    });

    tearDownAll(() async {
      await tearDownTestHive();
    });

    test('should push posts successfully', () async {
      final entries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'Post',
          entityId: 'post1',
          operation: ChangeOperation.create,
          timestamp: DateTime.now(),
          metadata: {
            'imagePath': 'test.jpg',
            'rawText': 'Test content',
          },
        ),
      ];

      final result = await mockApi.pushPosts(entries);

      expect(result.isSuccess, true);
      expect(result.message, contains('Posts pushed successfully'));
      expect(result.data?['count'], 1);
    });

    test('should push srs cards successfully', () async {
      final entries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'SrsCard',
          entityId: 'card1',
          operation: ChangeOperation.create,
          timestamp: DateTime.now(),
          metadata: {
            'term': 'テスト',
            'reading': 'test',
            'meaning': 'test meaning',
          },
        ),
      ];

      final result = await mockApi.pushSrsCards(entries);

      expect(result.isSuccess, true);
      expect(result.message, contains('SrsCards pushed successfully'));
      expect(result.data?['count'], 1);
    });

    test('should push review logs successfully', () async {
      final entries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'ReviewLog',
          entityId: 'log1',
          operation: ChangeOperation.create,
          timestamp: DateTime.now(),
          metadata: {
            'cardId': 'card1',
            'rating': 'good',
          },
        ),
      ];

      final result = await mockApi.pushReviewLogs(entries);

      expect(result.isSuccess, true);
      expect(result.message, contains('ReviewLogs pushed successfully'));
      expect(result.data?['count'], 1);
    });

    test('should handle network failure simulation', () async {
      mockApi.setSimulateNetworkFailure(true);

      final entries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'Post',
          entityId: 'post1',
          operation: ChangeOperation.create,
          timestamp: DateTime.now(),
        ),
      ];

      final result = await mockApi.pushPosts(entries);

      expect(result.isSuccess, false);
      expect(result.error, contains('Network error'));
    });

    test('should handle random failure rate', () async {
      mockApi.setFailureRate(1.0); // 100% 失敗率

      final entries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'Post',
          entityId: 'post1',
          operation: ChangeOperation.create,
          timestamp: DateTime.now(),
        ),
      ];

      final result = await mockApi.pushPosts(entries);

      expect(result.isSuccess, false);
      expect(result.error, contains('Network error'));
    });

    test('should pull posts successfully', () async {
      // まずモックデータを作成
      final entries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'Post',
          entityId: 'post1',
          operation: ChangeOperation.create,
          timestamp: DateTime.now(),
        ),
      ];
      await mockApi.pushPosts(entries);

      // プルを実行
      final result = await mockApi
          .pullPosts(DateTime.now().subtract(const Duration(hours: 1)));

      expect(result.isSuccess, true);
      expect(result.message, contains('Posts pulled successfully'));
    });

    test('should check connection status', () async {
      mockApi.setSimulateNetworkFailure(false);
      expect(await mockApi.isConnected(), true);

      mockApi.setSimulateNetworkFailure(true);
      expect(await mockApi.isConnected(), false);
    });

    test('should get sync status', () async {
      final status = await mockApi.getSyncStatus();

      expect(status.isConnected, true);
      expect(status.pendingChanges, 0);
    });

    test('should handle delete operations', () async {
      // まずデータを作成
      final createEntries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'Post',
          entityId: 'post1',
          operation: ChangeOperation.create,
          timestamp: DateTime.now(),
        ),
      ];
      await mockApi.pushPosts(createEntries);

      // 削除操作
      final deleteEntries = [
        ChangeJournalEntry(
          id: 'entry2',
          entityType: 'Post',
          entityId: 'post1',
          operation: ChangeOperation.delete,
          timestamp: DateTime.now(),
        ),
      ];
      final result = await mockApi.pushPosts(deleteEntries);

      expect(result.isSuccess, true);
    });

    test('should provide mock data statistics', () {
      final stats = mockApi.getMockDataStats();

      expect(stats['posts'], 0);
      expect(stats['srsCards'], 0);
      expect(stats['reviewLogs'], 0);
    });

    test('should clear mock data', () async {
      // データを追加
      final entries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'Post',
          entityId: 'post1',
          operation: ChangeOperation.create,
          timestamp: DateTime.now(),
        ),
      ];
      await mockApi.pushPosts(entries);

      // クリア
      mockApi.clearMockData();

      final stats = mockApi.getMockDataStats();
      expect(stats['posts'], 0);
    });

    test('should handle update operations', () async {
      final entries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'Post',
          entityId: 'post1',
          operation: ChangeOperation.update,
          timestamp: DateTime.now(),
          metadata: {
            'rawText': 'Updated content',
            'likeCount': 5,
          },
        ),
      ];

      final result = await mockApi.pushPosts(entries);

      expect(result.isSuccess, true);
      expect(result.message, contains('Posts pushed successfully'));
    });

    test('should create mock data with metadata', () async {
      final entries = [
        ChangeJournalEntry(
          id: 'entry1',
          entityType: 'Post',
          entityId: 'post1',
          operation: ChangeOperation.create,
          timestamp: DateTime.now(),
          metadata: {
            'imagePath': 'custom_image.jpg',
            'rawText': 'Custom content',
            'likeCount': 10,
            'learned': true,
          },
        ),
      ];

      final result = await mockApi.pushPosts(entries);
      expect(result.isSuccess, true);

      // モックデータが正しく作成されたことを確認
      final stats = mockApi.getMockDataStats();
      expect(stats['posts'], 1);
    });
  });
}
