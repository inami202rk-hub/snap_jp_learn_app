/// 課金関連の定数
class BillingConstants {
  // 商品ID
  static const String proMonthlyId = 'pro_monthly';
  static const String proLifetimeId = 'pro_lifetime';

  // 商品セット（実際の商品IDリスト）
  static const Set<String> productIds = {
    proMonthlyId,
    proLifetimeId,
  };

  // 商品表示名
  static const String proMonthlyName = 'Pro月額プラン';
  static const String proLifetimeName = 'Pro買い切りプラン';

  // 商品説明（ストア審査対応）
  static const String proMonthlyDescription =
      '月額サブスクリプション（自動更新）。購入後24時間以内にApp Store設定からキャンセル可能。';
  static const String proLifetimeDescription = '一度の購入でPro機能を永続利用（自動更新なし）';

  // 機能説明
  static const String proFeaturesTitle = 'Pro機能';
  static const List<String> proFeatures = [
    '📚 カード作成数無制限',
    '🔄 自動復習スケジュール',
    '📊 詳細な学習統計',
    '🎯 カスタム学習設定',
    '☁️ データバックアップ',
    '🚀 将来のAI機能（予定）',
  ];

  // エラーメッセージ
  static const String errorNetworkUnavailable = 'ネットワークに接続できません';
  static const String errorPurchaseFailed = '購入に失敗しました';
  static const String errorPurchaseCancelled = '購入がキャンセルされました';
  static const String errorRestoreFailed = '復元に失敗しました';
  static const String errorProductNotFound = '商品が見つかりません';
  static const String errorAlreadyOwned = '既に購入済みです';

  // 成功メッセージ
  static const String successPurchaseCompleted = '購入が完了しました！';
  static const String successRestoreCompleted = '復元が完了しました！';
}
