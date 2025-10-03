import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 提出前チェックページ（開発ビルドのみ表示）
class PreSubmissionCheckPage extends StatefulWidget {
  const PreSubmissionCheckPage({super.key});

  @override
  State<PreSubmissionCheckPage> createState() => _PreSubmissionCheckPageState();
}

class _PreSubmissionCheckPageState extends State<PreSubmissionCheckPage> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = packageInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提出前チェック'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildAppInfoSection(context),
                  const SizedBox(height: 24),
                  _buildPermissionsSection(context),
                  const SizedBox(height: 24),
                  _buildLegalDocumentsSection(context),
                  const SizedBox(height: 24),
                  _buildStorePreparationSection(context),
                  const SizedBox(height: 24),
                  _buildChecklistSection(context),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: Colors.blue[600]),
                const SizedBox(width: 12),
                Text(
                  'ストア提出前チェック',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'このページは開発ビルドでのみ表示されます。ストア提出前に必要な項目をチェックしてください。',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📱 アプリ情報',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_packageInfo != null) ...[
              _buildInfoRow('アプリ名', _packageInfo!.appName),
              _buildInfoRow('パッケージ名', _packageInfo!.packageName),
              _buildInfoRow('バージョン', _packageInfo!.version),
              _buildInfoRow('ビルド番号', _packageInfo!.buildNumber),
            ] else
              const Text('アプリ情報の取得に失敗しました'),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔐 権限設定',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildCheckItem(
              'iOS Info.plist の権限文言が設定されている',
              'NSCameraUsageDescription: OCRで文字抽出を行うためにカメラを使用します。',
              true,
            ),
            _buildCheckItem(
              'iOS Info.plist の権限文言が設定されている',
              'NSPhotoLibraryUsageDescription: OCRの対象画像を選ぶために写真ライブラリへアクセスします。',
              true,
            ),
            _buildCheckItem(
              'Android AndroidManifest.xml の権限コメントが設定されている',
              'カメラ、ストレージ権限の用途説明コメントが追加済み',
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalDocumentsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📄 法務ドキュメント',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildCheckItem(
              'プライバシーポリシーが作成されている',
              'assets/legal/privacy-ja.md が存在し、アプリ内で表示可能',
              true,
            ),
            _buildCheckItem(
              '利用規約が作成されている',
              'assets/legal/terms-ja.md が存在し、アプリ内で表示可能',
              true,
            ),
            _buildCheckItem(
              '設定画面に法務ドキュメントへの導線がある',
              '権限・プライバシーセクションからアクセス可能',
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorePreparationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏪 ストア提出準備',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildCheckItem(
              'iOS審査用メモが作成されている',
              'store/ios_review_notes.md が存在',
              true,
            ),
            _buildCheckItem(
              'Google Play データセーフティ回答が作成されている',
              'store/play_data_safety.yml が存在',
              true,
            ),
            _buildCheckItem(
              'アプリ内で権限の使いみちが説明されている',
              '権限の使いみちページが実装済み',
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistSection(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[600]),
                const SizedBox(width: 12),
                Text(
                  '⚠️ 提出前チェックリスト',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '以下の項目を確認してください：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('□ アプリアイコンが設定されている'),
            const Text('□ スクリーンショットが撮影されている'),
            const Text('□ アプリ説明文が作成されている'),
            const Text('□ キーワードが設定されている'),
            const Text('□ 年齢制限が適切に設定されている'),
            const Text('□ カテゴリが適切に選択されている'),
            const Text('□ 価格が設定されている（有料の場合）'),
            const Text('□ プライバシーポリシーURLが設定されている'),
            const Text('□ サポートURLが設定されている'),
            const Text('□ 開発者情報が設定されている'),
            const SizedBox(height: 16),
            const Text(
              '注意：このチェックリストは基本的な項目のみです。各ストアの要件を必ず確認してください。',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String title, String description, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
