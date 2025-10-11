import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_jp_learn_app/services/tips_service.dart';

void main() {
  group('TipsService', () {
    late TipsService tipsService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      tipsService = TipsService();
    });

    tearDown(() {
      tipsService.dispose();
    });

    test('should initialize correctly', () async {
      // Act
      await tipsService.initialize();

      // Assert
      expect(tipsService, isNotNull);
    });

    test('should return false for unshown tips', () async {
      // Arrange
      await tipsService.initialize();

      // Act
      final isShown = await tipsService.isTipShown('test_tip');

      // Assert
      expect(isShown, isFalse);
    });

    test('should mark tip as shown and return true', () async {
      // Arrange
      await tipsService.initialize();

      // Act
      await tipsService.markTipAsShown('test_tip');
      final isShown = await tipsService.isTipShown('test_tip');

      // Assert
      expect(isShown, isTrue);
    });

    test('should return true for canShowTip when tip is not shown', () async {
      // Arrange
      await tipsService.initialize();

      // Act
      final canShow = await tipsService.canShowTip('test_tip');

      // Assert
      expect(canShow, isTrue);
    });

    test('should return false for canShowTip when tip is already shown',
        () async {
      // Arrange
      await tipsService.initialize();
      await tipsService.markTipAsShown('test_tip');

      // Act
      final canShow = await tipsService.canShowTip('test_tip');

      // Assert
      expect(canShow, isFalse);
    });

    test('should mark multiple tips as shown', () async {
      // Arrange
      await tipsService.initialize();
      final tipIds = ['tip1', 'tip2', 'tip3'];

      // Act
      await tipsService.markMultipleTipsAsShown(tipIds);

      // Assert
      for (final tipId in tipIds) {
        expect(await tipsService.isTipShown(tipId), isTrue);
      }
    });

    test('should reset specific tip', () async {
      // Arrange
      await tipsService.initialize();
      await tipsService.markTipAsShown('test_tip');

      // Act
      await tipsService.resetTip('test_tip');

      // Assert
      expect(await tipsService.isTipShown('test_tip'), isFalse);
    });

    test('should reset all tips', () async {
      // Arrange
      await tipsService.initialize();
      await tipsService.markMultipleTipsAsShown(['tip1', 'tip2', 'tip3']);

      // Act
      await tipsService.resetAllTips();

      // Assert
      expect(await tipsService.isTipShown('tip1'), isFalse);
      expect(await tipsService.isTipShown('tip2'), isFalse);
      expect(await tipsService.isTipShown('tip3'), isFalse);
    });

    test('should get list of shown tips', () async {
      // Arrange
      await tipsService.initialize();
      await tipsService.markMultipleTipsAsShown(['tip1', 'tip2']);

      // Act
      final shownTips = await tipsService.getShownTips();

      // Assert
      expect(shownTips, containsAll(['tip1', 'tip2']));
    });

    test('should show timed tip and mark as shown', () async {
      // Arrange
      await tipsService.initialize();

      // Act
      await tipsService.showTimedTip('test_tip',
          duration: const Duration(milliseconds: 100));

      // Assert
      expect(await tipsService.isTipShown('test_tip'), isTrue);
      expect(tipsService.isTipActive('test_tip'), isTrue);
    });

    test('should cancel tip timer', () async {
      // Arrange
      await tipsService.initialize();
      await tipsService.showTimedTip('test_tip',
          duration: const Duration(seconds: 10));

      // Act
      tipsService.cancelTipTimer('test_tip');

      // Assert
      expect(tipsService.isTipActive('test_tip'), isFalse);
    });

    test('should cancel all timers', () async {
      // Arrange
      await tipsService.initialize();
      await tipsService.showTimedTip('tip1',
          duration: const Duration(seconds: 10));
      await tipsService.showTimedTip('tip2',
          duration: const Duration(seconds: 10));

      // Act
      tipsService.cancelAllTimers();

      // Assert
      expect(tipsService.isTipActive('tip1'), isFalse);
      expect(tipsService.isTipActive('tip2'), isFalse);
    });

    test('should not show tip if already shown', () async {
      // Arrange
      await tipsService.initialize();
      await tipsService.markTipAsShown('test_tip');

      // Act
      await tipsService.showTip('test_tip');

      // Assert
      expect(await tipsService.isTipShown('test_tip'), isTrue);
    });
  });

  group('TipsId', () {
    test('should have correct tip IDs', () {
      // Assert
      expect(TipsId.ocrLighting, equals('tips_ocr_lighting'));
      expect(TipsId.ocrAngle, equals('tips_ocr_angle'));
      expect(TipsId.syncAuto, equals('tips_sync_auto'));
      expect(TipsId.cardReview, equals('tips_card_review'));
      expect(TipsId.offlineMode, equals('tips_offline_mode'));
      expect(TipsId.homeNavigation, equals('tips_home_navigation'));
      expect(TipsId.statsProgress, equals('tips_stats_progress'));
    });
  });

  group('TipsTiming', () {
    test('should have correct timing values', () {
      // Assert
      expect(TipsTiming.immediate.toString(), contains('immediate'));
      expect(TipsTiming.delayed.toString(), contains('delayed'));
      expect(TipsTiming.onAction.toString(), contains('onAction'));
    });
  });
}
