import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/settings/services/settings_service.dart';
import '../widgets/help_info_icon.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                                  style: Theme.of(context).textTheme.bodySmall
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
}
