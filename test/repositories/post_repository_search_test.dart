import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/models/post.dart';
import 'package:snap_jp_learn_app/repositories/post_repository.dart';

// モックPostRepository
class MockPostRepository implements PostRepository {
  final List<Post> _posts = [];

  void addPost(Post post) => _posts.add(post);
  void clear() => _posts.clear();

  @override
  Future<Post> createPost({
    required image,
    required String raw,
    required String normalized,
  }) async {
    final post = Post(
      id: 'post_${_posts.length}',
      imagePath: image.path,
      rawText: raw,
      normalizedText: normalized,
      createdAt: DateTime.now(),
      likeCount: 0,
      learnedCount: 0,
      learned: false,
    );
    _posts.add(post);
    return post;
  }

  @override
  Future<List<Post>> listPosts({int limit = 100, int offset = 0}) async {
    return _posts.take(limit).skip(offset).toList();
  }

  @override
  Future<Post?> getPost(String id) async {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> toggleLike(String id) async {
    final post = _posts.firstWhere((post) => post.id == id);
    final index = _posts.indexOf(post);
    _posts[index] = post.copyWith(likeCount: post.likeCount + 1);
  }

  @override
  Future<void> toggleLearned(String id) async {
    final post = _posts.firstWhere((post) => post.id == id);
    final index = _posts.indexOf(post);
    _posts[index] = post.copyWith(learned: !post.learned);
  }

  @override
  Future<void> deletePost(String id) async {
    _posts.removeWhere((post) => post.id == id);
  }

  @override
  Future<List<Map<String, dynamic>>> exportPosts() async {
    return _posts.map((post) => post.toJson()).toList();
  }

  @override
  Future<int> getLearnedPostCount() async {
    return _posts.where((post) => post.learned).length;
  }

  @override
  Future<int> getLikedPostCount() async {
    return _posts.where((post) => post.likeCount > 0).length;
  }

  @override
  Future<int> getPostCount() async {
    return _posts.length;
  }

  @override
  Future<void> importPosts(List<Map<String, dynamic>> postsData) async {
    for (final data in postsData) {
      final post = Post.fromJson(data);
      _posts.add(post);
    }
  }

  @override
  Future<List<Post>> searchPosts({
    required String query,
    int limit = 100,
    int offset = 0,
  }) async {
    final normalizedQuery =
        query.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    final queryTerms =
        normalizedQuery.split(' ').where((term) => term.isNotEmpty).toList();

    if (queryTerms.isEmpty) {
      return _posts.take(limit).skip(offset).toList();
    }

    final filteredPosts = _posts.where((post) {
      final normalizedText = post.normalizedText
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');
      final normalizedRaw =
          post.rawText.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
      final normalizedDate = post.createdAt.toString().split(' ')[0];

      return queryTerms.every((term) =>
          normalizedText.contains(term) ||
          normalizedRaw.contains(term) ||
          normalizedDate.contains(term));
    }).toList();

    return filteredPosts.take(limit).skip(offset).toList();
  }

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
  }) async {
    List<Post> filteredPosts = List.from(_posts);

    // 日付フィルタ
    if (startDate != null || endDate != null) {
      filteredPosts = filteredPosts.where((post) {
        final postDate = DateTime(
            post.createdAt.year, post.createdAt.month, post.createdAt.day);
        if (startDate != null && postDate.isBefore(startDate)) return false;
        if (endDate != null && postDate.isAfter(endDate)) return false;
        return true;
      }).toList();
    }

    // いいねフィルタ
    if (likedOnly != null) {
      filteredPosts = filteredPosts
          .where((post) => post.likeCount > 0 == likedOnly)
          .toList();
    }

    // 学んだフィルタ
    if (learnedOnly != null) {
      filteredPosts =
          filteredPosts.where((post) => post.learned == learnedOnly).toList();
    }

    // カード化済みフィルタ
    if (hasCards != null) {
      filteredPosts = filteredPosts
          .where((post) => (post.learnedCount > 0) == hasCards)
          .toList();
    }

    // 並び替え
    if (sortBy == 'oldest') {
      filteredPosts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filteredPosts.take(limit).skip(offset).toList();
  }

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
  }) async {
    List<Post> posts;

    if (query != null && query.trim().isNotEmpty) {
      posts = await searchPosts(query: query, limit: 1000);
    } else {
      posts = List.from(_posts);
    }

    // フィルタを適用
    if (startDate != null || endDate != null) {
      posts = posts.where((post) {
        final postDate = DateTime(
            post.createdAt.year, post.createdAt.month, post.createdAt.day);
        if (startDate != null && postDate.isBefore(startDate)) return false;
        if (endDate != null && postDate.isAfter(endDate)) return false;
        return true;
      }).toList();
    }

    if (likedOnly != null) {
      posts = posts.where((post) => post.likeCount > 0 == likedOnly).toList();
    }

    if (learnedOnly != null) {
      posts = posts.where((post) => post.learned == learnedOnly).toList();
    }

    if (hasCards != null) {
      posts =
          posts.where((post) => (post.learnedCount > 0) == hasCards).toList();
    }

    // 並び替え
    if (sortBy == 'oldest') {
      posts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return posts.take(limit).skip(offset).toList();
  }

  @override
  Future<List<Post>> getAllPosts() async => [];

  @override
  Future<void> clearAllPosts() async {}
}

