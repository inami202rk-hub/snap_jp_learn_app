import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/entitlements.dart';
import '../generated/app_localizations.dart';
import '../services/entitlement_service.dart';
import '../services/purchase_service.dart';
import '../pages/paywall_page.dart';

/// 機能ロック時に表示するボトムシート
class LockSheet extends StatelessWidget {
  final Feature lockedFeature;
  final UsageStats usageStats;
  final VoidCallback? onUnlocked;

  const LockSheet({
    super.key,
    required this.lockedFeature,
    required this.usageStats,
    this.onUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final limitInfo = EntitlementsManager.getFeatureLimitInfo(
      lockedFeature,
      usageStats,
      false, // ロックシートが表示される時点でProではない
    );

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ハンドル
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // コンテンツ
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // タイトル
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: colorScheme.error,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getLockTitle(l10n),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 使用状況表示
                if (!limitInfo.isUnlimited) ...[
                  _buildUsageIndicator(theme, colorScheme, limitInfo),
                  const SizedBox(height: 16),
                ],

                // 機能説明
                Text(
                  _getLockDescription(l10n, limitInfo),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 24),

                // Pro版のメリット
                _buildProBenefits(theme, colorScheme),

                const SizedBox(height: 24),

                // アクションボタン
                _buildActionButtons(context, colorScheme, l10n),

                const SizedBox(height: 16),

                // 復元ボタン
                _buildRestoreButton(context, colorScheme, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageIndicator(
    ThemeData theme,
    ColorScheme colorScheme,
    FeatureLimitInfo limitInfo,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Usage',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${limitInfo.currentUsage}/${limitInfo.maxUsage}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: limitInfo.isLocked
                      ? colorScheme.error
                      : colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: limitInfo.usageRatio,
            backgroundColor: colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              limitInfo.isLocked ? colorScheme.error : colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${limitInfo.remainingUsage} remaining',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProBenefits(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Pro Benefits',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(theme, colorScheme, 'Unlimited posts and cards'),
          _buildBenefitItem(theme, colorScheme, 'Advanced OCR processing'),
          _buildBenefitItem(theme, colorScheme, 'Cloud backup & sync'),
          _buildBenefitItem(theme, colorScheme, 'Detailed statistics'),
          _buildBenefitItem(theme, colorScheme, 'Custom themes'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
      ThemeData theme, ColorScheme colorScheme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: colorScheme.outline),
            ),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => _openPaywall(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
            child: Text(
              l10n?.upgradeToPro ?? 'Upgrade to Pro',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestoreButton(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations? l10n,
  ) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _restorePurchases(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          l10n?.restorePurchases ?? 'Restore Purchases',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getLockTitle(AppLocalizations? l10n) {
    switch (lockedFeature) {
      case Feature.postStorage:
        return l10n?.lockPostLimitTitle ?? 'Storage Limit Reached';
      case Feature.ocrExecution:
        return l10n?.lockOcrLimitTitle ?? 'Daily OCR Limit Reached';
      case Feature.cardCreation:
        return l10n?.lockCardLimitTitle ?? 'Card Creation Limit Reached';
      case Feature.reviewHistory:
        return l10n?.lockHistoryLimitTitle ?? 'History Limit Reached';
      default:
        return l10n?.lockFeatureTitle ?? 'Feature Locked';
    }
  }

  String _getLockDescription(
      AppLocalizations? l10n, FeatureLimitInfo limitInfo) {
    switch (lockedFeature) {
      case Feature.postStorage:
        return l10n?.lockPostLimitDesc(limitInfo.maxUsage) ??
            'Free plan allows up to ${limitInfo.maxUsage} saved posts.';
      case Feature.ocrExecution:
        return l10n?.lockOcrLimitDesc(limitInfo.maxUsage) ??
            'Free plan allows up to ${limitInfo.maxUsage} OCR operations per day.';
      case Feature.cardCreation:
        return l10n?.lockCardLimitDesc(limitInfo.maxUsage) ??
            'Free plan allows up to ${limitInfo.maxUsage} learning cards.';
      case Feature.reviewHistory:
        return l10n?.lockHistoryLimitDesc(limitInfo.maxUsage) ??
            'Free plan allows up to ${limitInfo.maxUsage} review sessions.';
      default:
        return l10n?.lockFeatureDesc ??
            'This feature requires Pro subscription.';
    }
  }

  void _openPaywall(BuildContext context) {
    Navigator.of(context).pop(); // LockSheetを閉じる
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const PaywallPage(),
      ),
    )
        .then((_) {
      // Paywallから戻ってきた時にロック解除をチェック
      _checkUnlockStatus(context);
    });
  }

  void _restorePurchases(BuildContext context) async {
    final purchaseService =
        Provider.of<PurchaseService>(context, listen: false);

    try {
      // ローディング表示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await purchaseService.restorePurchases();

      Navigator.of(context).pop(); // ローディングを閉じる

      if (success) {
        // 復元成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.restoreSuccess ??
                  'Purchases restored successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // ロック解除をチェック
        _checkUnlockStatus(context);
      } else {
        // 復元失敗
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.restoreFailed ??
                  'No purchases found to restore.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // ローディングを閉じる

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.restoreError ??
                'Failed to restore purchases: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkUnlockStatus(BuildContext context) {
    EntitlementService.checkEntitlementStatus().then((isPro) {
      if (isPro && onUnlocked != null) {
        // Pro版になったので元の操作を実行
        onUnlocked!();
      }
    });
  }
}
