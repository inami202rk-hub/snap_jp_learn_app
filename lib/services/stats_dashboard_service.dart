import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/post.dart';
import '../models/srs_card.dart';
import '../models/review_log.dart';
import '../services/usage_tracker.dart';
// UsageEvent is defined in usage_tracker.dart

/// ダッシュボード用の統計データ
class DashboardStats {
  final int totalPosts;
  final int totalOcrCount;
  final int completedCards;
  final int streakDays;
  final List<TagFrequency> topTags;
  final List<DailyActivity> dailyActivities;
  final List<CardProgress> cardProgress;
  final DateTime lastUpdated;

  DashboardStats({
    required this.totalPosts,
    required this.totalOcrCount,
    required this.completedCards,
    required this.streakDays,
    required this.topTags,
    required this.dailyActivities,
    required this.cardProgress,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'totalPosts': totalPosts,
        'totalOcrCount': totalOcrCount,
        'completedCards': completedCards,
        'streakDays': streakDays,
        'topTags': topTags.map((e) => e.toJson()).toList(),
        'dailyActivities': dailyActivities.map((e) => e.toJson()).toList(),
        'cardProgress': cardProgress.map((e) => e.toJson()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
        totalPosts: json['totalPosts'] as int,
        totalOcrCount: json['totalOcrCount'] as int,
        completedCards: json['completedCards'] as int,
        streakDays: json['streakDays'] as int,
        topTags: (json['topTags'] as List)
            .map((e) => TagFrequency.fromJson(e as Map<String, dynamic>))
            .toList(),
        dailyActivities: (json['dailyActivities'] as List)
            .map((e) => DailyActivity.fromJson(e as Map<String, dynamic>))
            .toList(),
        cardProgress: (json['cardProgress'] as List)
            .map((e) => CardProgress.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      );
}

/// タグの頻度データ
class TagFrequency {
  final String tag;
  final int count;
  final double percentage;

  TagFrequency({
    required this.tag,
    required this.count,
    required this.percentage,
  });

  Map<String, dynamic> toJson() => {
        'tag': tag,
        'count': count,
        'percentage': percentage,
      };

  factory TagFrequency.fromJson(Map<String, dynamic> json) => TagFrequency(
        tag: json['tag'] as String,
        count: json['count'] as int,
        percentage: (json['percentage'] as num).toDouble(),
      );
}

/// 日別活動データ
class DailyActivity {
  final DateTime date;
  final int postsCount;
  final int ocrCount;
  final int cardsCompleted;

  DailyActivity({
    required this.date,
    required this.postsCount,
    required this.ocrCount,
    required this.cardsCompleted,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'postsCount': postsCount,
        'ocrCount': ocrCount,
        'cardsCompleted': cardsCompleted,
      };

  factory DailyActivity.fromJson(Map<String, dynamic> json) => DailyActivity(
        date: DateTime.parse(json['date'] as String),
        postsCount: json['postsCount'] as int,
        ocrCount: json['ocrCount'] as int,
        cardsCompleted: json['cardsCompleted'] as int,
      );
}

/// カード進捗データ
class CardProgress {
  final String status;
  final int count;
  final String color;

  CardProgress({
    required this.status,
    required this.count,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'status': status,
        'count': count,
        'color': color,
      };

  factory CardProgress.fromJson(Map<String, dynamic> json) => CardProgress(
        status: json['status'] as String,
        count: json['count'] as int,
        color: json['color'] as String,
      );
}

/// 統計ダッシュボードサービス
class StatsDashboardService {
  static const String _boxName = 'dashboard_stats';
  static const int _cacheValidHours = 1; // 1時間キャッシュ有効

  static StatsDashboardService? _instance;
  static StatsDashboardService get instance =>
      _instance ??= StatsDashboardService._();

  StatsDashboardService._();

  Box<DashboardStats>? _box;

  /// 初期化
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox<DashboardStats>(_boxName);
      debugPrint('[StatsDashboardService] Initialized');
    } catch (e) {
      debugPrint('[StatsDashboardService] Initialization failed: $e');
    }
  }

  /// 統計データを取得（キャッシュ優先）
  Future<DashboardStats> getStats() async {
    try {
      // キャッシュから取得を試行
      final cached = await _getCachedStats();
      if (cached != null && _isCacheValid(cached)) {
        debugPrint('[StatsDashboardService] Using cached stats');
        return cached;
      }

      // 新しい統計を計算
      debugPrint('[StatsDashboardService] Computing new stats');
      final stats = await _computeStats();

      // キャッシュに保存
      await _cacheStats(stats);

      return stats;
    } catch (e) {
      debugPrint('[StatsDashboardService] Failed to get stats: $e');
      return _getDefaultStats();
    }
  }

  /// 統計データを強制更新
  Future<DashboardStats> refreshStats() async {
    try {
      final stats = await _computeStats();
      await _cacheStats(stats);
      debugPrint('[StatsDashboardService] Stats refreshed');
      return stats;
    } catch (e) {
      debugPrint('[StatsDashboardService] Failed to refresh stats: $e');
      return _getDefaultStats();
    }
  }

  /// 統計データを計算
  Future<DashboardStats> _computeStats() async {
    try {
      // 投稿データを取得
      final postsBox = await Hive.openBox<Post>('posts');
      final posts = postsBox.values.toList();

      // SRSカードデータを取得
      final srsBox = await Hive.openBox<SrsCard>('srs_cards');
      final srsCards = srsBox.values.toList();

      // 学習ログデータを取得
      final reviewBox = await Hive.openBox<ReviewLog>('review_logs');
      final reviewLogs = reviewBox.values.toList();

      // 使用統計データを取得
      final usageBox = await Hive.openBox<UsageEvent>('usage_events');
      final usageEvents = usageBox.values.toList();

      // 基本統計を計算
      final totalPosts = posts.length;
      final totalOcrCount =
          usageEvents.where((e) => e.type == UsageEventType.ocrUsed).length;
      // 学習完了カード数を計算（ratingが高いものを完了とみなす）
      final completedCards =
          reviewLogs.where((r) => r.rating == '5' || r.rating == '4').length;

      // 継続日数を計算
      final streakDays = _calculateStreakDays(posts);

      // トップタグを計算
      final topTags = _calculateTopTags(posts);

      // 日別活動データを計算（過去30日）
      final dailyActivities =
          _calculateDailyActivities(posts, usageEvents, reviewLogs);

      // カード進捗を計算
      final cardProgress = _calculateCardProgress(srsCards);

      return DashboardStats(
        totalPosts: totalPosts,
        totalOcrCount: totalOcrCount,
        completedCards: completedCards,
        streakDays: streakDays,
        topTags: topTags,
        dailyActivities: dailyActivities,
        cardProgress: cardProgress,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[StatsDashboardService] Failed to compute stats: $e');
      return _getDefaultStats();
    }
  }

  /// 継続日数を計算
  int _calculateStreakDays(List<Post> posts) {
    if (posts.isEmpty) return 0;

    final sortedPosts = posts.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (final post in sortedPosts) {
      final postDate = DateTime(
        post.createdAt.year,
        post.createdAt.month,
        post.createdAt.day,
      );

      final currentDateOnly = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      if (postDate.isAtSameMomentAs(currentDateOnly)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (postDate.isBefore(currentDateOnly)) {
        break;
      }
    }

    return streak;
  }

  /// トップタグを計算（現在は空のリストを返す）
  List<TagFrequency> _calculateTopTags(List<Post> posts) {
    // TODO: Postモデルにtagsフィールドが追加されたら実装
    return [];
  }

  /// 日別活動データを計算
  List<DailyActivity> _calculateDailyActivities(
    List<Post> posts,
    List<UsageEvent> usageEvents,
    List<ReviewLog> reviewLogs,
  ) {
    final activities = <DateTime, DailyActivity>{};
    final now = DateTime.now();

    // 過去30日分のデータを初期化
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      activities[dateOnly] = DailyActivity(
        date: dateOnly,
        postsCount: 0,
        ocrCount: 0,
        cardsCompleted: 0,
      );
    }

    // 投稿データを集計
    for (final post in posts) {
      final dateOnly = DateTime(
        post.createdAt.year,
        post.createdAt.month,
        post.createdAt.day,
      );

      if (activities.containsKey(dateOnly)) {
        activities[dateOnly] = DailyActivity(
          date: dateOnly,
          postsCount: activities[dateOnly]!.postsCount + 1,
          ocrCount: activities[dateOnly]!.ocrCount,
          cardsCompleted: activities[dateOnly]!.cardsCompleted,
        );
      }
    }

    // OCRデータを集計
    for (final event in usageEvents.where(
      (e) => e.type == UsageEventType.ocrUsed,
    )) {
      final dateOnly = DateTime(
        event.timestamp.year,
        event.timestamp.month,
        event.timestamp.day,
      );

      if (activities.containsKey(dateOnly)) {
        activities[dateOnly] = DailyActivity(
          date: dateOnly,
          postsCount: activities[dateOnly]!.postsCount,
          ocrCount: activities[dateOnly]!.ocrCount + 1,
          cardsCompleted: activities[dateOnly]!.cardsCompleted,
        );
      }
    }

    // 学習完了データを集計（ratingが高いものを完了とみなす）
    for (final log in reviewLogs.where(
      (r) => r.rating == '5' || r.rating == '4',
    )) {
      final dateOnly = DateTime(
        log.reviewedAt.year,
        log.reviewedAt.month,
        log.reviewedAt.day,
      );

      if (activities.containsKey(dateOnly)) {
        activities[dateOnly] = DailyActivity(
          date: dateOnly,
          postsCount: activities[dateOnly]!.postsCount,
          ocrCount: activities[dateOnly]!.ocrCount,
          cardsCompleted: activities[dateOnly]!.cardsCompleted + 1,
        );
      }
    }

    return activities.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// カード進捗を計算
  List<CardProgress> _calculateCardProgress(List<SrsCard> srsCards) {
    final statusCounts = <String, int>{};

    for (final card in srsCards) {
      final status = _getCardStatus(card);
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }

    return statusCounts.entries
        .map((entry) => CardProgress(
              status: entry.key,
              count: entry.value,
              color: _getStatusColor(entry.key),
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  /// カードステータスを取得
  String _getCardStatus(SrsCard card) {
    if (card.due.isAfter(DateTime.now())) {
      return '学習中';
    } else if (card.repetition == 0) {
      return '未学習';
    } else {
      return '復習待ち';
    }
  }

  /// ステータス色を取得
  String _getStatusColor(String status) {
    switch (status) {
      case '学習中':
        return '#4CAF50'; // Green
      case '未学習':
        return '#FF9800'; // Orange
      case '復習待ち':
        return '#2196F3'; // Blue
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// キャッシュから統計を取得
  Future<DashboardStats?> _getCachedStats() async {
    if (_box == null) return null;

    try {
      return _box!.get('latest');
    } catch (e) {
      debugPrint('[StatsDashboardService] Failed to get cached stats: $e');
      return null;
    }
  }

  /// 統計をキャッシュに保存
  Future<void> _cacheStats(DashboardStats stats) async {
    if (_box == null) return;

    try {
      await _box!.put('latest', stats);
    } catch (e) {
      debugPrint('[StatsDashboardService] Failed to cache stats: $e');
    }
  }

  /// キャッシュが有効かチェック
  bool _isCacheValid(DashboardStats stats) {
    final now = DateTime.now();
    final diff = now.difference(stats.lastUpdated);
    return diff.inHours < _cacheValidHours;
  }

  /// デフォルト統計を取得
  DashboardStats _getDefaultStats() {
    return DashboardStats(
      totalPosts: 0,
      totalOcrCount: 0,
      completedCards: 0,
      streakDays: 0,
      topTags: [],
      dailyActivities: [],
      cardProgress: [],
      lastUpdated: DateTime.now(),
    );
  }

  /// リソースを解放
  Future<void> dispose() async {
    await _box?.close();
  }
}
