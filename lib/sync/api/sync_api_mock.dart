import 'dart:math';
import '../change_journal.dart';
import 'sync_api.dart';

/// モック同期API - メモリ内でサーバーの動作をシミュレート
class MockSyncApi implements SyncApi {
  final Map<String, Map<String, dynamic>> _posts = {};
  final Map<String, Map<String, dynamic>> _srsCards = {};
  final Map<String, Map<String, dynamic>> _reviewLogs = {};

  DateTime? _lastSyncTime;
  bool _simulateNetworkFailure = false;
  double _failureRate = 0.0; // 0.0 = 常に成功, 1.0 = 常に失敗

  @override
  Future<SyncResult> pushPosts(List<ChangeJournalEntry> entries) async {
    if (_simulateNetworkFailure || _shouldFail()) {
      return SyncResult.failure(error: 'Network error (simulated)');
    }

    try {
      for (final entry in entries) {
        final clientId = entry.entityId;
        final operation = entry.operation;

        switch (operation) {
          case ChangeOperation.create:
          case ChangeOperation.update:
            // モックサーバーでの処理をシミュレート
            final mockData = _createMockPostData(clientId, entry.metadata);
            _posts[clientId] = mockData;
            break;
          case ChangeOperation.delete:
            _posts.remove(clientId);
            break;
        }
      }

      _lastSyncTime = DateTime.now();
      return SyncResult.success(
        message: 'Posts pushed successfully',
        data: {'count': entries.length},
      );
    } catch (e) {
      return SyncResult.failure(error: 'Push failed: $e');
    }
  }

  @override
  Future<SyncResult> pushSrsCards(List<ChangeJournalEntry> entries) async {
    if (_simulateNetworkFailure || _shouldFail()) {
      return SyncResult.failure(error: 'Network error (simulated)');
    }

    try {
      for (final entry in entries) {
        final clientId = entry.entityId;
        final operation = entry.operation;

        switch (operation) {
          case ChangeOperation.create:
          case ChangeOperation.update:
            final mockData = _createMockSrsCardData(clientId, entry.metadata);
            _srsCards[clientId] = mockData;
            break;
          case ChangeOperation.delete:
            _srsCards.remove(clientId);
            break;
        }
      }

      _lastSyncTime = DateTime.now();
      return SyncResult.success(
        message: 'SrsCards pushed successfully',
        data: {'count': entries.length},
      );
    } catch (e) {
      return SyncResult.failure(error: 'Push failed: $e');
    }
  }

  @override
  Future<SyncResult> pushReviewLogs(List<ChangeJournalEntry> entries) async {
    if (_simulateNetworkFailure || _shouldFail()) {
      return SyncResult.failure(error: 'Network error (simulated)');
    }

    try {
      for (final entry in entries) {
        final clientId = entry.entityId;
        final operation = entry.operation;

        if (operation == ChangeOperation.create) {
          final mockData = _createMockReviewLogData(clientId, entry.metadata);
          _reviewLogs[clientId] = mockData;
        }
      }

      _lastSyncTime = DateTime.now();
      return SyncResult.success(
        message: 'ReviewLogs pushed successfully',
        data: {'count': entries.length},
      );
    } catch (e) {
      return SyncResult.failure(error: 'Push failed: $e');
    }
  }

  @override
  Future<SyncResult> pullPosts(DateTime since) async {
    if (_simulateNetworkFailure || _shouldFail()) {
      return SyncResult.failure(error: 'Network error (simulated)');
    }

    try {
      final entities = _posts.values
          .where((post) => _parseDateTime(post['updatedAt']).isAfter(since))
          .toList();

      return SyncResult.success(
        message: 'Posts pulled successfully',
        data: {'count': entities.length},
      );
    } catch (e) {
      return SyncResult.failure(error: 'Pull failed: $e');
    }
  }

  @override
  Future<SyncResult> pullSrsCards(DateTime since) async {
    if (_simulateNetworkFailure || _shouldFail()) {
      return SyncResult.failure(error: 'Network error (simulated)');
    }

    try {
      final entities = _srsCards.values
          .where((card) => _parseDateTime(card['updatedAt']).isAfter(since))
          .toList();

      return SyncResult.success(
        message: 'SrsCards pulled successfully',
        data: {'count': entities.length},
      );
    } catch (e) {
      return SyncResult.failure(error: 'Pull failed: $e');
    }
  }

