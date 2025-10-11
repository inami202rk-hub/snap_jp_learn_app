// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Snap JP Learn';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get stats => 'Statistics';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get ocr => 'Extract Text';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get back => 'Back';

  @override
  String get offline => 'Offline';

  @override
  String get online => 'Online';

  @override
  String get networkError => 'Network error';

  @override
  String get serverError => 'Server error';

  @override
  String get ocrError => 'Failed to extract text from image';

  @override
  String get syncError => 'Synchronization failed';

  @override
  String get todaySnap => 'Today\'s Snap';

  @override
  String get snapDiaryAndJapaneseLearning =>
      'Snap diary and Japanese learning main screen';

  @override
  String get takePhotoAndStartOCR => 'Take a photo and start OCR';

  @override
  String get photoTakenAndOCRStarted => 'Photo taken and OCR started';

  @override
  String get textExtractedSuccessfully => 'Text extracted successfully';

  @override
  String get synchronizationCompleted => 'Synchronization completed';

  @override
  String get startOCR => 'Start OCR';

  @override
  String get synchronizeData => 'Synchronize data';

  @override
  String get viewStatistics => 'View statistics';

  @override
  String get viewPostList => 'View post list';

  @override
  String get viewCardList => 'View card list';

  @override
  String get todayReviews => 'Today\'s Reviews';

  @override
  String get learningStreak => 'Learning Streak';

  @override
  String get totalCards => 'Total Cards';

  @override
  String get weekCreatedCards => 'Cards Created This Week';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String cards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
      zero: '0 cards',
    );
    return '$_temp0';
  }

  @override
  String reviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: '0 reviews',
    );
    return '$_temp0';
  }

  @override
  String get syncingOfflineTasks => 'Syncing offline tasks...';

  @override
  String get offlineSyncFailed => 'Offline sync failed';

  @override
  String offlineSyncCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offline tasks synced',
      one: '1 offline task synced',
      zero: 'No offline tasks synced',
    );
    return '$_temp0';
  }

  @override
  String offlineTasksQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offline tasks queued',
      one: '1 offline task queued',
      zero: 'No offline tasks',
    );
    return '$_temp0';
  }

  @override
  String get onboardTitle1 => 'Learn Japanese from Photos';

  @override
  String get onboardDesc1 =>
      'Take photos of Japanese text and turn them into learning cards instantly';

  @override
  String get onboardTitle2 => 'Extract Text with OCR';

  @override
  String get onboardDesc2 =>
      'Our smart OCR technology recognizes Japanese characters accurately';

  @override
  String get onboardTitle3 => 'Study with SRS Cards';

  @override
  String get onboardDesc3 =>
      'Review your cards using spaced repetition for effective learning';

  @override
  String get onboardTitle4 => 'Track Your Progress';

  @override
  String get onboardDesc4 =>
      'Monitor your learning journey with detailed statistics and insights';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get tipsOcrLighting => '💡 Better lighting improves OCR accuracy!';

  @override
  String get tipsOcrAngle =>
      '📐 Keep your phone parallel to the text for best results';

  @override
  String get tipsSyncAuto => '🔄 Your data syncs automatically when online';

  @override
  String get tipsCardReview =>
      '📚 Review cards regularly to strengthen your memory';

  @override
  String get tipsOfflineMode => '📱 You can learn even when offline!';

  @override
  String get showTutorialAgain => 'Show tutorial again';

  @override
  String get tutorialResetSuccess =>
      'Tutorial will be shown on next app launch';

  @override
  String get lockPostLimitTitle => 'Storage Limit Reached';

  @override
  String lockPostLimitDesc(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Free plan allows up to $countString saved posts. Upgrade to Pro for unlimited storage.';
  }

  @override
  String get lockOcrLimitTitle => 'Daily OCR Limit Reached';

  @override
  String lockOcrLimitDesc(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Free plan allows up to $countString OCR operations per day. Upgrade to Pro for unlimited OCR.';
  }

  @override
  String get lockCardLimitTitle => 'Card Creation Limit Reached';

  @override
  String lockCardLimitDesc(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Free plan allows up to $countString learning cards. Upgrade to Pro for unlimited cards.';
  }

  @override
  String get lockHistoryLimitTitle => 'History Limit Reached';

  @override
  String lockHistoryLimitDesc(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return 'Free plan allows up to $countString review sessions. Upgrade to Pro for unlimited history.';
  }

  @override
  String get lockFeatureTitle => 'Feature Locked';

  @override
  String get lockFeatureDesc =>
      'This feature requires Pro subscription. Upgrade to unlock all features.';

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get purchase => 'Purchase';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get restoreSuccess => 'Purchases restored successfully!';

  @override
  String get restoreFailed => 'No purchases found to restore.';

  @override
  String get restoreError => 'Failed to restore purchases';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get frequentlyAskedQuestions => 'Frequently Asked Questions';

  @override
  String get subscriptionCancelInfo =>
      'You can cancel your subscription at any time in your device settings.';

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String get subscriptionManagementInstructions =>
      'To manage your subscription:\n\niOS: Settings > [Your Name] > Subscriptions\nAndroid: Play Store > Menu > Subscriptions';

  @override
  String get proFeatures => 'Pro Features';

  @override
  String get unlimitedPosts => 'Unlimited posts and cards';

  @override
  String get advancedOcr => 'Advanced OCR processing';

  @override
  String get cloudBackup => 'Cloud backup & sync';

  @override
  String get detailedStats => 'Detailed statistics';

  @override
  String get customThemes => 'Custom themes';

  @override
  String get currentUsage => 'Current Usage';

  @override
  String get remaining => 'remaining';

  @override
  String get subscriptionManagement => 'Subscription Management';

  @override
  String get usageData => 'Usage Data';

  @override
  String get usageDataDescription =>
      'View your app usage statistics. All data is stored locally and never sent externally.';

  @override
  String get viewUsageData => 'View Usage Data';

  @override
  String get usageSummary => 'Usage Summary';

  @override
  String get dailyUsageChart => 'Daily Usage Chart';

  @override
  String get featureUsageList => 'Feature Usage';

  @override
  String get resetUsageData => 'Reset Usage Data';

  @override
  String get resetUsageDataDescription =>
      'Delete all usage data. This action cannot be undone.';

  @override
  String get resetData => 'Reset Data';

  @override
  String get resetUsageDataConfirm =>
      'Are you sure you want to delete all usage data? This action cannot be undone.';

  @override
  String get resetSuccess => 'Data has been reset successfully';

  @override
  String get usageDataPrivacyNotice =>
      'All usage data is stored locally and never sent to external servers.';

  @override
  String get noUsageData => 'No usage data available';
}
