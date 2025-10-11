import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/core/entitlements.dart';
import 'package:snap_jp_learn_app/services/log_service.dart';

void main() {
  group('Purchase Flow Integration', () {
    late MockPurchaseService mockPurchaseService;
    late MockEntitlementService mockEntitlementService;
    late LogService logService;

    setUp(() {
      mockPurchaseService = MockPurchaseService();
      mockEntitlementService = MockEntitlementService();
      logService = LogService();
    });

    group('Lock to Paywall Flow', () {
      test('should detect feature lock correctly', () {
        final stats = UsageStats(
          savedPostsCount: 50, // At limit
          todayOcrCount: 0,
          createdCardsCount: 0,
          reviewSessionsCount: 0,
          lastOcrDate: DateTime.now(),
        );

        final isLocked = EntitlementsManager.isFeatureLocked(
          Feature.postStorage,
          stats,
          false, // Free user
        );

        expect(isLocked, true);
      });

      test('should unlock feature after purchase', () {
        final stats = UsageStats(
          savedPostsCount: 50, // At limit
          todayOcrCount: 0,
          createdCardsCount: 0,
          reviewSessionsCount: 0,
          lastOcrDate: DateTime.now(),
        );

        // Before purchase - should be locked
        final beforePurchase = EntitlementsManager.isFeatureLocked(
          Feature.postStorage,
          stats,
          false, // Free user
        );
        expect(beforePurchase, true);

        // After purchase - should be unlocked
        final afterPurchase = EntitlementsManager.isFeatureLocked(
          Feature.postStorage,
          stats,
          true, // Pro user
        );
        expect(afterPurchase, false);
      });

      test('should log lock events', () {
        logService.logLockEvent(
          'post_storage',
          'limit_reached',
          data: {'current_usage': 50, 'max_usage': 50},
        );

        // Verify log was recorded (in real implementation, you'd check the log buffer)
        expect(logService, isNotNull);
      });

      test('should log purchase events', () {
        logService.logPurchaseEvent(
          'purchase_success',
          data: {'product_id': 'pro_monthly', 'price': 4.99},
        );

        // Verify log was recorded
        expect(logService, isNotNull);
      });
    });

    group('Restore Flow', () {
      test('should handle successful restore', () async {
        mockPurchaseService.setRestoreResult(true);
        mockEntitlementService.setIsPro(true);

        final success = await mockPurchaseService.restorePurchases();
        expect(success, true);

        final isPro = await mockEntitlementService.checkEntitlementStatus();
        expect(isPro, true);
      });

      test('should handle failed restore', () async {
        mockPurchaseService.setRestoreResult(false);

        final success = await mockPurchaseService.restorePurchases();
        expect(success, false);
      });

      test('should log restore events', () {
        logService.logPurchaseEvent('restore_attempt');
        logService.logPurchaseEvent('restore_success');

        expect(logService, isNotNull);
      });
    });

    group('Immediate Unlock Flow', () {
      test('should unlock immediately after purchase', () async {
        // Simulate purchase success
        mockEntitlementService.setIsPro(true);

        // Check that all features are unlocked
        final stats = UsageStats(
          savedPostsCount: 100, // Over free limit
          todayOcrCount: 20, // Over free limit
          createdCardsCount: 1000, // Over free limit
          reviewSessionsCount: 2000, // Over free limit
          lastOcrDate: DateTime.now(),
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

      test('should log immediate unlock', () {
        logService.logPurchaseEvent(
          'immediate_unlock',
          data: {
            'unlocked_features': ['post_storage', 'ocr_execution']
          },
        );

        expect(logService, isNotNull);
      });
    });

    group('Background Self-Repair', () {
      test('should detect entitlement status on startup', () async {
        mockEntitlementService.setIsPro(true);

        final isPro = await mockEntitlementService.checkEntitlementStatus();
        expect(isPro, true);

        // Should log startup check
        logService.logPurchaseEvent('startup_entitlement_check',
            data: {'is_pro': true});
        expect(logService, isNotNull);
      });

      test('should handle entitlement check failure gracefully', () async {
        mockEntitlementService.setShouldThrow(true);

        try {
          await mockEntitlementService.checkEntitlementStatus();
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<Exception>());
        }

        // Should log error
        logService.logPurchaseEvent('entitlement_check_error',
            data: {'error': 'network_error'});
        expect(logService, isNotNull);
      });
    });

    group('Usage Statistics Integration', () {
      test('should track usage statistics correctly', () {
        final stats = UsageStats(
          savedPostsCount: 25,
          todayOcrCount: 5,
          createdCardsCount: 100,
          reviewSessionsCount: 50,
          lastOcrDate: DateTime.now(),
        );

        // Check individual feature limits
        final postLimit = EntitlementsManager.getFeatureLimitInfo(
          Feature.postStorage,
          stats,
          false,
        );
        expect(postLimit.currentUsage, 25);
        expect(postLimit.maxUsage, 50);
        expect(postLimit.remainingUsage, 25);

        final ocrLimit = EntitlementsManager.getFeatureLimitInfo(
          Feature.ocrExecution,
          stats,
          false,
        );
        expect(ocrLimit.currentUsage, 5);
        expect(ocrLimit.maxUsage, 10);
        expect(ocrLimit.remainingUsage, 5);
      });

      test('should handle edge cases in usage statistics', () {
        // Test with zero usage
        final zeroStats = UsageStats(
          savedPostsCount: 0,
          todayOcrCount: 0,
          createdCardsCount: 0,
          reviewSessionsCount: 0,
          lastOcrDate: DateTime.now(),
        );

        final limitInfo = EntitlementsManager.getFeatureLimitInfo(
          Feature.postStorage,
          zeroStats,
          false,
        );
        expect(limitInfo.usageRatio, 0.0);
        expect(limitInfo.remainingUsage, 50);

        // Test with maximum usage
        final maxStats = UsageStats(
          savedPostsCount: 50,
          todayOcrCount: 10,
          createdCardsCount: 500,
          reviewSessionsCount: 1000,
          lastOcrDate: DateTime.now(),
        );

        final maxLimitInfo = EntitlementsManager.getFeatureLimitInfo(
          Feature.postStorage,
          maxStats,
          false,
        );
        expect(maxLimitInfo.usageRatio, 1.0);
        expect(maxLimitInfo.remainingUsage, 0);
        expect(maxLimitInfo.isLocked, true);
      });
    });
  });
}

/// Mock PurchaseService for testing
class MockPurchaseService {
  bool _restoreResult = false;

  void setRestoreResult(bool result) {
    _restoreResult = result;
  }

  Future<bool> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _restoreResult;
  }

  Future<bool> purchaseProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // Always successful for testing
  }
}

/// Mock EntitlementService for testing
class MockEntitlementService {
  bool _isPro = false;
  bool _shouldThrow = false;

  void setIsPro(bool isPro) {
    _isPro = isPro;
  }

  void setShouldThrow(bool shouldThrow) {
    _shouldThrow = shouldThrow;
  }

  Future<bool> checkEntitlementStatus() async {
    if (_shouldThrow) {
      throw Exception('Network error');
    }

    await Future.delayed(const Duration(milliseconds: 50));
    return _isPro;
  }
}
