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
import '../l10n/strings_en.dart';
import '../models/purchase_results.dart';
import '../services/diagnostics_service.dart';
import '../config/feature_flags.dart';
import '../sync/sync_service.dart';
import '../services/sync_api_service.dart';
import '../services/sync_engine.dart';
import 'package:hive/hive.dart';
import '../models/post.dart';
import 'paywall_page.dart';
import 'feedback_page.dart';
import 'faq_page.dart';
import 'permissions_usage_page.dart';
import 'legal_document_page.dart';
import 'pre_submission_check_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isBackupLoading = false;
  bool _isRestoreLoading = false;
  bool _isProRestoreLoading = false;
  bool _isSyncLoading = false;
  bool _isServerTestLoading = false;

  // 同期サービス（開発フラグで表示）
  SyncService? _syncService;

  // API接続テストサービス
  final SyncApiService _syncApiService = SyncApiService();

  // 同期エンジン（実際の同期処理用）
  SyncEngine? _syncEngine;

  @override
  void initState() {
    super.initState();
    _initializeSyncService();
  }

  /// 同期サービスを初期化
  void _initializeSyncService() {
    if (FeatureFlags.syncEnabled) {
      // TODO: 実際の実装では、DIコンテナから取得
      // ここでは簡易的に初期化
      // final mockApi = MockSyncApi();
      // _syncService = SyncService(...);
    }
  }

  /// 同期エンジンを初期化
  Future<void> _initializeSyncEngine() async {
    try {
      // HiveのPostBoxを取得
      final postBox = Hive.box<Post>('posts');

      // PostRepositoryのインスタンスを作成（簡易実装）
      // TODO: 実際の実装では、DIコンテナから取得
      // ここでは直接HiveのBoxを使用して簡易実装

      _syncEngine = SyncEngine(
        syncApiService: _syncApiService,
        postBox: postBox,
      );

      print('[SettingsPage] SyncEngine initialized');
    } catch (e) {
      print('[SettingsPage] Failed to initialize SyncEngine: $e');
    }
  }

  /// サーバー接続テストを実行
  Future<void> _testServerConnection() async {
    setState(() {
      _isServerTestLoading = true;
    });

    try {
      final isConnected = await _syncApiService.pingServer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isConnected ? '✅ サーバー接続成功' : '❌ サーバー接続エラー',
            ),
            backgroundColor: isConnected ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 接続テスト中にエラーが発生しました: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isServerTestLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _syncApiService.dispose();
    super.dispose();
  }

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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPro ? 'PRO ACTIVE' : 'FREE',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: isPro
                                              ? Colors.green[600]
                                              : Colors.orange[600],
                                        ),
                                      ),
                                      Text(
                                        isPro
                                            ? 'Premium features are available'
                                            : 'Upgrade for unlimited features',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isPro
                                              ? Colors.green[600]
                                              : Colors.orange[600],
                                        ),
                                      ),
                                    ],
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
                          label: Text(AppStrings.upgradeNow),
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
                          label: Text(_isProRestoreLoading
                              ? 'Restoring...'
                              : AppStrings.restorePurchases),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // FAQ・利用規約リンク
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showFAQ(),
                              icon: const Icon(Icons.help_outline, size: 18),
                              label: const Text('FAQ'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showTermsAndPrivacy(),
                              icon: const Icon(Icons.description_outlined,
                                  size: 18),
                              label: const Text('Terms & Privacy'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 権限・プライバシーセクション
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
                              '権限・プライバシー',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          HelpInfoIcon(
                            title: '権限・プライバシーについて',
                            content: 'アプリが使用する権限の詳細と、プライバシーに関する情報を確認できます。',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 権限の使いみち
                      ListTile(
                        leading: const Icon(Icons.security),
                        title: const Text('権限の使いみち'),
                        subtitle: const Text('カメラ・写真ライブラリの使用目的'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PermissionsUsagePage(),
                            ),
                          );
                        },
                      ),

                      const Divider(),

                      // プライバシーポリシー
                      ListTile(
                        leading: const Icon(Icons.privacy_tip),
                        title: const Text('プライバシーポリシー'),
                        subtitle: const Text('データの取り扱いについて'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LegalDocumentPage(
                                title: 'プライバシーポリシー',
                                assetPath: 'assets/legal/privacy-ja.md',
                              ),
                            ),
                          );
                        },
                      ),

                      const Divider(),

                      // 利用規約
                      ListTile(
                        leading: const Icon(Icons.description),
                        title: const Text('利用規約'),
                        subtitle: const Text('アプリの利用条件'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LegalDocumentPage(
                                title: '利用規約',
                                assetPath: 'assets/legal/terms-ja.md',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ヘルプ & フィードバックセクション
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
                              'Help & Feedback',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          HelpInfoIcon(
                            title: 'Help & Feedback',
                            content:
                                'Get help with the app, report issues, or suggest improvements.',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // フィードバックを送る
                      ListTile(
                        leading: const Icon(Icons.feedback),
                        title: const Text('Send Feedback'),
                        subtitle: const Text('Report bugs or suggest features'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const FeedbackPage(),
                            ),
                          );
                        },
                      ),

                      const Divider(),

                      // ログをエクスポート
                      ListTile(
                        leading: const Icon(Icons.analytics_outlined),
                        title: const Text('Export Logs'),
                        subtitle: const Text('Generate diagnostic information'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _exportDiagnostics,
                      ),

                      const Divider(),

                      // よくある質問
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: const Text('FAQ'),
                        subtitle: const Text('Frequently asked questions'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const FAQPage(),
                            ),
                          );
                        },
                      ),

                      const Divider(),

                      // FAQ検索
                      ListTile(
                        leading: const Icon(Icons.search),
                        title: const Text('Search FAQ'),
                        subtitle: const Text('Find answers quickly'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const FAQSearchPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 同期セクション（開発フラグで表示）
              if (FeatureFlags.debugMode) ...[
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
                                'クラウド同期（開発版）',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            HelpInfoIcon(
                              title: 'クラウド同期について',
                              content:
                                  '開発中の機能です。モックサーバーとの同期をテストできます。本番環境では使用されません。',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 同期ステータス表示
                        _buildSyncStatusWidget(),

                        const SizedBox(height: 16),

                        // 今すぐ同期ボタン
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSyncLoading ? null : _performSync,
                            icon: _isSyncLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.sync),
                            label: Text(_isSyncLoading ? '同期中...' : '今すぐ同期'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 同期設定
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '同期ポリシー',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Last Write Wins (既定)',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(
                                  FeatureFlags.syncMockMode ? 'Mock' : 'HTTP'),
                              backgroundColor: FeatureFlags.syncMockMode
                                  ? Colors.orange[100]
                                  : Colors.green[100],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 開発者向けセクション（開発ビルドのみ表示）
              if (const bool.fromEnvironment('dart.vm.product') == false) ...[
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
                                '開発者向け',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            HelpInfoIcon(
                              title: '開発者向け機能について',
                              content: '開発ビルドでのみ表示される機能です。本番ビルドでは表示されません。',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 提出前チェック
                        ListTile(
                          leading: const Icon(Icons.checklist),
                          title: const Text('提出前チェック'),
                          subtitle: const Text('ストア提出前の確認項目'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PreSubmissionCheckPage(),
                              ),
                            );
                          },
                        ),

                        // サーバー接続テスト
                        ListTile(
                          leading: const Icon(Icons.wifi),
                          title: const Text('サーバー接続テスト'),
                          subtitle: const Text('API接続の確認'),
                          trailing: _isServerTestLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_arrow),
                          onTap: _isServerTestLoading
                              ? null
                              : _testServerConnection,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
          switch (result) {
            case PurchaseSuccess():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pro purchase restored successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {}); // 画面を更新
            case PurchaseCancelled():
            case PurchaseFailed():
            case PurchaseNetworkError():
            case PurchaseAlreadyOwned():
            case PurchasePending():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restore failed. Please try again.'),
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

  /// FAQを表示
  void _showFAQ() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFAQItem(
                'When does billing stop?',
                'Monthly subscriptions automatically renew unless cancelled. Lifetime purchases are one-time payments with no recurring charges.',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'Can I use on multiple devices?',
                'Yes! Your Pro features are tied to your Apple ID or Google Account. You can restore purchases on any device using the same account.',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'How do I cancel my subscription?',
                'On iOS: Settings > Apple ID > Subscriptions > Snap JP Learn\nOn Android: Google Play Store > Subscriptions > Snap JP Learn',
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'What happens to my data?',
                'All your learning data stays on your device. We don\'t collect or store any personal information.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// FAQアイテムを構築
  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 利用規約とプライバシーポリシーを表示
  void _showTermsAndPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Legal Documents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Terms of Service'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LegalDocumentPage(
                      title: 'Terms of Service',
                      assetPath: 'assets/legal/terms-ja.md',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LegalDocumentPage(
                      title: 'Privacy Policy',
                      assetPath: 'assets/legal/privacy-ja.md',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// 診断情報をエクスポート
  Future<void> _exportDiagnostics() async {
    try {
      // ローディング表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating diagnostics...'),
            ],
          ),
        ),
      );

      final diagnosticsService = DiagnosticsService();
      final filePath = await diagnosticsService.saveDiagnosticsToFile();

      if (mounted) {
        Navigator.of(context).pop(); // ローディングダイアログを閉じる

        if (filePath != null) {
          // 成功ダイアログ
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Diagnostics Generated'),
              content: Text(
                  'Diagnostic information has been saved to:\n\n$filePath'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // ファイル共有の実装は省略（share_plusを使用）
                  },
                  child: const Text('Share'),
                ),
              ],
            ),
          );
        } else {
          // エラーダイアログ
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'Failed to generate diagnostic information. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // ローディングダイアログを閉じる
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 同期ステータスウィジェットを構築
  Widget _buildSyncStatusWidget() {
    if (_syncService == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '同期機能は無効です',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    // TODO: 実際の同期ステータスを取得して表示
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_sync, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'モックサーバーと接続中',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '未同期: 0件 | 最終同期: 未実行',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 同期を実行
  Future<void> _performSync() async {
    // SyncEngineを初期化（まだ初期化されていない場合）
    if (_syncEngine == null) {
      await _initializeSyncEngine();
    }

    if (_syncEngine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('同期エンジンの初期化に失敗しました'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSyncLoading = true;
    });

    try {
      // ネットワーク接続を確認
      final isConnected = await _syncEngine!.isConnected();
      if (!isConnected) {
        throw Exception('ネットワークに接続されていません');
      }

      // 同期処理を実行
      final result = await _syncEngine!.syncAll();

      if (mounted) {
        String message;
        Color backgroundColor;

        switch (result) {
          case SyncResult.success:
            message = '✅ 同期が完了しました';
            backgroundColor = Colors.green;
            break;
          case SyncResult.partial:
            message = '⚠️ 部分的な同期が完了しました';
            backgroundColor = Colors.orange;
            break;
          case SyncResult.failed:
            message = '❌ 同期に失敗しました';
            backgroundColor = Colors.red;
            break;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 同期に失敗しました: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncLoading = false;
        });
      }
    }
  }
}
