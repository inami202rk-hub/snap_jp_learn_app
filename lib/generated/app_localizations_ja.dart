// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'スナップ日本学習';

  @override
  String get home => 'ホーム';

  @override
  String get settings => '設定';

  @override
  String get stats => '統計';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get ocr => '文字を抽出';

  @override
  String get syncNow => '同期する';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラー';

  @override
  String get retry => '再試行';

  @override
  String get cancel => 'キャンセル';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get close => '閉じる';

  @override
  String get done => '完了';

  @override
  String get next => '次へ';

  @override
  String get previous => '前へ';

  @override
  String get back => '戻る';

  @override
  String get offline => 'オフラインです';

  @override
  String get online => 'インターネットに接続されました';

  @override
  String get networkError => 'ネットワークに接続されていません';

  @override
  String get serverError => 'サーバーでエラーが発生しました';

  @override
  String get ocrError => '画像の読み取りに失敗しました';

  @override
  String get syncError => '同期に失敗しました';

  @override
  String get todaySnap => '今日のスナップ';

  @override
  String get snapDiaryAndJapaneseLearning => 'スナップ日記と日本語学習のメイン画面';

  @override
  String get takePhotoAndStartOCR => '写真を撮ってOCR';

  @override
  String get photoTakenAndOCRStarted => '写真を撮影してOCR処理を開始しました';

  @override
  String get textExtractedSuccessfully => 'テキストの抽出が完了しました';

  @override
  String get synchronizationCompleted => '同期が完了しました';

  @override
  String get startOCR => 'OCRを開始';

  @override
  String get synchronizeData => 'データを同期';

  @override
  String get viewStatistics => '統計を表示';

  @override
  String get viewPostList => '投稿一覧を表示';

  @override
  String get viewCardList => 'カード一覧を表示';

  @override
  String get todayReviews => '今日のレビュー';

  @override
  String get learningStreak => '学習ストリーク';

  @override
  String get totalCards => '総カード数';

  @override
  String get weekCreatedCards => '今週作成したカード';

  @override
  String days(int count) {
    return '$count日';
  }

  @override
  String cards(int count) {
    return '$count枚のカード';
  }

  @override
  String reviews(int count) {
    return '$count回のレビュー';
  }
}
