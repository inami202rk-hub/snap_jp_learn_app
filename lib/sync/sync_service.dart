import 'dart:async';
import 'change_journal.dart';
import 'queue_pump.dart';
import 'api/sync_api.dart';

/// 同期ポリシー
enum SyncPolicy {
  lastWriteWins, // Last Write Wins (既定)
  serverWins, // サーバー権威
  merge, // マージ型（将来実装）
}

/// 同期サービス - 全体の同期処理を管理
class SyncService {
  final ChangeJournal _journal;
  final QueuePump _queuePump;
  final SyncApi _syncApi;
  final SyncPolicy _policy;

  DateTime? _lastFullSync;
  final StreamController<SyncEvent> _eventController =
      StreamController.broadcast();

  SyncService(
    this._journal,
    this._queuePump,
    this._syncApi,
    this._policy,
  );

  /// 同期イベントストリーム
  Stream<SyncEvent> get events => _eventController.stream;

  /// 初期化
  Future<void> initialize() async {
    await _journal.initialize();
    _queuePump.start();
    _eventController.add(SyncEvent.initialized());
  }

  /// 同期を停止
  Future<void> shutdown() async {
    _queuePump.stop();
    await _journal.close();
    await _eventController.close();
  }

  /// 手動同期を実行
  Future<SyncSummary> syncNow({bool full = false}) async {
    _eventController.add(SyncEvent.started(full: full));

    try {
      final result = await _performSync(full: full);

      if (result.isSuccess) {
        _eventController.add(SyncEvent.completed(result));
      } else {
        _eventController.add(SyncEvent.failed(result.error ?? 'Unknown error'));
      }

      return result;
    } catch (e) {
      final errorResult = SyncSummary.failure(error: e.toString());
      _eventController.add(SyncEvent.failed(e.toString()));
      return errorResult;
    }
  }

