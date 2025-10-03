import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap_jp_learn_app/services/stats_service.dart';
import 'package:snap_jp_learn_app/models/srs_card.dart';
import 'package:snap_jp_learn_app/models/review_log.dart';
import 'package:snap_jp_learn_app/models/post.dart';
import 'package:snap_jp_learn_app/repositories/srs_repository.dart';
import 'package:snap_jp_learn_app/repositories/post_repository.dart';

// モックリポジトリ
class MockSrsRepository implements SrsRepository {
  final List<SrsCard> _cards = [];
  final List<ReviewLog> _reviewLogs = [];

  void addCard(SrsCard card) {
    _cards.add(card);
  }

  void addReviewLog(ReviewLog log) {
    _reviewLogs.add(log);
  }

  @override
  Future<List<SrsCard>> listDueCards({DateTime? now, int limit = 20}) async {
    final dueDate = now ?? DateTime.now();
    return _cards
        .where((card) => card.due.isBefore(dueDate))
        .take(limit)
        .toList();
  }

  @override
  Future<SrsCard> upsertCard(SrsCard card) async {
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index >= 0) {
      _cards[index] = card;
    } else {
      _cards.add(card);
    }
    return card;
  }

  @override
  Future<void> review(String cardId, Rating rating, DateTime now) async {
    // モック実装
  }

  @override
  Future<List<SrsCard>> listByPost(String postId) async {
    return _cards.where((card) => card.sourcePostId == postId).toList();
  }

  @override
  Future<void> deleteByPost(String postId) async {
    _cards.removeWhere((card) => card.sourcePostId == postId);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    _cards.removeWhere((card) => card.id == cardId);
  }

  @override
  Future<SrsCard?> getCard(String cardId) async {
    try {
      return _cards.firstWhere((card) => card.id == cardId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getCardCount() async => _cards.length;

  @override
  Future<int> getDueCardCount({DateTime? now}) async {
    final dueDate = now ?? DateTime.now();
    return _cards.where((card) => card.due.isBefore(dueDate)).length;
  }

  @override
  Future<int> getTodayReviewCount() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return _reviewLogs.where((log) {
      return log.reviewedAt.isAfter(todayStart) &&
          log.reviewedAt.isBefore(todayEnd);
    }).length;
  }

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
  Future<ReviewLog> createReviewLog(ReviewLog log) async {
    _reviewLogs.add(log);
    return log;
  }

  @override
  Future<void> clearAllData() async {
    _cards.clear();
    _reviewLogs.clear();
  }

  @override
  Future<List<SrsCard>> findDuplicates({String? term}) async => [];

  @override
  Future<SrsCard> mergeCards(
      {required String baseId, required List<String> mergeIds}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<SrsCard>> searchByTerm(String term) async => [];

  @override
  Future<List<SrsCard>> searchCards({
    required String query,
    int limit = 100,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<List<SrsCard>> filterCards({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'newest',
    int limit = 100,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<List<SrsCard>> searchAndFilterCards({
    String? query,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String sortBy = 'newest',
    int limit = 100,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<void> close() async {}

  @override
  Future<int> createCardsFromCandidates(List<dynamic> candidates,
          String sourcePostId, String sourceSnippet) async =>
      0;

  @override
  Future<Map<String, dynamic>?> getCardStats(String cardId) async => null;

  @override
  Future<Map<String, int>> getCardsByStatus() async => {};

  @override
  Future<List<ReviewLog>> getReviewLogsByCard(String cardId) async => [];

  @override
  Future<List<ReviewLog>> getReviewLogsByDate(DateTime date) async => [];
}

class MockPostRepository implements PostRepository {
  @override
  Future<List<Post>> listPosts({int limit = 100, int offset = 0}) async => [];

  @override
  Future<Post?> getPost(String id) async => null;

  @override
  Future<Post> createPost(
      {required XFile image,
      required String raw,
      required String normalized}) async {
    return Post(
      id: 'test_id',
      imagePath: image.path,
      rawText: raw,
      normalizedText: normalized,
      createdAt: DateTime.now(),
      likeCount: 0,
      learnedCount: 0,
      learned: false,
    );
  }

  Future<Post> updatePost(Post post) async => post;

  @override
  Future<void> deletePost(String id) async {}

  Future<List<Post>> getPostsByDateRange(DateTime start, DateTime end) async =>
      [];

  @override
  Future<List<Post>> searchPosts({
    required String query,
    int limit = 100,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<List<Post>> filterPosts({
    DateTime? startDate,
    DateTime? endDate,
    bool? likedOnly,
    bool? learnedOnly,
    bool? hasCards,
    String sortBy = 'newest',
    int limit = 100,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<List<Post>> searchAndFilterPosts({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    bool? likedOnly,
    bool? learnedOnly,
    bool? hasCards,
    String sortBy = 'newest',
    int limit = 100,
    int offset = 0,
  }) async =>
      [];

  @override
  Future<void> close() async {}

  @override
  Future<List<Map<String, dynamic>>> exportPosts() async => [];

  @override
  Future<int> getLearnedPostCount() async => 0;

  @override
  Future<int> getLikedPostCount() async => 0;

  @override
  Future<int> getPostCount() async => 0;

  @override
  Future<void> importPosts(List<Map<String, dynamic>> postsData) async {}

  @override
  Future<void> toggleLearned(String id) async {}

  @override
  Future<void> toggleLike(String id) async {}

  @override
  Future<List<Post>> getAllPosts() async => [];

  @override
  Future<void> clearAllPosts() async {}
}

void main() {
  group('StatsService Tests', () {
    late StatsService statsService;
    late MockSrsRepository mockSrsRepository;
    late MockPostRepository mockPostRepository;

    setUp(() {
      mockSrsRepository = MockSrsRepository();
      mockPostRepository = MockPostRepository();
      statsService = StatsService(
        srsRepository: mockSrsRepository,
        postRepository: mockPostRepository,
      );
    });

    test('should calculate stats correctly with empty data', () async {
      final stats = await statsService.getStats();

      expect(stats.todayReviews, 0);
      expect(stats.weekReviews, 0);
      expect(stats.monthReviews, 0);
      expect(stats.streakDays, 0);
      expect(stats.todayDueCount, 0);
      expect(stats.remainingDueCount, 0);
      expect(stats.totalCards, 0);
      expect(stats.weekCreatedCards, 0);
    });

    test('should calculate today reviews correctly', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 今日のレビューログを追加
      mockSrsRepository.addReviewLog(ReviewLog(
        id: '1',
        cardId: 'card1',
        reviewedAt: today.add(const Duration(hours: 10)),
        rating: Rating.good.value,
      ));

      mockSrsRepository.addReviewLog(ReviewLog(
        id: '2',
        cardId: 'card2',
        reviewedAt: today.add(const Duration(hours: 15)),
        rating: Rating.easy.value,
      ));

      final stats = await statsService.getStats();

      expect(stats.todayReviews, 2);
    });

    test('should calculate week reviews correctly', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = _getWeekStart(today);

      // 今週のレビューログを追加
      for (int i = 0; i < 3; i++) {
        mockSrsRepository.addReviewLog(ReviewLog(
          id: 'log$i',
          cardId: 'card$i',
          reviewedAt: weekStart.add(Duration(days: i)),
          rating: Rating.good.value,
        ));
      }

      final stats = await statsService.getStats();

      expect(stats.weekReviews, 3);
    });

    test('should calculate month reviews correctly', () async {
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);

      // 今月のレビューログを追加（確実に月内に収まるように）
      mockSrsRepository.addReviewLog(ReviewLog(
        id: 'log1',
        cardId: 'card1',
        reviewedAt: monthStart.add(const Duration(days: 1)),
        rating: Rating.good.value,
      ));

      mockSrsRepository.addReviewLog(ReviewLog(
        id: 'log2',
        cardId: 'card2',
        reviewedAt: monthStart.add(const Duration(days: 5)),
        rating: Rating.good.value,
      ));

      mockSrsRepository.addReviewLog(ReviewLog(
        id: 'log3',
        cardId: 'card3',
        reviewedAt: monthStart.add(const Duration(days: 10)),
        rating: Rating.good.value,
      ));

      mockSrsRepository.addReviewLog(ReviewLog(
        id: 'log4',
        cardId: 'card4',
        reviewedAt: monthStart.add(const Duration(days: 15)),
        rating: Rating.good.value,
      ));

      mockSrsRepository.addReviewLog(ReviewLog(
        id: 'log5',
        cardId: 'card5',
        reviewedAt: monthStart.add(const Duration(days: 20)),
        rating: Rating.good.value,
      ));

      final stats = await statsService.getStats();

      expect(stats.monthReviews, 5);
    });

    test('should calculate streak days correctly', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 連続3日間のレビューログを追加
      mockSrsRepository.addReviewLog(ReviewLog(
        id: '1',
        cardId: 'card1',
        reviewedAt: today,
        rating: Rating.good.value,
      ));

      mockSrsRepository.addReviewLog(ReviewLog(
        id: '2',
        cardId: 'card2',
        reviewedAt: today.subtract(const Duration(days: 1)),
        rating: Rating.good.value,
      ));

      mockSrsRepository.addReviewLog(ReviewLog(
        id: '3',
        cardId: 'card3',
        reviewedAt: today.subtract(const Duration(days: 2)),
        rating: Rating.good.value,
      ));

      final stats = await statsService.getStats();

      expect(stats.streakDays, 3);
    });

    test('should calculate due counts correctly', () async {
      final now = DateTime.now();

      // Dueカードを追加
      mockSrsRepository.addCard(SrsCard(
        id: 'card1',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校で勉強する',
        createdAt: now.subtract(const Duration(days: 1)),
        due: now.subtract(const Duration(hours: 1)), // 過去のDue
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
      ));

      mockSrsRepository.addCard(SrsCard(
        id: 'card2',
        term: '学生',
        reading: 'がくせい',
        meaning: '学校に通う人',
        sourcePostId: 'post1',
        sourceSnippet: '学生が勉強する',
        createdAt: now.subtract(const Duration(days: 1)),
        due: now.add(const Duration(hours: 1)), // 未来のDue
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
      ));

      final stats = await statsService.getStats();

      expect(stats.todayDueCount, 1); // 今日Dueのカード数
      expect(stats.remainingDueCount, 1); // 残りDueのカード数
    });

    test('should calculate card counts correctly', () async {
      final now = DateTime.now();
      final weekStart = _getWeekStart(DateTime(now.year, now.month, now.day));

      // 古いカード
      mockSrsRepository.addCard(SrsCard(
        id: 'card1',
        term: '学校',
        reading: 'がっこう',
        meaning: '教育機関',
        sourcePostId: 'post1',
        sourceSnippet: '学校で勉強する',
        createdAt: now.subtract(const Duration(days: 10)),
        due: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
      ));

      // 今週作成のカード
      mockSrsRepository.addCard(SrsCard(
        id: 'card2',
        term: '学生',
        reading: 'がくせい',
        meaning: '学校に通う人',
        sourcePostId: 'post1',
        sourceSnippet: '学生が勉強する',
        createdAt: weekStart.add(const Duration(days: 2)),
        due: now,
        interval: 1,
        easeFactor: 2.5,
        repetition: 1,
      ));

      final stats = await statsService.getStats();

      expect(stats.totalCards, 2);
      expect(stats.weekCreatedCards, 1);
    });

    test('should update stats on review completed', () async {
      // 初期統計を取得
      final initialStats = await statsService.getStats();
      expect(initialStats.todayReviews, 0);

      // レビュー完了をシミュレート
      await statsService.onReviewCompleted(Rating.good);

      // 統計が更新されていることを確認
      final updatedStats = await statsService.getStats();
      expect(updatedStats.todayReviews, 1);
    });

    test('should update stats on card created', () async {
      // 初期統計を取得
      final initialStats = await statsService.getStats();
      expect(initialStats.totalCards, 0);
      expect(initialStats.weekCreatedCards, 0);

      // カード作成をシミュレート
      await statsService.onCardCreated();

      // 統計が更新されていることを確認
      final updatedStats = await statsService.getStats();
      expect(updatedStats.totalCards, 1);
      expect(updatedStats.weekCreatedCards, 1);
    });

    test('should cache stats for performance', () async {
      // 初回取得
      final stats1 = await statsService.getStats();

      // 2回目取得（キャッシュから）
      final stats2 = await statsService.getStats();

      // 同じオブジェクトであることを確認（キャッシュ）
      expect(stats1, same(stats2));
    });

    test('should refresh stats when requested', () async {
      // 初回取得
      final stats1 = await statsService.getStats();

      // 強制更新
      final stats2 = await statsService.refreshStats();

      // 異なるオブジェクトであることを確認（更新）
      expect(stats1, isNot(same(stats2)));
    });

    test('should clear cache', () {
      statsService.clearCache();
      // キャッシュクリア後は再計算される
      expect(statsService.getStats(), isA<Future<LearningStats>>());
    });
  });

  group('LearningStats Tests', () {
    test('should be created with required fields', () {
      final now = DateTime.now();
      final stats = LearningStats(
        todayReviews: 5,
        weekReviews: 20,
        monthReviews: 80,
        streakDays: 7,
        todayDueCount: 3,
        remainingDueCount: 10,
        totalCards: 100,
        weekCreatedCards: 5,
        lastUpdated: now,
      );

      expect(stats.todayReviews, 5);
      expect(stats.weekReviews, 20);
      expect(stats.monthReviews, 80);
      expect(stats.streakDays, 7);
      expect(stats.todayDueCount, 3);
      expect(stats.remainingDueCount, 10);
      expect(stats.totalCards, 100);
      expect(stats.weekCreatedCards, 5);
      expect(stats.lastUpdated, now);
    });

    test('copyWith should create new instance with updated fields', () {
      final now = DateTime.now();
      final original = LearningStats(
        todayReviews: 5,
        weekReviews: 20,
        monthReviews: 80,
        streakDays: 7,
        todayDueCount: 3,
        remainingDueCount: 10,
        totalCards: 100,
        weekCreatedCards: 5,
        lastUpdated: now,
      );

      final updated = original.copyWith(
        todayReviews: 6,
        streakDays: 8,
      );

      expect(updated.todayReviews, 6);
      expect(updated.weekReviews, 20); // 変更なし
      expect(updated.streakDays, 8);
      expect(updated.todayDueCount, 3); // 変更なし
    });

    test('toJson should serialize correctly', () {
      final now = DateTime.now();
      final stats = LearningStats(
        todayReviews: 5,
        weekReviews: 20,
        monthReviews: 80,
        streakDays: 7,
        todayDueCount: 3,
        remainingDueCount: 10,
        totalCards: 100,
        weekCreatedCards: 5,
        lastUpdated: now,
      );

      final json = stats.toJson();

      expect(json['todayReviews'], 5);
      expect(json['weekReviews'], 20);
      expect(json['monthReviews'], 80);
      expect(json['streakDays'], 7);
      expect(json['todayDueCount'], 3);
      expect(json['remainingDueCount'], 10);
      expect(json['totalCards'], 100);
      expect(json['weekCreatedCards'], 5);
      expect(json['lastUpdated'], now.toIso8601String());
    });

    test('fromJson should deserialize correctly', () {
      final now = DateTime.now();
      final json = {
        'todayReviews': 5,
        'weekReviews': 20,
        'monthReviews': 80,
        'streakDays': 7,
        'todayDueCount': 3,
        'remainingDueCount': 10,
        'totalCards': 100,
        'weekCreatedCards': 5,
        'lastUpdated': now.toIso8601String(),
      };

      final stats = LearningStats.fromJson(json);

      expect(stats.todayReviews, 5);
      expect(stats.weekReviews, 20);
      expect(stats.monthReviews, 80);
      expect(stats.streakDays, 7);
      expect(stats.todayDueCount, 3);
      expect(stats.remainingDueCount, 10);
      expect(stats.totalCards, 100);
      expect(stats.weekCreatedCards, 5);
      expect(stats.lastUpdated, now);
    });

    test('toString should return readable string', () {
      final now = DateTime.now();
      final stats = LearningStats(
        todayReviews: 5,
        weekReviews: 20,
        monthReviews: 80,
        streakDays: 7,
        todayDueCount: 3,
        remainingDueCount: 10,
        totalCards: 100,
        weekCreatedCards: 5,
        lastUpdated: now,
      );

      final str = stats.toString();

      expect(str, contains('5'));
      expect(str, contains('20'));
      expect(str, contains('80'));
      expect(str, contains('7'));
      expect(str, contains('3'));
      expect(str, contains('10'));
      expect(str, contains('100'));
    });
  });
}

// ヘルパー関数
DateTime _getWeekStart(DateTime date) {
  final weekday = date.weekday;
  final daysToSubtract = weekday == 1 ? 0 : weekday - 1;
  return date.subtract(Duration(days: daysToSubtract));
}
