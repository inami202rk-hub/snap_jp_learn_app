import 'package:hive/hive.dart';
import '../../models/post.dart';

/// Hiveを使用した投稿データのローカルデータソース
class PostLocalDataSource {
  static const String _boxName = 'posts';
  Box<Post>? _box;

  /// Hiveボックスを初期化
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<Post>(_boxName);
    }
  }

  /// ボックスが開いているかチェック
  bool get isInitialized => _box != null && _box!.isOpen;

  /// ボックスを取得（初期化されていない場合は例外をスロー）
  Box<Post> get _postsBox {
    if (!isInitialized) {
      throw PostLocalDataSourceException('Box is not initialized');
    }
    return _box!;
  }

  /// 投稿を作成
  ///
  /// [post] 作成する投稿
  ///
  /// Returns: 作成された投稿
  ///
  /// Throws: [PostLocalDataSourceException] 作成に失敗した場合
  Future<Post> createPost(Post post) async {
    try {
      await init();
      await _postsBox.put(post.id, post);
      return post;
    } catch (e) {
      throw PostLocalDataSourceException('Failed to create post: $e');
    }
  }

  /// 投稿一覧を取得
  ///
  /// [limit] 取得件数の上限
  /// [offset] 取得開始位置
  ///
  /// Returns: 投稿のリスト（作成日時の降順）
  Future<List<Post>> listPosts({int limit = 100, int offset = 0}) async {
    try {
      await init();

      final allPosts = _postsBox.values.toList();

      // 作成日時の降順でソート
      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // オフセットとリミットを適用
      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, allPosts.length);

      return allPosts.sublist(startIndex, endIndex);
    } catch (e) {
      throw PostLocalDataSourceException('Failed to list posts: $e');
    }
  }

  /// 指定されたIDの投稿を取得
  ///
  /// [id] 投稿のID
  ///
  /// Returns: 投稿（存在しない場合はnull）
  Future<Post?> getPost(String id) async {
    try {
      await init();
      return _postsBox.get(id);
    } catch (e) {
      throw PostLocalDataSourceException('Failed to get post: $e');
    }
  }

  /// 全投稿を取得
  ///
  /// Returns: 全投稿のリスト
  Future<List<Post>> getAllPosts() async {
    try {
      await init();
      return _postsBox.values.toList();
    } catch (e) {
      throw PostLocalDataSourceException('Failed to get all posts: $e');
    }
  }

  /// 投稿を更新
  ///
  /// [post] 更新する投稿
  ///
  /// Throws: [PostLocalDataSourceException] 更新に失敗した場合
  Future<void> updatePost(Post post) async {
    try {
      await init();
      await _postsBox.put(post.id, post);
    } catch (e) {
      throw PostLocalDataSourceException('Failed to update post: $e');
    }
  }

  /// 投稿を削除
  ///
  /// [id] 投稿のID
  ///
  /// Throws: [PostLocalDataSourceException] 削除に失敗した場合
  Future<void> deletePost(String id) async {
    try {
      await init();
      await _postsBox.delete(id);
    } catch (e) {
      throw PostLocalDataSourceException('Failed to delete post: $e');
    }
  }

  /// 投稿の総数を取得
  ///
  /// Returns: 投稿の総数
  Future<int> getPostCount() async {
    try {
      await init();
      return _postsBox.length;
    } catch (e) {
      throw PostLocalDataSourceException('Failed to get post count: $e');
    }
  }

  /// いいねされた投稿の数を取得
  ///
  /// Returns: いいねされた投稿の数
  Future<int> getLikedPostCount() async {
    try {
      await init();
      return _postsBox.values.where((post) => post.likeCount > 0).length;
    } catch (e) {
      throw PostLocalDataSourceException('Failed to get liked post count: $e');
    }
  }

  /// 学んだ投稿の数を取得
  ///
  /// Returns: 学んだ投稿の数
  Future<int> getLearnedPostCount() async {
    try {
      await init();
      return _postsBox.values.where((post) => post.learned).length;
    } catch (e) {
      throw PostLocalDataSourceException(
        'Failed to get learned post count: $e',
      );
    }
  }

  /// 投稿を検索
  ///
  /// [query] 検索クエリ（テキスト内容で検索）
  /// [limit] 取得件数の上限
  /// [offset] 取得開始位置
  ///
  /// Returns: 検索結果の投稿リスト
  Future<List<Post>> searchPosts({
    required String query,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      await init();

      final allPosts = _postsBox.values.toList();
      final queryLower = query.toLowerCase();

      // テキスト内容で検索（rawText または normalizedText）
      final filteredPosts = allPosts.where((post) {
        return post.rawText.toLowerCase().contains(queryLower) ||
            post.normalizedText.toLowerCase().contains(queryLower);
      }).toList();

      // 作成日時の降順でソート
      filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // オフセットとリミットを適用
      final startIndex = offset;
      final endIndex = (startIndex + limit).clamp(0, filteredPosts.length);

      return filteredPosts.sublist(startIndex, endIndex);
    } catch (e) {
      throw PostLocalDataSourceException('Failed to search posts: $e');
    }
  }

  /// 投稿データをエクスポート（JSON形式）
  ///
  /// Returns: 全投稿のJSONデータ
  Future<List<Map<String, dynamic>>> exportPosts() async {
    try {
      await init();
      return _postsBox.values.map((post) => post.toJson()).toList();
    } catch (e) {
      throw PostLocalDataSourceException('Failed to export posts: $e');
    }
  }

  /// 投稿データをインポート（JSON形式）
  ///
  /// [postsData] インポートする投稿データ
  ///
  /// Throws: [PostLocalDataSourceException] インポートに失敗した場合
  Future<void> importPosts(List<Map<String, dynamic>> postsData) async {
    try {
      await init();

      for (final postData in postsData) {
        final post = Post.fromJson(postData);
        await _postsBox.put(post.id, post);
      }
    } catch (e) {
      throw PostLocalDataSourceException('Failed to import posts: $e');
    }
  }

  /// ボックスを閉じる
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
  }

  /// ボックスをクリア（全データ削除）
  ///
  /// Throws: [PostLocalDataSourceException] クリアに失敗した場合
  Future<void> clear() async {
    try {
      await init();
      await _postsBox.clear();
    } catch (e) {
      throw PostLocalDataSourceException('Failed to clear posts: $e');
    }
  }
}

/// ローカルデータソース関連の例外
class PostLocalDataSourceException implements Exception {
  final String message;

  const PostLocalDataSourceException(this.message);

  @override
  String toString() => 'PostLocalDataSourceException: $message';
}
