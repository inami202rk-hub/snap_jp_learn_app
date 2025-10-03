import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/srs_card.dart';
import '../repositories/srs_repository.dart';
import '../services/srs_card_creation_service.dart';
import '../services/dictionary_service.dart';
import '../services/entitlement_service.dart';
import 'card_edit_page.dart';
import 'duplicate_merge_page.dart';
import 'paywall_page.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  List<SrsCard> _existingCards = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingCards();
  }

  Future<void> _loadExistingCards() async {
    try {
      final cards =
          await context.read<SrsRepository>().listByPost(widget.post.id);
      setState(() {
        _existingCards = cards;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('カード読み込みエラー: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createCardsFromPost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pro状態をチェック
      final isPro = await EntitlementService.isPro();
      if (!isPro) {
        // 現在のカード数をチェック
        final srsRepository = context.read<SrsRepository>();
        final allCards = await srsRepository.getAllCards();
        const maxFreeCards = 10; // 無料版の上限

        if (allCards.length >= maxFreeCards) {
          if (mounted) {
            await _showUpgradeDialog();
          }
          return;
        }
      }

      final dictionaryService = context.read<DictionaryService>();
      final srsRepository = context.read<SrsRepository>();
      final cardCreationService = SrsCardCreationService(
        dictionaryService: dictionaryService,
      );

      // 語彙候補を抽出して辞書検索
      final candidates =
          await cardCreationService.extractCandidatesWithDictionary(
        widget.post.normalizedText,
      );

      if (candidates.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('カード作成候補が見つかりませんでした'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // 既存カードとの重複チェック
      final duplicateTerms = <String>[];
      final newCandidates = <VocabCandidateWithDictionary>[];

      for (final candidate in candidates) {
        final existingCards =
            await srsRepository.searchByTerm(candidate.candidate.term);
        if (existingCards.isNotEmpty) {
          duplicateTerms.add(candidate.candidate.term);
        } else {
          newCandidates.add(candidate);
        }
      }

      // 重複がある場合は確認ダイアログを表示
      if (duplicateTerms.isNotEmpty) {
        final shouldUpdate =
            await _showDuplicateConfirmationDialog(duplicateTerms);
        if (shouldUpdate == null) return; // キャンセル

        if (shouldUpdate) {
          // 既存カードを更新
          await _updateExistingCards(duplicateTerms);
        }
      }

      // 新規カードを作成
      if (newCandidates.isNotEmpty) {
        await _createNewCards(newCandidates);
      }

      // カード一覧を更新
      await _loadExistingCards();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newCandidates.length}枚のカードを作成しました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('カード作成エラー: $e'),
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

  Future<bool?> _showDuplicateConfirmationDialog(List<String> duplicateTerms) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重複カードが見つかりました'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('以下の語句のカードが既に存在します：'),
            const SizedBox(height: 8),
            ...duplicateTerms.map((term) => Text('• $term')),
            const SizedBox(height: 16),
            const Text('既存カードを更新しますか？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('スキップ'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateExistingCards(List<String> duplicateTerms) async {
    final srsRepository = context.read<SrsRepository>();

    for (final term in duplicateTerms) {
      final existingCards = await srsRepository.searchByTerm(term);
      if (existingCards.isNotEmpty) {
        // 最初のカードを編集
        final cardToEdit = existingCards.first;
        final updatedCard = await Navigator.of(context).push<SrsCard>(
          MaterialPageRoute(
            builder: (context) => CardEditPage(
              card: cardToEdit,
              isNewCard: false,
            ),
          ),
        );

        if (updatedCard != null) {
          await srsRepository.upsertCard(updatedCard);
        }
      }
    }
  }

  Future<void> _createNewCards(
      List<VocabCandidateWithDictionary> candidates) async {
    final srsRepository = context.read<SrsRepository>();

    for (final candidate in candidates) {
      final card = SrsCard(
        id: '', // UUIDはupsertCardで生成
        term: candidate.candidate.term,
        reading: candidate.dictionaryEntry?.reading ?? '',
        meaning: candidate.dictionaryEntry?.meanings.join('; ') ?? '',
        sourcePostId: widget.post.id,
        sourceSnippet: candidate.candidate.snippet,
        createdAt: DateTime.now(),
        interval: 0,
        easeFactor: 2.5,
        repetition: 0,
        due: DateTime.now(),
      );

      await srsRepository.upsertCard(card);
    }
  }

  Future<void> _checkDuplicates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final duplicates = await context.read<SrsRepository>().findDuplicates();

      if (duplicates.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('重複カードは見つかりませんでした'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // 重複をグループ化
        final Map<String, List<SrsCard>> groupedDuplicates = {};
        for (final card in duplicates) {
          final normalizedTerm = card.term.toLowerCase().trim();
          groupedDuplicates.putIfAbsent(normalizedTerm, () => []).add(card);
        }

        // 各グループでマージページを表示
        for (final group in groupedDuplicates.values) {
          if (group.length > 1) {
            final result = await Navigator.of(context).push<SrsCard>(
              MaterialPageRoute(
                builder: (context) => DuplicateMergePage(
                  duplicateCards: group,
                ),
              ),
            );

            if (result != null) {
              // マージが完了したらカード一覧を更新
              await _loadExistingCards();
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('重複チェックエラー: $e'),
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
        title: const Text('投稿詳細'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadExistingCards,
            tooltip: 'カード一覧を更新',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 投稿情報
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '投稿内容',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(widget.post.normalizedText),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '作成日: ${widget.post.createdAt.toString().split(' ')[0]}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // アクションボタン
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _createCardsFromPost,
                          icon: const Icon(Icons.add),
                          label: const Text('カード作成'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _checkDuplicates,
                          icon: const Icon(Icons.merge),
                          label: const Text('重複チェック'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 既存カード一覧
                  Text(
                    '既存カード (${_existingCards.length}枚)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  if (_existingCards.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text('この投稿から作成されたカードはありません'),
                        ),
                      ),
                    )
                  else
                    ..._existingCards.map((card) => _buildCardTile(card)),
                ],
              ),
            ),
    );
  }

  Widget _buildCardTile(SrsCard card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
            Text(
              '次回レビュー: ${card.due.toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
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
                  await _loadExistingCards();
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
                  await _loadExistingCards();
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

  /// Pro機能へのアップグレードダイアログを表示
  Future<void> _showUpgradeDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 8),
            Text('Pro機能が必要です'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('カード作成数の上限に達しました。'),
            SizedBox(height: 16),
            Text(
              'Pro機能で以下の特典をご利用いただけます：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• 📚 カード作成数無制限'),
            Text('• 🔄 自動復習スケジュール'),
            Text('• 📊 詳細な学習統計'),
            Text('• ☁️ データバックアップ'),
            Text('• 🚀 将来のAI機能'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PaywallPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Pro機能を購入'),
          ),
        ],
      ),
    );
  }
}
