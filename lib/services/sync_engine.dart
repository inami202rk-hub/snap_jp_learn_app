import 'dart:io';
import 'package:hive/hive.dart';
import '../models/post.dart';
import '../core/ui_state.dart';
import 'sync_api_service.dart';
import 'offline_queue_service.dart';

/// 同期結果を表すenum
enum SyncResult {
  success,
  partial,
  failed,
}

/// 同期統計情報
class SyncStats {
  final int pushedCount;
  final int pulledCount;
  final int conflictCount;
  final int errorCount;
  final Duration duration;

  SyncStats({
    required this.pushedCount,
    required this.pulledCount,
    required this.conflictCount,
    required this.errorCount,
    required this.duration,
  });

  @override
  String toString() {
    return 'SyncStats(pushed: $pushedCount, pulled: $pulledCount, '
        'conflicts: $conflictCount, errors: $errorCount, '
        'duration: ${duration.inMilliseconds}ms)';
  }
}

/// ローカルDB（Hive）とバックエンドAPI間の差分同期エンジン
///
/// Last-Write-Wins（LWW）戦略を使用してコンフリクトを解決
class SyncEngine {
  final SyncApiService _syncApiService;
  final Box<Post> _postBox;
  final OfflineQueueService _offlineQueueService;

  SyncEngine({
    required SyncApiService syncApiService,
    required Box<Post> postBox,
    required OfflineQueueService offlineQueueService,
  })  : _syncApiService = syncApiService,
        _postBox = postBox,
        _offlineQueueService = offlineQueueService;

  /// 完全同期を実行（push + pull）
  ///
  /// Returns: [SyncResult] 同期結果
  Future<SyncResult> syncAll() async {
    final stopwatch = Stopwatch()..start();

    try {
      print('[SyncEngine] Starting full sync...');

      // 1. ローカル変更をサーバーにプッシュ
      final pushResult = await pushLocalChanges();
      if (pushResult == SyncResult.failed) {
        print('[SyncEngine] Push failed, aborting sync');
        return SyncResult.failed;
      }

      // 2. サーバーから最新データをプル
      final pullResult = await pullRemoteUpdates();

      stopwatch.stop();

      if (pullResult == SyncResult.success &&
          pushResult == SyncResult.success) {
        print('[SyncEngine] Full sync completed successfully');
        return SyncResult.success;
      } else {
        print('[SyncEngine] Partial sync completed');
        return SyncResult.partial;
      }
    } catch (e) {
      stopwatch.stop();
      print('[SyncEngine] Sync failed with error: $e');
      return SyncResult.failed;
    }
  }

  /// ローカル変更をサーバーにプッシュ
  ///
  /// Returns: [SyncResult] プッシュ結果
  Future<SyncResult> pushLocalChanges() async {
    try {
      print('[SyncEngine] Starting push operation...');

      // dirty=true または deleted=true の投稿を取得
      final localChanges =
          _postBox.values.where((post) => post.dirty || post.deleted).toList();

      if (localChanges.isEmpty) {
        print('[SyncEngine] No local changes to push');
        return SyncResult.success;
      }

      print('[SyncEngine] Found ${localChanges.length} local changes to push');

      // サーバーに送信
      await _syncApiService.pushPosts(localChanges);

      // 送信成功後、dirtyフラグをクリア
      for (final post in localChanges) {
        if (post.deleted) {
          // 削除された投稿はローカルからも削除
          await _postBox.delete(post.id);
        } else {
          // dirtyフラグをクリア
          final updatedPost = post.copyWith(dirty: false);
          await _postBox.put(post.id, updatedPost);
        }
      }

      print('[SyncEngine] Push completed successfully');
      return SyncResult.success;
    } on SocketException {
      print('[SyncEngine] Push failed: Network offline');
      return SyncResult.failed;
    } catch (e) {
      print('[SyncEngine] Push failed with error: $e');
      return SyncResult.failed;
    }
  }

