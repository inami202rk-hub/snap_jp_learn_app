import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/stats_dashboard_service.dart';
import '../widgets/stats_chart.dart';

class StatsDashboardPage extends StatefulWidget {
  const StatsDashboardPage({super.key});

  @override
  State<StatsDashboardPage> createState() => _StatsDashboardPageState();
}

class _StatsDashboardPageState extends State<StatsDashboardPage> {
  DashboardStats? _stats;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  /// 統計データを読み込み
  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await StatsDashboardService.instance.getStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('統計データの読み込みに失敗しました: $e');
      }
    }
  }

  /// 統計データを更新
  Future<void> _refreshStats() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      final stats = await StatsDashboardService.instance.refreshStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isRefreshing = false;
        });
        _showSuccessSnackBar('統計データを更新しました');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        _showErrorSnackBar('統計データの更新に失敗しました: $e');
      }
    }
  }

  /// スクリーンショットを撮影して共有
  Future<void> _shareScreenshot() async {
    try {
      // スクリーンショットを撮影
      final image = await _captureScreenshot();

      if (image != null) {
        // 一時ファイルに保存
        final tempPath = await _saveImageToTemp(image);

        // 共有
        await Share.shareXFiles(
          [XFile(tempPath)],
          text: 'Snap JP Learn - 学習統計ダッシュボード\n\n'
              '📊 今月の学習成果\n'
              '📝 投稿数: ${_stats?.totalPosts ?? 0}件\n'
              '🔍 OCR回数: ${_stats?.totalOcrCount ?? 0}回\n'
              '✅ 学習完了: ${_stats?.completedCards ?? 0}カード\n'
              '🔥 継続日数: ${_stats?.streakDays ?? 0}日',
        );
      }
    } catch (e) {
      _showErrorSnackBar('スクリーンショットの共有に失敗しました: $e');
    }
  }

  /// スクリーンショットをキャッチ
  Future<Uint8List?> _captureScreenshot() async {
    try {
      // RepaintBoundaryでラップされたウィジェットから画像を生成
      final boundary = _screenshotKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      final image = await boundary?.toImage(pixelRatio: 2.0);
      final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Screenshot capture failed: $e');
      return null;
    }
  }

  /// 画像を一時ファイルに保存
  Future<String> _saveImageToTemp(Uint8List imageBytes) async {
    final tempDir = await Directory.systemTemp.createTemp('snap_jp_stats_');
    final file = File('${tempDir.path}/stats_dashboard.png');
    await file.writeAsBytes(imageBytes);
    return file.path;
  }

  final GlobalKey _screenshotKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学習統計ダッシュボード'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshStats,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _stats != null ? _shareScreenshot : null,
            tooltip: 'スクリーンショットを共有',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_stats == null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _refreshStats,
      child: RepaintBoundary(
        key: _screenshotKey,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatsCards(),
              const SizedBox(height: 16),
              _buildDailyActivityChart(),
              const SizedBox(height: 16),
              _buildTagFrequencyChart(),
              const SizedBox(height: 16),
              _buildCardProgressChart(),
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// ヘッダーセクション
  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '学習統計ダッシュボード',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        '最終更新: ${_formatDateTime(_stats!.lastUpdated)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 統計カード
  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: '投稿数',
                value: '${_stats!.totalPosts}',
                subtitle: '今月の投稿',
                icon: Icons.note_add,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'OCR回数',
                value: '${_stats!.totalOcrCount}',
                subtitle: '文字認識実行',
                icon: Icons.text_fields,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: '学習完了',
                value: '${_stats!.completedCards}',
                subtitle: 'カード数',
                icon: Icons.check_circle,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: '継続日数',
                value: '${_stats!.streakDays}',
                subtitle: '連続学習',
                icon: Icons.local_fire_department,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 日別活動チャート
  Widget _buildDailyActivityChart() {
    return StatsSection(
      title: '過去30日の活動',
      trailing: Icon(
        Icons.trending_up,
        color: Colors.blue,
        size: 20,
      ),
      child: StatsChart(
        stats: _stats!,
        chartType: ChartType.dailyActivity,
        height: 200,
      ),
    );
  }

  /// タグ頻度チャート
  Widget _buildTagFrequencyChart() {
    return StatsSection(
      title: 'よく使うタグ',
      trailing: Icon(
        Icons.label,
        color: Colors.green,
        size: 20,
      ),
      child: Column(
        children: [
          StatsChart(
            stats: _stats!,
            chartType: ChartType.tagFrequency,
            height: 200,
          ),
          if (_stats!.topTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTagList(),
          ],
        ],
      ),
    );
  }

  /// タグリスト
  Widget _buildTagList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _stats!.topTags
          .map((tag) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(tag.tag),
                    ),
                    Text(
                      '${tag.count}回 (${tag.percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  /// カード進捗チャート
  Widget _buildCardProgressChart() {
    return StatsSection(
      title: 'カード進捗',
      trailing: Icon(
        Icons.analytics,
        color: Colors.purple,
        size: 20,
      ),
      child: StatsChart(
        stats: _stats!,
        chartType: ChartType.cardProgress,
        height: 200,
      ),
    );
  }

  /// フッター
  Widget _buildFooter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '統計情報について',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'この統計は、アプリ内の学習データから自動的に計算されます。'
              'データはローカルに保存され、外部に送信されることはありません。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '統計データは1時間ごとに自動更新されます。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// エラー状態
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '統計データの読み込みに失敗しました',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'ネットワーク接続を確認して、再試行してください。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
            label: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  /// 日時をフォーマット
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 成功スナックバーを表示
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// エラースナックバーを表示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
