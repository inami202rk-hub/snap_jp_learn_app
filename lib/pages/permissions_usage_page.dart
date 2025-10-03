import 'package:flutter/material.dart';

/// 権限の使いみち説明ページ
class PermissionsUsagePage extends StatelessWidget {
  const PermissionsUsagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('権限の使いみち'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: '📷 カメラ',
              icon: Icons.camera_alt,
              description: 'OCRで文字抽出を行うためにカメラを使用します。',
              details: [
                '• 日本語の看板、メニュー、本などの写真を撮影',
                '• 撮影した画像からテキストを自動抽出',
                '• 撮影した画像は端末内にのみ保存',
                '• 外部サーバーへ送信することはありません',
                '• ユーザーが撮影ボタンを押した時のみアクセス',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '🖼️ 写真ライブラリ',
              icon: Icons.photo_library,
              description: 'OCRの対象画像を選ぶために写真ライブラリへアクセスします。',
              details: [
                '• 既存の写真からOCR対象を選択',
                '• 選択した画像からテキストを自動抽出',
                '• 選択した画像は端末内にのみ保存',
                '• 外部サーバーへ送信することはありません',
                '• ユーザーが写真選択ボタンを押した時のみアクセス',
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '💾 ストレージ',
              icon: Icons.storage,
              description: 'バックアップファイルの保存に使用します。',
              details: [
                '• ユーザーが明示的にエクスポートを選択した場合のみ使用',
                '• 学習データのバックアップファイルを作成',
                '• ファイルは端末内の指定フォルダに保存',
                '• 外部サーバーへ自動送信することはありません',
              ],
            ),
            const SizedBox(height: 32),
            _buildPermissionDeniedSection(context),
            const SizedBox(height: 24),
            _buildPrivacySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required List<String> details,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 16),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    detail,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedSection(BuildContext context) {
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
                  '権限を拒否した場合',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '権限を拒否した場合、以下の機能が制限されます：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• カメラでの写真撮影ができません'),
            const Text('• 写真ライブラリからの画像選択ができません'),
            const Text('• バックアップファイルの保存ができません'),
            const SizedBox(height: 16),
            const Text(
              '権限を再度許可するには：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('1. 端末の設定アプリを開く'),
            const Text('2. 「アプリ」または「アプリケーション」を選択'),
            const Text('3. 「Snap Jp Learn App」を選択'),
            const Text('4. 「権限」を選択'),
            const Text('5. 必要な権限を「許可」に変更'),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip, color: Colors.blue[600]),
                const SizedBox(width: 12),
                Text(
                  'プライバシーについて',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '本アプリは、ユーザーのプライバシーを最優先に考えています：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• 撮影・選択した画像は端末内にのみ保存'),
            const Text('• 学習データは端末内にのみ保存'),
            const Text('• 外部サーバーへデータを送信しません'),
            const Text('• 広告やトラッキングは行いません'),
            const Text('• 個人情報の収集は行いません'),
            const SizedBox(height: 16),
            const Text(
              '詳細については、設定画面の「プライバシーポリシー」をご確認ください。',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
