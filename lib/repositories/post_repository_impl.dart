import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import '../services/image_store.dart';
import '../data/local/post_local_data_source.dart';

/// Hiveを使用したPostRepositoryの実装
class PostRepositoryImpl implements PostRepository {
  final PostLocalDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  PostRepositoryImpl(this._dataSource);

  @override
  Future<Post> createPost({
    required XFile image,
    required String raw,
    required String normalized,
  }) async {
    try {
      // 1. 画像ファイルを保存
      final imagePath = await ImageStore.saveImageFile(image);

      // 2. 投稿を作成
      final post = Post(
        id: _uuid.v4(),
        imagePath: imagePath,
        rawText: raw,
        normalizedText: normalized,
        createdAt: DateTime.now(),
      );

      // 3. データベースに保存
      await _dataSource.createPost(post);

      return post;
    } catch (e) {
      // エラーが発生した場合、画像ファイルを削除（ロールバック）
      try {
        if (e is PostRepositoryException) {
          // 既にPostRepositoryExceptionの場合は再スロー
          rethrow;
        }
        throw PostRepositoryException('Failed to create post: $e');
      } catch (rollbackError) {
        // ロールバックに失敗した場合でも、元のエラーを優先
        throw PostRepositoryException('Failed to create post: $e');
      }
    }
  }

  @override
  Future<List<Post>> listPosts({int limit = 100, int offset = 0}) async {
    try {
      return await _dataSource.listPosts(limit: limit, offset: offset);
    } catch (e) {
      throw PostRepositoryException('Failed to list posts: $e');
    }
  }

  @override
  Future<Post?> getPost(String id) async {
    try {
      return await _dataSource.getPost(id);
    } catch (e) {
      throw PostRepositoryException('Failed to get post: $e');
    }
  }

  @override
  Future<void> toggleLike(String id) async {
    try {
      final post = await _dataSource.getPost(id);
      if (post == null) {
        throw PostRepositoryException('Post not found: $id');
      }

      // いいねをトグル（MVPでは単純に+1/-1）
      final newLikeCount = post.likeCount > 0 ? 0 : 1;
      final updatedPost = post.copyWith(likeCount: newLikeCount);

      await _dataSource.updatePost(updatedPost);
    } catch (e) {
      throw PostRepositoryException('Failed to toggle like: $e');
    }
  }

  @override
  Future<void> toggleLearned(String id) async {
    try {
      final post = await _dataSource.getPost(id);
      if (post == null) {
        throw PostRepositoryException('Post not found: $id');
      }

      // 学んだフラグをトグル
      final newLearned = !post.learned;
      final newLearnedCount =
          newLearned ? post.learnedCount + 1 : post.learnedCount - 1;

      final updatedPost = post.copyWith(
        learned: newLearned,
        learnedCount: newLearnedCount.clamp(0, double.infinity).toInt(),
      );

      await _dataSource.updatePost(updatedPost);
    } catch (e) {
      throw PostRepositoryException('Failed to toggle learned: $e');
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      // 1. 投稿を取得して画像パスを確認
      final post = await _dataSource.getPost(id);
      if (post == null) {
        throw PostRepositoryException('Post not found: $id');
      }

      // 2. データベースから削除
      await _dataSource.deletePost(id);

      // 3. 画像ファイルを削除
      try {
        await ImageStore.deleteImageFile(post.imagePath);
      } catch (imageError) {
        // 画像削除に失敗しても、DB削除は完了しているので警告のみ
        debugPrint('Warning: Failed to delete image file: $imageError');
      }
    } catch (e) {
      throw PostRepositoryException('Failed to delete post: $e');
    }
  }

  @override
  Future<int> getPostCount() async {
    try {
      return await _dataSource.getPostCount();
    } catch (e) {
      throw PostRepositoryException('Failed to get post count: $e');
    }
  }

  @override
  Future<int> getLikedPostCount() async {
    try {
      return await _dataSource.getLikedPostCount();
    } catch (e) {
      throw PostRepositoryException('Failed to get liked post count: $e');
    }
  }

  @override
  Future<int> getLearnedPostCount() async {
    try {
      return await _dataSource.getLearnedPostCount();
    } catch (e) {
      throw PostRepositoryException('Failed to get learned post count: $e');
    }
  }

  @override
  Future<List<Post>> searchPosts({
    required String query,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      return await _dataSource.searchPosts(
        query: query,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw PostRepositoryException('Failed to search posts: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> exportPosts() async {
    try {
      return await _dataSource.exportPosts();
    } catch (e) {
      throw PostRepositoryException('Failed to export posts: $e');
    }
  }

  @override
  Future<void> importPosts(List<Map<String, dynamic>> postsData) async {
    try {
      await _dataSource.importPosts(postsData);
    } catch (e) {
      throw PostRepositoryException('Failed to import posts: $e');
    }
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
    try {
      final allPosts = await _dataSource.getAllPosts();
      List<Post> filteredPosts = allPosts;

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
        filteredPosts = filteredPosts.where((post) {
          // カード化済みかどうかは learnedCount > 0 で判定
          return (post.learnedCount > 0) == hasCards;
        }).toList();
      }

      // 並び替え
      if (sortBy == 'oldest') {
        filteredPosts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else {
        filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      return filteredPosts.take(limit).skip(offset).toList();
    } catch (e) {
      throw PostRepositoryException('Failed to filter posts: $e');
    }
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
    try {
      List<Post> posts;

      if (query != null && query.trim().isNotEmpty) {
        // 検索を実行
        posts = await searchPosts(query: query, limit: 1000); // 検索結果を多めに取得
      } else {
        // 全投稿を取得
        posts = await _dataSource.getAllPosts();
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
    } catch (e) {
      throw PostRepositoryException('Failed to search and filter posts: $e');
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
      throw PostRepositoryException('Failed to close repository: $e');
    }
  }
}
