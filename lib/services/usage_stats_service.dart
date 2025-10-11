import '../services/usage_tracker.dart';

/// 利用状況統計サービス
/// UsageTrackerのデータを集計・分析
class UsageStatsService {
  static final UsageStatsService _instance = UsageStatsService._internal();
  factory UsageStatsService({UsageTracker? tracker}) =>
      _instance.._tracker = tracker ?? UsageTracker();
  UsageStatsService._internal();

  late final UsageTracker _tracker;

  /// 指定期間の利用統計を取得
  Future<UsageStats> getStats({
    DateTime? from,
    DateTime? to,
  }) async {
    final now = DateTime.now();
    final startDate = from ?? now.subtract(const Duration(days: 30));
    final endDate = to ?? now;

    final events = await _tracker.getEvents(
      from: startDate,
      to: endDate,
    );

    return _calculateStats(events, startDate, endDate);
  }

  /// 直近7日間の統計を取得
  Future<UsageStats> getWeeklyStats() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return getStats(from: weekAgo, to: now);
  }

  /// 直近30日間の統計を取得
  Future<UsageStats> getMonthlyStats() async {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    return getStats(from: monthAgo, to: now);
  }

  /// 最も使用された機能を取得
  Future<String> getMostUsedFeature() async {
    final events = await _tracker.getEvents();

    final featureCounts = <String, int>{};
    for (final event in events) {
      featureCounts[event.type] = (featureCounts[event.type] ?? 0) + 1;
    }

    if (featureCounts.isEmpty) return 'None';

    return featureCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// アクティブ日数を取得
  Future<int> getActiveDays({int days = 30}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final events = await _tracker.getEvents(from: startDate, to: now);

    final activeDays = <String>{};
    for (final event in events) {
      final dayKey = '${event.timestamp.year}-${event.timestamp.month}-${event.timestamp.day}';
      activeDays.add(dayKey);
    }

    return activeDays.length;
  }

  /// 日別利用回数を取得（チャート用）
  Future<List<DailyUsage>> getDailyUsage({int days = 7}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final events = await _tracker.getEvents(from: startDate, to: now);

    final dailyCounts = <String, int>{};
    for (final event in events) {
      final dayKey = '${event.timestamp.year}-${event.timestamp.month}-${event.timestamp.day}';
      dailyCounts[dayKey] = (dailyCounts[dayKey] ?? 0) + 1;
    }

    final result = <DailyUsage>[];
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dayKey = '${date.year}-${date.month}-${date.day}';
      final count = dailyCounts[dayKey] ?? 0;

      result.add(DailyUsage(
        date: date,
        count: count,
      ));
    }

    // 新しい日付順にソート
    result.sort((a, b) => a.date.compareTo(b.date));

    return result;
  }

  /// 機能別利用回数を取得
  Future<List<FeatureUsage>> getFeatureUsage() async {
    final events = await _tracker.getEvents();

    final featureCounts = <String, int>{};
    for (final event in events) {
      featureCounts[event.type] = (featureCounts[event.type] ?? 0) + 1;
    }

    final totalEvents = featureCounts.values.fold(0, (a, b) => a + b);

    final result = <FeatureUsage>[];
    for (final entry in featureCounts.entries) {
      result.add(FeatureUsage(
        feature: entry.key,
        count: entry.value,
        percentage: totalEvents > 0 ? (entry.value / totalEvents * 100) : 0.0,
      ));
    }

    // 利用回数順にソート
    result.sort((a, b) => b.count.compareTo(a.count));

    return result;
  }

  /// 統計を計算
  UsageStats _calculateStats(List<UsageEvent> events, DateTime from, DateTime to) {
    final totalEvents = events.length;
    final appLaunches = events.where((e) => e.type == UsageEventType.appLaunch).length;
    final ocrUsed = events.where((e) => e.type == UsageEventType.ocrUsed).length;
    final postsCreated = events.where((e) => e.type == UsageEventType.postCreated).length;
    final cardsCompleted = events.where((e) => e.type == UsageEventType.cardCompleted).length;
    final syncCompleted = events.where((e) => e.type == UsageEventType.syncCompleted).length;
    final paywallShown = events.where((e) => e.type == UsageEventType.paywallShown).length;
    final purchasesCompleted =
        events.where((e) => e.type == UsageEventType.purchaseCompleted).length;

    // アクティブ日数を計算
    final activeDays = <String>{};
    for (final event in events) {
      final dayKey = '${event.timestamp.year}-${event.timestamp.month}-${event.timestamp.day}';
      activeDays.add(dayKey);
    }

    // 最も使用された機能
    final featureCounts = <String, int>{};
    for (final event in events) {
      featureCounts[event.type] = (featureCounts[event.type] ?? 0) + 1;
    }

    final mostUsedFeature = featureCounts.isEmpty
        ? 'None'
        : featureCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return UsageStats(
      period: from,
      periodEnd: to,
      totalEvents: totalEvents,
      activeDays: activeDays.length,
      appLaunches: appLaunches,
      ocrUsed: ocrUsed,
      postsCreated: postsCreated,
      cardsCompleted: cardsCompleted,
      syncCompleted: syncCompleted,
      paywallShown: paywallShown,
      purchasesCompleted: purchasesCompleted,
      mostUsedFeature: mostUsedFeature,
      eventCounts: featureCounts,
    );
  }

  /// 利用状況の概要を取得
  Future<UsageSummary> getSummary() async {
    final weeklyStats = await getWeeklyStats();
    final monthlyStats = await getMonthlyStats();
    final activeDays = await getActiveDays(days: 30);
    final mostUsedFeature = await getMostUsedFeature();

    return UsageSummary(
      weeklyStats: weeklyStats,
      monthlyStats: monthlyStats,
      activeDays30: activeDays,
      mostUsedFeature: mostUsedFeature,
    );
  }

  /// 利用データをリセット
  Future<void> resetUsageData() async {
    await _tracker.reset();
  }
}

