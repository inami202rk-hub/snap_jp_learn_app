import 'package:uuid/uuid.dart';
import '../models/srs_card.dart';
import '../models/review_log.dart';
import '../repositories/srs_repository.dart';
import '../services/srs_scheduler.dart';
import '../services/stats_service.dart';
import '../data/local/srs_local_data_source.dart';

/// Hiveを使用したSrsRepositoryの実装
class SrsRepositoryImpl implements SrsRepository {
  final SrsLocalDataSource _dataSource;
  final Uuid _uuid = const Uuid();
  StatsService? _statsService;

  SrsRepositoryImpl(this._dataSource);

  /// StatsServiceを設定（DI）
  void setStatsService(StatsService statsService) {
    _statsService = statsService;
  }

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
      final isNewCard = card.id.isEmpty;
      final result = await _dataSource.updateCard(card);

      // 新規カード作成時は統計を更新
      if (isNewCard) {
        _statsService?.onCardCreated();
      }

      return result;
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

      // 4. 統計を更新
      _statsService?.onReviewCompleted(rating);
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
      throw SrsRepositoryException(
        'Failed to create cards from candidates: $e',
      );
    }
  }

  @override
  Future<List<SrsCard>> getAllCards() async {
    try {
      return await _dataSource.getAllCards();
    } catch (e) {
      throw SrsRepositoryException('Failed to get all cards: $e');
    }
  }

  @override
  Future<List<SrsCard>> getDueCards() async {
    try {
      return await _dataSource.getAllDueCards();
    } catch (e) {
      throw SrsRepositoryException('Failed to get due cards: $e');
    }
  }

  @override
  Future<List<ReviewLog>> getAllReviewLogs() async {
    try {
      return await _dataSource.getAllReviewLogs();
    } catch (e) {
      throw SrsRepositoryException('Failed to get all review logs: $e');
    }
  }

  @override
  Future<List<SrsCard>> findDuplicates({String? term}) async {
    try {
      final allCards = await _dataSource.getAllCards();
      final duplicates = <SrsCard>[];

      if (term != null) {
        // 特定の語句の重複を検索
        final normalizedTerm = _normalizeTerm(term);
        duplicates.addAll(allCards
            .where((card) => _normalizeTerm(card.term) == normalizedTerm));
      } else {
        // 全カードから重複を検索
        final termGroups = <String, List<SrsCard>>{};

        for (final card in allCards) {
          final normalizedTerm = _normalizeTerm(card.term);
          termGroups.putIfAbsent(normalizedTerm, () => []).add(card);
        }

        // 2つ以上のカードがある語句を重複として追加
        for (final group in termGroups.values) {
          if (group.length > 1) {
            duplicates.addAll(group);
          }
        }
      }

      return duplicates;
    } catch (e) {
      throw SrsRepositoryException('Failed to find duplicates: $e');
    }
  }

  @override
  Future<SrsCard> mergeCards(
      {required String baseId, required List<String> mergeIds}) async {
    try {
      // ベースカードを取得
      final baseCard = await _dataSource.getCard(baseId);
      if (baseCard == null) {
        throw SrsRepositoryException('Base card not found: $baseId');
      }

      // マージ対象カードを取得
      final mergeCards = <SrsCard>[];
      for (final id in mergeIds) {
        final card = await _dataSource.getCard(id);
        if (card != null) {
          mergeCards.add(card);
        }
      }

      // マージ処理
      final mergedCard = _performMerge(baseCard, mergeCards);

      // ベースカードを更新
      await _dataSource.updateCard(mergedCard);

      // マージ対象カードを削除
      for (final card in mergeCards) {
        await _dataSource.deleteCard(card.id);
      }

      return mergedCard;
    } catch (e) {
      throw SrsRepositoryException('Failed to merge cards: $e');
    }
  }

  @override
  Future<List<SrsCard>> searchByTerm(String term) async {
    try {
      final allCards = await _dataSource.getAllCards();
      final normalizedTerm = _normalizeTerm(term);

      return allCards
          .where((card) => _normalizeTerm(card.term) == normalizedTerm)
          .toList();
    } catch (e) {
      throw SrsRepositoryException('Failed to search by term: $e');
    }
  }

  /// 語句を正規化（重複検知用）
  String _normalizeTerm(String term) {
    // 基本的な正規化：空白除去、大文字小文字統一
    return term.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  /// カードマージ処理
  SrsCard _performMerge(SrsCard baseCard, List<SrsCard> mergeCards) {
    // reading: 非空優先
    String mergedReading = baseCard.reading;
    if (mergedReading.isEmpty) {
      for (final card in mergeCards) {
        if (card.reading.isNotEmpty) {
          mergedReading = card.reading;
          break;
        }
      }
    }

    // meanings: 和集合＋重複排除
    final Set<String> mergedMeanings =
        Set.from(baseCard.meaning.split('; ').where((m) => m.isNotEmpty));
    for (final card in mergeCards) {
      final meanings = card.meaning.split('; ').where((m) => m.isNotEmpty);
      mergedMeanings.addAll(meanings);
    }

    // SRSフィールドはベースカードを優先
    return baseCard.copyWith(
      reading: mergedReading,
      meaning: mergedMeanings.join('; '),
    );
  }

  @override
  Future<List<SrsCard>> searchCards({
    required String query,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final allCards = await _dataSource.getAllCards();
      final normalizedQuery = _normalizeText(query);
      final queryTerms =
          normalizedQuery.split(' ').where((term) => term.isNotEmpty).toList();

      if (queryTerms.isEmpty) {
        return allCards.take(limit).skip(offset).toList();
      }

      final filteredCards = allCards.where((card) {
        final normalizedTerm = _normalizeText(card.term);
        final normalizedMeaning = _normalizeText(card.meaning);
        final normalizedSnippet = _normalizeText(card.sourceSnippet);

        // AND検索：すべてのクエリ用語が含まれている必要がある
        return queryTerms.every((term) =>
            normalizedTerm.contains(term) ||
            normalizedMeaning.contains(term) ||
            normalizedSnippet.contains(term));
      }).toList();

      return filteredCards.take(limit).skip(offset).toList();
    } catch (e) {
      throw SrsRepositoryException('Failed to search cards: $e');
    }
  }

  @override
  Future<List<SrsCard>> filterCards({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'newest',
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final allCards = await _dataSource.getAllCards();
      List<SrsCard> filteredCards = allCards;

      // 状態フィルタ
      if (status != null) {
        final now = DateTime.now();
        filteredCards = filteredCards.where((card) {
          switch (status) {
            case 'due':
              return card.due.isBefore(now);
            case 'not_due':
              return !card.due.isBefore(now);
            case 'new':
              return card.repetition == 0;
            default:
              return true;
          }
        }).toList();
      }

      // 作成日フィルタ
      if (startDate != null || endDate != null) {
        filteredCards = filteredCards.where((card) {
          final cardDate = DateTime(
              card.createdAt.year, card.createdAt.month, card.createdAt.day);
          if (startDate != null && cardDate.isBefore(startDate)) return false;
          if (endDate != null && cardDate.isAfter(endDate)) return false;
          return true;
        }).toList();
      }

      // 並び替え
      switch (sortBy) {
        case 'oldest':
          filteredCards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'due_date':
          filteredCards.sort((a, b) => a.due.compareTo(b.due));
          break;
        default: // 'newest'
          filteredCards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }

      return filteredCards.take(limit).skip(offset).toList();
    } catch (e) {
      throw SrsRepositoryException('Failed to filter cards: $e');
    }
  }

  @override
  Future<List<SrsCard>> searchAndFilterCards({
    String? query,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'newest',
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      List<SrsCard> cards;

      if (query != null && query.trim().isNotEmpty) {
        // 検索を実行
        cards = await searchCards(query: query, limit: 1000); // 検索結果を多めに取得
      } else {
        // 全カードを取得
        cards = await _dataSource.getAllCards();
      }

      // フィルタを適用
      if (status != null) {
        final now = DateTime.now();
        cards = cards.where((card) {
          switch (status) {
            case 'due':
              return card.due.isBefore(now);
            case 'not_due':
              return !card.due.isBefore(now);
            case 'new':
              return card.repetition == 0;
            default:
              return true;
          }
        }).toList();
      }

      if (startDate != null || endDate != null) {
        cards = cards.where((card) {
          final cardDate = DateTime(
              card.createdAt.year, card.createdAt.month, card.createdAt.day);
          if (startDate != null && cardDate.isBefore(startDate)) return false;
          if (endDate != null && cardDate.isAfter(endDate)) return false;
          return true;
        }).toList();
      }

      // 並び替え
      switch (sortBy) {
        case 'oldest':
          cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'due_date':
          cards.sort((a, b) => a.due.compareTo(b.due));
          break;
        default: // 'newest'
          cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }

      return cards.take(limit).skip(offset).toList();
    } catch (e) {
      throw SrsRepositoryException('Failed to search and filter cards: $e');
    }
  }

  @override
  Future<ReviewLog> createReviewLog(ReviewLog log) async {
    try {
      return await _dataSource.createReviewLog(log);
    } catch (e) {
      throw SrsRepositoryException('Failed to create review log: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _dataSource.clear();
    } catch (e) {
      throw SrsRepositoryException('Failed to clear all data: $e');
    }
  }

  /// テキストを正規化（検索用）
  String _normalizeText(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
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
