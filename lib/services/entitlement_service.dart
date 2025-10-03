import 'package:shared_preferences/shared_preferences.dart';

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
}
