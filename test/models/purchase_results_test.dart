import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/models/purchase_results.dart';

void main() {
  group('PurchaseResult Tests', () {
    test('PurchaseSuccess has correct properties', () {
      const result = PurchaseSuccess(
        productId: 'pro_monthly',
        transactionId: 'transaction_123',
      );

      expect(result.productId, equals('pro_monthly'));
      expect(result.transactionId, equals('transaction_123'));
    });

    test('PurchaseSuccess without transactionId', () {
      const result = PurchaseSuccess(productId: 'pro_lifetime');

      expect(result.productId, equals('pro_lifetime'));
      expect(result.transactionId, isNull);
    });

    test('PurchaseCancelled is constant', () {
      const result1 = PurchaseCancelled();
      const result2 = PurchaseCancelled();

      expect(result1, equals(result2));
    });

    test('PurchasePending with reason', () {
      const result = PurchasePending(reason: 'Waiting for approval');

      expect(result.reason, equals('Waiting for approval'));
    });

    test('PurchasePending without reason', () {
      const result = PurchasePending();

      expect(result.reason, isNull);
    });

    test('PurchaseNetworkError with message', () {
      const result = PurchaseNetworkError(message: 'No internet connection');

      expect(result.message, equals('No internet connection'));
    });

    test('PurchaseAlreadyOwned has productId', () {
      const result = PurchaseAlreadyOwned(productId: 'pro_monthly');

      expect(result.productId, equals('pro_monthly'));
    });

    test('PurchaseFailed with error details', () {
      const result = PurchaseFailed(
        errorCode: 'BILLING_ERROR',
        message: 'Billing service unavailable',
      );

      expect(result.errorCode, equals('BILLING_ERROR'));
      expect(result.message, equals('Billing service unavailable'));
    });
  });

  group('RestoreResult Tests', () {
    test('RestoreSuccess with product IDs', () {
      const result = RestoreSuccess(
        restoredProductIds: ['pro_monthly', 'pro_lifetime'],
      );

      expect(
          result.restoredProductIds, equals(['pro_monthly', 'pro_lifetime']));
    });

    test('RestoreSuccess with empty list', () {
      const result = RestoreSuccess(restoredProductIds: []);

      expect(result.restoredProductIds, isEmpty);
    });

    test('RestoreNoItems is constant', () {
      const result1 = RestoreNoItems();
      const result2 = RestoreNoItems();

      expect(result1, equals(result2));
    });

    test('RestoreNetworkError with message', () {
      const result = RestoreNetworkError(message: 'Network timeout');

      expect(result.message, equals('Network timeout'));
    });

    test('RestoreFailed with error details', () {
      const result = RestoreFailed(
        errorCode: 'RESTORE_ERROR',
        message: 'Failed to restore purchases',
      );

      expect(result.errorCode, equals('RESTORE_ERROR'));
      expect(result.message, equals('Failed to restore purchases'));
    });
  });

  group('Result Type Matching Tests', () {
    test('PurchaseResult can be matched with switch', () {
      const results = [
        PurchaseSuccess(productId: 'test'),
        PurchaseCancelled(),
        PurchasePending(),
        PurchaseNetworkError(),
        PurchaseAlreadyOwned(productId: 'test'),
        PurchaseFailed(),
      ];

      for (final result in results) {
        String? type;
        switch (result) {
          case PurchaseSuccess():
            type = 'success';
          case PurchaseCancelled():
            type = 'cancelled';
          case PurchasePending():
            type = 'pending';
          case PurchaseNetworkError():
            type = 'network_error';
          case PurchaseAlreadyOwned():
            type = 'already_owned';
          case PurchaseFailed():
            type = 'failed';
        }
        expect(type, isNotNull);
      }
    });

    test('RestoreResult can be matched with switch', () {
      const results = [
        RestoreSuccess(restoredProductIds: ['test']),
        RestoreNoItems(),
        RestoreNetworkError(),
        RestoreFailed(),
      ];

      for (final result in results) {
        String? type;
        switch (result) {
          case RestoreSuccess():
            type = 'success';
          case RestoreNoItems():
            type = 'no_items';
          case RestoreNetworkError():
            type = 'network_error';
          case RestoreFailed():
            type = 'failed';
        }
        expect(type, isNotNull);
      }
    });
  });
}
