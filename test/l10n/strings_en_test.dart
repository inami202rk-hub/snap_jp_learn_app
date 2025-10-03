import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/l10n/strings_en.dart';

void main() {
  group('AppStrings Tests', () {
    test('Permission related strings are not empty', () {
      expect(AppStrings.cameraPermissionDeniedTitle, isNotEmpty);
      expect(AppStrings.cameraPermissionDeniedMessage, isNotEmpty);
      expect(AppStrings.photoPermissionDeniedTitle, isNotEmpty);
      expect(AppStrings.photoPermissionDeniedMessage, isNotEmpty);
      expect(AppStrings.openSettings, isNotEmpty);
      expect(AppStrings.cancel, isNotEmpty);
    });

    test('Error message strings are not empty', () {
      expect(AppStrings.networkErrorTitle, isNotEmpty);
      expect(AppStrings.networkErrorMessage, isNotEmpty);
      expect(AppStrings.ocrErrorTitle, isNotEmpty);
      expect(AppStrings.ocrErrorMessage, isNotEmpty);
      expect(AppStrings.saveErrorTitle, isNotEmpty);
      expect(AppStrings.saveErrorMessage, isNotEmpty);
      expect(AppStrings.imageTooLargeTitle, isNotEmpty);
      expect(AppStrings.imageTooLargeMessage, isNotEmpty);
      expect(AppStrings.processingTimeoutTitle, isNotEmpty);
      expect(AppStrings.processingTimeoutMessage, isNotEmpty);
    });

    test('General message strings are not empty', () {
      expect(AppStrings.retry, isNotEmpty);
      expect(AppStrings.ok, isNotEmpty);
      expect(AppStrings.loading, isNotEmpty);
      expect(AppStrings.success, isNotEmpty);
      expect(AppStrings.error, isNotEmpty);
    });

    test('Premium/Paywall strings are not empty', () {
      expect(AppStrings.premiumRequiredTitle, isNotEmpty);
      expect(AppStrings.premiumRequiredMessage, isNotEmpty);
      expect(AppStrings.upgradeNow, isNotEmpty);
      expect(AppStrings.restorePurchases, isNotEmpty);
      expect(AppStrings.purchaseSuccessMessage, isNotEmpty);
      expect(AppStrings.purchaseFailedMessage, isNotEmpty);
      expect(AppStrings.purchaseCancelledMessage, isNotEmpty);
    });

    test('Onboarding strings are not empty', () {
      expect(AppStrings.welcomeTitle, isNotEmpty);
      expect(AppStrings.welcomeMessage, isNotEmpty);
      expect(AppStrings.permissionExplanationTitle, isNotEmpty);
      expect(AppStrings.cameraPermissionExplanation, isNotEmpty);
      expect(AppStrings.photoPermissionExplanation, isNotEmpty);
      expect(AppStrings.allowPermission, isNotEmpty);
      expect(AppStrings.skipForNow, isNotEmpty);
    });

    test('Permission denied messages contain camera/photo keywords', () {
      expect(AppStrings.cameraPermissionDeniedMessage, contains('camera'));
      expect(AppStrings.photoPermissionDeniedMessage, contains('photo'));
    });

    test('Error messages are user-friendly', () {
      // Check that error messages don't contain technical jargon
      expect(AppStrings.networkErrorMessage, isNot(contains('HTTP')));
      expect(AppStrings.ocrErrorMessage, isNot(contains('ML Kit')));
      expect(AppStrings.saveErrorMessage, isNot(contains('database')));
    });

    test('Premium messages mention Pro features', () {
      expect(AppStrings.premiumRequiredMessage, contains('Pro'));
      expect(AppStrings.purchaseSuccessMessage, contains('Premium'));
    });

    test('All strings are properly formatted', () {
      // Check that all strings start with capital letter
      final allStrings = [
        AppStrings.cameraPermissionDeniedTitle,
        AppStrings.photoPermissionDeniedTitle,
        AppStrings.networkErrorTitle,
        AppStrings.ocrErrorTitle,
        AppStrings.saveErrorTitle,
        AppStrings.imageTooLargeTitle,
        AppStrings.processingTimeoutTitle,
        AppStrings.premiumRequiredTitle,
        AppStrings.welcomeTitle,
        AppStrings.permissionExplanationTitle,
      ];

      for (final string in allStrings) {
        expect(string, matches(RegExp(r'^[A-Z]')));
      }
    });
  });
}
