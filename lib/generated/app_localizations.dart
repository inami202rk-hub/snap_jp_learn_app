import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Snap JP Learn'**
  String get appTitle;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Statistics page title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// Camera button label
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Gallery button label
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// OCR button label
  ///
  /// In en, this message translates to:
  /// **'Extract Text'**
  String get ocr;

  /// Sync button label
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message prefix
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Yes button label
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button label
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Previous button label
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Back button label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Offline status message
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Online status message
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error'**
  String get networkError;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// OCR error message
  ///
  /// In en, this message translates to:
  /// **'Failed to extract text from image'**
  String get ocrError;

  /// Sync error message
  ///
  /// In en, this message translates to:
  /// **'Synchronization failed'**
  String get syncError;

  /// Today's snap section title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Snap'**
  String get todaySnap;

  /// Home page subtitle
  ///
  /// In en, this message translates to:
  /// **'Snap diary and Japanese learning main screen'**
  String get snapDiaryAndJapaneseLearning;

  /// Main camera button description
  ///
  /// In en, this message translates to:
  /// **'Take a photo and start OCR'**
  String get takePhotoAndStartOCR;

  /// Success message after taking photo
  ///
  /// In en, this message translates to:
  /// **'Photo taken and OCR started'**
  String get photoTakenAndOCRStarted;

  /// Success message after OCR
  ///
  /// In en, this message translates to:
  /// **'Text extracted successfully'**
  String get textExtractedSuccessfully;

  /// Success message after sync
  ///
  /// In en, this message translates to:
  /// **'Synchronization completed'**
  String get synchronizationCompleted;

  /// OCR start button for screen reader
  ///
  /// In en, this message translates to:
  /// **'Start OCR'**
  String get startOCR;

  /// Sync button for screen reader
  ///
  /// In en, this message translates to:
  /// **'Synchronize data'**
  String get synchronizeData;

  /// Statistics button for screen reader
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get viewStatistics;

  /// Post list button for screen reader
  ///
  /// In en, this message translates to:
  /// **'View post list'**
  String get viewPostList;

  /// Card list button for screen reader
  ///
  /// In en, this message translates to:
  /// **'View card list'**
  String get viewCardList;

  /// Today's reviews statistic
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reviews'**
  String get todayReviews;

  /// Learning streak statistic
  ///
  /// In en, this message translates to:
  /// **'Learning Streak'**
  String get learningStreak;

  /// Total cards statistic
  ///
  /// In en, this message translates to:
  /// **'Total Cards'**
  String get totalCards;

  /// Week created cards statistic
  ///
  /// In en, this message translates to:
  /// **'Cards Created This Week'**
  String get weekCreatedCards;

  /// Days counter with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String days(int count);

  /// Cards counter with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 cards} =1{1 card} other{{count} cards}}'**
  String cards(int count);

  /// Reviews counter with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 reviews} =1{1 review} other{{count} reviews}}'**
  String reviews(int count);

  /// Message shown while syncing offline tasks
  ///
  /// In en, this message translates to:
  /// **'Syncing offline tasks...'**
  String get syncingOfflineTasks;

  /// Message shown when offline sync fails
  ///
  /// In en, this message translates to:
  /// **'Offline sync failed'**
  String get offlineSyncFailed;

  /// Message shown when offline sync completes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No offline tasks synced} =1{1 offline task synced} other{{count} offline tasks synced}}'**
  String offlineSyncCompleted(int count);

  /// Message showing number of queued offline tasks
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No offline tasks} =1{1 offline task queued} other{{count} offline tasks queued}}'**
  String offlineTasksQueued(int count);

  /// First onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Learn Japanese from Photos'**
  String get onboardTitle1;

  /// First onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'Take photos of Japanese text and turn them into learning cards instantly'**
  String get onboardDesc1;

  /// Second onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Extract Text with OCR'**
  String get onboardTitle2;

  /// Second onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'Our smart OCR technology recognizes Japanese characters accurately'**
  String get onboardDesc2;

  /// Third onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Study with SRS Cards'**
  String get onboardTitle3;

  /// Third onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'Review your cards using spaced repetition for effective learning'**
  String get onboardDesc3;

  /// Fourth onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardTitle4;

  /// Fourth onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'Monitor your learning journey with detailed statistics and insights'**
  String get onboardDesc4;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Tip about OCR lighting
  ///
  /// In en, this message translates to:
  /// **'💡 Better lighting improves OCR accuracy!'**
  String get tipsOcrLighting;

  /// Tip about camera angle
  ///
  /// In en, this message translates to:
  /// **'📐 Keep your phone parallel to the text for best results'**
  String get tipsOcrAngle;

  /// Tip about auto sync
  ///
  /// In en, this message translates to:
  /// **'🔄 Your data syncs automatically when online'**
  String get tipsSyncAuto;

  /// Tip about card review
  ///
  /// In en, this message translates to:
  /// **'📚 Review cards regularly to strengthen your memory'**
  String get tipsCardReview;

  /// Tip about offline mode
  ///
  /// In en, this message translates to:
  /// **'📱 You can learn even when offline!'**
  String get tipsOfflineMode;

  /// Setting to show tutorial again
  ///
  /// In en, this message translates to:
  /// **'Show tutorial again'**
  String get showTutorialAgain;

  /// Success message when tutorial is reset
  ///
  /// In en, this message translates to:
  /// **'Tutorial will be shown on next app launch'**
  String get tutorialResetSuccess;

  /// Title when post storage limit is reached
  ///
  /// In en, this message translates to:
  /// **'Storage Limit Reached'**
  String get lockPostLimitTitle;

  /// Description when post storage limit is reached
  ///
  /// In en, this message translates to:
  /// **'Free plan allows up to {count} saved posts. Upgrade to Pro for unlimited storage.'**
  String lockPostLimitDesc(int count);

  /// Title when daily OCR limit is reached
  ///
  /// In en, this message translates to:
  /// **'Daily OCR Limit Reached'**
  String get lockOcrLimitTitle;

  /// Description when daily OCR limit is reached
  ///
  /// In en, this message translates to:
  /// **'Free plan allows up to {count} OCR operations per day. Upgrade to Pro for unlimited OCR.'**
  String lockOcrLimitDesc(int count);

  /// Title when card creation limit is reached
  ///
  /// In en, this message translates to:
  /// **'Card Creation Limit Reached'**
  String get lockCardLimitTitle;

  /// Description when card creation limit is reached
  ///
  /// In en, this message translates to:
  /// **'Free plan allows up to {count} learning cards. Upgrade to Pro for unlimited cards.'**
  String lockCardLimitDesc(int count);

  /// Title when review history limit is reached
  ///
  /// In en, this message translates to:
  /// **'History Limit Reached'**
  String get lockHistoryLimitTitle;

  /// Description when review history limit is reached
  ///
  /// In en, this message translates to:
  /// **'Free plan allows up to {count} review sessions. Upgrade to Pro for unlimited history.'**
  String lockHistoryLimitDesc(int count);

  /// Generic title for locked features
  ///
  /// In en, this message translates to:
  /// **'Feature Locked'**
  String get lockFeatureTitle;

  /// Generic description for locked features
  ///
  /// In en, this message translates to:
  /// **'This feature requires Pro subscription. Upgrade to unlock all features.'**
  String get lockFeatureDesc;

  /// Button text to upgrade to Pro
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// Purchase button text
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// Restore purchases button text
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// Success message when purchases are restored
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully!'**
  String get restoreSuccess;

  /// Message when no purchases are found to restore
  ///
  /// In en, this message translates to:
  /// **'No purchases found to restore.'**
  String get restoreFailed;

  /// Error message when restore fails
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases'**
  String get restoreError;

  /// Terms of service link text
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Privacy policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// FAQ link text
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get frequentlyAskedQuestions;

  /// Information about subscription cancellation
  ///
  /// In en, this message translates to:
  /// **'You can cancel your subscription at any time in your device settings.'**
  String get subscriptionCancelInfo;

  /// Manage subscription button text
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// Instructions for managing subscription
  ///
  /// In en, this message translates to:
  /// **'To manage your subscription:\n\niOS: Settings > [Your Name] > Subscriptions\nAndroid: Play Store > Menu > Subscriptions'**
  String get subscriptionManagementInstructions;

  /// Pro features section title
  ///
  /// In en, this message translates to:
  /// **'Pro Features'**
  String get proFeatures;

  /// Unlimited posts feature description
  ///
  /// In en, this message translates to:
  /// **'Unlimited posts and cards'**
  String get unlimitedPosts;

  /// Advanced OCR feature description
  ///
  /// In en, this message translates to:
  /// **'Advanced OCR processing'**
  String get advancedOcr;

  /// Cloud backup feature description
  ///
  /// In en, this message translates to:
  /// **'Cloud backup & sync'**
  String get cloudBackup;

  /// Detailed statistics feature description
  ///
  /// In en, this message translates to:
  /// **'Detailed statistics'**
  String get detailedStats;

  /// Custom themes feature description
  ///
  /// In en, this message translates to:
  /// **'Custom themes'**
  String get customThemes;

  /// Current usage label
  ///
  /// In en, this message translates to:
  /// **'Current Usage'**
  String get currentUsage;

  /// Remaining usage label
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// Subscription management section title
  ///
  /// In en, this message translates to:
  /// **'Subscription Management'**
  String get subscriptionManagement;

  /// Usage data section title
  ///
  /// In en, this message translates to:
  /// **'Usage Data'**
  String get usageData;

  /// Usage data description
  ///
  /// In en, this message translates to:
  /// **'View your app usage statistics. All data is stored locally and never sent externally.'**
  String get usageDataDescription;

  /// Button to view usage data
  ///
  /// In en, this message translates to:
  /// **'View Usage Data'**
  String get viewUsageData;

  /// Usage summary section title
  ///
  /// In en, this message translates to:
  /// **'Usage Summary'**
  String get usageSummary;

  /// Daily usage chart title
  ///
  /// In en, this message translates to:
  /// **'Daily Usage Chart'**
  String get dailyUsageChart;

  /// Feature usage list title
  ///
  /// In en, this message translates to:
  /// **'Feature Usage'**
  String get featureUsageList;

  /// Reset usage data button
  ///
  /// In en, this message translates to:
  /// **'Reset Usage Data'**
  String get resetUsageData;

  /// Reset usage data description
  ///
  /// In en, this message translates to:
  /// **'Delete all usage data. This action cannot be undone.'**
  String get resetUsageDataDescription;

  /// Reset data button
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// Reset usage data confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all usage data? This action cannot be undone.'**
  String get resetUsageDataConfirm;

  /// Reset success message
  ///
  /// In en, this message translates to:
  /// **'Data has been reset successfully'**
  String get resetSuccess;

  /// Usage data privacy notice
  ///
  /// In en, this message translates to:
  /// **'All usage data is stored locally and never sent to external servers.'**
  String get usageDataPrivacyNotice;

  /// No usage data message
  ///
  /// In en, this message translates to:
  /// **'No usage data available'**
  String get noUsageData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
