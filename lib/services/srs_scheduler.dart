import '../models/srs_card.dart';
import '../models/review_log.dart';

/// SRSスケジューラー（SM2変形アルゴリズム）
class SrsScheduler {
  /// カードのスケジュールを更新
  ///
  /// [card] 対象のカード
  /// [rating] レビューの評価
  /// [now] 現在時刻
  ///
  /// Returns: 更新されたカード
  static SrsCard schedule(SrsCard card, Rating rating, DateTime now) {
    switch (rating) {
      case Rating.again:
        return _scheduleAgain(card, now);
      case Rating.hard:
        return _scheduleHard(card, now);
      case Rating.good:
        return _scheduleGood(card, now);
      case Rating.easy:
        return _scheduleEasy(card, now);
    }
  }

  /// Again（もう一度）のスケジューリング
  static SrsCard _scheduleAgain(SrsCard card, DateTime now) {
    // repetition = 0, interval = 0/1, easeFactor = max(1.3, ef-0.2)
    final newEaseFactor = (card.easeFactor - 0.2).clamp(1.3, 2.8);
    final newInterval = card.repetition == 0 ? 0 : 1;
    final newDue = now.add(Duration(days: newInterval));

    return card.copyWith(
      repetition: 0,
      interval: newInterval,
      easeFactor: newEaseFactor,
      due: newDue,
    );
  }

  /// Hard（難しい）のスケジューリング
  static SrsCard _scheduleHard(SrsCard card, DateTime now) {
    // repetition += 1, interval = max(1, ceil(interval*1.2)), ef = max(1.3, ef-0.15)
    final newRepetition = card.repetition + 1;
    final newInterval = (card.interval * 1.2).ceil().clamp(1, 365);
    final newEaseFactor = (card.easeFactor - 0.15).clamp(1.3, 2.8);
    final newDue = now.add(Duration(days: newInterval));

    return card.copyWith(
      repetition: newRepetition,
      interval: newInterval,
      easeFactor: newEaseFactor,
      due: newDue,
    );
  }

  /// Good（良い）のスケジューリング
  static SrsCard _scheduleGood(SrsCard card, DateTime now) {
    // repetition += 1, interval = next via SM2, ef = ef
    final newRepetition = card.repetition + 1;
    final newInterval = _calculateGoodInterval(card.repetition, card.interval);
    final newDue = now.add(Duration(days: newInterval));

    return card.copyWith(
      repetition: newRepetition,
      interval: newInterval,
      easeFactor: card.easeFactor,
      due: newDue,
    );
  }

  /// Easy（簡単）のスケジューリング
  static SrsCard _scheduleEasy(SrsCard card, DateTime now) {
    // repetition += 1, interval = ceil(interval*1.4)+1, ef = min(2.8, ef+0.05)
    final newRepetition = card.repetition + 1;
    final newInterval = (card.interval * 1.4).ceil() + 1;
    final newEaseFactor = (card.easeFactor + 0.05).clamp(1.3, 2.8);
    final newDue = now.add(Duration(days: newInterval));

    return card.copyWith(
      repetition: newRepetition,
      interval: newInterval,
      easeFactor: newEaseFactor,
      due: newDue,
    );
  }

  /// Good評価での間隔計算（SM2アルゴリズム）
  static int _calculateGoodInterval(int repetition, int currentInterval) {
    if (repetition == 0) {
      return 1; // 初回は1日後
    } else if (repetition == 1) {
      return 6; // 2回目は6日後
    } else {
      // 3回目以降は現在の間隔を使用
      return currentInterval;
    }
  }

  /// 新しいカードの初期値を作成
  static SrsCard createNewCard({
    required String id,
    required String term,
    String reading = '',
    String meaning = '',
    required String sourcePostId,
    required String sourceSnippet,
    required DateTime createdAt,
  }) {
    final now = DateTime.now();

    return SrsCard(
      id: id,
      term: term,
      reading: reading,
      meaning: meaning,
      sourcePostId: sourcePostId,
      sourceSnippet: sourceSnippet,
      createdAt: createdAt,
      interval: 0,
      easeFactor: 2.5,
      repetition: 0,
      due: now, // 即座にレビュー対象
    );
  }

  /// カードの学習ステータスを取得
  static String getLearningStatus(SrsCard card) {
    if (card.repetition == 0) {
      return 'New';
    } else if (card.repetition < 3) {
      return 'Learning';
    } else if (card.repetition < 10) {
      return 'Young';
    } else {
      return 'Mature';
    }
  }

  /// カードの難易度レベルを取得
  static String getDifficultyLevel(SrsCard card) {
    if (card.easeFactor < 1.5) {
      return 'Very Hard';
    } else if (card.easeFactor < 2.0) {
      return 'Hard';
    } else if (card.easeFactor < 2.5) {
      return 'Medium';
    } else {
      return 'Easy';
    }
  }

  /// 次回レビューまでの時間を取得（人間が読みやすい形式）
  static String getTimeUntilReview(SrsCard card) {
    final now = DateTime.now();
    final difference = card.due.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes';
    } else {
      return 'Now';
    }
  }

  /// カードの統計情報を取得
  static Map<String, dynamic> getCardStats(SrsCard card) {
    return {
      'learningStatus': getLearningStatus(card),
      'difficultyLevel': getDifficultyLevel(card),
      'timeUntilReview': getTimeUntilReview(card),
      'totalReviews': card.repetition,
      'currentInterval': card.interval,
      'easeFactor': card.easeFactor,
      'isDue': card.isDueToday,
    };
  }
}
