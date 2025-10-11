import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/offline_task.dart';
import '../core/ui_state.dart';
import '../services/sync_api_service.dart';
import '../models/post.dart';

/// オフラインキューサービスのステータス
enum OfflineQueueStatus {
  idle,
  processing,
  completed,
  error,
}

/// オフラインキューサービス
/// ネットワークがない状態での操作をキューに保存し、
/// オンライン復帰時に自動で再送する
class OfflineQueueService extends ChangeNotifier {
  static const String _boxName = 'offline_queue_box';
  static const String _statusKey = 'queue_status';

  final Connectivity _connectivity = Connectivity();
  final SyncApiService _syncApiService;
  final Uuid _uuid = const Uuid();

  Box<OfflineTask>? _queueBox;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  OfflineQueueStatus _status = OfflineQueueStatus.idle;
  String? _lastError;

  OfflineQueueService(this._syncApiService);

  /// サービスの初期化
  Future<void> initialize() async {
    try {
      // Hiveボックスを開く
      if (!Hive.isAdapterRegistered(10)) {
        Hive.registerAdapter(OfflineTaskAdapter());
      }
      _queueBox = await Hive.openBox<OfflineTask>(_boxName);

      // ネットワーク状態の監視を開始
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
      );

      // 初期状態でキューを処理（既存のタスクがある場合）
      final isOnline = await _isOnline();
      if (isOnline && _queueBox!.isNotEmpty) {
        await processQueue();
      }
    } catch (e) {
      _lastError = e.toString();
      _status = OfflineQueueStatus.error;
      notifyListeners();
    }
  }

  /// サービスの破棄
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _queueBox?.close();
    super.dispose();
  }

  /// 現在のステータス
  OfflineQueueStatus get status => _status;

  /// 最後のエラーメッセージ
  String? get lastError => _lastError;

  /// キュー内のタスク数
  int get taskCount => _queueBox?.length ?? 0;

  /// キュー内のタスク一覧
  List<OfflineTask> get tasks => _queueBox?.values.toList() ?? [];

  /// ネットワークがオンラインかどうか
  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  /// ネットワーク状態の変更を監視
  void _onConnectivityChanged(ConnectivityResult result) async {
    final isOnline = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

    if (isOnline && _queueBox!.isNotEmpty) {
      // オンライン復帰時にキューを処理
      await processQueue();
    }
  }

  /// タスクをキューに追加
  Future<UiState<String>> addTask({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    try {
      if (_queueBox == null) {
        return UiStateUtils.error('キューが初期化されていません');
      }

      final task = OfflineTask(
        id: _uuid.v4(),
        type: type,
        payload: payload,
        createdAt: DateTime.now(),
      );

      await _queueBox!.add(task);

      _log('タスクを追加しました: $type');
      return UiStateUtils.success(task.id);
    } catch (e) {
      _log('タスク追加エラー: $e');
      return UiStateUtils.error(e.toString());
    }
  }

  /// 投稿をキューに追加
  Future<UiState<String>> addPostTask(Post post) async {
    return addTask(
      type: OfflineTaskType.pushPost,
      payload: post.toJson(),
    );
  }

  /// リアクション更新をキューに追加
  Future<UiState<String>> addReactionTask({
    required String postId,
    required String reactionType,
    required bool isActive,
  }) async {
    return addTask(
      type: OfflineTaskType.updateReaction,
      payload: {
        'postId': postId,
        'reactionType': reactionType,
        'isActive': isActive,
      },
    );
  }

  /// 学習履歴更新をキューに追加
  Future<UiState<String>> addLearningHistoryTask({
    required String cardId,
    required String result,
  }) async {
    return addTask(
      type: OfflineTaskType.updateLearningHistory,
      payload: {
        'cardId': cardId,
        'result': result,
      },
    );
  }

  /// キューを処理（再同期）
  Future<UiState<int>> processQueue() async {
    if (_queueBox == null || _queueBox!.isEmpty) {
      return UiStateUtils.success(0);
    }

    try {
      _status = OfflineQueueStatus.processing;
      notifyListeners();

      final tasks = _queueBox!.values.toList();
      int processedCount = 0;
      final List<String> failedTaskIds = [];

      for (final task in tasks) {
        if (task.isExpired) {
          // 期限切れのタスクを削除
          await _removeTask(task);
          continue;
        }

        final result = await _processTask(task);
        if (result.isSuccess) {
          await _removeTask(task);
          processedCount++;
        } else {
          // リトライ可能かチェック
          if (task.canRetry) {
            final retryTask = task.copyWithRetry();
            await _updateTask(task, retryTask);
          } else {
            // 最大リトライ回数に達したタスクを削除
            await _removeTask(task);
            failedTaskIds.add(task.id);
          }
        }
      }

      _status = OfflineQueueStatus.completed;
      _lastError = null;
      notifyListeners();

      if (failedTaskIds.isNotEmpty) {
        _log('処理に失敗したタスク: ${failedTaskIds.length}件');
      }

      return UiStateUtils.success(processedCount);
    } catch (e) {
      _status = OfflineQueueStatus.error;
      _lastError = e.toString();
      notifyListeners();
      return UiStateUtils.error(e.toString());
    }
  }

  /// 個別タスクを処理
  Future<UiState<void>> _processTask(OfflineTask task) async {
    try {
      switch (task.type) {
        case OfflineTaskType.pushPost:
          final post = Post.fromJson(task.payload);
          final result = await _syncApiService.pushPost(post);
          return result.isSuccess
              ? UiStateUtils.success(null)
              : UiStateUtils.error(result.errorMessage ?? '投稿の同期に失敗しました');

        case OfflineTaskType.updateReaction:
          final result = await _syncApiService.updateReaction(
            task.payload['postId'],
            task.payload['reactionType'],
            task.payload['isActive'],
          );
          return result.isSuccess
              ? UiStateUtils.success(null)
              : UiStateUtils.error(result.errorMessage ?? 'リアクションの同期に失敗しました');

        case OfflineTaskType.updateLearningHistory:
          final result = await _syncApiService.updateLearningHistory(
            task.payload['cardId'],
            task.payload['result'],
          );
          return result.isSuccess
              ? UiStateUtils.success(null)
              : UiStateUtils.error(result.errorMessage ?? '学習履歴の同期に失敗しました');

        case OfflineTaskType.deletePost:
          final result =
              await _syncApiService.deletePost(task.payload['postId']);
          return result.isSuccess
              ? UiStateUtils.success(null)
              : UiStateUtils.error(result.errorMessage ?? '投稿削除の同期に失敗しました');

        default:
          return UiStateUtils.error('未対応のタスクタイプ: ${task.type}');
      }
    } catch (e) {
      return UiStateUtils.error('タスク処理エラー: $e');
    }
  }

  /// タスクを削除
  Future<void> _removeTask(OfflineTask task) async {
    final key = _queueBox!.keyAt(_queueBox!.values.toList().indexOf(task));
    await _queueBox!.delete(key);
  }

  /// タスクを更新
  Future<void> _updateTask(OfflineTask oldTask, OfflineTask newTask) async {
    final key = _queueBox!.keyAt(_queueBox!.values.toList().indexOf(oldTask));
    await _queueBox!.put(key, newTask);
  }

  /// キューをクリア
  Future<void> clearQueue() async {
    await _queueBox?.clear();
    _status = OfflineQueueStatus.idle;
    _lastError = null;
    notifyListeners();
  }

  /// デバッグ用ログ
  void _log(String message) {
    print('[OfflineQueueService] $message');
  }
}
