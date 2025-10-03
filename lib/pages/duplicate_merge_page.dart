import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/srs_card.dart';
import '../repositories/srs_repository.dart';

class DuplicateMergePage extends StatefulWidget {
  final List<SrsCard> duplicateCards;

  const DuplicateMergePage({
    super.key,
    required this.duplicateCards,
  });

  @override
  State<DuplicateMergePage> createState() => _DuplicateMergePageState();
}

class _DuplicateMergePageState extends State<DuplicateMergePage> {
  String? _selectedBaseCardId;
  final Set<String> _selectedMergeIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // デフォルトで最初のカードをベースカードに選択
    if (widget.duplicateCards.isNotEmpty) {
      _selectedBaseCardId = widget.duplicateCards.first.id;
    }
  }

  // ベースカードのgetter（将来の拡張用）
  // SrsCard? get _baseCard {
  //   if (_selectedBaseCardId == null) return null;
  //   return widget.duplicateCards.firstWhere(
  //     (card) => card.id == _selectedBaseCardId,
  //     orElse: () => widget.duplicateCards.first,
  //   );
  // }

  List<SrsCard> get _mergeCandidates {
    if (_selectedBaseCardId == null) return [];
    return widget.duplicateCards
        .where(
          (card) => card.id != _selectedBaseCardId,
        )
        .toList();
  }

  bool get _canMerge {
    return _selectedBaseCardId != null && _selectedMergeIds.isNotEmpty;
  }

  Future<void> _performMerge() async {
    if (!_canMerge) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final mergedCard = await context.read<SrsRepository>().mergeCards(
            baseId: _selectedBaseCardId!,
            mergeIds: _selectedMergeIds.toList(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedMergeIds.length}枚のカードをマージしました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(mergedCard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('マージに失敗しました: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('重複カードマージ'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ヘッダー情報
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '重複カードが見つかりました',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.duplicateCards.length}枚のカードが同じ語句「${widget.duplicateCards.first.term}」で重複しています。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ベースカードを選択し、マージするカードをチェックしてください。',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                // ベースカード選択
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ベースカード（マージ先）',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'マージ後のカードとして残るカードを選択してください',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),

                        // ベースカード選択リスト
                        ...widget.duplicateCards
                            .map((card) => _buildBaseCardTile(card)),

                        const SizedBox(height: 24),

                        // マージ候補カード
                        Text(
                          'マージ候補カード',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ベースカードに統合するカードを選択してください',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),

                        // マージ候補リスト
                        ..._mergeCandidates
                            .map((card) => _buildMergeCandidateTile(card)),
                      ],
                    ),
                  ),
                ),

                // マージボタン
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('キャンセル'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _canMerge && !_isLoading ? _performMerge : null,
                          child: Text('マージ (${_selectedMergeIds.length})'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBaseCardTile(SrsCard card) {
    final isSelected = _selectedBaseCardId == card.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<String>(
        title: Text(
          card.term,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.reading.isNotEmpty) Text('読み: ${card.reading}'),
            if (card.meaning.isNotEmpty) Text('意味: ${card.meaning}'),
            Text(
              '出典: ${card.sourceSnippet}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        value: card.id,
        groupValue: _selectedBaseCardId,
        onChanged: (value) {
          setState(() {
            _selectedBaseCardId = value;
            // ベースカードが変更されたら、マージ候補の選択をクリア
            _selectedMergeIds.clear();
          });
        },
        selected: isSelected,
      ),
    );
  }

  Widget _buildMergeCandidateTile(SrsCard card) {
    final isSelected = _selectedMergeIds.contains(card.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(
          card.term,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (card.reading.isNotEmpty) Text('読み: ${card.reading}'),
            if (card.meaning.isNotEmpty) Text('意味: ${card.meaning}'),
            Text(
              '出典: ${card.sourceSnippet}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedMergeIds.add(card.id);
            } else {
              _selectedMergeIds.remove(card.id);
            }
          });
        },
      ),
    );
  }
}
