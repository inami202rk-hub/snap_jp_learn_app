import 'package:image_picker/image_picker.dart';
import '../models/post.dart';

/// 投稿データの永続化を管理するリポジトリの抽象クラス
abstract class PostRepository {
  /// 新しい投稿を作成
  ///
  /// [image] OCR対象の画像ファイル
  /// [raw] OCRで取得した生のテキスト
  /// [normalized] 整形されたテキスト
  ///
  /// Returns: 作成された投稿
  ///
  /// Throws: [PostRepositoryException] 作成に失敗した場合
  Future<Post> createPost({
    required XFile image,
    required String raw,
    required String normalized,
  });

  /// 投稿一覧を取得
  ///
  /// [limit] 取得件数の上限（デフォルト: 100）
  /// [offset] 取得開始位置（デフォルト: 0）
  ///
  /// Returns: 投稿のリスト（作成日時の降順）
  Future<List<Post>> listPosts({int limit = 100, int offset = 0});

  /// 指定されたIDの投稿を取得
  ///
  /// [id] 投稿のID
  ///
  /// Returns: 投稿（存在しない場合はnull）
  Future<Post?> getPost(String id);

  /// いいねをトグル
  ///
  /// [id] 投稿のID
  ///
  /// Throws: [PostRepositoryException] 更新に失敗した場合
  Future<void> toggleLike(String id);

  /// 学んだフラグをトグル
  ///
  /// [id] 投稿のID
  ///
  /// Throws: [PostRepositoryException] 更新に失敗した場合
  Future<void> toggleLearned(String id);

  /// 投稿を削除
  ///
  /// [id] 投稿のID
  ///
  /// Throws: [PostRepositoryException] 削除に失敗した場合
  Future<void> deletePost(String id);

  /// 投稿の総数を取得
  ///
  /// Returns: 投稿の総数
  Future<int> getPostCount();

  /// いいねされた投稿の数を取得
  ///
  /// Returns: いいねされた投稿の数
  Future<int> getLikedPostCount();

  /// 学んだ投稿の数を取得
  ///
  /// Returns: 学んだ投稿の数
  Future<int> getLearnedPostCount();

  /// 投稿データをエクスポート（JSON形式）
  ///
  /// Returns: 全投稿のJSONデータ
  Future<List<Map<String, dynamic>>> exportPosts();

  /// 投稿データをインポート（JSON形式）
  ///
  /// [postsData] インポートする投稿データ
  ///
  /// Throws: [PostRepositoryException] インポートに失敗した場合
  Future<void> importPosts(List<Map<String, dynamic>> postsData);

  /// 投稿を検索
  ///
  /// [query] 検索クエリ（スペース区切りでAND検索）
  /// [limit] 取得件数の上限（デフォルト: 100）
  /// [offset] 取得開始位置（デフォルト: 0）
  ///
  /// Returns: 検索結果の投稿リスト
  Future<List<Post>> searchPosts({
    required String query,
    int limit = 100,
    int offset = 0,
  });

  /// フィルタ条件で投稿を取得
  ///
  /// [startDate] 開始日（nullの場合は制限なし）
  /// [endDate] 終了日（nullの場合は制限なし）
  /// [likedOnly] いいね済みのみ（nullの場合は制限なし）
  /// [learnedOnly] 学んだ済みのみ（nullの場合は制限なし）
  /// [hasCards] カード化済みのみ（nullの場合は制限なし）
  /// [sortBy] 並び替え順（'newest' or 'oldest'）
  /// [limit] 取得件数の上限（デフォルト: 100）
  /// [offset] 取得開始位置（デフォルト: 0）
  ///
  /// Returns: フィルタ結果の投稿リスト
  Future<List<Post>> filterPosts({
    DateTime? startDate,
    DateTime? endDate,
    bool? likedOnly,
    bool? learnedOnly,
    bool? hasCards,
    String sortBy = 'newest',
    int limit = 100,
    int offset = 0,
  });

  /// 検索とフィルタを組み合わせて投稿を取得
  ///
  /// [query] 検索クエリ（nullの場合は検索なし）
  /// [startDate] 開始日（nullの場合は制限なし）
  /// [endDate] 終了日（nullの場合は制限なし）
  /// [likedOnly] いいね済みのみ（nullの場合は制限なし）
  /// [learnedOnly] 学んだ済みのみ（nullの場合は制限なし）
  /// [hasCards] カード化済みのみ（nullの場合は制限なし）
  /// [sortBy] 並び替え順（'newest' or 'oldest'）
  /// [limit] 取得件数の上限（デフォルト: 100）
  /// [offset] 取得開始位置（デフォルト: 0）
  ///
  /// Returns: 検索・フィルタ結果の投稿リスト
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
  });

  /// リポジトリを閉じる（リソースのクリーンアップ）
  Future<void> close();
}

/// 投稿リポジトリ関連の例外
class PostRepositoryException implements Exception {
  final String message;

  const PostRepositoryException(this.message);

  @override
  String toString() => 'PostRepositoryException: $message';
}
