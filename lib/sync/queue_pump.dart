import 'dart:async';
import 'dart:math';
import 'change_journal.dart';
import 'api/sync_api.dart';

/// 同期キューのポンプ - バックグラウンドで同期処理を実行
class QueuePump {
  final ChangeJournal _journal;
  final SyncApi _syncApi;
  Timer? _timer;
  bool _isRunning = false;
  int _currentRetryDelay = 1000; // 1秒から開始
  static const int _maxRetryDelay = 300000; // 5分
  static const int _maxAttempts = 5;

  QueuePump(this._journal, this._syncApi);

  /// ポンプを開始
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _scheduleNextPump();
  }

  /// ポンプを停止
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  /// 即座に同期を実行
  Future<SyncResult> pumpNow() async {
    return await _performSync();
  }

  /// 次の同期をスケジュール
  void _scheduleNextPump() {
    if (!_isRunning) return;

    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: _currentRetryDelay), () async {
      try {
        final result = await _performSync();

        if (result.isSuccess) {
          // 成功時はリトライ遅延をリセット
          _currentRetryDelay = 1000;
          _scheduleNextPump(); // 次の同期をスケジュール
        } else {
          // 失敗時は指数バックオフで再試行
          _handleSyncFailure();
        }
      } catch (e) {
        print('QueuePump error: $e');
        _handleSyncFailure();
      }
    });
  }

  /// 同期処理を実行
  Future<SyncResult> _performSync() async {
    final pendingEntries = _journal.getPendingEntries();

    if (pendingEntries.isEmpty) {
      return SyncResult.success(message: 'No pending changes to sync');
    }

    print('QueuePump: Processing ${pendingEntries.length} pending changes');

    final results = <SyncResult>[];

    // エンティティタイプごとにグループ化
    final groupedEntries = _groupEntriesByType(pendingEntries);

    for (final entry in groupedEntries.entries) {
      final entityType = entry.key;
      final entries = entry.value;

      try {
        final result = await _syncEntityType(entityType, entries);
        results.add(result);

        if (result.isSuccess) {
          // 成功したエントリをジャーナルから削除
          for (final journalEntry in entries) {
            await _journal.removeEntry(journalEntry.id);
          }
        } else {
          // 失敗したエントリの試行回数を増加
          for (final journalEntry in entries) {
            await _journal.incrementAttempt(journalEntry.id);
          }
        }
      } catch (e) {
        print('Error syncing $entityType: $e');
        results.add(SyncResult.failure(error: e.toString()));
      }
    }

    // 全体的な結果を判定
    final hasFailures = results.any((r) => !r.isSuccess);
    if (hasFailures) {
      return SyncResult.failure(error: 'Some sync operations failed');
    }

    return SyncResult.success(
        message: 'Successfully synced ${pendingEntries.length} changes');
  }

  /// エンティティタイプごとにエントリをグループ化
  Map<String, List<ChangeJournalEntry>> _groupEntriesByType(
      List<ChangeJournalEntry> entries) {
    final grouped = <String, List<ChangeJournalEntry>>{};

    for (final entry in entries) {
      grouped.putIfAbsent(entry.entityType, () => []).add(entry);
    }

    return grouped;
  }

  /// 特定のエンティティタイプの同期を実行
  Future<SyncResult> _syncEntityType(
      String entityType, List<ChangeJournalEntry> entries) async {
    switch (entityType) {
      case 'Post':
        return await _syncPosts(entries);
      case 'SrsCard':
        return await _syncSrsCards(entries);
      case 'ReviewLog':
        return await _syncReviewLogs(entries);
      default:
        return SyncResult.failure(error: 'Unknown entity type: $entityType');
    }
  }

  /// Postの同期
  Future<SyncResult> _syncPosts(List<ChangeJournalEntry> entries) async {
    try {
      // 作成・更新のエントリを処理
      final createUpdateEntries = entries
          .where((e) =>
              e.operation == ChangeOperation.create ||
              e.operation == ChangeOperation.update)
          .toList();

      if (createUpdateEntries.isNotEmpty) {
        final result = await _syncApi.pushPosts(createUpdateEntries);
        if (!result.isSuccess) {
          return SyncResult.failure(error: result.error ?? 'Unknown error');
        }
      }

      // 削除のエントリを処理
      final deleteEntries =
          entries.where((e) => e.operation == ChangeOperation.delete).toList();

      if (deleteEntries.isNotEmpty) {
        final result = await _syncApi.pushPosts(deleteEntries);
        if (!result.isSuccess) {
          return SyncResult.failure(error: result.error ?? 'Unknown error');
        }
      }

      return SyncResult.success(message: 'Posts synced successfully');
    } catch (e) {
      return SyncResult.failure(error: 'Post sync failed: $e');
    }
  }

  /// SrsCardの同期
  Future<SyncResult> _syncSrsCards(List<ChangeJournalEntry> entries) async {
    try {
      // 作成・更新のエントリを処理
      final createUpdateEntries = entries
          .where((e) =>
              e.operation == ChangeOperation.create ||
              e.operation == ChangeOperation.update)
          .toList();

      if (createUpdateEntries.isNotEmpty) {
        final result = await _syncApi.pushSrsCards(createUpdateEntries);
        if (!result.isSuccess) {
          return SyncResult.failure(error: result.error ?? 'Unknown error');
        }
      }

      // 削除のエントリを処理
      final deleteEntries =
          entries.where((e) => e.operation == ChangeOperation.delete).toList();

      if (deleteEntries.isNotEmpty) {
        final result = await _syncApi.pushSrsCards(deleteEntries);
        if (!result.isSuccess) {
          return SyncResult.failure(error: result.error ?? 'Unknown error');
        }
      }

      return SyncResult.success(message: 'SrsCards synced successfully');
    } catch (e) {
      return SyncResult.failure(error: 'SrsCard sync failed: $e');
    }
  }

  /// ReviewLogの同期
  Future<SyncResult> _syncReviewLogs(List<ChangeJournalEntry> entries) async {
    try {
      // ReviewLogは追加のみ（削除は想定しない）
      final createEntries =
          entries.where((e) => e.operation == ChangeOperation.create).toList();

      if (createEntries.isNotEmpty) {
        final result = await _syncApi.pushReviewLogs(createEntries);
        if (!result.isSuccess) {
          return SyncResult.failure(error: result.error ?? 'Unknown error');
        }
      }

      return SyncResult.success(message: 'ReviewLogs synced successfully');
    } catch (e) {
      return SyncResult.failure(error: 'ReviewLog sync failed: $e');
    }
  }

  /// 同期失敗時の処理
  void _handleSyncFailure() {
    // 指数バックオフでリトライ遅延を増加
    _currentRetryDelay = min(_currentRetryDelay * 2, _maxRetryDelay);

    // 最大試行回数をチェック
    final pendingEntries = _journal.getPendingEntries();
    final maxAttemptsReached =
        pendingEntries.any((e) => e.attempt >= _maxAttempts);

    if (maxAttemptsReached) {
      print('QueuePump: Max attempts reached, stopping retry');
      stop();
      return;
    }

    _scheduleNextPump();
  }

  /// ポンプの状態を取得
  bool get isRunning => _isRunning;

  /// 現在のリトライ遅延を取得
  Duration get currentRetryDelay => Duration(milliseconds: _currentRetryDelay);

  /// 未処理のエントリ数を取得
  int get pendingCount => _journal.getPendingEntries().length;
}

/// 同期結果
class SyncResult {
  final bool isSuccess;
  final String message;
  final String? error;
  final Map<String, dynamic>? data;

  SyncResult._({
    required this.isSuccess,
    required this.message,
    this.error,
    this.data,
  });

  factory SyncResult.success({
    required String message,
    Map<String, dynamic>? data,
  }) {
    return SyncResult._(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory SyncResult.failure({
    required String error,
    Map<String, dynamic>? data,
  }) {
    return SyncResult._(
      isSuccess: false,
      message: 'Sync failed',
      error: error,
      data: data,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'SyncResult.success: $message';
    } else {
      return 'SyncResult.failure: $error';
    }
  }
}
