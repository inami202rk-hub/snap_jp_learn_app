import '../models/review_log.dart';
import '../repositories/srs_repository.dart';
import '../repositories/post_repository.dart';
import '../core/ui_state.dart';

/// 学習統計データ
class LearningStats {
  final int todayReviews;
  final int weekReviews;
  final int monthReviews;
  final int streakDays;
  final int todayDueCount;
  final int remainingDueCount;
  final int totalCards;
  final int weekCreatedCards;
  final DateTime lastUpdated;

  const LearningStats({
    required this.todayReviews,
    required this.weekReviews,
    required this.monthReviews,
    required this.streakDays,
    required this.todayDueCount,
    required this.remainingDueCount,
    required this.totalCards,
    required this.weekCreatedCards,
    required this.lastUpdated,
  });

  LearningStats copyWith({
    int? todayReviews,
    int? weekReviews,
    int? monthReviews,
    int? streakDays,
    int? todayDueCount,
    int? remainingDueCount,
    int? totalCards,
    int? weekCreatedCards,
    DateTime? lastUpdated,
  }) {
    return LearningStats(
      todayReviews: todayReviews ?? this.todayReviews,
      weekReviews: weekReviews ?? this.weekReviews,
      monthReviews: monthReviews ?? this.monthReviews,
      streakDays: streakDays ?? this.streakDays,
      todayDueCount: todayDueCount ?? this.todayDueCount,
      remainingDueCount: remainingDueCount ?? this.remainingDueCount,
      totalCards: totalCards ?? this.totalCards,
      weekCreatedCards: weekCreatedCards ?? this.weekCreatedCards,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayReviews': todayReviews,
      'weekReviews': weekReviews,
      'monthReviews': monthReviews,
      'streakDays': streakDays,
      'todayDueCount': todayDueCount,
      'remainingDueCount': remainingDueCount,
      'totalCards': totalCards,
      'weekCreatedCards': weekCreatedCards,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory LearningStats.fromJson(Map<String, dynamic> json) {
    return LearningStats(
      todayReviews: json['todayReviews'] as int,
      weekReviews: json['weekReviews'] as int,
      monthReviews: json['monthReviews'] as int,
      streakDays: json['streakDays'] as int,
      todayDueCount: json['todayDueCount'] as int,
      remainingDueCount: json['remainingDueCount'] as int,
      totalCards: json['totalCards'] as int,
      weekCreatedCards: json['weekCreatedCards'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  @override
  String toString() {
    return 'LearningStats(todayReviews: $todayReviews, weekReviews: $weekReviews, monthReviews: $monthReviews, streakDays: $streakDays, todayDueCount: $todayDueCount, remainingDueCount: $remainingDueCount, totalCards: $totalCards, weekCreatedCards: $weekCreatedCards, lastUpdated: $lastUpdated)';
  }
}

/// 学習統計サービス
/// SRS学習状況の集計とキャッシュ管理
class StatsService {
  final SrsRepository _srsRepository;

  LearningStats? _cachedStats;
  DateTime? _lastCacheUpdate;

  StatsService({
    required SrsRepository srsRepository,
    required PostRepository postRepository,
  }) : _srsRepository = srsRepository;

  /// 統計データを取得（キャッシュ優先）
  Future<LearningStats> getStats() async {
    final now = DateTime.now();

    // キャッシュが有効な場合は返す（5分以内）
    if (_cachedStats != null &&
        _lastCacheUpdate != null &&
        now.difference(_lastCacheUpdate!).inMinutes < 5) {
      return _cachedStats!;
    }

    // 統計を再計算
    final stats = await _calculateStats();
    _cachedStats = stats;
    _lastCacheUpdate = now;

    return stats;
  }

  /// 統計データを強制再計算
  Future<LearningStats> refreshStats() async {
    final stats = await _calculateStats();
    _cachedStats = stats;
    _lastCacheUpdate = DateTime.now();
    return stats;
  }

  /// レビュー完了時の差分更新
  Future<void> onReviewCompleted(Rating rating) async {
    if (_cachedStats == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 今日のレビュー数を増加
    _cachedStats = _cachedStats!.copyWith(
      todayReviews: _cachedStats!.todayReviews + 1,
      lastUpdated: now,
    );

    // 週・月のレビュー数も更新
    final weekStart = _getWeekStart(today);
    final monthStart = DateTime(today.year, today.month, 1);

    // 実際のデータから週・月のレビュー数を再計算
    final weekReviews = await _getReviewsInPeriod(weekStart, today);
    final monthReviews = await _getReviewsInPeriod(monthStart, today);

    _cachedStats = _cachedStats!.copyWith(
      weekReviews: weekReviews,
      monthReviews: monthReviews,
    );

    // Due件数を更新
    await _updateDueCounts();
  }

  /// カード作成時の差分更新
  Future<void> onCardCreated() async {
    if (_cachedStats == null) return;

    final now = DateTime.now();

    // 今週の作成数を増加
    _cachedStats = _cachedStats!.copyWith(
      weekCreatedCards: _cachedStats!.weekCreatedCards + 1,
      totalCards: _cachedStats!.totalCards + 1,
      lastUpdated: now,
    );
  }

  /// 統計データを計算
  Future<LearningStats> _calculateStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = _getWeekStart(today);
    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 0); // 月の最終日

    // レビュー数の集計
    final todayReviews = await _getReviewsInPeriod(today, today);
    final weekReviews = await _getReviewsInPeriod(weekStart, today);
    final monthReviews = await _getReviewsInPeriod(monthStart, monthEnd);

    // 学習連続日数の計算
    final streakDays = await _calculateStreakDays();

    // Due件数の計算
    final dueCards = await _srsRepository.getDueCards();
    final todayDueCount = dueCards.where((card) => card.isDueToday).length;
    final remainingDueCount = dueCards.length;

    // カード数の集計
    final allCards = await _srsRepository.getAllCards();
    final totalCards = allCards.length;
    final weekCreatedCards =
        allCards.where((card) => card.createdAt.isAfter(weekStart)).length;

    return LearningStats(
      todayReviews: todayReviews,
      weekReviews: weekReviews,
      monthReviews: monthReviews,
      streakDays: streakDays,
      todayDueCount: todayDueCount,
      remainingDueCount: remainingDueCount,
      totalCards: totalCards,
      weekCreatedCards: weekCreatedCards,
      lastUpdated: now,
    );
  }

  /// 指定期間のレビュー数を取得
  Future<int> _getReviewsInPeriod(DateTime start, DateTime end) async {
    final reviewLogs = await _srsRepository.getAllReviewLogs();

    return reviewLogs.where((log) {
      final logDate = DateTime(
          log.reviewedAt.year, log.reviewedAt.month, log.reviewedAt.day);
      return logDate.isAtSameMomentAs(start) ||
          logDate.isAtSameMomentAs(end) ||
          (logDate.isAfter(start) && logDate.isBefore(end));
    }).length;
  }

  /// 学習連続日数を計算
  Future<int> _calculateStreakDays() async {
    final reviewLogs = await _srsRepository.getAllReviewLogs();

    if (reviewLogs.isEmpty) return 0;

    // レビュー日を重複除去してソート
    final reviewDates = reviewLogs
        .map((log) => DateTime(
            log.reviewedAt.year, log.reviewedAt.month, log.reviewedAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // 降順ソート

    if (reviewDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 今日または昨日から連続日数を計算
    int streak = 0;
    DateTime currentDate = todayDate;

    for (final reviewDate in reviewDates) {
      if (reviewDate.isAtSameMomentAs(currentDate) ||
          reviewDate.isAtSameMomentAs(
              currentDate.subtract(const Duration(days: 1)))) {
        streak++;
        currentDate = reviewDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Due件数を更新
  Future<void> _updateDueCounts() async {
    final dueCards = await _srsRepository.getDueCards();
    final todayDueCount = dueCards.where((card) => card.isDueToday).length;
    final remainingDueCount = dueCards.length;

    _cachedStats = _cachedStats!.copyWith(
      todayDueCount: todayDueCount,
      remainingDueCount: remainingDueCount,
    );
  }

  /// 週の開始日を取得（月曜日）
  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    final daysToSubtract = weekday == 1 ? 0 : weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }

  /// 直近N日間の日別レビュー数を取得
  Future<List<int>> getDailyReviewCounts({int lastNDays = 7}) async {
    final reviewLogs = await _srsRepository.getAllReviewLogs();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dailyCounts = <int>[];

    for (int i = lastNDays - 1; i >= 0; i--) {
      final targetDate = today.subtract(Duration(days: i));
      final count = reviewLogs.where((log) {
        final logDate = DateTime(
            log.reviewedAt.year, log.reviewedAt.month, log.reviewedAt.day);
        return logDate.year == targetDate.year &&
            logDate.month == targetDate.month &&
            logDate.day == targetDate.day;
      }).length;

      dailyCounts.add(count);
    }

    return dailyCounts;
  }

  /// 直近N週間の週別レビュー数を取得
  Future<List<int>> getWeeklyReviewCounts({int lastNWeeks = 4}) async {
    final reviewLogs = await _srsRepository.getAllReviewLogs();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final weeklyCounts = <int>[];

    for (int i = lastNWeeks - 1; i >= 0; i--) {
      final weekEnd = today.subtract(Duration(days: i * 7));
      final weekStart = _getWeekStart(weekEnd);

      final count = reviewLogs.where((log) {
        final logDate = DateTime(
            log.reviewedAt.year, log.reviewedAt.month, log.reviewedAt.day);
        return (logDate.isAtSameMomentAs(weekStart) ||
            logDate.isAtSameMomentAs(weekEnd) ||
            (logDate.isAfter(weekStart) && logDate.isBefore(weekEnd)));
      }).length;

      weeklyCounts.add(count);
    }

    return weeklyCounts;
  }

  /// キャッシュをクリア
  void clearCache() {
    _cachedStats = null;
    _lastCacheUpdate = null;
  }

  /// 統計データを取得（UiState対応）
  Future<UiState<LearningStats>> getStatsWithState() async {
    try {
      final stats = await getStats();
      return UiStateUtils.success(stats);
    } catch (e) {
      return UiStateUtils.error('統計データの取得に失敗しました');
    }
  }

  /// 今日のレビュー数を取得（UiState対応）
  Future<UiState<int>> getTodayReviewsWithState() async {
    try {
      final count = await getTodayReviews();
      return UiStateUtils.success(count);
    } catch (e) {
      return UiStateUtils.error('今日のレビュー数の取得に失敗しました');
    }
  }

  /// 学習ストリーク日数を取得（UiState対応）
  Future<UiState<int>> getStreakDaysWithState() async {
    try {
      final days = await getStreakDays();
      return UiStateUtils.success(days);
    } catch (e) {
      return UiStateUtils.error('学習ストリークの取得に失敗しました');
    }
  }

  /// 総カード数を取得（UiState対応）
  Future<UiState<int>> getTotalCardsWithState() async {
    try {
      final count = await getTotalCards();
      return UiStateUtils.success(count);
    } catch (e) {
      return UiStateUtils.error('総カード数の取得に失敗しました');
    }
  }
}
