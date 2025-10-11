import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:snap_jp_learn_app/services/usage_tracker.dart';
import 'package:snap_jp_learn_app/services/usage_stats_service.dart';

void main() {
  group('UsageStatsService', () {
    late UsageTracker usageTracker;
    late UsageStatsService usageStatsService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      Hive.registerAdapter(UsageEventAdapter());
      usageTracker = UsageTracker();
      await usageTracker.initialize();
      usageStatsService = UsageStatsService(tracker: usageTracker);
    });

    tearDown(() async {
      await usageTracker.dispose();
      await Hive.deleteFromDisk();
    });

    test('getStats should return correct overall statistics', () async {
      final now = DateTime.now();
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.postCreated);
      await usageTracker.trackEvent(UsageEventType.cardCompleted);

      final stats = await usageStatsService.getStats(
          from: now.subtract(const Duration(days: 6)), to: now);

      expect(stats.totalEvents, 5);
      expect(stats.activeDays, 1);
      expect(stats.appLaunches, 1);
      expect(stats.ocrUsed, 2);
      expect(stats.postsCreated, 1);
      expect(stats.cardsCompleted, 1);
      expect(stats.mostUsedFeature, UsageEventType.ocrUsed);
      expect(stats.eventCounts[UsageEventType.appLaunch], 1);
      expect(stats.eventCounts[UsageEventType.ocrUsed], 2);
    });

    test('getDailyUsage should return correct daily event counts', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.postCreated);

      final dailyUsage = await usageStatsService.getDailyUsage(days: 3);

      expect(dailyUsage.length, 3);
      expect(dailyUsage.every((u) => u.count >= 0), true);
    });

    test('getFeatureUsage should return correct feature counts and percentages', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.postCreated);

      final featureUsage = await usageStatsService.getFeatureUsage();

      expect(featureUsage.length, 3);
      
      final ocrUsage = featureUsage.firstWhere((u) => u.feature == UsageEventType.ocrUsed);
      expect(ocrUsage.count, 2);
      expect(ocrUsage.percentage, 50.0);

      final appUsage = featureUsage.firstWhere((u) => u.feature == UsageEventType.appLaunch);
      expect(appUsage.count, 1);
      expect(appUsage.percentage, 25.0);

      final postUsage = featureUsage.firstWhere((u) => u.feature == UsageEventType.postCreated);
      expect(postUsage.count, 1);
      expect(postUsage.percentage, 25.0);
    });

    test('getSummary should return correct summary data', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);

      final summary = await usageStatsService.getSummary();

      expect(summary.weeklyStats.totalEvents, 3);
      expect(summary.monthlyStats.totalEvents, 3);
      expect(summary.activeDays30, 1);
      expect(summary.mostUsedFeature, UsageEventType.ocrUsed);
    });

    test('getMostUsedFeature should return correct feature', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);

      final mostUsed = await usageStatsService.getMostUsedFeature();
      expect(mostUsed, UsageEventType.ocrUsed);
    });

    test('getActiveDays should return correct active days count', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);

      final activeDays = await usageStatsService.getActiveDays(days: 30);
      expect(activeDays, 1);
    });

    test('resetUsageData should reset all data', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);

      expect((await usageStatsService.getStats()).totalEvents, 2);

      await usageStatsService.resetUsageData();

      expect((await usageStatsService.getStats()).totalEvents, 0);
    });
  });
}