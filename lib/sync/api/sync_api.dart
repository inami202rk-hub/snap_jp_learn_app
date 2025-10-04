import '../change_journal.dart';

/// 同期APIの抽象インターフェース
abstract class SyncApi {
  /// Postをサーバーにプッシュ
  Future<SyncResult> pushPosts(List<ChangeJournalEntry> entries);

  /// SrsCardをサーバーにプッシュ
  Future<SyncResult> pushSrsCards(List<ChangeJournalEntry> entries);

  /// ReviewLogをサーバーにプッシュ
  Future<SyncResult> pushReviewLogs(List<ChangeJournalEntry> entries);

  /// 指定日時以降のPostをサーバーからプル
  Future<SyncResult> pullPosts(DateTime since);

  /// 指定日時以降のSrsCardをサーバーからプル
  Future<SyncResult> pullSrsCards(DateTime since);

  /// 指定日時以降のReviewLogをサーバーからプル
  Future<SyncResult> pullReviewLogs(DateTime since);

  /// 接続状態をチェック
  Future<bool> isConnected();

  /// 同期の状態を取得
  Future<SyncStatus> getSyncStatus();
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

/// 同期ステータス
class SyncStatus {
  final bool isConnected;
  final DateTime? lastSyncTime;
  final int pendingChanges;
  final String? error;

  SyncStatus({
    required this.isConnected,
    this.lastSyncTime,
    this.pendingChanges = 0,
    this.error,
  });

  @override
  String toString() {
    return 'SyncStatus(isConnected: $isConnected, lastSyncTime: $lastSyncTime, '
        'pendingChanges: $pendingChanges, error: $error)';
  }
}

/// アップサートリクエスト
class UpsertRequest {
  final String clientId;
  final int version;
  final Map<String, dynamic> payload;
  final DateTime updatedAt;

  UpsertRequest({
    required this.clientId,
    required this.version,
    required this.payload,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'version': version,
      'payload': payload,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UpsertRequest.fromJson(Map<String, dynamic> json) {
    return UpsertRequest(
      clientId: json['clientId'] as String,
      version: json['version'] as int,
      payload: json['payload'] as Map<String, dynamic>,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// アップサートレスポンス
class UpsertResponse {
  final String syncId;
  final int version;
  final DateTime serverUpdatedAt;
  final bool wasCreated;

  UpsertResponse({
    required this.syncId,
    required this.version,
    required this.serverUpdatedAt,
    required this.wasCreated,
  });

  Map<String, dynamic> toJson() {
    return {
      'syncId': syncId,
      'version': version,
      'serverUpdatedAt': serverUpdatedAt.toIso8601String(),
      'wasCreated': wasCreated,
    };
  }

  factory UpsertResponse.fromJson(Map<String, dynamic> json) {
    return UpsertResponse(
      syncId: json['syncId'] as String,
      version: json['version'] as int,
      serverUpdatedAt: DateTime.parse(json['serverUpdatedAt'] as String),
      wasCreated: json['wasCreated'] as bool,
    );
  }
}

/// プルレスポンス
class PullResponse {
  final List<Map<String, dynamic>> entities;
  final DateTime serverTime;
  final bool hasMore;

  PullResponse({
    required this.entities,
    required this.serverTime,
    this.hasMore = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'entities': entities,
      'serverTime': serverTime.toIso8601String(),
      'hasMore': hasMore,
    };
  }

  factory PullResponse.fromJson(Map<String, dynamic> json) {
    return PullResponse(
      entities: List<Map<String, dynamic>>.from(json['entities'] as List),
      serverTime: DateTime.parse(json['serverTime'] as String),
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
