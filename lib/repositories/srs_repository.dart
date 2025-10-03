import '../models/srs_card.dart';
import '../models/review_log.dart';

/// SRSカードとレビューログの永続化を管理するリポジトリの抽象クラス
abstract class SrsRepository {
  /// 今日レビュー対象のカード一覧を取得
  /// 
  /// [now] 現在時刻（テスト用）
  /// [limit] 取得件数の上限（デフォルト: 20）
  /// 
  /// Returns: レビュー対象のカードリスト（due日時順）
  Future<List<SrsCard>> listDueCards({DateTime? now, int limit = 20});

  /// カードを作成または更新
  /// 
  /// [card] 作成・更新するカード
  /// 
  /// Returns: 保存されたカード
  /// 
  /// Throws: [SrsRepositoryException] 保存に失敗した場合
  Future<SrsCard> upsertCard(SrsCard card);

  /// カードをレビュー
  /// 
  /// [cardId] カードのID
  /// [rating] レビューの評価
  /// [now] 現在時刻
  /// 
  /// Throws: [SrsRepositoryException] レビューに失敗した場合
  Future<void> review(String cardId, Rating rating, DateTime now);

  /// 指定された投稿のカード一覧を取得
  /// 
  /// [postId] 投稿のID
  /// 
  /// Returns: カードのリスト
  Future<List<SrsCard>> listByPost(String postId);

  /// 指定された投稿のカードを全て削除
  /// 
  /// [postId] 投稿のID
  /// 
  /// Throws: [SrsRepositoryException] 削除に失敗した場合
  Future<void> deleteByPost(String postId);

  /// カードを削除
  /// 
  /// [cardId] カードのID
  /// 
  /// Throws: [SrsRepositoryException] 削除に失敗した場合
  Future<void> deleteCard(String cardId);

  /// カードを取得
  /// 
  /// [cardId] カードのID
  /// 
  /// Returns: カード（存在しない場合はnull）
  Future<SrsCard?> getCard(String cardId);

  /// 全カード数を取得
  /// 
  /// Returns: カードの総数
  Future<int> getCardCount();

  /// 今日レビュー対象のカード数を取得
  /// 
  /// [now] 現在時刻（テスト用）
  /// 
  /// Returns: レビュー対象のカード数
  Future<int> getDueCardCount({DateTime? now});

  /// 今日のレビュー数を取得
  /// 
  /// Returns: 今日レビューしたカード数
  Future<int> getTodayReviewCount();

  /// 学習ステータス別のカード数を取得
  /// 
  /// Returns: ステータス別のカード数
  Future<Map<String, int>> getCardsByStatus();

  /// 指定されたカードのレビューログ一覧を取得
  /// 
  /// [cardId] カードのID
  /// 
  /// Returns: レビューログのリスト（新しい順）
  Future<List<ReviewLog>> getReviewLogsByCard(String cardId);

  /// 指定された日付のレビューログ一覧を取得
  /// 
  /// [date] 対象日付
  /// 
  /// Returns: レビューログのリスト（新しい順）
  Future<List<ReviewLog>> getReviewLogsByDate(DateTime date);

  /// カードの統計情報を取得
  /// 
  /// [cardId] カードのID
  /// 
  /// Returns: 統計情報
  Future<Map<String, dynamic>?> getCardStats(String cardId);

  /// 語彙候補からカードを作成
  /// 
  /// [candidates] 語彙候補のリスト
  /// [sourcePostId] 出典投稿のID
  /// [sourceSnippet] 出典スニペット
  /// 
  /// Returns: 作成されたカード数
  /// 
  /// Throws: [SrsRepositoryException] 作成に失敗した場合
  Future<int> createCardsFromCandidates(
    List<dynamic> candidates, // VocabCandidate型だが循環参照を避けるためdynamic
    String sourcePostId,
    String sourceSnippet,
  );

  /// リポジトリを閉じる（リソースのクリーンアップ）
  Future<void> close();
}

/// SRSリポジトリ関連の例外
class SrsRepositoryException implements Exception {
  final String message;
  
  const SrsRepositoryException(this.message);
  
  @override
  String toString() => 'SrsRepositoryException: $message';
}
