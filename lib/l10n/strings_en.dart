/// English strings for store review and user interface
/// This file contains English text constants for app review purposes
class AppStrings {
  // Permission related messages
  static const String cameraPermissionDeniedTitle =
      'Camera Permission Required';
  static const String cameraPermissionDeniedMessage =
      'Snap JP Learn needs camera access to extract Japanese text from photos. '
      'Please enable camera permission in Settings to use this feature.';
  static const String photoPermissionDeniedTitle =
      'Photo Library Permission Required';
  static const String photoPermissionDeniedMessage =
      'Snap JP Learn needs photo library access to select images for text extraction. '
      'Please enable photo library permission in Settings to use this feature.';
  static const String openSettings = 'Open Settings';
  static const String cancel = 'Cancel';

  // Error messages
  static const String networkErrorTitle = 'Network Error';
  static const String networkErrorMessage =
      'Please check your internet connection and try again.';
  static const String ocrErrorTitle = 'Text Recognition Failed';
  static const String ocrErrorMessage =
      'Could not extract text from the image. Please try with a clearer image.';
  static const String saveErrorTitle = 'Save Failed';
  static const String saveErrorMessage =
      'Failed to save your data. Please try again.';
  static const String imageTooLargeTitle = 'Image Too Large';
  static const String imageTooLargeMessage =
      'The selected image is too large. Please choose a smaller image.';
  static const String processingTimeoutTitle = 'Processing Timeout';
  static const String processingTimeoutMessage =
      'Processing is taking longer than expected. Please try again.';

  // General messages
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String loading = 'Processing...';
  static const String success = 'Success';
  static const String error = 'Error';

  // Premium/Paywall messages
  static const String premiumRequiredTitle = 'Premium Required';
  static const String premiumRequiredMessage =
      'This feature requires Snap JP Learn Pro. Upgrade now for unlimited cards and advanced features.';
  static const String upgradeNow = 'Upgrade Now';
  static const String restorePurchases = 'Restore Purchases';
  static const String purchaseSuccessMessage =
      'Purchase successful! Premium features are now available.';
  static const String purchaseFailedMessage =
      'Purchase failed. Please try again.';
  static const String purchaseCancelledMessage = 'Purchase was cancelled.';

  // Onboarding messages
  static const String welcomeTitle = 'Welcome to Snap JP Learn';
  static const String welcomeMessage =
      'Learn Japanese from your daily photos. Take pictures of Japanese text and turn them into study cards.';
  static const String permissionExplanationTitle = 'Why We Need Permissions';
  static const String cameraPermissionExplanation =
      'Camera access is needed to capture photos of Japanese text for learning.';
  static const String photoPermissionExplanation =
      'Photo library access is needed to select existing images for text extraction.';
  static const String allowPermission = 'Allow Permission';
  static const String skipForNow = 'Skip for Now';
}
