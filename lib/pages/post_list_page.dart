import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import '../services/image_store.dart';
import 'post_detail_page.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Post> _filteredPosts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // フィルタ状態
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _likedOnly;
  bool? _learnedOnly;
  bool? _hasCards;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('投稿の読み込みに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    try {
      final posts = await context.read<PostRepository>().searchAndFilterPosts(
            query: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
            startDate: _startDate,
            endDate: _endDate,
            likedOnly: _likedOnly,
            learnedOnly: _learnedOnly,
            hasCards: _hasCards,
            sortBy: _sortBy,
            limit: 1000,
          );

      setState(() {
        _filteredPosts = posts;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('フィルタの適用に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _startDate = null;
      _endDate = null;
      _likedOnly = null;
      _learnedOnly = null;
      _hasCards = null;
      _sortBy = 'newest';
    });
    _applyFilters();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投稿一覧'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
            tooltip: '更新',
          ),
        ],
      ),
      body: Column(
        children: [
          // 検索バー
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '投稿を検索...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // フィルタチップ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // 期間フィルタ
                _buildFilterChip(
                  label: _startDate != null && _endDate != null
                      ? '${_startDate!.month}/${_startDate!.day}-${_endDate!.month}/${_endDate!.day}'
                      : '期間',
                  isSelected: _startDate != null && _endDate != null,
                  onTap: _selectDateRange,
                ),
                const SizedBox(width: 8),

                // いいねフィルタ
                _buildFilterChip(
                  label: '❤️ いいね',
                  isSelected: _likedOnly == true,
                  onTap: () {
                    setState(() {
                      _likedOnly = _likedOnly == true ? null : true;
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),

                // 学んだフィルタ
                _buildFilterChip(
                  label: '📚 学んだ',
                  isSelected: _learnedOnly == true,
                  onTap: () {
                    setState(() {
                      _learnedOnly = _learnedOnly == true ? null : true;
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),

                // カード化済みフィルタ
                _buildFilterChip(
                  label: '🎴 カード化済み',
                  isSelected: _hasCards == true,
                  onTap: () {
                    setState(() {
                      _hasCards = _hasCards == true ? null : true;
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),

                // 並び替え
                _buildFilterChip(
                  label: _sortBy == 'newest' ? '新しい順' : '古い順',
                  isSelected: true,
                  onTap: () {
                    setState(() {
                      _sortBy = _sortBy == 'newest' ? 'oldest' : 'newest';
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),

                // リセットボタン
                if (_hasActiveFilters())
                  _buildFilterChip(
                    label: 'リセット',
                    isSelected: false,
                    onTap: _resetFilters,
                    backgroundColor: Colors.red[100],
                    textColor: Colors.red[800],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 結果表示
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPosts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredPosts.length,
                        cacheExtent: 1000, // パフォーマンス向上のためキャッシュ範囲を調整
                        itemBuilder: (context, index) {
                          final post = _filteredPosts[index];
                          return _buildPostTile(post);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: backgroundColor,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: textColor ??
            (isSelected
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : null),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _hasActiveFilters() ? '条件に一致する投稿がありません' : '投稿がありません',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          if (_hasActiveFilters()) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _resetFilters,
              child: const Text('条件をリセット'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostTile(Post post) {
    return PostTile(
      key: ValueKey(post.id), // パフォーマンス向上のためKeyを追加
      post: post,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostDetailPage(post: post),
          ),
        );
      },
    );
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _startDate != null ||
        _endDate != null ||
        _likedOnly != null ||
        _learnedOnly != null ||
        _hasCards != null;
  }
}

/// 最適化されたPostTileウィジェット
class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostTile({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildThumbnail(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(context),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThumbnail() {
    return SizedBox(
      width: 48,
      height: 48,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FutureBuilder<Uint8List?>(
          future: _getThumbnailBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholder(),
              );
            }
            return _buildPlaceholder();
          },
        ),
      ),
    );
  }

  Future<Uint8List?> _getThumbnailBytes() async {
    try {
      return await ImageStore.getThumbnailBytes(
        post.imagePath,
        maxWidth: 96,
        maxHeight: 96,
      );
    } catch (e) {
      return null;
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.image,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  Widget _buildTitle() {
    final displayText = post.normalizedText.length > 100
        ? '${post.normalizedText.substring(0, 100)}...'
        : post.normalizedText;

    return Text(
      displayText,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              post.createdAt.toString().split(' ')[0],
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 16),
            if (post.likeCount > 0) ...[
              Icon(
                Icons.favorite,
                size: 16,
                color: Colors.red[400],
              ),
              const SizedBox(width: 4),
              Text(
                '${post.likeCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
            ],
            if (post.learnedCount > 0) ...[
              Icon(
                Icons.school,
                size: 16,
                color: Colors.blue[400],
              ),
              const SizedBox(width: 4),
              Text(
                '${post.learnedCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
