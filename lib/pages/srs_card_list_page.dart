import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/srs_card.dart';
import '../repositories/srs_repository.dart';
import 'card_edit_page.dart';

class SrsCardListPage extends StatefulWidget {
  const SrsCardListPage({super.key});

  @override
  State<SrsCardListPage> createState() => _SrsCardListPageState();
}

class _SrsCardListPageState extends State<SrsCardListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SrsCard> _filteredCards = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // フィルタ状態
  String? _status;
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    _loadCards();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('カードの読み込みに失敗しました: $e'),
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
      final cards = await context.read<SrsRepository>().searchAndFilterCards(
            query: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
            status: _status,
            startDate: _startDate,
            endDate: _endDate,
            sortBy: _sortBy,
            limit: 1000,
          );

      setState(() {
        _filteredCards = cards;
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
      _status = null;
      _startDate = null;
      _endDate = null;
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
        title: const Text('SRSカード一覧'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCards,
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
                hintText: 'カードを検索...',
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
                // 状態フィルタ
                _buildFilterChip(
                  label: '📅 Due',
                  isSelected: _status == 'due',
                  onTap: () {
                    setState(() {
                      _status = _status == 'due' ? null : 'due';
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),

                _buildFilterChip(
                  label: '⏰ Not Due',
                  isSelected: _status == 'not_due',
                  onTap: () {
                    setState(() {
                      _status = _status == 'not_due' ? null : 'not_due';
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),

                _buildFilterChip(
                  label: '🆕 新規',
                  isSelected: _status == 'new',
                  onTap: () {
                    setState(() {
                      _status = _status == 'new' ? null : 'new';
                    });
                    _applyFilters();
                  },
                ),
                const SizedBox(width: 8),

                // 期間フィルタ
                _buildFilterChip(
                  label: _startDate != null && _endDate != null
                      ? '${_startDate!.month}/${_startDate!.day}-${_endDate!.month}/${_endDate!.day}'
                      : '期間',
                  isSelected: _startDate != null && _endDate != null,
                  onTap: _selectDateRange,
                ),
                const SizedBox(width: 8),

                // 並び替え
                _buildFilterChip(
                  label: _getSortLabel(),
                  isSelected: true,
                  onTap: () {
                    setState(() {
                      _sortBy = _getNextSortOption();
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
                : _filteredCards.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredCards.length,
                        itemBuilder: (context, index) {
                          final card = _filteredCards[index];
                          return _buildCardTile(card);
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
            _hasActiveFilters() ? '条件に一致するカードがありません' : 'カードがありません',
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

  Widget _buildCardTile(SrsCard card) {
    final isDue = card.due.isBefore(DateTime.now());
    final isNew = card.repetition == 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(
          card.term,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.reading.isNotEmpty) Text('読み: ${card.reading}'),
            if (card.meaning.isNotEmpty) Text('意味: ${card.meaning}'),
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
                  '作成: ${card.createdAt.toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: isDue ? Colors.red[400] : Colors.green[400],
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${card.due.toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDue ? Colors.red[400] : Colors.green[400],
                      ),
                ),
                const SizedBox(width: 16),
                if (isNew)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                final updatedCard = await Navigator.of(context).push<SrsCard>(
                  MaterialPageRoute(
                    builder: (context) => CardEditPage(
                      card: card,
                      isNewCard: false,
                    ),
                  ),
                );
                if (updatedCard != null) {
                  await _loadCards();
                }
                break;
              case 'delete':
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('カードを削除'),
                    content: const Text('このカードを削除しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('キャンセル'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text('削除',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await context.read<SrsRepository>().deleteCard(card.id);
                  await _loadCards();
                }
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('編集'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('削除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _status != null ||
        _startDate != null ||
        _endDate != null;
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'newest':
        return '新しい順';
      case 'oldest':
        return '古い順';
      case 'due_date':
        return 'Due順';
      default:
        return '新しい順';
    }
  }

  String _getNextSortOption() {
    switch (_sortBy) {
      case 'newest':
        return 'oldest';
      case 'oldest':
        return 'due_date';
      case 'due_date':
        return 'newest';
      default:
        return 'newest';
    }
  }
}
