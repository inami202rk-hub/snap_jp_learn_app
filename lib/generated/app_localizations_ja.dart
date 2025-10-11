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

  @override
  String get syncingOfflineTasks => 'オフラインタスクを同期中...';

  @override
  String get offlineSyncFailed => 'オフライン同期に失敗しました';

  @override
  String offlineSyncCompleted(int count) {
    return '$count件のオフラインタスクを同期しました';
  }

  @override
  String offlineTasksQueued(int count) {
    return '$count件のオフラインタスクがキューに保存されています';
  }

  @override
  String get onboardTitle1 => '写真から日本語を学ぶ';

  @override
  String get onboardDesc1 => '日本語のテキストを写真に撮って、すぐに学習カードに変換できます';

  @override
  String get onboardTitle2 => 'OCRで文字を抽出';

  @override
  String get onboardDesc2 => 'スマートOCR技術が日本語文字を正確に認識します';

  @override
  String get onboardTitle3 => 'カードで学習を続ける';

  @override
  String get onboardDesc3 => '間隔反復学習で効果的にカードを復習できます';

  @override
  String get onboardTitle4 => 'あなたの学びを記録しよう';

  @override
  String get onboardDesc4 => '詳細な統計とインサイトで学習の進歩を追跡できます';

  @override
  String get getStarted => 'はじめる';

  @override
  String get skip => 'スキップ';

  @override
  String get tipsOcrLighting => '💡 照明を明るくするとOCR精度が上がります！';

  @override
  String get tipsOcrAngle => '📐 テキストに平行にスマホをかまえると良い結果が得られます';

  @override
  String get tipsSyncAuto => '🔄 オンライン時にデータが自動同期されます';

  @override
  String get tipsCardReview => '📚 定期的にカードを復習して記憶を強化しましょう';

  @override
  String get tipsOfflineMode => '📱 オフラインでも学習できます！';

  @override
  String get showTutorialAgain => 'チュートリアルをもう一度見る';

  @override
  String get tutorialResetSuccess => '次回アプリ起動時にチュートリアルが表示されます';

  @override
  String get lockPostLimitTitle => '保存上限に達しました';

  @override
  String lockPostLimitDesc(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '無料プランでは$countString件まで投稿を保存できます。Pro版で無制限保存を利用しましょう。';
  }

  @override
  String get lockOcrLimitTitle => '1日のOCR上限に達しました';

  @override
  String lockOcrLimitDesc(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '無料プランでは1日$countString回までOCRを実行できます。Pro版で無制限OCRを利用しましょう。';
  }

  @override
  String get lockCardLimitTitle => 'カード作成上限に達しました';

  @override
  String lockCardLimitDesc(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '無料プランでは$countString枚まで学習カードを作成できます。Pro版で無制限カードを作成しましょう。';
  }

  @override
  String get lockHistoryLimitTitle => '履歴上限に達しました';

  @override
  String lockHistoryLimitDesc(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '無料プランでは$countString回まで学習履歴を保存できます。Pro版で無制限履歴を利用しましょう。';
  }

  @override
  String get lockFeatureTitle => '機能がロックされています';

  @override
  String get lockFeatureDesc =>
      'この機能はPro版サブスクリプションが必要です。全機能を解放するためにアップグレードしましょう。';

  @override
  String get upgradeToPro => 'Pro版にアップグレード';

  @override
  String get purchase => '購入';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get restoreSuccess => '購入が正常に復元されました！';

  @override
  String get restoreFailed => '復元できる購入が見つかりませんでした。';

  @override
  String get restoreError => '購入の復元に失敗しました';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get frequentlyAskedQuestions => 'よくある質問';

  @override
  String get subscriptionCancelInfo => 'デバイス設定からいつでもサブスクリプションをキャンセルできます。';

  @override
  String get manageSubscription => 'サブスクリプションを管理';

  @override
  String get subscriptionManagementInstructions =>
      'サブスクリプションの管理方法：\n\niOS: 設定 > [あなたの名前] > サブスクリプション\nAndroid: Playストア > メニュー > サブスクリプション';

  @override
  String get proFeatures => 'Pro機能';

  @override
  String get unlimitedPosts => '無制限の投稿とカード';

  @override
  String get advancedOcr => '高度なOCR処理';

  @override
  String get cloudBackup => 'クラウドバックアップと同期';

  @override
  String get detailedStats => '詳細統計';

  @override
  String get customThemes => 'カスタムテーマ';

  @override
  String get currentUsage => '現在の使用量';

  @override
  String get remaining => '残り';

  @override
  String get subscriptionManagement => 'サブスクリプション管理';
}
