import 'package:flutter/material.dart';
import 'package:snap_jp_learn_app/l10n/strings_en.dart';

/// Common error toast widget for consistent error messaging
class ErrorToast {
  static void show(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: AppStrings.retry,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show network error toast
  static void showNetworkError(BuildContext context) {
    show(
      context,
      AppStrings.networkErrorTitle,
      AppStrings.networkErrorMessage,
    );
  }

  /// Show OCR error toast
  static void showOcrError(BuildContext context) {
    show(
      context,
      AppStrings.ocrErrorTitle,
      AppStrings.ocrErrorMessage,
    );
  }

  /// Show save error toast
  static void showSaveError(BuildContext context) {
    show(
      context,
      AppStrings.saveErrorTitle,
      AppStrings.saveErrorMessage,
    );
  }

  /// Show image too large error toast
  static void showImageTooLarge(BuildContext context) {
    show(
      context,
      AppStrings.imageTooLargeTitle,
      AppStrings.imageTooLargeMessage,
    );
  }

  /// Show processing timeout error toast
  static void showProcessingTimeout(BuildContext context) {
    show(
      context,
      AppStrings.processingTimeoutTitle,
      AppStrings.processingTimeoutMessage,
    );
  }

  /// Show success toast
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