void main() {
  group('PostRepository Search Tests', () {
    late MockPostRepository mockRepository;

    setUp(() {
      mockRepository = MockPostRepository();
    });

    tearDown(() {
      mockRepository.clear();
    });

    test('should search posts by normalized text', () async {
      final now = DateTime.now();

      final post1 = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: '学校に行く',
        normalizedText: '学校に行く',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      final post2 = Post(
        id: 'post2',
        imagePath: 'path2',
        rawText: '病院で診察',
        normalizedText: '病院で診察',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post1);
      mockRepository.addPost(post2);

      final results = await mockRepository.searchPosts(query: '学校');
      expect(results.length, 1);
      expect(results.first.id, 'post1');

      final results2 = await mockRepository.searchPosts(query: '病院');
      expect(results2.length, 1);
      expect(results2.first.id, 'post2');
    });

    test('should perform AND search with multiple terms', () async {
      final now = DateTime.now();

      final post1 = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: '学校に行く',
        normalizedText: '学校に行く',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      final post2 = Post(
        id: 'post2',
        imagePath: 'path2',
        rawText: '学校で勉強する',
        normalizedText: '学校で勉強する',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post1);
      mockRepository.addPost(post2);

      // "学校 勉強" で検索 - 両方の語が含まれる必要がある
      final results = await mockRepository.searchPosts(query: '学校 勉強');
      expect(results.length, 1);
      expect(results.first.id, 'post2');
    });

    test('should normalize search terms', () async {
      final now = DateTime.now();

      final post = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: '学校に行く',
        normalizedText: '学校に行く',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post);

      // 空白付きで検索
      final results = await mockRepository.searchPosts(query: ' 学校 ');
      expect(results.length, 1);
      expect(results.first.id, 'post1');
    });

    test('should search by date', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final post = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: '学校に行く',
        normalizedText: '学校に行く',
        createdAt: today,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post);

      // 日付で検索
      final results = await mockRepository.searchPosts(
          query: today.toString().split(' ')[0]);
      expect(results.length, 1);
      expect(results.first.id, 'post1');
    });
  });

  group('PostRepository Filter Tests', () {
    late MockPostRepository mockRepository;

    setUp(() {
      mockRepository = MockPostRepository();
    });

    tearDown(() {
      mockRepository.clear();
    });

    test('should filter posts by date range', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      final post1 = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: '昨日の投稿',
        normalizedText: '昨日の投稿',
        createdAt: yesterday,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      final post2 = Post(
        id: 'post2',
        imagePath: 'path2',
        rawText: '今日の投稿',
        normalizedText: '今日の投稿',
        createdAt: today,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      final post3 = Post(
        id: 'post3',
        imagePath: 'path3',
        rawText: '明日の投稿',
        normalizedText: '明日の投稿',
        createdAt: tomorrow,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post1);
      mockRepository.addPost(post2);
      mockRepository.addPost(post3);

      // 今日のみフィルタ
      final results = await mockRepository.filterPosts(
        startDate: today,
        endDate: today,
      );
      expect(results.length, 1);
      expect(results.first.id, 'post2');

      // 昨日から今日までフィルタ
      final results2 = await mockRepository.filterPosts(
        startDate: yesterday,
        endDate: today,
      );
      expect(results2.length, 2);
    });

    test('should filter posts by liked status', () async {
      final now = DateTime.now();

      final post1 = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: 'いいねあり',
        normalizedText: 'いいねあり',
        createdAt: now,
        likeCount: 1,
        learnedCount: 0,
        learned: false,
      );

      final post2 = Post(
        id: 'post2',
        imagePath: 'path2',
        rawText: 'いいねなし',
        normalizedText: 'いいねなし',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post1);
      mockRepository.addPost(post2);

      // いいね済みのみフィルタ
      final likedResults = await mockRepository.filterPosts(likedOnly: true);
      expect(likedResults.length, 1);
      expect(likedResults.first.id, 'post1');

      // いいねなしのみフィルタ
      final notLikedResults =
          await mockRepository.filterPosts(likedOnly: false);
      expect(notLikedResults.length, 1);
      expect(notLikedResults.first.id, 'post2');
    });

    test('should filter posts by learned status', () async {
      final now = DateTime.now();

      final post1 = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: '学んだ投稿',
        normalizedText: '学んだ投稿',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: true,
      );

      final post2 = Post(
        id: 'post2',
        imagePath: 'path2',
        rawText: '未学習投稿',
        normalizedText: '未学習投稿',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post1);
      mockRepository.addPost(post2);

      // 学んだ済みのみフィルタ
      final learnedResults =
          await mockRepository.filterPosts(learnedOnly: true);
      expect(learnedResults.length, 1);
      expect(learnedResults.first.id, 'post1');

      // 未学習のみフィルタ
      final notLearnedResults =
          await mockRepository.filterPosts(learnedOnly: false);
      expect(notLearnedResults.length, 1);
      expect(notLearnedResults.first.id, 'post2');
    });

    test('should filter posts by card status', () async {
      final now = DateTime.now();

      final post1 = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: 'カード化済み',
        normalizedText: 'カード化済み',
        createdAt: now,
        likeCount: 0,
        learnedCount: 1,
        learned: false,
      );

      final post2 = Post(
        id: 'post2',
        imagePath: 'path2',
        rawText: '未カード化',
        normalizedText: '未カード化',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post1);
      mockRepository.addPost(post2);

      // カード化済みのみフィルタ
      final cardedResults = await mockRepository.filterPosts(hasCards: true);
      expect(cardedResults.length, 1);
      expect(cardedResults.first.id, 'post1');

      // 未カード化のみフィルタ
      final notCardedResults =
          await mockRepository.filterPosts(hasCards: false);
      expect(notCardedResults.length, 1);
      expect(notCardedResults.first.id, 'post2');
    });

    test('should sort posts correctly', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      final post1 = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: '昨日の投稿',
        normalizedText: '昨日の投稿',
        createdAt: yesterday,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      final post2 = Post(
        id: 'post2',
        imagePath: 'path2',
        rawText: '今日の投稿',
        normalizedText: '今日の投稿',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      final post3 = Post(
        id: 'post3',
        imagePath: 'path3',
        rawText: '明日の投稿',
        normalizedText: '明日の投稿',
        createdAt: tomorrow,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post1);
      mockRepository.addPost(post2);
      mockRepository.addPost(post3);

      // 新しい順
      final newestResults = await mockRepository.filterPosts(sortBy: 'newest');
      expect(newestResults.length, 3);
      expect(newestResults[0].id, 'post3');
      expect(newestResults[1].id, 'post2');
      expect(newestResults[2].id, 'post1');

      // 古い順
      final oldestResults = await mockRepository.filterPosts(sortBy: 'oldest');
      expect(oldestResults.length, 3);
      expect(oldestResults[0].id, 'post1');
      expect(oldestResults[1].id, 'post2');
      expect(oldestResults[2].id, 'post3');
    });
  });

  group('PostRepository Search and Filter Combined Tests', () {
    late MockPostRepository mockRepository;

    setUp(() {
      mockRepository = MockPostRepository();
    });

    tearDown(() {
      mockRepository.clear();
    });

    test('should combine search and filter correctly', () async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final post1 = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: '学校に行く',
        normalizedText: '学校に行く',
        createdAt: today,
        likeCount: 1,
        learnedCount: 0,
        learned: false,
      );

      final post2 = Post(
        id: 'post2',
        imagePath: 'path2',
        rawText: '病院で診察',
        normalizedText: '病院で診察',
        createdAt: today,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      final post3 = Post(
        id: 'post3',
        imagePath: 'path3',
        rawText: '学校で勉強',
        normalizedText: '学校で勉強',
        createdAt: today,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post1);
      mockRepository.addPost(post2);
      mockRepository.addPost(post3);

      // "学校" で検索 + いいね済みフィルタ
      final results = await mockRepository.searchAndFilterPosts(
        query: '学校',
        likedOnly: true,
      );
      expect(results.length, 1);
      expect(results.first.id, 'post1');

      // "学校" で検索 + いいねなしフィルタ
      final results2 = await mockRepository.searchAndFilterPosts(
        query: '学校',
        likedOnly: false,
      );
      expect(results2.length, 1);
      expect(results2.first.id, 'post3');
    });

    test('should handle empty search query', () async {
      final now = DateTime.now();

      final post = Post(
        id: 'post1',
        imagePath: 'path1',
        rawText: 'テスト投稿',
        normalizedText: 'テスト投稿',
        createdAt: now,
        likeCount: 0,
        learnedCount: 0,
        learned: false,
      );

      mockRepository.addPost(post);

      // 空のクエリで検索
      final results = await mockRepository.searchAndFilterPosts(query: '');
      expect(results.length, 1);
      expect(results.first.id, 'post1');

      // nullクエリで検索
      final results2 = await mockRepository.searchAndFilterPosts(query: null);
      expect(results2.length, 1);
      expect(results2.first.id, 'post1');
    });
  });
}
