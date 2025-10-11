import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/usage_tracker.dart';
import '../services/usage_stats_service.dart';
import '../generated/app_localizations.dart';

/// 利用データ表示ページ
class SettingsUsagePage extends StatefulWidget {
  const SettingsUsagePage({super.key});

  @override
  State<SettingsUsagePage> createState() => _SettingsUsagePageState();
}

class _SettingsUsagePageState extends State<SettingsUsagePage> {
  final UsageStatsService _statsService = UsageStatsService();
  final UsageTracker _tracker = UsageTracker();

  UsageSummary? _summary;
  List<DailyUsage>? _dailyUsage;
  List<FeatureUsage>? _featureUsage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final summary = await _statsService.getSummary();
      final dailyUsage = await _statsService.getDailyUsage(days: 7);
      final featureUsage = await _statsService.getFeatureUsage();

      setState(() {
        _summary = summary;
        _dailyUsage = dailyUsage;
        _featureUsage = featureUsage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('データの読み込みに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.usageData ?? '利用データ'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '更新',
          ),
          PopupMenuButton<String>(
            onSelected: (period) {
              // 期間選択の処理（現在は実装していない）
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'week',
                child: Text('過去7日間'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('過去30日間'),
              ),
            ],
            child: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _summary == null
              ? _buildEmptyState()
              : _buildContent(),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.noUsageData ?? '利用データがありません',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.usageDataDescription ?? 'アプリを使用すると、ここに利用状況が表示されます。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildDailyUsageChart(),
          const SizedBox(height: 24),
          _buildFeatureUsageList(),
          const SizedBox(height: 24),
          _buildResetButton(),
          const SizedBox(height: 16),
          _buildPrivacyNotice(),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final l10n = AppLocalizations.of(context);
    final summary = _summary!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.usageSummary ?? '利用状況サマリー',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: '過去7日間',
                value: '${summary.weeklyStats.totalEvents}',
                subtitle: 'イベント数',
                icon: Icons.trending_up,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: 'アクティブ日数',
                value: '${summary.activeDays30}',
                subtitle: '過去30日間',
                icon: Icons.calendar_today,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                title: '最も使用された機能',
                value: _getFeatureDisplayName(summary.mostUsedFeature),
                subtitle: 'トップ機能',
                icon: Icons.star,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                title: '継続率',
                value:
                    '${(summary.monthlyStats.retentionRate * 100).toStringAsFixed(1)}%',
                subtitle: '過去30日間',
                icon: Icons.timeline,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyUsageChart() {
    final l10n = AppLocalizations.of(context);
    final dailyUsage = _dailyUsage ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.dailyUsageChart ?? '日別利用状況',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: dailyUsage.isEmpty
                  ? const Center(
                      child: Text('データがありません'),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: dailyUsage
                                .map((e) => e.count)
                                .reduce((a, b) => a > b ? a : b)
                                .toDouble() +
                            1,
                        barTouchData: BarTouchData(
                          enabled: false,
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                if (value.toInt() >= dailyUsage.length)
                                  return const Text('');
                                final date = dailyUsage[value.toInt()].date;
                                return Text(
                                  '${date.month}/${date.day}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: Theme.of(context).textTheme.bodySmall,
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: dailyUsage.asMap().entries.map((entry) {
                          final index = entry.key;
                          final usage = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: usage.count.toDouble(),
                                color: Colors.blue,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureUsageList() {
    final l10n = AppLocalizations.of(context);
    final featureUsage = _featureUsage ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.featureUsageList ?? '機能別利用状況',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (featureUsage.isEmpty)
              const Center(
                child: Text('データがありません'),
              )
            else
              ...featureUsage.map((usage) => _buildFeatureUsageItem(usage)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureUsageItem(FeatureUsage usage) {
    final totalUsage =
        _featureUsage!.map((e) => e.count).reduce((a, b) => a + b);
    final percentage = (usage.count / totalUsage * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _getFeatureDisplayName(usage.feature),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${usage.count}回',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$percentage%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.resetUsageData ?? '利用データをリセット',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.resetUsageDataDescription ??
                  'すべての利用データを削除します。この操作は取り消せません。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showResetDialog,
                icon: const Icon(Icons.delete_forever),
                label: Text(l10n?.resetData ?? 'データをリセット'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    final l10n = AppLocalizations.of(context);

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              color: Colors.blue[700],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n?.usageDataPrivacyNotice ??
                    '利用データはすべてローカルに保存され、外部に送信されることはありません。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFeatureDisplayName(String feature) {
    switch (feature) {
      case UsageEventType.appLaunch:
        return 'アプリ起動';
      case UsageEventType.appClose:
        return 'アプリ終了';
      case UsageEventType.ocrUsed:
        return 'OCR実行';
      case UsageEventType.postCreated:
        return '投稿作成';
      case UsageEventType.cardCompleted:
        return '学習完了';
      case UsageEventType.syncCompleted:
        return '同期完了';
      case UsageEventType.paywallShown:
        return 'Paywall表示';
      case UsageEventType.purchaseCompleted:
        return '購入完了';
      case UsageEventType.restoreCompleted:
        return '復元完了';
      case UsageEventType.settingsOpened:
        return '設定開く';
      case UsageEventType.tutorialStarted:
        return 'チュートリアル開始';
      case UsageEventType.tutorialCompleted:
        return 'チュートリアル完了';
      default:
        return feature;
    }
  }

  void _showResetDialog() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.resetUsageData ?? '利用データをリセット'),
        content: Text(
          l10n?.resetUsageDataConfirm ?? 'すべての利用データを削除します。この操作は取り消せません。続行しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetUsageData();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n?.resetData ?? 'リセット'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetUsageData() async {
    try {
      await _tracker.reset();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)?.resetSuccess ?? '利用データをリセットしました'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('リセットに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
