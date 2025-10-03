import 'package:uuid/uuid.dart';
import '../models/srs_card.dart';
import '../models/review_log.dart';
import '../repositories/srs_repository.dart';
import '../services/srs_scheduler.dart';
import '../data/local/srs_local_data_source.dart';

/// Hiveを使用したSrsRepositoryの実装
class SrsRepositoryImpl implements SrsRepository {
  final SrsLocalDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  SrsRepositoryImpl(this._dataSource);

  @override
  Future<List<SrsCard>> listDueCards({DateTime? now, int limit = 20}) async {
    try {
      return await _dataSource.getDueCards(now: now, limit: limit);
    } catch (e) {
      throw SrsRepositoryException('Failed to list due cards: $e');
    }
  }

  @override
  Future<SrsCard> upsertCard(SrsCard card) async {
    try {
      return await _dataSource.updateCard(card);
    } catch (e) {
      throw SrsRepositoryException('Failed to upsert card: $e');
    }
  }

  @override
  Future<void> review(String cardId, Rating rating, DateTime now) async {
    try {
      // 1. カードを取得
      final card = await _dataSource.getCard(cardId);
      if (card == null) {
        throw SrsRepositoryException('Card not found: $cardId');
      }

      // 2. スケジューラーでカードを更新
      final updatedCard = SrsScheduler.schedule(card, rating, now);
      await _dataSource.updateCard(updatedCard);

      // 3. レビューログを作成
      final reviewLog = ReviewLog(
        id: _uuid.v4(),
        cardId: cardId,
        reviewedAt: now,
        rating: rating.value,
      );
      await _dataSource.createReviewLog(reviewLog);
    } catch (e) {
      throw SrsRepositoryException('Failed to review card: $e');
    }
  }

  @override
  Future<List<SrsCard>> listByPost(String postId) async {
    try {
      return await _dataSource.getCardsByPost(postId);
    } catch (e) {
      throw SrsRepositoryException('Failed to list cards by post: $e');
    }
  }

  @override
  Future<void> deleteByPost(String postId) async {
    try {
      await _dataSource.deleteCardsByPost(postId);
    } catch (e) {
      throw SrsRepositoryException('Failed to delete cards by post: $e');
    }
  }

  @override
  Future<void> deleteCard(String cardId) async {
    try {
      await _dataSource.deleteCard(cardId);
    } catch (e) {
      throw SrsRepositoryException('Failed to delete card: $e');
    }
  }

  @override
  Future<SrsCard?> getCard(String cardId) async {
    try {
      return await _dataSource.getCard(cardId);
    } catch (e) {
      throw SrsRepositoryException('Failed to get card: $e');
    }
  }

  @override
  Future<int> getCardCount() async {
    try {
      return await _dataSource.getCardCount();
    } catch (e) {
      throw SrsRepositoryException('Failed to get card count: $e');
    }
  }

  @override
  Future<int> getDueCardCount({DateTime? now}) async {
    try {
      return await _dataSource.getDueCardCount(now: now);
    } catch (e) {
      throw SrsRepositoryException('Failed to get due card count: $e');
    }
  }

  @override
  Future<int> getTodayReviewCount() async {
    try {
      return await _dataSource.getTodayReviewCount();
    } catch (e) {
      throw SrsRepositoryException('Failed to get today review count: $e');
    }
  }

  @override
  Future<Map<String, int>> getCardsByStatus() async {
    try {
      return await _dataSource.getCardsByStatus();
    } catch (e) {
      throw SrsRepositoryException('Failed to get cards by status: $e');
    }
  }

  @override
  Future<List<ReviewLog>> getReviewLogsByCard(String cardId) async {
    try {
      return await _dataSource.getReviewLogsByCard(cardId);
    } catch (e) {
      throw SrsRepositoryException('Failed to get review logs by card: $e');
    }
  }

  @override
  Future<List<ReviewLog>> getReviewLogsByDate(DateTime date) async {
    try {
      return await _dataSource.getReviewLogsByDate(date);
    } catch (e) {
      throw SrsRepositoryException('Failed to get review logs by date: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getCardStats(String cardId) async {
    try {
      final card = await _dataSource.getCard(cardId);
      if (card == null) return null;
      
      return SrsScheduler.getCardStats(card);
    } catch (e) {
      throw SrsRepositoryException('Failed to get card stats: $e');
    }
  }

  @override
  Future<int> createCardsFromCandidates(
    List<dynamic> candidates,
    String sourcePostId,
    String sourceSnippet,
  ) async {
    try {
      int createdCount = 0;
      final now = DateTime.now();

      for (final candidate in candidates) {
        // VocabCandidate型の動的チェック
        if (candidate == null || 
            !candidate.toString().contains('VocabCandidate')) {
          continue;
        }

        // 動的にプロパティにアクセス
        final term = candidate.term as String?;
        if (term == null || term.isEmpty) continue;

        // 重複チェック（同じ投稿から同じ語彙は作成しない）
        final existingCards = await _dataSource.getCardsByPost(sourcePostId);
        final isDuplicate = existingCards.any((card) => card.term == term);
        if (isDuplicate) continue;

        // カードを作成
        final card = SrsScheduler.createNewCard(
          id: _uuid.v4(),
          term: term,
          sourcePostId: sourcePostId,
          sourceSnippet: sourceSnippet,
          createdAt: now,
        );

        await _dataSource.createCard(card);
        createdCount++;
      }

      return createdCount;
    } catch (e) {
      throw SrsRepositoryException('Failed to create cards from candidates: $e');
    }
  }

  @override
  Future<void> close() async {
    try {
      await _dataSource.close();
    } catch (e) {
      throw SrsRepositoryException('Failed to close repository: $e');
    }
  }
}
