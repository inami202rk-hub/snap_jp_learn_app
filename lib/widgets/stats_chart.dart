import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/stats_dashboard_service.dart';

/// 統計チャートウィジェット
class StatsChart extends StatelessWidget {
  final DashboardStats stats;
  final ChartType chartType;
  final double height;

  const StatsChart({
    super.key,
    required this.stats,
    required this.chartType,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: _buildChart(),
    );
  }

  Widget _buildChart() {
    switch (chartType) {
      case ChartType.dailyActivity:
        return _buildDailyActivityChart();
      case ChartType.tagFrequency:
        return _buildTagFrequencyChart();
      case ChartType.cardProgress:
        return _buildCardProgressChart();
    }
  }

  /// 日別活動チャート（棒グラフ）
  Widget _buildDailyActivityChart() {
    if (stats.dailyActivities.isEmpty) {
      return _buildEmptyState('過去30日の活動データがありません');
    }

    final spots = stats.dailyActivities
        .asMap()
        .entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value.postsCount.toDouble(),
            ))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value % 5 == 0) {
                  final index = value.toInt();
                  if (index < stats.dailyActivities.length) {
                    final date = stats.dailyActivities[index].date;
                    return Text(
                      '${date.month}/${date.day}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.1),
            ),
          ),
        ],
        minX: 0,
        maxX: (stats.dailyActivities.length - 1).toDouble(),
        minY: 0,
        maxY: spots.isNotEmpty
            ? spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 1
            : 10,
      ),
    );
  }

  /// タグ頻度チャート（円グラフ）
  Widget _buildTagFrequencyChart() {
    if (stats.topTags.isEmpty) {
      return _buildEmptyState('タグデータがありません');
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    final sections = stats.topTags.asMap().entries.map((entry) {
      final index = entry.key;
      final tag = entry.value;
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: tag.count.toDouble(),
        title: '${tag.tag}\n${tag.count}',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 60,
        sectionsSpace: 2,
        startDegreeOffset: -90,
      ),
    );
  }

  /// カード進捗チャート（棒グラフ）
  Widget _buildCardProgressChart() {
    if (stats.cardProgress.isEmpty) {
      return _buildEmptyState('カード進捗データがありません');
    }

    final bars = stats.cardProgress.asMap().entries.map((entry) {
      final index = entry.key;
      final progress = entry.value;
      final color = Color(int.parse(progress.color.replaceFirst('#', '0xFF')));

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: progress.count.toDouble(),
            color: color,
            width: 40,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: stats.cardProgress.isNotEmpty
            ? stats.cardProgress
                    .map((p) => p.count)
                    .reduce((a, b) => a > b ? a : b)
                    .toDouble() +
                5
            : 10,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < stats.cardProgress.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      stats.cardProgress[index].status,
                      style: const TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        barGroups: bars,
      ),
    );
  }

  /// 空の状態を表示
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// チャートの種類
enum ChartType {
  dailyActivity,
  tagFrequency,
  cardProgress,
}

/// 統計カードウィジェット
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 統計セクションウィジェット
class StatsSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const StatsSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
