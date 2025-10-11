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
}