  /// サーバーから最新データをプル
  ///
  /// Returns: [SyncResult] プル結果
  Future<SyncResult> pullRemoteUpdates() async {
    try {
      print('[SyncEngine] Starting pull operation...');

      // サーバーから投稿一覧を取得
      final remotePosts = await _syncApiService.pullPosts();

      if (remotePosts.isEmpty) {
        print('[SyncEngine] No remote updates to pull');
        return SyncResult.success;
      }

      print('[SyncEngine] Found ${remotePosts.length} remote posts');

      int conflictCount = 0;
      int updatedCount = 0;

      for (final remotePost in remotePosts) {
        final localPost = _postBox.get(remotePost.id);

        if (localPost == null) {
          // 新しい投稿を追加
          await _postBox.put(remotePost.id, remotePost);
          updatedCount++;
          print('[SyncEngine] Added new post: ${remotePost.id}');
        } else {
          // 既存投稿の競合解決（LWW）
          if (remotePost.updatedAt.isAfter(localPost.updatedAt)) {
            // リモートが新しい
            await _postBox.put(remotePost.id, remotePost);
            updatedCount++;
            print('[SyncEngine] Updated post from remote: ${remotePost.id}');
          } else if (localPost.updatedAt.isAfter(remotePost.updatedAt)) {
            // ローカルが新しい（競合）
            conflictCount++;
            print('[SyncEngine] Conflict detected for post: ${remotePost.id} '
                '(local: ${localPost.updatedAt}, remote: ${remotePost.updatedAt})');

            // LWW戦略：ローカルの方が新しい場合はそのまま保持
            // ただし、リモートで削除されている場合は削除を優先
            if (remotePost.deleted && !localPost.deleted) {
              await _postBox.delete(remotePost.id);
              updatedCount++;
              print('[SyncEngine] Applied remote deletion: ${remotePost.id}');
            }
          }
        }
      }

      print(
          '[SyncEngine] Pull completed: $updatedCount updated, $conflictCount conflicts');
      return SyncResult.success;
    } on SocketException {
      print('[SyncEngine] Pull failed: Network offline');
      return SyncResult.failed;
    } catch (e) {
      print('[SyncEngine] Pull failed with error: $e');
      return SyncResult.failed;
    }
  }

  /// 同期統計を取得
  ///
  /// Returns: [SyncStats] 統計情報
  Future<SyncStats> getSyncStats() async {
    final dirtyCount = _postBox.values.where((post) => post.dirty).length;

    return SyncStats(
      pushedCount: dirtyCount,
      pulledCount: 0, // 実際の統計は同期実行時に記録
      conflictCount: 0,
      errorCount: 0,
      duration: Duration.zero,
    );
  }

  /// ローカル投稿にdirtyフラグを設定
  ///
  /// [postId] 投稿ID
  Future<void> markAsDirty(String postId) async {
    final post = _postBox.get(postId);
    if (post != null && !post.dirty) {
      final updatedPost = post.copyWith(
        dirty: true,
        updatedAt: DateTime.now(),
      );
      await _postBox.put(postId, updatedPost);
      print('[SyncEngine] Marked post as dirty: $postId');
    }
  }

  /// ローカル投稿に削除フラグを設定
  ///
  /// [postId] 投稿ID
  Future<void> markAsDeleted(String postId) async {
    final post = _postBox.get(postId);
    if (post != null && !post.deleted) {
      final updatedPost = post.copyWith(
        deleted: true,
        dirty: true,
        updatedAt: DateTime.now(),
      );
      await _postBox.put(postId, updatedPost);
      print('[SyncEngine] Marked post as deleted: $postId');
    }
  }

  /// ネットワーク接続状態を確認
  ///
  /// Returns: [bool] 接続可能かどうか
  Future<bool> isConnected() async {
    return await _syncApiService.isConnected();
  }

  /// 完全同期を実行（UiState対応）
  Future<UiState<SyncStats>> performFullSyncWithState() async {
    try {
      await syncAll();
      final stats = await getSyncStats();
      return UiStateUtils.success(stats);
    } catch (e) {
      return UiStateUtils.error(
        e is SocketException
            ? UiStateUtils.networkErrorMessage
            : UiStateUtils.syncErrorMessage,
      );
    }
  }

  /// プッシュのみを実行（UiState対応）
  Future<UiState<SyncStats>> performPushWithState() async {
    try {
      await pushLocalChanges();
      final stats = await getSyncStats();
      return UiStateUtils.success(stats);
    } catch (e) {
      return UiStateUtils.error(
        e is SocketException
            ? UiStateUtils.networkErrorMessage
            : UiStateUtils.syncErrorMessage,
      );
    }
  }

