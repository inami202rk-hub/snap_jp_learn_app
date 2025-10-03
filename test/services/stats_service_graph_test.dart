import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/stats_service.dart';
import 'package:snap_jp_learn_app/models/review_log.dart';
import 'package:snap_jp_learn_app/models/srs_card.dart';
import 'package:snap_jp_learn_app/repositories/srs_repository.dart';
import 'package:snap_jp_learn_app/repositories/post_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap_jp_learn_app/models/post.dart';

// Mock classes
class MockSrsRepository implements SrsRepository {
  final List<ReviewLog> _reviewLogs = [];
  final List<SrsCard> _cards = [];

  void addReviewLog(ReviewLog log) {
    _reviewLogs.add(log);
  }

  void addCard(SrsCard card) {
    _cards.add(card);
  }

  @override
  Future<List<SrsCard>> listDueCards({DateTime? now, int limit = 20}) async {
    return _cards.where((card) => card.isDueToday).take(limit).toList();
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
    final log = ReviewLog(
      id: 'log_${_reviewLogs.length}',
      cardId: cardId,
      rating: rating.value,
      reviewedAt: now,
    );
    _reviewLogs.add(log);
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
  Future<int> getCardCount() async {
    return _cards.length;
  }

  Future<int> getTodayDueCount() async {
    return _cards.where((card) => card.isDueToday).length;
  }

  @override
  Future<List<SrsCard>> getAllCards() async {
    return List.from(_cards);
  }

  @override
  Future<List<SrsCard>> getDueCards() async {
    return _cards.where((card) => card.isDueToday).toList();
  }

  @override
  Future<List<ReviewLog>> getAllReviewLogs() async {
    return List.from(_reviewLogs);
  }

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
  Future<List<SrsCard>> findDuplicates({String? term}) async {
    return [];
  }

  @override
  Future<SrsCard> mergeCards(
      {required String baseId, required List<String> mergeIds}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<SrsCard>> searchByTerm(String term) async {
    return [];
  }

  @override
  Future<List<SrsCard>> searchCards(
      {required String query, int limit = 100, int offset = 0}) async {
    return [];
  }

  @override
  Future<List<SrsCard>> filterCards(
      {String? status,
      DateTime? startDate,
      DateTime? endDate,
      String sortBy = 'newest',
      int limit = 100,
      int offset = 0}) async {
    return [];
  }

  @override
  Future<List<SrsCard>> searchAndFilterCards(
      {String? query,
      String? status,
      DateTime? startDate,
      DateTime? endDate,
      String sortBy = 'newest',
      int limit = 100,
      int offset = 0}) async {
    return [];
  }

  // 未実装のメソッド（テストでは使用しない）
  @override
  Future<int> getDueCardCount({DateTime? now}) async => 0;

  @override
  Future<int> getTodayReviewCount() async => 0;

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
  Future<void> close() async {}
}

class MockPostRepository implements PostRepository {
  @override
  Future<Post> createPost(
      {required XFile image,
      required String raw,
      required String normalized}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Post>> listPosts({int limit = 20, int offset = 0}) async {
    return [];
  }

  @override
  Future<Post?> getPost(String id) async {
    return null;
  }

  @override
  Future<void> deletePost(String id) async {}

  @override
  Future<void> toggleLike(String id) async {}

  @override
  Future<void> toggleLearned(String id) async {}

  @override
  Future<int> getLikedPostCount() async {
    return 0;
  }

  @override
  Future<int> getPostCount() async {
    return 0;
  }

  @override
  Future<void> importPosts(List<Map<String, dynamic>> postsData) async {}

  @override
  Future<List<Post>> searchPosts(
      {required String query, int limit = 100, int offset = 0}) async {
    return [];
  }

  @override
  Future<List<Post>> filterPosts(
      {DateTime? startDate,
      DateTime? endDate,
      bool? likedOnly,
      bool? learnedOnly,
      bool? hasCards,
      String sortBy = 'newest',
      int limit = 100,
      int offset = 0}) async {
    return [];
  }

  @override
  Future<List<Post>> searchAndFilterPosts(
      {String? query,
      DateTime? startDate,
      DateTime? endDate,
      bool? likedOnly,
      bool? learnedOnly,
      bool? hasCards,
      String sortBy = 'newest',
      int limit = 100,
      int offset = 0}) async {
    return [];
  }

  @override
  Future<int> getLearnedPostCount() async => 0;

  @override
  Future<List<Map<String, dynamic>>> exportPosts() async => [];

  @override
  Future<List<Post>> getAllPosts() async => [];

  @override
  Future<void> clearAllPosts() async {}

  @override
  Future<void> close() async {}
}

void main() {
  group('StatsService Graph Tests', () {
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

    group('getDailyReviewCounts', () {
      test('should return correct length for last 7 days', () async {
        final dailyCounts = await statsService.getDailyReviewCounts();
        expect(dailyCounts, hasLength(7));
      });

      test('should return zeros when no reviews exist', () async {
        final dailyCounts = await statsService.getDailyReviewCounts();
        expect(dailyCounts.every((count) => count == 0), isTrue);
      });

      test('should handle custom lastNDays parameter', () async {
        final dailyCounts =
            await statsService.getDailyReviewCounts(lastNDays: 3);
        expect(dailyCounts, hasLength(3));
      });
    });

    group('getWeeklyReviewCounts', () {
      test('should return correct length for last 4 weeks', () async {
        final weeklyCounts = await statsService.getWeeklyReviewCounts();
        expect(weeklyCounts, hasLength(4));
      });

      test('should return zeros when no reviews exist', () async {
        final weeklyCounts = await statsService.getWeeklyReviewCounts();
        expect(weeklyCounts.every((count) => count == 0), isTrue);
      });

      test('should handle custom lastNWeeks parameter', () async {
        final weeklyCounts =
            await statsService.getWeeklyReviewCounts(lastNWeeks: 2);
        expect(weeklyCounts, hasLength(2));
      });
    });

    group('Integration with existing stats', () {
      test('should work with existing getStats method', () async {
        final stats = await statsService.getStats();
        expect(stats, isNotNull);
        expect(stats.todayReviews, isA<int>());
        expect(stats.totalCards, isA<int>());
      });
    });
  });
}
