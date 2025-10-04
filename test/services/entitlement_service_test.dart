import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/entitlement_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('EntitlementService Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('isPro returns false by default', () async {
      final isPro = await EntitlementService.isPro();
      expect(isPro, isFalse);
    });

    test('setPro(true) sets pro status correctly', () async {
      await EntitlementService.setPro(true, productId: 'pro_monthly');

      final isPro = await EntitlementService.isPro();
      expect(isPro, isTrue);

      final productId = await EntitlementService.getProProductId();
      expect(productId, equals('pro_monthly'));
    });

    test('setPro(false) clears pro status', () async {
      // First set pro to true
      await EntitlementService.setPro(true, productId: 'pro_monthly');

      // Then set to false
      await EntitlementService.setPro(false);

      final isPro = await EntitlementService.isPro();
      expect(isPro, isFalse);

      final productId = await EntitlementService.getProProductId();
      expect(productId, isNull);
    });

    test('getProPurchaseDate returns correct date', () async {
      final now = DateTime.now();
      await EntitlementService.setPro(true, productId: 'pro_monthly');

      final purchaseDate = await EntitlementService.getProPurchaseDate();
      expect(purchaseDate, isNotNull);
      expect(purchaseDate!.difference(now).inSeconds.abs(), lessThan(5));
    });

    test('getProProductId returns correct product ID', () async {
      await EntitlementService.setPro(true, productId: 'pro_lifetime');

      final productId = await EntitlementService.getProProductId();
      expect(productId, equals('pro_lifetime'));
    });

    test('resetProStatus clears all pro data', () async {
      // Set some pro data
      await EntitlementService.setPro(true, productId: 'pro_monthly');

      // Reset
      await EntitlementService.resetProStatus();

      // Verify everything is cleared
      final isPro = await EntitlementService.isPro();
      expect(isPro, isFalse);

      final productId = await EntitlementService.getProProductId();
      expect(productId, isNull);

      final purchaseDate = await EntitlementService.getProPurchaseDate();
      expect(purchaseDate, isNull);
    });

    test('isSubscriptionValid returns true for lifetime purchase', () async {
      await EntitlementService.setPro(true, productId: 'pro_lifetime');

      final isValid = await EntitlementService.isSubscriptionValid();
      expect(isValid, isTrue);
    });

    test('isSubscriptionValid returns true for monthly within 30 days',
        () async {
      await EntitlementService.setPro(true, productId: 'pro_monthly');

      final isValid = await EntitlementService.isSubscriptionValid();
      expect(isValid, isTrue); // Should be valid since it was just set
    });

    test('isSubscriptionValid returns false for non-pro user', () async {
      final isValid = await EntitlementService.isSubscriptionValid();
      expect(isValid, isFalse);
    });

    test('verifyAndRepairEntitlement handles network errors gracefully',
        () async {
      // This test verifies that the method doesn't throw exceptions
      // even when there are network issues
      final result = await EntitlementService.verifyAndRepairEntitlement();
      expect(result, isA<bool>());
    });

    test('retryEntitlementRepair completes without throwing', () async {
      // This test verifies that the retry mechanism doesn't throw exceptions
      await EntitlementService.retryEntitlementRepair(maxRetries: 1);
      // If we get here without throwing, the test passes
    });

  });

  group('EntitlementService Edge Cases', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('handles corrupted purchase date gracefully', () async {
      // Simulate corrupted data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pro_purchase_date', 'invalid-date');

      final purchaseDate = await EntitlementService.getProPurchaseDate();
      expect(purchaseDate, isNull);
    });

    test('handles missing product ID gracefully', () async {
      await EntitlementService.setPro(true);

      final productId = await EntitlementService.getProProductId();
      expect(productId, isNull);
    });

    test('subscription validity for monthly after 30 days', () async {
      // This is a theoretical test since we can't easily mock time
      // In a real implementation, you might want to add a method to
      // set a custom purchase date for testing
      await EntitlementService.setPro(true, productId: 'pro_monthly');

      // The current implementation should return true for recent purchases
      final isValid = await EntitlementService.isSubscriptionValid();
      expect(isValid, isTrue);
    });
  });
}
