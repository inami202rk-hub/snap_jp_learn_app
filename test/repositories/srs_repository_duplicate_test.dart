import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/models/srs_card.dart';
import 'package:snap_jp_learn_app/models/review_log.dart';
import 'package:snap_jp_learn_app/repositories/srs_repository.dart';

// モックリポジトリ
class MockSrsRepository implements SrsRepository {
  final List<SrsCard> _cards = [];
  final List<ReviewLog> _reviewLogs = [];

  void addCard(SrsCard card) => _cards.add(card);
  void addReviewLog(ReviewLog log) => _reviewLogs.add(log);
  void clear() {
    _cards.clear();
    _reviewLogs.clear();
  }

  @override
  Future<List<SrsCard>> listDueCards({DateTime? now, int limit = 20}) async {
    final targetDate = now ?? DateTime.now();
    final today = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return _cards
        .where((card) =>
            card.due.isBefore(today) || card.due.isAtSameMomentAs(today))
        .take(limit)
        .toList();
  }

  @override
  Future<SrsCard> upsertCard(SrsCard card) async {
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _cards[index] = card;
    } else {
      _cards.add(card);
    }
    return card;
  }

  @override
  Future<void> review(String cardId, Rating rating, DateTime now) async {
    _reviewLogs.add(ReviewLog(
      id: 'log_${_reviewLogs.length}',
      cardId: cardId,
      reviewedAt: now,
      rating: rating.value,
    ));
  }

  @override
  Future<List<SrsCard>> listByPost(String postId) async =>
      _cards.where((card) => card.sourcePostId == postId).toList();

  @override
  Future<void> deleteByPost(String postId) async =>
      _cards.removeWhere((card) => card.sourcePostId == postId);

  @override
  Future<void> deleteCard(String cardId) async =>
      _cards.removeWhere((card) => card.id == cardId);

  @override
  Future<SrsCard?> getCard(String cardId) async =>
      _cards.firstWhere((card) => card.id == cardId);

  @override
  Future<int> getCardCount() async => _cards.length;

  @override
  Future<int> getDueCardCount({DateTime? now}) async {
    final targetDate = now ?? DateTime.now();
    final today = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return _cards
        .where((card) =>
            card.due.isBefore(today) || card.due.isAtSameMomentAs(today))
        .length;
  }

  @override
  Future<int> getTodayReviewCount() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _reviewLogs.where((log) {
      return log.reviewedAt.isAfter(todayStart) &&
          log.reviewedAt.isBefore(todayEnd);
    }).length;
  }

  @override
  Future<Map<String, int>> getCardsByStatus() async => {};

  @override
  Future<List<ReviewLog>> getReviewLogsByCard(String cardId) async => [];

  @override
  Future<List<ReviewLog>> getReviewLogsByDate(DateTime date) async => [];

  @override
  Future<Map<String, dynamic>?> getCardStats(String cardId) async => null;

  @override
  Future<int> createCardsFromCandidates(List<dynamic> candidates,
          String sourcePostId, String sourceSnippet) async =>
      0;

  @override
  Future<List<SrsCard>> getAllCards() async => List.from(_cards);

  @override
  Future<List<SrsCard>> getDueCards() async {
    final now = DateTime.now();
    return _cards.where((card) => card.due.isBefore(now)).toList();
  }

  @override
  Future<List<ReviewLog>> getAllReviewLogs() async => List.from(_reviewLogs);

  @override
  Future<List<SrsCard>> findDuplicates({String? term}) async {
    if (term != null) {
      final normalizedTerm = term.toLowerCase().trim();
      return _cards
          .where((card) => card.term.toLowerCase().trim() == normalizedTerm)
          .toList();
    } else {
      // 全カードから重複を検索
      final termGroups = <String, List<SrsCard>>{};

      for (final card in _cards) {
        final normalizedTerm = card.term.toLowerCase().trim();
        termGroups.putIfAbsent(normalizedTerm, () => []).add(card);
      }

      final duplicates = <SrsCard>[];
      for (final group in termGroups.values) {
        if (group.length > 1) {
          duplicates.addAll(group);
        }
      }

      return duplicates;
    }
  }

  @override
  Future<SrsCard> mergeCards(
      {required String baseId, required List<String> mergeIds}) async {
    try {
      final baseCard = _cards.firstWhere((c) => c.id == baseId);
      final mergeCards = _cards.where((c) => mergeIds.contains(c.id)).toList();

      // マージ処理
      String mergedReading = baseCard.reading;
      if (mergedReading.isEmpty) {
        for (final card in mergeCards) {
          if (card.reading.isNotEmpty) {
            mergedReading = card.reading;
            break;
          }
        }
      }

      final Set<String> mergedMeanings =
          Set.from(baseCard.meaning.split('; ').where((m) => m.isNotEmpty));
      for (final card in mergeCards) {
        final meanings = card.meaning.split('; ').where((m) => m.isNotEmpty);
        mergedMeanings.addAll(meanings);
      }

      final mergedCard = baseCard.copyWith(
        reading: mergedReading,
        meaning: mergedMeanings.join('; '),
      );

      // ベースカードを更新
      final index = _cards.indexWhere((c) => c.id == baseId);
      _cards[index] = mergedCard;

      // マージ対象カードを削除
      _cards.removeWhere((card) => mergeIds.contains(card.id));

      return mergedCard;
    } catch (e) {
      throw SrsRepositoryException('Failed to merge cards: $e');
    }
  }

  @override
  Future<List<SrsCard>> searchByTerm(String term) async {
    final normalizedTerm = term.toLowerCase().trim();
    return _cards
        .where((card) => card.term.toLowerCase().trim() == normalizedTerm)
        .toList();
  }

  @override
  Future<List<SrsCard>> searchCards({
    required String query,
    int limit = 100,
    int offset = 0,
  }) async => [];

  @override
  Future<List<SrsCard>> filterCards({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'newest',
    int limit = 100,
    int offset = 0,
  }) async => [];

  @override
  Future<List<SrsCard>> searchAndFilterCards({
    String? query,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'newest',
    int limit = 100,
    int offset = 0,
  }) async => [];

  @override
  Future<void> close() async {}
}