  /// プルのみを実行（UiState対応）
  Future<UiState<SyncStats>> performPullWithState() async {
    try {
      await pullRemoteUpdates();
      final stats = await getSyncStats();
      return UiStateUtils.success(stats);
    } catch (e) {
      return UiStateUtils.error(
        e is SocketException
            ? UiStateUtils.networkErrorMessage
            : UiStateUtils.syncErrorMessage,
      );
    }
  }

  /// 保留中の同期を再試行
  Future<UiState<SyncStats>> retryPending() async {
    try {
      // ネットワーク接続を確認
      if (!await isConnected()) {
        return UiStateUtils.error(UiStateUtils.networkErrorMessage);
      }

      // 保留中の投稿を確認
      final pendingPosts = _postBox.values.where((post) => post.dirty).toList();

      if (pendingPosts.isEmpty) {
        return UiStateUtils.success(SyncStats(
          pushedCount: 0,
          pulledCount: 0,
          conflictCount: 0,
          errorCount: 0,
          duration: Duration.zero,
        ));
      }

      // 保留中の投稿を同期
      await pushLocalChanges();
      final stats = await getSyncStats();
      return UiStateUtils.success(stats);
    } catch (e) {
      return UiStateUtils.error(
        e is SocketException
            ? UiStateUtils.networkErrorMessage
            : UiStateUtils.syncErrorMessage,
      );
    }
  }

  /// オフラインキューを処理（再同期）
  Future<UiState<int>> processOfflineQueue() async {
    try {
      print('SyncEngine: オフラインキューの処理を開始');
      final result = await _offlineQueueService.processQueue();

      if (result.isSuccess) {
        final processedCount = result.data ?? 0;
        print('SyncEngine: オフラインキュー処理完了 - $processedCount件');
        return UiStateUtils.success(processedCount);
      } else {
        print('SyncEngine: オフラインキュー処理失敗 - ${result.errorMessage}');
        return UiStateUtils.error(result.errorMessage ?? 'オフラインキューの処理に失敗しました');
      }
    } catch (e) {
      print('SyncEngine: オフラインキュー処理エラー - $e');
      return UiStateUtils.error('オフラインキューの処理中にエラーが発生しました: $e');
    }
  }

  /// オフライン時の投稿をキューに追加
  Future<UiState<String>> addOfflinePost(Post post) async {
    try {
      print('SyncEngine: オフライン投稿をキューに追加');
      final result = await _offlineQueueService.addPostTask(post);

      if (result.isSuccess) {
        print('SyncEngine: オフライン投稿追加完了');
        return UiStateUtils.success(result.data ?? '');
      } else {
        print('SyncEngine: オフライン投稿追加失敗 - ${result.errorMessage}');
        return UiStateUtils.error(result.errorMessage ?? 'オフライン投稿の追加に失敗しました');
      }
    } catch (e) {
      print('SyncEngine: オフライン投稿追加エラー - $e');
      return UiStateUtils.error('オフライン投稿の追加中にエラーが発生しました: $e');
    }
  }

  /// オフライン時のリアクションをキューに追加
  Future<UiState<String>> addOfflineReaction({
    required String postId,
    required String reactionType,
    required bool isActive,
  }) async {
    try {
      print('SyncEngine: オフラインリアクションをキューに追加');
      final result = await _offlineQueueService.addReactionTask(
        postId: postId,
        reactionType: reactionType,
        isActive: isActive,
      );

      if (result.isSuccess) {
        print('SyncEngine: オフラインリアクション追加完了');
        return UiStateUtils.success(result.data ?? '');
      } else {
        print('SyncEngine: オフラインリアクション追加失敗 - ${result.errorMessage}');
        return UiStateUtils.error(
            result.errorMessage ?? 'オフラインリアクションの追加に失敗しました');
      }
    } catch (e) {
      print('SyncEngine: オフラインリアクション追加エラー - $e');
      return UiStateUtils.error('オフラインリアクションの追加中にエラーが発生しました: $e');
    }
  }

  /// オフラインキュー内のタスク数
  int get offlineTaskCount => _offlineQueueService.taskCount;

  /// オフラインキューのステータス
  OfflineQueueStatus get offlineQueueStatus => _offlineQueueService.status;
}
