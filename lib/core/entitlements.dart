/// アプリの機能制限とPro版の権限管理
/// 無料枠の上限設定とPro版での機能解放を管理
library;

/// アプリの機能一覧
enum Feature {
  /// 投稿保存機能
  postStorage,

  /// OCR実行機能
  ocrExecution,

  /// 学習カード作成機能
  cardCreation,

  /// 学習履歴保存機能
  reviewHistory,

  /// バックアップ機能
  backup,

  /// 詳細統計表示機能
  detailedStats,

  /// カスタムテーマ機能
  customTheme,
}

/// 使用状況統計
class UsageStats {
  final int savedPostsCount;
  final int todayOcrCount;
  final int createdCardsCount;
  final int reviewSessionsCount;
  final DateTime lastOcrDate;

  const UsageStats({
    required this.savedPostsCount,
    required this.todayOcrCount,
    required this.createdCardsCount,
    required this.reviewSessionsCount,
    required this.lastOcrDate,
  });

  /// 今日のOCR実行回数をリセット
  UsageStats copyWith({
    int? savedPostsCount,
    int? todayOcrCount,
    int? createdCardsCount,
    int? reviewSessionsCount,
    DateTime? lastOcrDate,
  }) {
    return UsageStats(
      savedPostsCount: savedPostsCount ?? this.savedPostsCount,
      todayOcrCount: todayOcrCount ?? this.todayOcrCount,
      createdCardsCount: createdCardsCount ?? this.createdCardsCount,
      reviewSessionsCount: reviewSessionsCount ?? this.reviewSessionsCount,
      lastOcrDate: lastOcrDate ?? this.lastOcrDate,
    );
  }
}

/// 無料枠の制限ポリシー
class FreeTierPolicy {
  /// 保存できる投稿の上限
  static const int maxSavedPosts = 50;

  /// 1日のOCR実行上限
  static const int maxDailyOcr = 10;

  /// 作成できる学習カードの上限
  static const int maxCreatedCards = 500;

  /// 学習セッション履歴の保存上限
  static const int maxReviewSessions = 1000;

  /// 無料枠で利用可能な機能
  static const Set<Feature> freeFeatures = {
    Feature.postStorage,
    Feature.ocrExecution,
    Feature.cardCreation,
    Feature.reviewHistory,
  };

  /// Pro版でのみ利用可能な機能
  static const Set<Feature> proOnlyFeatures = {
    Feature.backup,
    Feature.detailedStats,
    Feature.customTheme,
  };
}

/// 権限管理クラス
class EntitlementsManager {
  /// 機能がロックされているかチェック
  static bool isFeatureLocked(
    Feature feature,
    UsageStats stats,
    bool isPro,
  ) {
    // Pro版ユーザーは全ての機能が利用可能
    if (isPro) {
      return false;
    }

    // 無料枠でのみ利用可能な機能は制限なし
    if (FreeTierPolicy.freeFeatures.contains(feature)) {
      return _checkFreeTierLimits(feature, stats);
    }

    // Pro版専用機能は無料ユーザーにはロック
    if (FreeTierPolicy.proOnlyFeatures.contains(feature)) {
      return true;
    }

    return false;
  }

  /// 無料枠の制限チェック
  static bool _checkFreeTierLimits(Feature feature, UsageStats stats) {
    final now = DateTime.now();
    final isNewDay = now.difference(stats.lastOcrDate).inDays >= 1;

    switch (feature) {
      case Feature.postStorage:
        return stats.savedPostsCount >= FreeTierPolicy.maxSavedPosts;

      case Feature.ocrExecution:
        // 新しい日ならOCR回数をリセット
        if (isNewDay) {
          return false; // 実際のリセットは呼び出し側で行う
        }
        return stats.todayOcrCount >= FreeTierPolicy.maxDailyOcr;

      case Feature.cardCreation:
        return stats.createdCardsCount >= FreeTierPolicy.maxCreatedCards;

      case Feature.reviewHistory:
        return stats.reviewSessionsCount >= FreeTierPolicy.maxReviewSessions;

      default:
        return false;
    }
  }

