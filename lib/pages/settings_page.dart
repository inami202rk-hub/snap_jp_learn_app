import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../features/settings/services/settings_service.dart';
import '../services/backup_service.dart';
import '../services/purchase_service.dart';
import '../services/entitlement_service.dart';
import '../repositories/post_repository.dart';
import '../repositories/srs_repository.dart';
import '../widgets/help_info_icon.dart';
import 'paywall_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isBackupLoading = false;
  bool _isRestoreLoading = false;
  bool _isProRestoreLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 学習設定セクション
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '学習設定',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SRS プレビュー表示',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'ホーム画面と統計画面にSRSプレビューカードを表示します',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          HelpInfoIcon(
                            title: 'SRS プレビューについて',
                            content:
                                'SRS（間隔反復学習）プレビューカードは、次に復習する予定の単語や漢字を表示します。学習の進捗を確認するのに役立ちます。',
                          ),
                          Switch(
                            value: settingsService.srsPreviewEnabled,
                            onChanged: (value) {
                              settingsService.setSrsPreviewEnabled(value);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // バックアップと復元セクション
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'バックアップと復元',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          HelpInfoIcon(
                            title: 'バックアップについて',
                            content:
                                '投稿データとSRSカード、学習履歴をJSONファイルとして保存・復元できます。データの移行やバックアップにご利用ください。',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // エクスポートボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isBackupLoading ? null : _exportBackup,
                          icon: _isBackupLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.download),
                          label: Text(_isBackupLoading
                              ? 'エクスポート中...'
                              : 'バックアップをエクスポート'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // インポートボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isRestoreLoading ? null : _importBackup,
                          icon: _isRestoreLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload),
                          label: Text(
                              _isRestoreLoading ? 'インポート中...' : 'バックアップをインポート'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Pro機能セクション
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Pro機能',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          HelpInfoIcon(
                            title: 'Pro機能について',
                            content:
                                'Pro機能では、カード作成数無制限、詳細な学習統計、データバックアップなどの機能をご利用いただけます。',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Pro状態表示
                      FutureBuilder<bool>(
                        future: EntitlementService.isPro(),
                        builder: (context, snapshot) {
                          final isPro = snapshot.data ?? false;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isPro ? Colors.green[50] : Colors.orange[50],
                              border: Border.all(
                                color: isPro
                                    ? Colors.green[200]!
                                    : Colors.orange[200]!,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isPro
                                      ? Icons.check_circle
                                      : Icons.info_outline,
                                  color: isPro
                                      ? Colors.green[600]
                                      : Colors.orange[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    isPro ? 'Pro機能が有効です' : 'Pro機能が無効です',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isPro
                                          ? Colors.green[600]
                                          : Colors.orange[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Pro購入ボタン
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToPaywall(),
                          icon: const Icon(Icons.star),
                          label: const Text('Pro機能を購入'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Pro復元ボタン
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isProRestoreLoading
                              ? null
                              : _restoreProPurchases,
                          icon: _isProRestoreLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.restore),
                          label: Text(
                              _isProRestoreLoading ? '復元中...' : 'Pro購入を復元'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // アプリ情報セクション
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'アプリ情報',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('バージョン'),
                        subtitle: Text('1.0.0'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const ListTile(
                        leading: Icon(Icons.description),
                        title: Text('説明'),
                        subtitle: Text('スナップ日記と日本語学習を組み合わせたアプリ'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// バックアップをエクスポート
  Future<void> _exportBackup() async {
    setState(() {
      _isBackupLoading = true;
    });

    try {
      final postRepository = context.read<PostRepository>();
      final srsRepository = context.read<SrsRepository>();
      final backupService = BackupService(
        postRepository: postRepository,
        srsRepository: srsRepository,
      );

      final result = await backupService.exportBackup();

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'バックアップが作成されました\n${result.fileName}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message ?? 'バックアップの作成に失敗しました',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBackupLoading = false;
        });
      }
    }
  }

  /// バックアップをインポート
  Future<void> _importBackup() async {
    try {
      // ファイル選択
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // ユーザーがキャンセル
      }

      final file = result.files.first;
      if (file.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ファイルのパスを取得できませんでした'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 確認ダイアログを表示
      final shouldProceed = await _showRestoreConfirmationDialog(file.name);
      if (!shouldProceed) {
        return;
      }

      setState(() {
        _isRestoreLoading = true;
      });

      final postRepository = context.read<PostRepository>();
      final srsRepository = context.read<SrsRepository>();
      final backupService = BackupService(
        postRepository: postRepository,
        srsRepository: srsRepository,
      );

      final importResult = await backupService.importBackup(file.path!);

      if (mounted) {
        if (importResult.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'バックアップが復元されました\n投稿: ${importResult.metadata?.postCount}件, カード: ${importResult.metadata?.cardCount}件',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                importResult.message ?? 'バックアップの復元に失敗しました',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoreLoading = false;
        });
      }
    }
  }

  /// 復元確認ダイアログを表示
  Future<bool> _showRestoreConfirmationDialog(String fileName) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('バックアップを復元しますか？'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ファイル: $fileName'),
                const SizedBox(height: 16),
                const Text(
                  '⚠️ 注意事項',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• 現在のデータが消える可能性があります\n'
                  '• 復元後は現在のデータに戻すことはできません\n'
                  '• 復元を続行しますか？',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('復元する'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// PaywallPageに遷移
  Future<void> _navigateToPaywall() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const PaywallPage()),
    );

    if (result == true && mounted) {
      // Pro状態が変更された場合、画面を更新
      setState(() {});
    }
  }

  /// Pro購入を復元
  Future<void> _restoreProPurchases() async {
    setState(() {
      _isProRestoreLoading = true;
    });

    try {
      final purchaseService = PurchaseService();
      await purchaseService.initialize();
      await purchaseService.restore();

      // 復元結果を監視
      purchaseService.purchaseStream.listen((result) {
        if (mounted) {
          if (result.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Pro購入が復元されました！'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {}); // 画面を更新
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.errorMessage ?? '復元に失敗しました'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProRestoreLoading = false;
        });
      }
    }
  }
}
