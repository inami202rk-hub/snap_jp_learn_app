import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:snap_jp_learn_app/services/usage_tracker.dart';

void main() {
  group('UsageTracker', () {
    late UsageTracker usageTracker;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      Hive.registerAdapter(UsageEventAdapter());
      usageTracker = UsageTracker();
      await usageTracker.initialize();
    });

    tearDown(() async {
      await usageTracker.dispose();
      await Hive.deleteFromDisk();
    });

    test('should record an event', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      final events = await usageTracker.getEvents();
      expect(events.length, 1);
      expect(events.first.type, UsageEventType.appLaunch);
    });

    test('should record multiple events', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.postCreated);
      final events = await usageTracker.getEvents();
      expect(events.length, 3);
      expect(events[0].type, UsageEventType.appLaunch);
      expect(events[1].type, UsageEventType.ocrUsed);
      expect(events[2].type, UsageEventType.postCreated);
    });

    test('should retrieve events in a specific period', () async {
      final now = DateTime.now();
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.postCreated);

      final eventsInPeriod = await usageTracker.getEvents(
          from: now.subtract(const Duration(days: 1)),
          to: now.add(const Duration(days: 1)));
      expect(eventsInPeriod.length, 3);
    });

    test('should reset usage data', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      expect((await usageTracker.getEvents()).length, 1);

      await usageTracker.reset();
      expect((await usageTracker.getEvents()).length, 0);
    });

    test('should handle metadata correctly', () async {
      final metadata = {'version': '1.0.0', 'platform': 'android'};
      await usageTracker.trackEvent(UsageEventType.appLaunch, metadata: metadata);
      final events = await usageTracker.getEvents();
      expect(events.first.metadata, metadata);
    });

    test('should filter events by type', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);

      final ocrEvents = await usageTracker.getEvents(type: UsageEventType.ocrUsed);
      expect(ocrEvents.length, 2);
      expect(ocrEvents.every((e) => e.type == UsageEventType.ocrUsed), true);
    });

    test('should get event count', () async {
      await usageTracker.trackEvent(UsageEventType.appLaunch);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);
      await usageTracker.trackEvent(UsageEventType.ocrUsed);

      final totalCount = await usageTracker.getEventCount();
      expect(totalCount, 3);

      final ocrCount = await usageTracker.getEventCount(type: UsageEventType.ocrUsed);
      expect(ocrCount, 2);
    });
  });
}