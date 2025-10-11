import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_jp_learn_app/core/feature_flags.dart';

void main() {
  group('FeatureFlags', () {
    setUp(() async {
      // 各テストの前にSharedPreferencesをクリア
      SharedPreferences.setMockInitialValues({});
      await FeatureFlags.initialize();
    });

    tearDown(() async {
      await FeatureFlags.reset();
      FeatureFlagNotifier.clearAllListeners();
    });

    test('should initialize with default values', () async {
      expect(FeatureFlags.enableExperimentalOCR, false);
      expect(FeatureFlags.enableAdvancedStats, false);
      expect(FeatureFlags.enableUsageTracking, true);
      expect(FeatureFlags.enableBetaFeatures, false);
      expect(FeatureFlags.enableDebugMode, false);
      expect(FeatureFlags.isInitialized, true);
    });

    test('should set and get a flag', () async {
      await FeatureFlags.setFlag('enableExperimentalOCR', true);
      expect(FeatureFlags.enableExperimentalOCR, true);

      await FeatureFlags.setFlag('enableAdvancedStats', true);
      expect(FeatureFlags.enableAdvancedStats, true);
    });

    test('should reset flags to default values', () async {
      await FeatureFlags.setFlag('enableExperimentalOCR', true);
      await FeatureFlags.setFlag('enableUsageTracking', false);

      expect(FeatureFlags.enableExperimentalOCR, true);
      expect(FeatureFlags.enableUsageTracking, false);

      await FeatureFlags.reset();

      expect(FeatureFlags.enableExperimentalOCR, false);
      expect(FeatureFlags.enableUsageTracking, true);
    });

    test('should notify listeners when a flag changes', () async {
      bool? notifiedValue;
      void listener(bool value) {
        notifiedValue = value;
      }

      FeatureFlagNotifier.addListener('enableExperimentalOCR', listener);

      await FeatureFlags.setFlag('enableExperimentalOCR', true);
      expect(notifiedValue, true);

      await FeatureFlags.setFlag('enableExperimentalOCR', false);
      expect(notifiedValue, false);

      FeatureFlagNotifier.removeListener('enableExperimentalOCR', listener);
    });

    test('getAllFlags should return current state of all flags', () async {
      await FeatureFlags.setFlag('enableExperimentalOCR', true);
      await FeatureFlags.setFlag('enableDebugMode', true);

      final allFlags = await FeatureFlags.getAllFlags();

      expect(allFlags['enableExperimentalOCR'], true);
      expect(allFlags['enableAdvancedStats'], false);
      expect(allFlags['enableUsageTracking'], true);
      expect(allFlags['enableBetaFeatures'], false);
      expect(allFlags['enableDebugMode'], true);
    });

    test('getFlagDescription should return correct description', () {
      expect(FeatureFlags.getFlagDescription('enableExperimentalOCR'),
          '実験的OCR機能を有効にします。新しいOCRアルゴリズムや機能をテストできます。');
      expect(FeatureFlags.getFlagDescription('unknownFlag'), '不明なフラグです。');
    });

    test('getFlagCategory should return correct category', () {
      expect(FeatureFlags.getFlagCategory('enableExperimentalOCR'), '実験機能');
      expect(FeatureFlags.getFlagCategory('enableUsageTracking'), '分析機能');
      expect(FeatureFlags.getFlagCategory('unknownFlag'), 'その他');
    });

    test('isFlagMutable should return correct mutability', () {
      expect(FeatureFlags.isFlagMutable('enableExperimentalOCR'), true);
      expect(FeatureFlags.isFlagMutable('nonExistentFlag'), false);
    });
  });
}
