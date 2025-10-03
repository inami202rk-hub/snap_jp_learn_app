import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/srs_card.dart';
import '../repositories/srs_repository.dart';

class CardEditPage extends StatefulWidget {
  final SrsCard card;
  final bool isNewCard;

  const CardEditPage({
    super.key,
    required this.card,
    this.isNewCard = false,
  });

  @override
  State<CardEditPage> createState() => _CardEditPageState();
}

class _CardEditPageState extends State<CardEditPage> {
  late TextEditingController _termController;
  late TextEditingController _readingController;
  late TextEditingController _meaningsController;
  late TextEditingController _sourceSnippetController;

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _termController = TextEditingController(text: widget.card.term);
    _readingController = TextEditingController(text: widget.card.reading);
    _meaningsController = TextEditingController(text: widget.card.meaning);
    _sourceSnippetController =
        TextEditingController(text: widget.card.sourceSnippet);

    // 変更検知
    _termController.addListener(_onFieldChanged);
    _readingController.addListener(_onFieldChanged);
    _meaningsController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _termController.dispose();
    _readingController.dispose();
    _meaningsController.dispose();
    _sourceSnippetController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  bool _validateForm() {
    final term = _termController.text.trim();
    if (term.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('語句は必須です'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (term.length > 32) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('語句は32文字以内で入力してください'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveCard() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedCard = widget.card.copyWith(
        term: _termController.text.trim(),
        reading: _readingController.text.trim(),
        meaning: _meaningsController.text.trim(),
      );

      await context.read<SrsRepository>().upsertCard(updatedCard);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isNewCard ? 'カードを作成しました' : 'カードを更新しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(updatedCard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
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

  Future<void> _deleteCard() async {
    if (widget.isNewCard) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カードを削除'),
        content: const Text('このカードを削除しますか？この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await context.read<SrsRepository>().deleteCard(widget.card.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('カードを削除しました'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop('deleted');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('削除に失敗しました: $e'),
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
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('変更を破棄'),
        content: const Text('変更が保存されていません。変更を破棄しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('破棄'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isNewCard ? 'カード作成' : 'カード編集'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            if (!widget.isNewCard)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _isLoading ? null : _deleteCard,
                tooltip: 'カードを削除',
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
                    // 語句フィールド
                    _buildTextField(
                      controller: _termController,
                      label: '語句 *',
                      hint: '例: 学校',
                      maxLength: 32,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    // 読みフィールド
                    _buildTextField(
                      controller: _readingController,
                      label: '読み',
                      hint: '例: がっこう',
                    ),
                    const SizedBox(height: 16),

                    // 意味フィールド
                    _buildTextField(
                      controller: _meaningsController,
                      label: '意味',
                      hint: '例: 教育機関; 学びの場',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // 出典スニペット（閲覧のみ）
                    _buildTextField(
                      controller: _sourceSnippetController,
                      label: '出典スニペット',
                      enabled: false,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),

                    // 保存・キャンセルボタン
                    Row(
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
                            onPressed: _isLoading ? null : _saveCard,
                            child: Text(widget.isNewCard ? '作成' : '保存'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int? maxLength,
    int maxLines = 1,
    bool isRequired = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            counterText: maxLength != null ? null : '',
          ),
        ),
      ],
    );
  }
}
