import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/models/srs_card.dart';
import 'package:snap_jp_learn_app/models/review_log.dart';
import 'package:snap_jp_learn_app/services/srs_scheduler.dart';

void main() {
  group('SrsScheduler Tests', () {
    late SrsCard testCard;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testCard = SrsCard(
        id: 'test-card',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テストのスニペット',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now,
      );
    });

    test(
      'schedule with Again should reset repetition and set interval to 0 or 1',
      () {
        final updatedCard = SrsScheduler.schedule(testCard, Rating.again, now);

        expect(updatedCard.repetition, 0);
        expect(updatedCard.interval, anyOf(0, 1));
        expect(updatedCard.easeFactor, lessThan(testCard.easeFactor));
        expect(updatedCard.easeFactor, greaterThanOrEqualTo(1.3));
      },
    );

    test(
      'schedule with Hard should increment repetition and increase interval',
      () {
        final updatedCard = SrsScheduler.schedule(testCard, Rating.hard, now);

        expect(updatedCard.repetition, testCard.repetition + 1);
        expect(updatedCard.interval, greaterThanOrEqualTo(testCard.interval));
        expect(updatedCard.easeFactor, lessThan(testCard.easeFactor));
        expect(updatedCard.easeFactor, greaterThanOrEqualTo(1.3));
      },
    );

    test(
      'schedule with Good should increment repetition and calculate interval',
      () {
        final updatedCard = SrsScheduler.schedule(testCard, Rating.good, now);

        expect(updatedCard.repetition, testCard.repetition + 1);
        expect(updatedCard.easeFactor, testCard.easeFactor);
        expect(updatedCard.due.isAfter(now), true);
      },
    );

    test(
      'schedule with Easy should increment repetition and increase interval significantly',
      () {
        final updatedCard = SrsScheduler.schedule(testCard, Rating.easy, now);

        expect(updatedCard.repetition, testCard.repetition + 1);
        expect(updatedCard.interval, greaterThan(testCard.interval));
        expect(updatedCard.easeFactor, greaterThan(testCard.easeFactor));
        expect(updatedCard.easeFactor, lessThanOrEqualTo(2.8));
      },
    );

    test('schedule should update due date correctly', () {
      final updatedCard = SrsScheduler.schedule(testCard, Rating.good, now);

      expect(updatedCard.due.isAfter(now), true);
      expect(
        updatedCard.due.difference(now).inDays,
        equals(updatedCard.interval),
      );
    });

    test('createNewCard should create card with correct initial values', () {
      final newCard = SrsScheduler.createNewCard(
        id: 'new-card',
        term: '新しい',
        sourcePostId: 'post-2',
        sourceSnippet: '新しいスニペット',
        createdAt: now,
      );

      expect(newCard.id, 'new-card');
      expect(newCard.term, '新しい');
      expect(newCard.sourcePostId, 'post-2');
      expect(newCard.sourceSnippet, '新しいスニペット');
      expect(
        newCard.createdAt.difference(now).inMicroseconds.abs(),
        lessThan(2000),
      );
      expect(newCard.interval, 0);
      expect(newCard.easeFactor, 2.5);
      expect(newCard.repetition, 0);
      expect(newCard.due.difference(now).inMicroseconds.abs(), lessThan(2000));
    });

    test('getLearningStatus should return correct status', () {
      final newCard = SrsCard(
        id: 'new',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now,
        repetition: 0,
      );

      final learningCard = SrsCard(
        id: 'learning',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now,
        repetition: 2,
      );

      final youngCard = SrsCard(
        id: 'young',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now,
        repetition: 5,
      );

      final matureCard = SrsCard(
        id: 'mature',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now,
        repetition: 15,
      );

      expect(SrsScheduler.getLearningStatus(newCard), 'New');
      expect(SrsScheduler.getLearningStatus(learningCard), 'Learning');
      expect(SrsScheduler.getLearningStatus(youngCard), 'Young');
      expect(SrsScheduler.getLearningStatus(matureCard), 'Mature');
    });

    test('getDifficultyLevel should return correct level', () {
      final veryHardCard = SrsCard(
        id: 'very-hard',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now,
        easeFactor: 1.2,
      );

      final hardCard = SrsCard(
        id: 'hard',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now,
        easeFactor: 1.8,
      );

      final mediumCard = SrsCard(
        id: 'medium',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now,
        easeFactor: 2.2,
      );

      final easyCard = SrsCard(
        id: 'easy',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now,
        easeFactor: 2.7,
      );

      expect(SrsScheduler.getDifficultyLevel(veryHardCard), 'Very Hard');
      expect(SrsScheduler.getDifficultyLevel(hardCard), 'Hard');
      expect(SrsScheduler.getDifficultyLevel(mediumCard), 'Medium');
      expect(SrsScheduler.getDifficultyLevel(easyCard), 'Easy');
    });

    test('getTimeUntilReview should return correct time description', () {
      final overdueCard = SrsCard(
        id: 'overdue',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now.subtract(const Duration(days: 1)),
      );

      final dueNowCard = SrsCard(
        id: 'due-now',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now.add(const Duration(days: 1)), // 1日後に設定
      );

      final futureCard = SrsCard(
        id: 'future',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: now.add(const Duration(days: 3)),
      );

      expect(SrsScheduler.getTimeUntilReview(overdueCard), 'Overdue');
      expect(
        SrsScheduler.getTimeUntilReview(dueNowCard),
        matches(RegExp(r'\d+.*')),
      );
      expect(
        SrsScheduler.getTimeUntilReview(futureCard),
        matches(RegExp(r'\d+.*')),
      );
    });

    test('getCardStats should return comprehensive stats', () {
      final stats = SrsScheduler.getCardStats(testCard);

      expect(stats['learningStatus'], isA<String>());
      expect(stats['difficultyLevel'], isA<String>());
      expect(stats['timeUntilReview'], isA<String>());
      expect(stats['totalReviews'], isA<int>());
      expect(stats['currentInterval'], isA<int>());
      expect(stats['easeFactor'], isA<double>());
      expect(stats['isDue'], isA<bool>());
    });

    test('schedule should handle edge cases correctly', () {
      // 最小値のeaseFactor
      final minEaseCard = testCard.copyWith(easeFactor: 1.3);
      final againCard = SrsScheduler.schedule(minEaseCard, Rating.again, now);
      expect(againCard.easeFactor, 1.3);

      // 最大値のeaseFactor
      final maxEaseCard = testCard.copyWith(easeFactor: 2.8);
      final easyCard = SrsScheduler.schedule(maxEaseCard, Rating.easy, now);
      expect(easyCard.easeFactor, 2.8);

      // 初回カード（repetition = 0）
      final newCard = testCard.copyWith(repetition: 0);
      final goodCard = SrsScheduler.schedule(newCard, Rating.good, now);
      expect(goodCard.interval, 1); // 初回は1日後
    });
  });
}
