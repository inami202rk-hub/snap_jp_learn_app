import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:snap_jp_learn_app/theme/app_theme.dart';

void main() {
  group('StatsCard Golden Tests', () {
    testGoldens('StatCard looks correct in light theme', (tester) async {
      await tester.pumpWidgetBuilder(
        _buildStatCard(
          '今日のレビュー',
          '12回',
          Icons.check_circle,
          Colors.green,
        ),
        wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
        surfaceSize: const Size(300, 150),
      );

      await screenMatchesGolden(tester, 'stats_card_today_reviews');
    });

    testGoldens('StatCard with total cards', (tester) async {
      await tester.pumpWidgetBuilder(
        _buildStatCard(
          '累計カード',
          '156枚',
          Icons.style,
          Colors.blue,
        ),
        wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
        surfaceSize: const Size(300, 150),
      );

      await screenMatchesGolden(tester, 'stats_card_total_cards');
    });

    testGoldens('StatCard with learning streak', (tester) async {
      await tester.pumpWidgetBuilder(
        _buildStatCard(
          '学習ストリーク',
          '7日',
          Icons.local_fire_department,
          Colors.orange,
        ),
        wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
        surfaceSize: const Size(300, 150),
      );

      await screenMatchesGolden(tester, 'stats_card_learning_streak');
    });

    testGoldens('StatCard in dark theme', (tester) async {
      await tester.pumpWidgetBuilder(
        _buildStatCard(
          '今日のレビュー',
          '12回',
          Icons.check_circle,
          Colors.green,
        ),
        wrapper: materialAppWrapper(theme: AppTheme.darkTheme),
        surfaceSize: const Size(300, 150),
      );

      await screenMatchesGolden(tester, 'stats_card_dark_theme');
    });
  });
}

Widget _buildStatCard(
  String title,
  String value,
  IconData icon,
  Color color,
) {
  return Builder(
    builder: (context) => Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    ),
  );
}
