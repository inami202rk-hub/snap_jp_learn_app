// TODO: HTTP同期API実装予定
// 将来のSpring Bootサーバーとの通信用

import '../change_journal.dart';
import 'sync_api.dart';

/// HTTP同期API - 実サーバーとの通信（未実装）
///
/// 実装予定のエンドポイント:
/// - POST /api/sync/posts/upsert
/// - POST /api/sync/srs-cards/upsert
/// - POST /api/sync/review-logs/upsert
/// - GET /api/sync/posts?since={timestamp}
/// - GET /api/sync/srs-cards?since={timestamp}
/// - GET /api/sync/review-logs?since={timestamp}
class HttpSyncApi implements SyncApi {
  // TODO: HTTPクライアント（dio等）を注入
  // TODO: ベースURL、認証トークン等の設定

  @override
  Future<SyncResult> pushPosts(List<ChangeJournalEntry> entries) async {
    // TODO: POST /api/sync/posts/upsert
    throw UnimplementedError('HTTP sync not implemented yet');
  }

  @override
  Future<SyncResult> pushSrsCards(List<ChangeJournalEntry> entries) async {
    // TODO: POST /api/sync/srs-cards/upsert
    throw UnimplementedError('HTTP sync not implemented yet');
  }

  @override
  Future<SyncResult> pushReviewLogs(List<ChangeJournalEntry> entries) async {
    // TODO: POST /api/sync/review-logs/upsert
    throw UnimplementedError('HTTP sync not implemented yet');
  }

  @override
  Future<SyncResult> pullPosts(DateTime since) async {
    // TODO: GET /api/sync/posts?since={timestamp}
    throw UnimplementedError('HTTP sync not implemented yet');
  }

  @override
  Future<SyncResult> pullSrsCards(DateTime since) async {
    // TODO: GET /api/sync/srs-cards?since={timestamp}
    throw UnimplementedError('HTTP sync not implemented yet');
  }

  @override
  Future<SyncResult> pullReviewLogs(DateTime since) async {
    // TODO: GET /api/sync/review-logs?since={timestamp}
    throw UnimplementedError('HTTP sync not implemented yet');
  }

  @override
  Future<bool> isConnected() async {
    // TODO: ネットワーク接続チェック
    throw UnimplementedError('HTTP sync not implemented yet');
  }

  @override
  Future<SyncStatus> getSyncStatus() async {
    // TODO: サーバー状態チェック
    throw UnimplementedError('HTTP sync not implemented yet');
  }
}