/// 利用統計データ
class UsageStats {
  final DateTime period;
  final DateTime periodEnd;
  final int totalEvents;
  final int activeDays;
  final int appLaunches;
  final int ocrUsed;
  final int postsCreated;
  final int cardsCompleted;
  final int syncCompleted;
  final int paywallShown;
  final int purchasesCompleted;
  final String mostUsedFeature;
  final Map<String, int> eventCounts;

  UsageStats({
    required this.period,
    required this.periodEnd,
    required this.totalEvents,
    required this.activeDays,
    required this.appLaunches,
    required this.ocrUsed,
    required this.postsCreated,
    required this.cardsCompleted,
    required this.syncCompleted,
    required this.paywallShown,
    required this.purchasesCompleted,
    required this.mostUsedFeature,
    required this.eventCounts,
  });

  /// 期間の日数
  int get periodDays => periodEnd.difference(period).inDays + 1;

  /// 1日あたりの平均イベント数
  double get averageEventsPerDay {
    if (periodDays == 0) return 0.0;
    return totalEvents / periodDays;
  }

  /// 1日あたりの平均アクティブ日数
  double get averageActiveDaysPerDay {
    if (periodDays == 0) return 0.0;
    return activeDays / periodDays;
  }

  /// 利用継続率（アクティブ日数 / 総日数）
  double get retentionRate {
    if (periodDays == 0) return 0.0;
    return activeDays / periodDays;
  }

  @override
  String toString() {
    return 'UsageStats(period: $period, periodEnd: $periodEnd, totalEvents: $totalEvents, activeDays: $activeDays, mostUsedFeature: $mostUsedFeature)';
  }
}

/// 日別利用データ
class DailyUsage {
  final DateTime date;
  final int count;

  DailyUsage({
    required this.date,
    required this.count,
  });

  @override
  String toString() {
    return 'DailyUsage(date: $date, count: $count)';
  }
}

/// 機能別利用データ
class FeatureUsage {
  final String feature;
  final int count;
  final double percentage;

  FeatureUsage({
    required this.feature,
    required this.count,
    required this.percentage,
  });

  @override
  String toString() {
    return 'FeatureUsage(feature: $feature, count: $count)';
  }
}

/// 利用状況概要
class UsageSummary {
  final UsageStats weeklyStats;
  final UsageStats monthlyStats;
  final int activeDays30;
  final String mostUsedFeature;

  UsageSummary({
    required this.weeklyStats,
    required this.monthlyStats,
    required this.activeDays30,
    required this.mostUsedFeature,
  });

  @override
  String toString() {
    return 'UsageSummary(weeklyStats: $weeklyStats, monthlyStats: $monthlyStats, activeDays30: $activeDays30, mostUsedFeature: $mostUsedFeature)';
  }
}
