import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/core/entitlements.dart';

void main() {
  group('EntitlementsManager', () {
    late UsageStats testStats;

    setUp(() {
      testStats = UsageStats(
        savedPostsCount: 0,
        todayOcrCount: 0,
        createdCardsCount: 0,
        reviewSessionsCount: 0,
        lastOcrDate: DateTime.now(),
      );
    });

    group('Free tier limits', () {
      test('should allow post storage within limit', () {
        final stats = testStats.copyWith(savedPostsCount: 49);
        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.postStorage,
          stats,
          false,
        );
        expect(isLocked, false);
      });

      test('should lock post storage when limit reached', () {
        final stats = testStats.copyWith(savedPostsCount: 50);
        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.postStorage,
          stats,
          false,
        );
        expect(isLocked, true);
      });

      test('should allow OCR within daily limit', () {
        final stats = testStats.copyWith(todayOcrCount: 9);
        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.ocrExecution,
          stats,
          false,
        );
        expect(isLocked, false);
      });

      test('should lock OCR when daily limit reached', () {
        final stats = testStats.copyWith(todayOcrCount: 10);
        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.ocrExecution,
          stats,
          false,
        );
        expect(isLocked, true);
      });

      test('should allow card creation within limit', () {
        final stats = testStats.copyWith(createdCardsCount: 499);
        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.cardCreation,
          stats,
          false,
        );
        expect(isLocked, false);
      });

      test('should lock card creation when limit reached', () {
        final stats = testStats.copyWith(createdCardsCount: 500);
        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.cardCreation,
          stats,
          false,
        );
        expect(isLocked, true);
      });

      test('should allow review history within limit', () {
        final stats = testStats.copyWith(reviewSessionsCount: 999);
        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.reviewHistory,
          stats,
          false,
        );
        expect(isLocked, false);
      });

      test('should lock review history when limit reached', () {
        final stats = testStats.copyWith(reviewSessionsCount: 1000);
        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.reviewHistory,
          stats,
          false,
        );
        expect(isLocked, true);
      });
    });

    group('Pro features', () {
      test('should unlock all features for Pro users', () {
        final stats = testStats.copyWith(
          savedPostsCount: 100,
          todayOcrCount: 20,
          createdCardsCount: 1000,
          reviewSessionsCount: 2000,
        );

        final features = [
          Feature.postStorage,
          Feature.ocrExecution,
          Feature.cardCreation,
          Feature.reviewHistory,
          Feature.backup,
          Feature.detailedStats,
          Feature.customTheme,
        ];

        for (final feature in features) {
          final isLocked = EntitlementsManager.isFeatureLocked(
            feature,
            stats,
            true, // Pro user
          );
          expect(isLocked, false,
              reason: 'Pro user should have access to $feature');
        }
      });

      test('should lock Pro-only features for free users', () {
        final proOnlyFeatures = [
          Feature.backup,
          Feature.detailedStats,
          Feature.customTheme,
        ];

        for (final feature in proOnlyFeatures) {
          final isLocked = EntitlementsManager.isFeatureLocked(
            feature,
            testStats,
            false, // Free user
          );
          expect(isLocked, true,
              reason: 'Free user should not have access to $feature');
        }
      });
    });

    group('Feature limit info', () {
      test('should return correct limit info for post storage', () {
        final stats = testStats.copyWith(savedPostsCount: 25);
        final limitInfo = EntitlementsManager.getFeatureLimitInfo(
          Feature.postStorage,
          stats,
          false,
        );

        expect(limitInfo.isLocked, false);
        expect(limitInfo.currentUsage, 25);
        expect(limitInfo.maxUsage, 50);
        expect(limitInfo.usageRatio, 0.5);
        expect(limitInfo.remainingUsage, 25);
      });

      test('should return correct limit info for OCR', () {
        final stats = testStats.copyWith(todayOcrCount: 8);
        final limitInfo = EntitlementsManager.getFeatureLimitInfo(
          Feature.ocrExecution,
          stats,
          false,
        );

        expect(limitInfo.isLocked, false);
        expect(limitInfo.currentUsage, 8);
        expect(limitInfo.maxUsage, 10);
        expect(limitInfo.usageRatio, 0.8);
        expect(limitInfo.remainingUsage, 2);
      });

      test('should return unlimited info for Pro users', () {
        final limitInfo = EntitlementsManager.getFeatureLimitInfo(
          Feature.postStorage,
          testStats,
          true, // Pro user
        );

        expect(limitInfo.isLocked, false);
        expect(limitInfo.isUnlimited, true);
        expect(limitInfo.currentUsage, 0);
        expect(limitInfo.maxUsage, 0);
        expect(limitInfo.usageRatio, 0.0);
        expect(limitInfo.remainingUsage, -1);
      });
    });

    group('Feature display names', () {
      test('should return correct display names', () {
        expect(EntitlementsManager.getFeatureDisplayName(Feature.postStorage),
            'Post Storage');
        expect(EntitlementsManager.getFeatureDisplayName(Feature.ocrExecution),
            'OCR Processing');
        expect(EntitlementsManager.getFeatureDisplayName(Feature.cardCreation),
            'Card Creation');
        expect(EntitlementsManager.getFeatureDisplayName(Feature.reviewHistory),
            'Review History');
        expect(EntitlementsManager.getFeatureDisplayName(Feature.backup),
            'Backup & Sync');
        expect(EntitlementsManager.getFeatureDisplayName(Feature.detailedStats),
            'Detailed Statistics');
        expect(EntitlementsManager.getFeatureDisplayName(Feature.customTheme),
            'Custom Themes');
      });
    });

    group('Feature descriptions', () {
      test('should return correct descriptions', () {
        expect(EntitlementsManager.getFeatureDescription(Feature.postStorage),
            'Save and organize your Japanese text posts');
        expect(EntitlementsManager.getFeatureDescription(Feature.ocrExecution),
            'Extract text from images using OCR technology');
        expect(EntitlementsManager.getFeatureDescription(Feature.cardCreation),
            'Create learning cards from your posts');
        expect(EntitlementsManager.getFeatureDescription(Feature.reviewHistory),
            'Track your learning progress and history');
        expect(EntitlementsManager.getFeatureDescription(Feature.backup),
            'Backup your data to the cloud and sync across devices');
        expect(EntitlementsManager.getFeatureDescription(Feature.detailedStats),
            'View detailed statistics and learning insights');
        expect(EntitlementsManager.getFeatureDescription(Feature.customTheme),
            'Customize app appearance with themes');
      });
    });

    group('OCR daily reset', () {
      test('should reset OCR count for new day', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final stats = testStats.copyWith(
          todayOcrCount: 10,
          lastOcrDate: yesterday,
        );

        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.ocrExecution,
          stats,
          false,
        );

        expect(isLocked, false); // Should be unlocked due to new day
      });

      test('should maintain OCR count for same day', () {
        final today = DateTime.now();
        final stats = testStats.copyWith(
          todayOcrCount: 10,
          lastOcrDate: today,
        );

        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.ocrExecution,
          stats,
          false,
        );

        expect(isLocked, true); // Should be locked due to daily limit
      });
    });
  });

  group('FreeTierPolicy', () {
    test('should have correct limits', () {
      expect(FreeTierPolicy.maxSavedPosts, 50);
      expect(FreeTierPolicy.maxDailyOcr, 10);
      expect(FreeTierPolicy.maxCreatedCards, 500);
      expect(FreeTierPolicy.maxReviewSessions, 1000);
    });

    test('should have correct free features', () {
      expect(FreeTierPolicy.freeFeatures, contains(Feature.postStorage));
      expect(FreeTierPolicy.freeFeatures, contains(Feature.ocrExecution));
      expect(FreeTierPolicy.freeFeatures, contains(Feature.cardCreation));
      expect(FreeTierPolicy.freeFeatures, contains(Feature.reviewHistory));
    });

    test('should have correct Pro-only features', () {
      expect(FreeTierPolicy.proOnlyFeatures, contains(Feature.backup));
      expect(FreeTierPolicy.proOnlyFeatures, contains(Feature.detailedStats));
      expect(FreeTierPolicy.proOnlyFeatures, contains(Feature.customTheme));
    });
  });

  group('FeatureLimitInfo', () {
    test('should calculate usage ratio correctly', () {
      final limitInfo = FeatureLimitInfo(
        isLocked: false,
        currentUsage: 25,
        maxUsage: 100,
        isUnlimited: false,
      );

      expect(limitInfo.usageRatio, 0.25);
      expect(limitInfo.remainingUsage, 75);
    });

    test('should clamp usage ratio to 1.0', () {
      final limitInfo = FeatureLimitInfo(
        isLocked: true,
        currentUsage: 150,
        maxUsage: 100,
        isUnlimited: false,
      );

      expect(limitInfo.usageRatio, 1.0);
      expect(limitInfo.remainingUsage, 0);
    });

    test('should handle unlimited usage', () {
      final limitInfo = FeatureLimitInfo(
        isLocked: false,
        currentUsage: 0,
        maxUsage: 0,
        isUnlimited: true,
      );

      expect(limitInfo.usageRatio, 0.0);
      expect(limitInfo.remainingUsage, -1);
    });
  });
}
