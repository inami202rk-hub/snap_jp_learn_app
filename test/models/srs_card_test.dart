import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/models/srs_card.dart';
import 'package:snap_jp_learn_app/models/review_log.dart';

void main() {
  group('SrsCard Model Tests', () {
    test('SrsCard should be created with required fields', () {
      final now = DateTime.now();
      final card = SrsCard(
        id: 'test-id',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テストのスニペット',
        createdAt: now,
        due: now,
      );

      expect(card.id, 'test-id');
      expect(card.term, 'テスト');
      expect(card.reading, '');
      expect(card.meaning, '');
      expect(card.sourcePostId, 'post-1');
      expect(card.sourceSnippet, 'テストのスニペット');
      expect(card.createdAt, now);
      expect(card.interval, 0);
      expect(card.easeFactor, 2.5);
      expect(card.repetition, 0);
      expect(card.due, now);
    });

    test('SrsCard should be created with custom fields', () {
      final now = DateTime.now();
      final card = SrsCard(
        id: 'test-id',
        term: 'テスト',
        reading: 'てすと',
        meaning: 'test',
        sourcePostId: 'post-1',
        sourceSnippet: 'テストのスニペット',
        createdAt: now,
        interval: 5,
        easeFactor: 2.0,
        repetition: 3,
        due: now.add(const Duration(days: 5)),
      );

      expect(card.reading, 'てすと');
      expect(card.meaning, 'test');
      expect(card.interval, 5);
      expect(card.easeFactor, 2.0);
      expect(card.repetition, 3);
    });

    test('SrsCard copyWith should create new instance with updated fields', () {
      final now = DateTime.now();
      final originalCard = SrsCard(
        id: 'test-id',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テストのスニペット',
        createdAt: now,
        due: now,
        repetition: 1,
        easeFactor: 2.0,
      );

      final updatedCard = originalCard.copyWith(repetition: 5, easeFactor: 2.5);

      // 元のオブジェクトは変更されない
      expect(originalCard.repetition, 1);
      expect(originalCard.easeFactor, 2.0);

      // 新しいオブジェクトは更新される
      expect(updatedCard.id, 'test-id');
      expect(updatedCard.term, 'テスト');
      expect(updatedCard.repetition, 5);
      expect(updatedCard.easeFactor, 2.5);
    });

    test('SrsCard toJson should serialize correctly', () {
      final now = DateTime.now();
      final card = SrsCard(
        id: 'test-id',
        term: 'テスト',
        reading: 'てすと',
        meaning: 'test',
        sourcePostId: 'post-1',
        sourceSnippet: 'テストのスニペット',
        createdAt: now,
        interval: 5,
        easeFactor: 2.0,
        repetition: 3,
        due: now.add(const Duration(days: 5)),
      );

      final json = card.toJson();

      expect(json['id'], 'test-id');
      expect(json['term'], 'テスト');
      expect(json['reading'], 'てすと');
      expect(json['meaning'], 'test');
      expect(json['sourcePostId'], 'post-1');
      expect(json['sourceSnippet'], 'テストのスニペット');
      expect(json['createdAt'], now.toIso8601String());
      expect(json['interval'], 5);
      expect(json['easeFactor'], 2.0);
      expect(json['repetition'], 3);
      expect(json['due'], now.add(const Duration(days: 5)).toIso8601String());
    });

    test('SrsCard fromJson should deserialize correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'term': 'テスト',
        'reading': 'てすと',
        'meaning': 'test',
        'sourcePostId': 'post-1',
        'sourceSnippet': 'テストのスニペット',
        'createdAt': now.toIso8601String(),
        'interval': 5,
        'easeFactor': 2.0,
        'repetition': 3,
        'due': now.add(const Duration(days: 5)).toIso8601String(),
      };

      final card = SrsCard.fromJson(json);

      expect(card.id, 'test-id');
      expect(card.term, 'テスト');
      expect(card.reading, 'てすと');
      expect(card.meaning, 'test');
      expect(card.sourcePostId, 'post-1');
      expect(card.sourceSnippet, 'テストのスニペット');
      expect(card.createdAt, now);
      expect(card.interval, 5);
      expect(card.easeFactor, 2.0);
      expect(card.repetition, 3);
    });

    test('SrsCard isDueToday should work correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      final overdueCard = SrsCard(
        id: 'overdue',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: yesterday,
      );

      final dueTodayCard = SrsCard(
        id: 'due-today',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: today,
      );

      final futureCard = SrsCard(
        id: 'future',
        term: 'テスト',
        sourcePostId: 'post-1',
        sourceSnippet: 'テスト',
        createdAt: now,
        due: tomorrow,
      );

      expect(overdueCard.isDueToday, true);
      expect(dueTodayCard.isDueToday, true);
      expect(futureCard.isDueToday, false);
    });

    test('SrsCard difficultyLevel should work correctly', () {
      final now = DateTime.now();

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

      expect(newCard.difficultyLevel, 'New');
      expect(learningCard.difficultyLevel, 'Learning');
      expect(youngCard.difficultyLevel, 'Young');
      expect(matureCard.difficultyLevel, 'Mature');
    });
  });

  group('ReviewLog Model Tests', () {
    test('ReviewLog should be created with required fields', () {
      final now = DateTime.now();
      final log = ReviewLog(
        id: 'log-1',
        cardId: 'card-1',
        reviewedAt: now,
        rating: 'good',
      );

      expect(log.id, 'log-1');
      expect(log.cardId, 'card-1');
      expect(log.reviewedAt, now);
      expect(log.rating, 'good');
    });

    test('ReviewLog copyWith should create new instance', () {
      final now = DateTime.now();
      final originalLog = ReviewLog(
        id: 'log-1',
        cardId: 'card-1',
        reviewedAt: now,
        rating: 'good',
      );

      final updatedLog = originalLog.copyWith(rating: 'easy');

      expect(originalLog.rating, 'good');
      expect(updatedLog.rating, 'easy');
      expect(updatedLog.id, 'log-1');
      expect(updatedLog.cardId, 'card-1');
    });

    test('ReviewLog toJson should serialize correctly', () {
      final now = DateTime.now();
      final log = ReviewLog(
        id: 'log-1',
        cardId: 'card-1',
        reviewedAt: now,
        rating: 'good',
      );

      final json = log.toJson();

      expect(json['id'], 'log-1');
      expect(json['cardId'], 'card-1');
      expect(json['reviewedAt'], now.toIso8601String());
      expect(json['rating'], 'good');
    });

    test('ReviewLog fromJson should deserialize correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'log-1',
        'cardId': 'card-1',
        'reviewedAt': now.toIso8601String(),
        'rating': 'good',
      };

      final log = ReviewLog.fromJson(json);

      expect(log.id, 'log-1');
      expect(log.cardId, 'card-1');
      expect(log.reviewedAt, now);
      expect(log.rating, 'good');
    });
  });

  group('Rating Enum Tests', () {
    test('Rating should have correct values', () {
      expect(Rating.again.value, 'again');
      expect(Rating.hard.value, 'hard');
      expect(Rating.good.value, 'good');
      expect(Rating.easy.value, 'easy');
    });

    test('Rating fromString should work correctly', () {
      expect(Rating.fromString('again'), Rating.again);
      expect(Rating.fromString('hard'), Rating.hard);
      expect(Rating.fromString('good'), Rating.good);
      expect(Rating.fromString('easy'), Rating.easy);
    });

    test('Rating fromString should throw for invalid input', () {
      expect(() => Rating.fromString('invalid'), throwsArgumentError);
    });

    test('Rating displayName should return Japanese names', () {
      expect(Rating.again.displayName, 'もう一度');
      expect(Rating.hard.displayName, '難しい');
      expect(Rating.good.displayName, '良い');
      expect(Rating.easy.displayName, '簡単');
    });

    test('Rating colorName should return color names', () {
      expect(Rating.again.colorName, 'red');
      expect(Rating.hard.colorName, 'orange');
      expect(Rating.good.colorName, 'blue');
      expect(Rating.easy.colorName, 'green');
    });
  });
}
