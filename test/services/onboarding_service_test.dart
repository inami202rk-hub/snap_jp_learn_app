import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_jp_learn_app/services/onboarding_service.dart';

void main() {
  group('OnboardingService Tests', () {
    setUp(() {
      // テスト前にSharedPreferencesをクリア
      SharedPreferences.setMockInitialValues({});
    });

    group('Onboarding Status', () {
      test('should return false for onboarding completion initially', () async {
        final isCompleted = await OnboardingService.isOnboardingCompleted();
        expect(isCompleted, isFalse);
      });

      test('should mark onboarding as completed', () async {
        await OnboardingService.markOnboardingCompleted();
        final isCompleted = await OnboardingService.isOnboardingCompleted();
        expect(isCompleted, isTrue);
      });

      test('should reset onboarding status', () async {
        // まず完了状態にする
        await OnboardingService.markOnboardingCompleted();
        expect(await OnboardingService.isOnboardingCompleted(), isTrue);

        // リセット
        await OnboardingService.resetOnboarding();
        expect(await OnboardingService.isOnboardingCompleted(), isFalse);
      });
    });

    group('Tips Status', () {
      test('should return false for tip shown status initially', () async {
        final isShown = await OnboardingService.isTipShown('test_tip');
        expect(isShown, isFalse);
      });

      test('should mark tip as shown', () async {
        await OnboardingService.markTipShown('test_tip');
        final isShown = await OnboardingService.isTipShown('test_tip');
        expect(isShown, isTrue);
      });

      test('should handle multiple tips independently', () async {
        await OnboardingService.markTipShown('tip1');
        await OnboardingService.markTipShown('tip2');

        expect(await OnboardingService.isTipShown('tip1'), isTrue);
        expect(await OnboardingService.isTipShown('tip2'), isTrue);
        expect(await OnboardingService.isTipShown('tip3'), isFalse);
      });

      test('should reset all tips', () async {
        // 複数のTipsを表示済みにする
        await OnboardingService.markTipShown('tip1');
        await OnboardingService.markTipShown('tip2');
        await OnboardingService.markTipShown('tip3');

        // 全て表示済みであることを確認
        expect(await OnboardingService.isTipShown('tip1'), isTrue);
        expect(await OnboardingService.isTipShown('tip2'), isTrue);
        expect(await OnboardingService.isTipShown('tip3'), isTrue);

        // リセット
        await OnboardingService.resetAllTips();

        // 全て未表示であることを確認
        expect(await OnboardingService.isTipShown('tip1'), isFalse);
        expect(await OnboardingService.isTipShown('tip2'), isFalse);
        expect(await OnboardingService.isTipShown('tip3'), isFalse);
      });
    });

    group('Integration Tests', () {
      test('should maintain separate state for onboarding and tips', () async {
        // オンボーディング完了
        await OnboardingService.markOnboardingCompleted();

        // Tips表示
        await OnboardingService.markTipShown('test_tip');

        // それぞれ独立して状態を保持
        expect(await OnboardingService.isOnboardingCompleted(), isTrue);
        expect(await OnboardingService.isTipShown('test_tip'), isTrue);

        // オンボーディングのみリセット
        await OnboardingService.resetOnboarding();

        expect(await OnboardingService.isOnboardingCompleted(), isFalse);
        expect(await OnboardingService.isTipShown('test_tip'), isTrue);
      });
    });
  });
}
