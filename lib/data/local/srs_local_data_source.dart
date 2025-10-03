import 'package:hive/hive.dart';
import '../../models/srs_card.dart';
import '../../models/review_log.dart';

/// SRSカードとレビューログのローカルデータソース
class SrsLocalDataSource {
  static const String _cardsBoxName = 'srs_cards';
  static const String _logsBoxName = 'review_logs';

  Box<SrsCard>? _cardsBox;
  Box<ReviewLog>? _logsBox;

  /// Hiveボックスを初期化
  Future<void> init() async {
    if (_cardsBox == null || !_cardsBox!.isOpen) {
      _cardsBox = await Hive.openBox<SrsCard>(_cardsBoxName);
    }

    if (_logsBox == null || !_logsBox!.isOpen) {
      _logsBox = await Hive.openBox<ReviewLog>(_logsBoxName);
    }
  }

  /// ボックスが開いているかチェック
  bool get isInitialized =>
      _cardsBox != null &&
      _cardsBox!.isOpen &&
      _logsBox != null &&
      _logsBox!.isOpen;

  /// カードボックスを取得
  Box<SrsCard> get _cards {
    if (!isInitialized) {
      throw SrsLocalDataSourceException('Boxes are not initialized');
    }
    return _cardsBox!;
  }

  /// ログボックスを取得
  Box<ReviewLog> get _logs {
    if (!isInitialized) {
      throw SrsLocalDataSourceException('Boxes are not initialized');
    }
    return _logsBox!;
  }

  // === SRSカード操作 ===

  /// カードを作成
  Future<SrsCard> createCard(SrsCard card) async {
    try {
      await init();
      await _cards.put(card.id, card);
      return card;
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to create card: $e');
    }
  }

  /// カードを更新
  Future<SrsCard> updateCard(SrsCard card) async {
    try {
      await init();
      await _cards.put(card.id, card);
      return card;
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to update card: $e');
    }
  }

  /// カードを取得
  Future<SrsCard?> getCard(String id) async {
    try {
      await init();
      return _cards.get(id);
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to get card: $e');
    }
  }

  /// 今日レビュー対象のカード一覧を取得
  Future<List<SrsCard>> getDueCards({DateTime? now, int limit = 20}) async {
    try {
      await init();

      final targetDate = now ?? DateTime.now();
      final today = DateTime(targetDate.year, targetDate.month, targetDate.day);

      final dueCards = _cards.values.where((card) {
        final dueDate = DateTime(card.due.year, card.due.month, card.due.day);
        return dueDate.isBefore(today) || dueDate.isAtSameMomentAs(today);
      }).toList();

      // due日時でソート（早い順）
      dueCards.sort((a, b) => a.due.compareTo(b.due));

      return dueCards.take(limit).toList();
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to get due cards: $e');
    }
  }

  /// 指定された投稿のカード一覧を取得
  Future<List<SrsCard>> getCardsByPost(String postId) async {
    try {
      await init();

      return _cards.values
          .where((card) => card.sourcePostId == postId)
          .toList();
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to get cards by post: $e');
    }
  }

  /// カードを削除
  Future<void> deleteCard(String id) async {
    try {
      await init();
      await _cards.delete(id);
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to delete card: $e');
    }
  }

  /// 指定された投稿のカードを全て削除
  Future<void> deleteCardsByPost(String postId) async {
    try {
      await init();

      final cardsToDelete = _cards.values
          .where((card) => card.sourcePostId == postId)
          .map((card) => card.id)
          .toList();

      for (final cardId in cardsToDelete) {
        await _cards.delete(cardId);
      }
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to delete cards by post: $e');
    }
  }

  /// 全カード数を取得
  Future<int> getCardCount() async {
    try {
      await init();
      return _cards.length;
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to get card count: $e');
    }
  }

  /// 今日レビュー対象のカード数を取得
  Future<int> getDueCardCount({DateTime? now}) async {
    try {
      await init();

      final targetDate = now ?? DateTime.now();
      final today = DateTime(targetDate.year, targetDate.month, targetDate.day);

      return _cards.values.where((card) {
        final dueDate = DateTime(card.due.year, card.due.month, card.due.day);
        return dueDate.isBefore(today) || dueDate.isAtSameMomentAs(today);
      }).length;
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to get due card count: $e');
    }
  }

  // === レビューログ操作 ===

  /// レビューログを作成
  Future<ReviewLog> createReviewLog(ReviewLog log) async {
    try {
      await init();
      await _logs.put(log.id, log);
      return log;
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to create review log: $e');
    }
  }

  /// 指定されたカードのレビューログ一覧を取得
  Future<List<ReviewLog>> getReviewLogsByCard(String cardId) async {
    try {
      await init();

      return _logs.values.where((log) => log.cardId == cardId).toList()
        ..sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt)); // 新しい順
    } catch (e) {
      throw SrsLocalDataSourceException(
        'Failed to get review logs by card: $e',
      );
    }
  }

  /// 指定された日付のレビューログ一覧を取得
  Future<List<ReviewLog>> getReviewLogsByDate(DateTime date) async {
    try {
      await init();

      final targetDate = DateTime(date.year, date.month, date.day);

      return _logs.values.where((log) {
        final logDate = DateTime(
          log.reviewedAt.year,
          log.reviewedAt.month,
          log.reviewedAt.day,
        );
        return logDate.isAtSameMomentAs(targetDate);
      }).toList()
        ..sort((a, b) => b.reviewedAt.compareTo(a.reviewedAt)); // 新しい順
    } catch (e) {
      throw SrsLocalDataSourceException(
        'Failed to get review logs by date: $e',
      );
    }
  }

  /// 全レビューログ数を取得
  Future<int> getReviewLogCount() async {
    try {
      await init();
      return _logs.length;
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to get review log count: $e');
    }
  }

  // === 統計情報 ===

  /// 今日のレビュー数を取得
  Future<int> getTodayReviewCount() async {
    try {
      await init();

      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      return _logs.values
          .where(
            (log) =>
                log.reviewedAt.isAfter(todayStart) &&
                log.reviewedAt.isBefore(tomorrowStart),
          )
          .length;
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to get today review count: $e');
    }
  }

  /// 学習ステータス別のカード数を取得
  Future<Map<String, int>> getCardsByStatus() async {
    try {
      await init();

      final stats = <String, int>{
        'New': 0,
        'Learning': 0,
        'Young': 0,
        'Mature': 0,
      };

      for (final card in _cards.values) {
        String status;
        if (card.repetition == 0) {
          status = 'New';
        } else if (card.repetition < 3) {
          status = 'Learning';
        } else if (card.repetition < 10) {
          status = 'Young';
        } else {
          status = 'Mature';
        }
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to get cards by status: $e');
    }
  }

  // === ユーティリティ ===

  /// ボックスを閉じる
  Future<void> close() async {
    if (_cardsBox != null && _cardsBox!.isOpen) {
      await _cardsBox!.close();
    }
    if (_logsBox != null && _logsBox!.isOpen) {
      await _logsBox!.close();
    }
  }

  /// ボックスをクリア（全データ削除）
  Future<void> clear() async {
    try {
      await init();
      await _cards.clear();
      await _logs.clear();
    } catch (e) {
      throw SrsLocalDataSourceException('Failed to clear data: $e');
    }
  }
}

/// SRSローカルデータソース関連の例外
class SrsLocalDataSourceException implements Exception {
  final String message;

  const SrsLocalDataSourceException(this.message);

  @override
  String toString() => 'SrsLocalDataSourceException: $message';
}