  /// 機能の制限情報を取得
  static FeatureLimitInfo getFeatureLimitInfo(
    Feature feature,
    UsageStats stats,
    bool isPro,
  ) {
    if (isPro) {
      return FeatureLimitInfo(
        isLocked: false,
        currentUsage: 0,
        maxUsage: 0,
        isUnlimited: true,
      );
    }

    switch (feature) {
      case Feature.postStorage:
        return FeatureLimitInfo(
          isLocked: stats.savedPostsCount >= FreeTierPolicy.maxSavedPosts,
          currentUsage: stats.savedPostsCount,
          maxUsage: FreeTierPolicy.maxSavedPosts,
          isUnlimited: false,
        );

      case Feature.ocrExecution:
        final now = DateTime.now();
        final isNewDay = now.difference(stats.lastOcrDate).inDays >= 1;
        return FeatureLimitInfo(
          isLocked:
              !isNewDay && stats.todayOcrCount >= FreeTierPolicy.maxDailyOcr,
          currentUsage: isNewDay ? 0 : stats.todayOcrCount,
          maxUsage: FreeTierPolicy.maxDailyOcr,
          isUnlimited: false,
        );

      case Feature.cardCreation:
        return FeatureLimitInfo(
          isLocked: stats.createdCardsCount >= FreeTierPolicy.maxCreatedCards,
          currentUsage: stats.createdCardsCount,
          maxUsage: FreeTierPolicy.maxCreatedCards,
          isUnlimited: false,
        );

      case Feature.reviewHistory:
        return FeatureLimitInfo(
          isLocked:
              stats.reviewSessionsCount >= FreeTierPolicy.maxReviewSessions,
          currentUsage: stats.reviewSessionsCount,
          maxUsage: FreeTierPolicy.maxReviewSessions,
          isUnlimited: false,
        );

      default:
        return FeatureLimitInfo(
          isLocked: true,
          currentUsage: 0,
          maxUsage: 0,
          isUnlimited: false,
        );
    }
  }

  /// 機能の表示名を取得
  static String getFeatureDisplayName(Feature feature) {
    switch (feature) {
      case Feature.postStorage:
        return 'Post Storage';
      case Feature.ocrExecution:
        return 'OCR Processing';
      case Feature.cardCreation:
        return 'Card Creation';
      case Feature.reviewHistory:
        return 'Review History';
      case Feature.backup:
        return 'Backup & Sync';
      case Feature.detailedStats:
        return 'Detailed Statistics';
      case Feature.customTheme:
        return 'Custom Themes';
    }
  }

  /// 機能の説明を取得
  static String getFeatureDescription(Feature feature) {
    switch (feature) {
      case Feature.postStorage:
        return 'Save and organize your Japanese text posts';
      case Feature.ocrExecution:
        return 'Extract text from images using OCR technology';
      case Feature.cardCreation:
        return 'Create learning cards from your posts';
      case Feature.reviewHistory:
        return 'Track your learning progress and history';
      case Feature.backup:
        return 'Backup your data to the cloud and sync across devices';
      case Feature.detailedStats:
        return 'View detailed statistics and learning insights';
      case Feature.customTheme:
        return 'Customize app appearance with themes';
    }
  }
}

/// 機能の制限情報
class FeatureLimitInfo {
  final bool isLocked;
  final int currentUsage;
  final int maxUsage;
  final bool isUnlimited;

  const FeatureLimitInfo({
    required this.isLocked,
    required this.currentUsage,
    required this.maxUsage,
    required this.isUnlimited,
  });

  /// 使用率を取得（0.0 - 1.0）
  double get usageRatio {
    if (isUnlimited || maxUsage == 0) return 0.0;
    return (currentUsage / maxUsage).clamp(0.0, 1.0);
  }

  /// 残り使用可能回数
  int get remainingUsage {
    if (isUnlimited) return -1; // 無制限
    return (maxUsage - currentUsage).clamp(0, maxUsage);
  }
}
