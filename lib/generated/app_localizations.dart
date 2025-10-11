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

  /// Cancel button label
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

  /// Close button label
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Done button label
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Next button label
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
