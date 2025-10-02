import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/settings/services/settings_service.dart';
import '../widgets/srs_preview_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Icon(
                  Icons.home,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'ホーム画面',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                const Text(
                  'スナップ日記と日本語学習のメイン画面',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                if (settingsService.srsPreviewEnabled) ...[
                  const SrsPreviewCard(),
                  const SizedBox(height: 16),
                ],
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.camera_alt, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              '今日のスナップ',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('写真を撮って日本語学習を始めましょう！'),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: カメラ機能の実装
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('カメラ機能は今後実装予定です')),
                            );
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('写真を撮る'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