  /// 同期処理を実行
  Future<SyncSummary> _performSync({bool full = false}) async {
    final startTime = DateTime.now();
    var syncedCount = 0;
    var dirtyCount = 0;

    try {
      // 接続チェック
      final isConnected = await _syncApi.isConnected();
      if (!isConnected) {
        return SyncSummary.failure(
          error: 'No network connection',
          syncedCount: 0,
          dirtyCount: _journal.getPendingEntries().length,
        );
      }

      // プッシュ処理（ローカル変更をサーバーに送信）
      final pushResult = await _queuePump.pumpNow();
      if (pushResult.isSuccess) {
        syncedCount += 1; // プッシュ成功時は1件としてカウント
      }

      // プル処理（サーバー変更をローカルに取得）
      if (full || _shouldPerformPull()) {
        final pullResult = await _performPull();
        if (pullResult.isSuccess) {
          syncedCount += 1; // プル成功時は1件としてカウント
        }
      }

      // 統計更新
      dirtyCount = _journal.getPendingEntries().length;
      _lastFullSync = DateTime.now();

      return SyncSummary.success(
        syncedCount: syncedCount,
        dirtyCount: dirtyCount,
        lastSyncTime: _lastFullSync,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e) {
      return SyncSummary.failure(
        error: e.toString(),
        syncedCount: syncedCount,
        dirtyCount: _journal.getPendingEntries().length,
      );
    }
  }

  /// プル処理を実行
  Future<SyncSummary> _performPull() async {
    final since =
        _lastFullSync ?? DateTime.now().subtract(const Duration(days: 30));
    var totalPulled = 0;

    try {
      // Postsをプル
      final postsResult = await _syncApi.pullPosts(since);
      if (postsResult.isSuccess) {
        totalPulled += postsResult.data?['count'] as int? ?? 0;
        // TODO: 取得したPostをローカルDBに反映
      }

      // SrsCardsをプル
      final cardsResult = await _syncApi.pullSrsCards(since);
      if (cardsResult.isSuccess) {
        totalPulled += cardsResult.data?['count'] as int? ?? 0;
        // TODO: 取得したSrsCardをローカルDBに反映
      }

      // ReviewLogsをプル
      final logsResult = await _syncApi.pullReviewLogs(since);
      if (logsResult.isSuccess) {
        totalPulled += logsResult.data?['count'] as int? ?? 0;
        // TODO: 取得したReviewLogをローカルDBに反映
      }

      return SyncSummary.success(
        syncedCount: totalPulled,
        dirtyCount: _journal.getPendingEntries().length,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      return SyncSummary.failure(
        error: 'Pull failed: $e',
        dirtyCount: _journal.getPendingEntries().length,
      );
    }
  }

  /// プル処理が必要かどうか
  bool _shouldPerformPull() {
    if (_lastFullSync == null) return true;

    final timeSinceLastSync = DateTime.now().difference(_lastFullSync!);
    return timeSinceLastSync.inMinutes > 30; // 30分ごとにプル
  }

  /// 変更をジャーナルに記録
  Future<void> recordChange({
    required String entityType,
    required String entityId,
    required ChangeOperation operation,
    Map<String, dynamic>? metadata,
  }) async {
    await _journal.addEntry(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      metadata: metadata,
    );
  }

  /// 同期ステータスを取得
  Future<SyncStatus> getSyncStatus() async {
    return await _syncApi.getSyncStatus();
  }

  /// 同期統計を取得
  SyncStats getSyncStats() {
    final journalStats = _journal.getStatistics();

    return SyncStats(
      pendingChanges: _journal.getPendingEntries().length,
      createOperations: journalStats['create'] ?? 0,
      updateOperations: journalStats['update'] ?? 0,
      deleteOperations: journalStats['delete'] ?? 0,
      lastSyncTime: _lastFullSync,
      isRunning: _queuePump.isRunning,
      currentRetryDelay: _queuePump.currentRetryDelay,
    );
  }

  /// 衝突解決を実行
  Future<void> resolveConflict({
    required String entityType,
    required String clientId,
    required Map<String, dynamic> clientData,
    required Map<String, dynamic> serverData,
  }) async {
    switch (_policy) {
      case SyncPolicy.lastWriteWins:
        await _resolveLastWriteWins(
          entityType: entityType,
          clientId: clientId,
          clientData: clientData,
          serverData: serverData,
        );
        break;
      case SyncPolicy.serverWins:
        await _resolveServerWins(
          entityType: entityType,
          clientId: clientId,
          serverData: serverData,
        );
        break;
      case SyncPolicy.merge:
        // TODO: マージ型の実装
        throw UnimplementedError('Merge policy not implemented yet');
    }
  }

  /// Last Write Wins による衝突解決
  Future<void> _resolveLastWriteWins({
    required String entityType,
    required String clientId,
    required Map<String, dynamic> clientData,
    required Map<String, dynamic> serverData,
  }) async {
    final clientUpdatedAt = DateTime.parse(clientData['updatedAt'] as String);
    final serverUpdatedAt = DateTime.parse(serverData['updatedAt'] as String);

    // 削除フラグをチェック（墓石が最優先）
    if (serverData['deleted'] == true) {
      await _markAsDeleted(entityType, clientId);
      return;
    }

    if (clientData['deleted'] == true) {
      await _markAsDeleted(entityType, clientId);
      return;
    }

    // 更新時刻で比較
    if (clientUpdatedAt.isAfter(serverUpdatedAt)) {
      // クライアントの方が新しい
      await _updateLocalEntity(entityType, clientId, clientData);
    } else if (serverUpdatedAt.isAfter(clientUpdatedAt)) {
      // サーバーの方が新しい
      await _updateLocalEntity(entityType, clientId, serverData);
    } else {
      // 同時刻の場合はバージョンで比較
      final clientVersion = clientData['version'] as int;
      final serverVersion = serverData['version'] as int;

      if (clientVersion > serverVersion) {
        await _updateLocalEntity(entityType, clientId, clientData);
      } else {
        await _updateLocalEntity(entityType, clientId, serverData);
      }
    }
  }

  /// サーバー権威による衝突解決
  Future<void> _resolveServerWins({
    required String entityType,
    required String clientId,
    required Map<String, dynamic> serverData,
  }) async {
    await _updateLocalEntity(entityType, clientId, serverData);
  }

  /// エンティティを削除済みとしてマーク
  Future<void> _markAsDeleted(String entityType, String clientId) async {
    // TODO: ローカルDBでdeleted=trueに更新
    await recordChange(
      entityType: entityType,
      entityId: clientId,
      operation: ChangeOperation.delete,
    );
  }

  /// ローカルエンティティを更新
  Future<void> _updateLocalEntity(
    String entityType,
    String clientId,
    Map<String, dynamic> data,
  ) async {
    // TODO: ローカルDBのエンティティを更新
    // この実装では、Repository層で適切に処理されることを想定
  }
}

/// 同期イベント
class SyncEvent {
  final SyncEventType type;
  final String? message;
  final SyncSummary? summary;
  final bool? full;

  SyncEvent._({
    required this.type,
    this.message,
    this.summary,
    this.full,
  });

  factory SyncEvent.initialized() {
    return SyncEvent._(type: SyncEventType.initialized);
  }

  factory SyncEvent.started({bool full = false}) {
    return SyncEvent._(type: SyncEventType.started, full: full);
  }

  factory SyncEvent.completed(SyncSummary summary) {
    return SyncEvent._(type: SyncEventType.completed, summary: summary);
  }

  factory SyncEvent.failed(String message) {
    return SyncEvent._(type: SyncEventType.failed, message: message);
  }
}

enum SyncEventType {
  initialized,
  started,
  completed,
  failed,
}

/// 同期サマリー
class SyncSummary {
  final bool isSuccess;
  final int syncedCount;
  final int dirtyCount;
  final DateTime? lastSyncTime;
  final Duration? duration;
  final String? error;

  SyncSummary._({
    required this.isSuccess,
    required this.syncedCount,
    required this.dirtyCount,
    this.lastSyncTime,
    this.duration,
    this.error,
  });

  factory SyncSummary.success({
    required int syncedCount,
    required int dirtyCount,
    DateTime? lastSyncTime,
    Duration? duration,
  }) {
    return SyncSummary._(
      isSuccess: true,
      syncedCount: syncedCount,
      dirtyCount: dirtyCount,
      lastSyncTime: lastSyncTime,
      duration: duration,
    );
  }

  factory SyncSummary.failure({
    required String error,
    int syncedCount = 0,
    int dirtyCount = 0,
  }) {
    return SyncSummary._(
      isSuccess: false,
      syncedCount: syncedCount,
      dirtyCount: dirtyCount,
      error: error,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'SyncSummary.success(synced: $syncedCount, dirty: $dirtyCount)';
    } else {
      return 'SyncSummary.failure(error: $error)';
    }
  }
}

/// 同期統計
class SyncStats {
  final int pendingChanges;
  final int createOperations;
  final int updateOperations;
  final int deleteOperations;
  final DateTime? lastSyncTime;
  final bool isRunning;
  final Duration currentRetryDelay;

  SyncStats({
    required this.pendingChanges,
    required this.createOperations,
    required this.updateOperations,
    required this.deleteOperations,
    this.lastSyncTime,
    required this.isRunning,
    required this.currentRetryDelay,
  });

  @override
  String toString() {
    return 'SyncStats(pending: $pendingChanges, create: $createOperations, '
        'update: $updateOperations, delete: $deleteOperations, '
        'lastSync: $lastSyncTime, running: $isRunning)';
  }
}
