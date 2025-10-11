import 'package:shared_preferences/shared_preferences.dart';

/// オンボーディングとTipsの表示状態を管理するサービス
class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _tipsShownKey = 'tips_shown';

  /// オンボーディングが完了しているかチェック
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    // 新しいキー名もチェック（後方互換性のため）
    return prefs.getBool('onboarded') ??
        prefs.getBool(_onboardingCompletedKey) ??
        false;
  }

  /// オンボーディング完了をマーク
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  /// 特定のTipsが表示済みかチェック
  static Future<bool> isTipShown(String tipKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_tipsShownKey}_$tipKey') ?? false;
  }

  /// Tips表示済みをマーク
  static Future<void> markTipShown(String tipKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_tipsShownKey}_$tipKey', true);
  }

  /// 全てのTips表示状態をリセット（デバッグ用）
  static Future<void> resetAllTips() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_tipsShownKey)) {
        await prefs.remove(key);
      }
    }
  }

  /// オンボーディング状態をリセット（デバッグ用）
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
  }
}
