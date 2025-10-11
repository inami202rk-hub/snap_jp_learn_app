import 'package:shared_preferences/shared_preferences.dart';
import 'purchase_service.dart';
import '../models/purchase_results.dart';
import 'log_service.dart';

/// Pro機能のエンタイトルメント管理サービス
class EntitlementService {
  static const String _isProUserKey = 'is_pro_user';
  static const String _proPurchaseDateKey = 'pro_purchase_date';
  static const String _proProductIdKey = 'pro_product_id';

  /// Proユーザーかどうかを確認
  static Future<bool> isPro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isProUserKey) ?? false;
  }

  /// Pro状態を設定
  static Future<void> setPro(bool isPro, {String? productId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isProUserKey, isPro);

    if (isPro) {
      await prefs.setString(
          _proPurchaseDateKey, DateTime.now().toIso8601String());
      if (productId != null) {
        await prefs.setString(_proProductIdKey, productId);
      }
    } else {
      await prefs.remove(_proPurchaseDateKey);
      await prefs.remove(_proProductIdKey);
    }
  }

  /// Pro購入日時を取得
  static Future<DateTime?> getProPurchaseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_proPurchaseDateKey);
    if (dateString != null) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Pro商品IDを取得
  static Future<String?> getProProductId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_proProductIdKey);
  }

  /// Pro状態をリセット（デバッグ用）
  static Future<void> resetProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isProUserKey);
    await prefs.remove(_proPurchaseDateKey);
    await prefs.remove(_proProductIdKey);
  }

  /// 月額サブスクリプションの有効期限をチェック（将来の拡張用）
  static Future<bool> isSubscriptionValid() async {
    final isPro = await EntitlementService.isPro();
    if (!isPro) return false;

    final productId = await getProProductId();
    if (productId == null) return true; // 買い切りプランの場合

    // 月額プランの場合（将来の実装）
    if (productId == 'pro_monthly') {
      final purchaseDate = await getProPurchaseDate();
      if (purchaseDate == null) return false;

      // 30日以内かチェック
      final now = DateTime.now();
      final daysSincePurchase = now.difference(purchaseDate).inDays;
      return daysSincePurchase < 30;
    }

    return true; // 買い切りプランは常に有効
  }

  /// 起動時のエンタイトルメント自己修復
  static Future<bool> verifyAndRepairEntitlement() async {
    try {
      final purchaseService = PurchaseService();
      await purchaseService.initialize();

      // 過去の購入を確認
      final restoreResult = await purchaseService.verifyPastPurchases();

      switch (restoreResult) {
        case RestoreSuccess():
          // 購入履歴がある場合、Pro状態に設定
          final currentProStatus = await isPro();
          if (!currentProStatus) {
            await setPro(true, productId: 'restored');
            return true; // 修復が行われた
          }
          return false; // 既にPro状態

        case RestoreNoItems():
          // 購入履歴がない場合、Pro状態を解除
          final currentProStatus = await isPro();
          if (currentProStatus) {
            await setPro(false);
            return true; // 修復が行われた
          }
          return false; // 既にFree状態

        case RestoreNetworkError():
        case RestoreFailed():
          // ネットワークエラーやその他のエラーの場合、現状維持
          return false;
      }
    } catch (e) {
      // エラーの場合、現状維持
      return false;
    }
  }

  /// 指数バックオフでリトライする自己修復
  static Future<void> retryEntitlementRepair({int maxRetries = 3}) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final repaired = await verifyAndRepairEntitlement();
        if (repaired) {
          break; // 修復成功または不要
        }

        // 指数バックオフで待機
        final delay = Duration(seconds: (retryCount + 1) * 2);
        await Future.delayed(delay);
        retryCount++;
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          break; // 最大リトライ回数に達した
        }

        // 指数バックオフで待機
        final delay = Duration(seconds: (retryCount + 1) * 2);
        await Future.delayed(delay);
      }
    }
  }

  /// エンタイトルメント状態をチェック（バックグラウンド自己修復）
  static Future<bool> checkEntitlementStatus() async {
    try {
      LogService()
          .logInfo('Starting entitlement status check', tag: 'entitlement');

      // 現在のPro状態を取得
      final currentProStatus = await isPro();

      // 購入サービスから実際の購入状態を確認
      final purchaseService = PurchaseService();
      final hasActiveSubscription = await purchaseService.isPro();

      // 状態が一致しない場合は修復
      if (currentProStatus != hasActiveSubscription) {
        LogService().logWarning(
          'Entitlement mismatch detected: local=$currentProStatus, remote=$hasActiveSubscription',
          tag: 'entitlement',
        );

        // 修復実行
        await setPro(hasActiveSubscription);

        LogService().logInfo(
          'Entitlement repaired: set to $hasActiveSubscription',
          tag: 'entitlement',
        );

        return hasActiveSubscription;
      }

      LogService().logInfo('Entitlement status verified: $currentProStatus',
          tag: 'entitlement');
      return currentProStatus;
    } catch (e) {
      LogService().logError('Failed to check entitlement status: $e',
          tag: 'entitlement');

      // エラーの場合は現在の状態を返す
      return await isPro();
    }
  }

  /// 購入成功時の即時解放処理
  static Future<void> handlePurchaseSuccess(PurchaseSuccess results) async {
    try {
      LogService()
          .logInfo('Handling purchase success', tag: 'entitlement', data: {
        'product_id': results.productId,
        'transaction_id': results.transactionId,
      });

      // Pro状態を即座に有効化
      await setPro(true, productId: results.productId);

      // 購入ログを記録
      LogService().logPurchaseEvent('purchase_success', data: {
        'product_id': results.productId,
        'transaction_id': results.transactionId,
      });

      LogService().logInfo('Purchase success handled: Pro features unlocked',
          tag: 'entitlement');
    } catch (e) {
      LogService().logError('Failed to handle purchase success: $e',
          tag: 'entitlement');
    }
  }

  /// 復元成功時の即時解放処理
  static Future<void> handleRestoreSuccess() async {
    try {
      LogService().logInfo('Handling restore success', tag: 'entitlement');

      // Pro状態を有効化
      await setPro(true);

      // 復元ログを記録
      LogService().logPurchaseEvent('restore_success');

      LogService().logInfo('Restore success handled: Pro features unlocked',
          tag: 'entitlement');
    } catch (e) {
      LogService()
          .logError('Failed to handle restore success: $e', tag: 'entitlement');
    }
  }

  /// 定期エンタイトルメント検証（アプリ起動時など）
  static Future<void> performPeriodicVerification() async {
    try {
      LogService().logInfo('Starting periodic entitlement verification',
          tag: 'entitlement');

      final isPro = await checkEntitlementStatus();

      // 検証結果をログに記録
      LogService().logInfo('Periodic verification completed: isPro=$isPro',
          tag: 'entitlement');
    } catch (e) {
      LogService().logError('Periodic entitlement verification failed: $e',
          tag: 'entitlement');
    }
  }
}