void main() {
  group('SrsRepository Duplicate Detection Tests', () {
    late MockSrsRepository mockRepository;

    setUp(() {
      mockRepository = MockSrsRepository();
    });

    tearDown(() {
      mockRepository.clear();
    });

    test('should find exact duplicates', () async {
      final now = DateTime.now();

      // 同じ語句のカードを複数作成
      final card1 = SrsCard(
        id: 'card1',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 1)),
      );

      final card2 = SrsCard(
        id: 'card2',
        term: '学校',
        reading: 'がっこう',
        meaning: '学びの場',
        sourcePostId: 'post2',
        sourceSnippet: '学校で勉強',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 2)),
      );

      mockRepository.addCard(card1);
      mockRepository.addCard(card2);

      final duplicates = await mockRepository.findDuplicates(term: '学校');
      expect(duplicates.length, 2);
      expect(duplicates.map((c) => c.id).toSet(), {'card1', 'card2'});
    });

    test('should find all duplicates when no term specified', () async {
      final now = DateTime.now();

      // 重複するカードグループを作成
      final card1 = SrsCard(
        id: 'card1',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 1)),
      );

      final card2 = SrsCard(
        id: 'card2',
        term: '学校',
        reading: 'がっこう',
        meaning: '学びの場',
        sourcePostId: 'post2',
        sourceSnippet: '学校で勉強',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 2)),
      );

      final card3 = SrsCard(
        id: 'card3',
        term: '病院',
        reading: 'びょういん',
        meaning: '医療機関',
        sourcePostId: 'post3',
        sourceSnippet: '病院に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 3)),
      );

      mockRepository.addCard(card1);
      mockRepository.addCard(card2);
      mockRepository.addCard(card3);

      final duplicates = await mockRepository.findDuplicates();
      expect(duplicates.length, 2); // 学校の重複のみ
      expect(duplicates.map((c) => c.term).toSet(), {'学校'});
    });

    test('should normalize terms for duplicate detection', () async {
      final now = DateTime.now();

      // 大文字小文字・空白の違いがあるカード
      final card1 = SrsCard(
        id: 'card1',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 1)),
      );

      final card2 = SrsCard(
        id: 'card2',
        term: ' 学校 ',
        reading: 'がっこう',
        meaning: '学びの場',
        sourcePostId: 'post2',
        sourceSnippet: '学校で勉強',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 2)),
      );

      mockRepository.addCard(card1);
      mockRepository.addCard(card2);

      final duplicates = await mockRepository.findDuplicates(term: '学校');
      expect(duplicates.length, 2);
    });

    test('should return empty list when no duplicates found', () async {
      final now = DateTime.now();

      final card1 = SrsCard(
        id: 'card1',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 1)),
      );

      mockRepository.addCard(card1);

      final duplicates = await mockRepository.findDuplicates(term: '学校');
      expect(duplicates.length, 1); // 自分自身のみ

      final duplicates2 = await mockRepository.findDuplicates(term: '病院');
      expect(duplicates2.length, 0);
    });
  });

  group('SrsRepository Merge Tests', () {
    late MockSrsRepository mockRepository;

    setUp(() {
      mockRepository = MockSrsRepository();
    });

    tearDown(() {
      mockRepository.clear();
    });

    test('should merge cards correctly', () async {
      final now = DateTime.now();

      final baseCard = SrsCard(
        id: 'base',
        term: '学校',
        reading: '', // 空の読み
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 1)),
      );

      final mergeCard = SrsCard(
        id: 'merge',
        term: '学校',
        reading: 'がっこう', // 非空の読み
        meaning: '学びの場',
        sourcePostId: 'post2',
        sourceSnippet: '学校で勉強',
        createdAt: now,
        interval: 2,
        easeFactor: 3.0,
        repetition: 2,
        due: now.add(const Duration(days: 2)),
      );

      mockRepository.addCard(baseCard);
      mockRepository.addCard(mergeCard);

      final mergedCard = await mockRepository.mergeCards(
        baseId: 'base',
        mergeIds: ['merge'],
      );

      // ベースカードの情報が保持される
      expect(mergedCard.id, 'base');
      expect(mergedCard.term, '学校');
      expect(mergedCard.sourcePostId, 'post1');
      expect(mergedCard.interval, 1);
      expect(mergedCard.easeFactor, 2.5);
      expect(mergedCard.repetition, 1);

      // マージされた情報
      expect(mergedCard.reading, 'がっこう'); // 非空優先
      expect(mergedCard.meaning, '教育機関; 学びの場'); // 和集合

      // マージ対象カードが削除されている
      final allCards = await mockRepository.getAllCards();
      expect(allCards.length, 1);
      expect(allCards.first.id, 'base');
    });

    test('should handle empty reading in merge', () async {
      final now = DateTime.now();

      final baseCard = SrsCard(
        id: 'base',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 1)),
      );

      final mergeCard = SrsCard(
        id: 'merge',
        term: '学校',
        reading: '', // 空の読み
        meaning: '学びの場',
        sourcePostId: 'post2',
        sourceSnippet: '学校で勉強',
        createdAt: now,
        interval: 2,
        easeFactor: 3.0,
        repetition: 2,
        due: now.add(const Duration(days: 2)),
      );

      mockRepository.addCard(baseCard);
      mockRepository.addCard(mergeCard);

      final mergedCard = await mockRepository.mergeCards(
        baseId: 'base',
        mergeIds: ['merge'],
      );

      expect(mergedCard.reading, 'がっこう'); // ベースカードの読みが保持
      expect(mergedCard.meaning, '教育機関; 学びの場');
    });

    test('should handle duplicate meanings in merge', () async {
      final now = DateTime.now();

      final baseCard = SrsCard(
        id: 'base',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 1)),
      );

      final mergeCard = SrsCard(
        id: 'merge',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関; 学びの場', // 重複する意味を含む
        sourcePostId: 'post2',
        sourceSnippet: '学校で勉強',
        createdAt: now,
        interval: 2,
        easeFactor: 3.0,
        repetition: 2,
        due: now.add(const Duration(days: 2)),
      );

      mockRepository.addCard(baseCard);
      mockRepository.addCard(mergeCard);

      final mergedCard = await mockRepository.mergeCards(
        baseId: 'base',
        mergeIds: ['merge'],
      );

      // 重複が排除される
      final meanings = mergedCard.meaning.split('; ').toSet();
      expect(meanings.length, 2);
      expect(meanings.contains('教育機関'), true);
      expect(meanings.contains('学びの場'), true);
    });

    test('should throw exception when base card not found', () async {
      expect(
        () => mockRepository.mergeCards(baseId: 'nonexistent', mergeIds: []),
        throwsA(isA<SrsRepositoryException>()),
      );
    });
  });

  group('SrsRepository Search Tests', () {
    late MockSrsRepository mockRepository;

    setUp(() {
      mockRepository = MockSrsRepository();
    });

    tearDown(() {
      mockRepository.clear();
    });

    test('should search cards by term', () async {
      final now = DateTime.now();

      final card1 = SrsCard(
        id: 'card1',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 1)),
      );

      final card2 = SrsCard(
        id: 'card2',
        term: '病院',
        reading: 'びょういん',
        meaning: '医療機関',
        sourcePostId: 'post2',
        sourceSnippet: '病院に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 2)),
      );

      mockRepository.addCard(card1);
      mockRepository.addCard(card2);

      final results = await mockRepository.searchByTerm('学校');
      expect(results.length, 1);
      expect(results.first.id, 'card1');

      final results2 = await mockRepository.searchByTerm('病院');
      expect(results2.length, 1);
      expect(results2.first.id, 'card2');

      final results3 = await mockRepository.searchByTerm('存在しない');
      expect(results3.length, 0);
    });

    test('should normalize search terms', () async {
      final now = DateTime.now();

      final card = SrsCard(
        id: 'card1',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校に行く',
        createdAt: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
        due: now.add(const Duration(days: 1)),
      );

      mockRepository.addCard(card);

      // 空白付きで検索
      final results = await mockRepository.searchByTerm(' 学校 ');
      expect(results.length, 1);
      expect(results.first.id, 'card1');
    });
  });
}