  @override
  Future<SyncResult> pullReviewLogs(DateTime since) async {
    if (_simulateNetworkFailure || _shouldFail()) {
      return SyncResult.failure(error: 'Network error (simulated)');
    }

    try {
      final entities = _reviewLogs.values
          .where((log) => _parseDateTime(log['updatedAt']).isAfter(since))
          .toList();

      return SyncResult.success(
        message: 'ReviewLogs pulled successfully',
        data: {'count': entities.length},
      );
    } catch (e) {
      return SyncResult.failure(error: 'Pull failed: $e');
    }
  }

  @override
  Future<bool> isConnected() async {
    // ネットワーク障害をシミュレート
    if (_simulateNetworkFailure) {
      return false;
    }

    // ランダムな接続障害をシミュレート
    return Random().nextDouble() > _failureRate;
  }

  @override
  Future<SyncStatus> getSyncStatus() async {
    final connected = await isConnected();

    return SyncStatus(
      isConnected: connected,
      lastSyncTime: _lastSyncTime,
      pendingChanges: 0, // モックでは常に0
      error: _simulateNetworkFailure ? 'Network error (simulated)' : null,
    );
  }

  /// モックデータを作成
  Map<String, dynamic> _createMockPostData(
      String clientId, Map<String, dynamic>? metadata) {
    final now = DateTime.now();
    return {
      'syncId': 'mock_post_${Random().nextInt(10000)}',
      'clientId': clientId,
      'id': clientId,
      'imagePath': metadata?['imagePath'] ?? 'mock_image.jpg',
      'rawText': metadata?['rawText'] ?? 'Mock text content',
      'normalizedText': metadata?['normalizedText'] ?? 'Mock normalized text',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'likeCount': metadata?['likeCount'] ?? 0,
      'learnedCount': metadata?['learnedCount'] ?? 0,
      'learned': metadata?['learned'] ?? false,
      'version': 1,
    };
  }

  Map<String, dynamic> _createMockSrsCardData(
      String clientId, Map<String, dynamic>? metadata) {
    final now = DateTime.now();
    return {
      'syncId': 'mock_card_${Random().nextInt(10000)}',
      'clientId': clientId,
      'id': clientId,
      'term': metadata?['term'] ?? 'Mock term',
      'reading': metadata?['reading'] ?? 'Mock reading',
      'meaning': metadata?['meaning'] ?? 'Mock meaning',
      'sourcePostId': metadata?['sourcePostId'] ?? 'mock_post_1',
      'sourceSnippet': metadata?['sourceSnippet'] ?? 'Mock snippet',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'interval': metadata?['interval'] ?? 0,
      'easeFactor': metadata?['easeFactor'] ?? 2.5,
      'repetition': metadata?['repetition'] ?? 0,
      'due': now.add(const Duration(days: 1)).toIso8601String(),
      'version': 1,
    };
  }

  Map<String, dynamic> _createMockReviewLogData(
      String clientId, Map<String, dynamic>? metadata) {
    final now = DateTime.now();
    return {
      'syncId': 'mock_log_${Random().nextInt(10000)}',
      'clientId': clientId,
      'id': clientId,
      'cardId': metadata?['cardId'] ?? 'mock_card_1',
      'reviewedAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'rating': metadata?['rating'] ?? 'good',
      'version': 1,
    };
  }

  /// 日時文字列をパース
  DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime is DateTime) {
      return dateTime;
    }
    if (dateTime is String) {
      return DateTime.parse(dateTime);
    }
    return DateTime.now();
  }

  /// 失敗をシミュレートするかどうか
  bool _shouldFail() {
    return Random().nextDouble() < _failureRate;
  }

  /// テスト用の設定メソッド
  void setSimulateNetworkFailure(bool simulate) {
    _simulateNetworkFailure = simulate;
  }

  void setFailureRate(double rate) {
    _failureRate = rate.clamp(0.0, 1.0);
  }

  /// モックデータをクリア
  void clearMockData() {
    _posts.clear();
    _srsCards.clear();
    _reviewLogs.clear();
    _lastSyncTime = null;
  }

  /// モックデータの統計を取得
  Map<String, int> getMockDataStats() {
    return {
      'posts': _posts.length,
      'srsCards': _srsCards.length,
      'reviewLogs': _reviewLogs.length,
    };
  }
}
