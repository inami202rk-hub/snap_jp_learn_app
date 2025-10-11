import 'package:shared_preferences/shared_preferences.dart';

/// 機能フラグ管理クラス
/// 実験機能やA/Bテストの切り替えを管理
class FeatureFlags {
  static const String _prefix = 'feature_flag_';
  static final bool _isInitialized = false;

  // 実験機能フラグ（デフォルト値）
  static const bool _defaultEnableExperimentalOCR = false;
  static const bool _defaultEnableAdvancedStats = false;
  static const bool _defaultEnableUsageTracking = true;
  static const bool _defaultEnableBetaFeatures = false;
  static const bool _defaultEnableDebugMode = false;

  /// 実験的OCR機能を有効にするか
  static bool get enableExperimentalOCR =>
      _getFlag('enableExperimentalOCR', _defaultEnableExperimentalOCR);

  /// 高度な統計機能を有効にするか
  static bool get enableAdvancedStats =>
      _getFlag('enableAdvancedStats', _defaultEnableAdvancedStats);

  /// 利用状況トラッキングを有効にするか
  static bool get enableUsageTracking =>
      _getFlag('enableUsageTracking', _defaultEnableUsageTracking);

  /// ベータ機能を有効にするか
  static bool get enableBetaFeatures => _getFlag('enableBetaFeatures', _defaultEnableBetaFeatures);

  /// デバッグモードを有効にするか
  static bool get enableDebugMode => _getFlag('enableDebugMode', _defaultEnableDebugMode);

  /// フラグを設定
  static Future<void> setFlag(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$key', value);
  }

  /// フラグを取得
  static bool _getFlag(String key, bool defaultValue) {
    // SharedPreferencesは非同期なので、ここでは同期でデフォルト値を返す
    // 実際のアプリでは、初期化時にSharedPreferencesから値を読み込む
    return defaultValue;
  }

  /// 非同期でフラグを取得
  static Future<bool> getFlagAsync(String key, bool defaultValue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_prefix$key') ?? defaultValue;
    } catch (e) {
      print('[FeatureFlags] Failed to get flag $key: $e');
      return defaultValue;
    }
  }

  /// 全てのフラグを初期化
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // デフォルト値を設定（既存の値がある場合は上書きしない）
      if (!prefs.containsKey('${_prefix}enableExperimentalOCR')) {
        await prefs.setBool('${_prefix}enableExperimentalOCR', _defaultEnableExperimentalOCR);
      }
      if (!prefs.containsKey('${_prefix}enableAdvancedStats')) {
        await prefs.setBool('${_prefix}enableAdvancedStats', _defaultEnableAdvancedStats);
      }
      if (!prefs.containsKey('${_prefix}enableUsageTracking')) {
        await prefs.setBool('${_prefix}enableUsageTracking', _defaultEnableUsageTracking);
      }
      if (!prefs.containsKey('${_prefix}enableBetaFeatures')) {
        await prefs.setBool('${_prefix}enableBetaFeatures', _defaultEnableBetaFeatures);
      }
      if (!prefs.containsKey('${_prefix}enableDebugMode')) {
        await prefs.setBool('${_prefix}enableDebugMode', _defaultEnableDebugMode);
      }

      print('[FeatureFlags] Initialized with default values');
    } catch (e) {
      print('[FeatureFlags] Failed to initialize: $e');
    }
  }

  /// 全てのフラグをリセット
  static Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('${_prefix}enableExperimentalOCR');
      await prefs.remove('${_prefix}enableAdvancedStats');
      await prefs.remove('${_prefix}enableUsageTracking');
      await prefs.remove('${_prefix}enableBetaFeatures');
      await prefs.remove('${_prefix}enableDebugMode');

      print('[FeatureFlags] Reset all flags to default values');
    } catch (e) {
      print('[FeatureFlags] Failed to reset flags: $e');
    }
  }

  /// 全てのフラグの状態を取得
  static Future<Map<String, bool>> getAllFlags() async {
    try {
      return {
        'enableExperimentalOCR':
            await getFlagAsync('enableExperimentalOCR', _defaultEnableExperimentalOCR),
        'enableAdvancedStats':
            await getFlagAsync('enableAdvancedStats', _defaultEnableAdvancedStats),
        'enableUsageTracking':
            await getFlagAsync('enableUsageTracking', _defaultEnableUsageTracking),
        'enableBetaFeatures': await getFlagAsync('enableBetaFeatures', _defaultEnableBetaFeatures),
        'enableDebugMode': await getFlagAsync('enableDebugMode', _defaultEnableDebugMode),
      };
    } catch (e) {
      print('[FeatureFlags] Failed to get all flags: $e');
      return {};
    }
  }

  /// フラグの説明を取得
  static String getFlagDescription(String key) {
    switch (key) {
      case 'enableExperimentalOCR':
        return '実験的OCR機能を有効にします。新しいOCRアルゴリズムや機能をテストできます。';
      case 'enableAdvancedStats':
        return '高度な統計機能を有効にします。詳細な分析データやチャートを表示できます。';
      case 'enableUsageTracking':
        return '利用状況トラッキングを有効にします。アプリの使用状況を匿名で記録します。';
      case 'enableBetaFeatures':
        return 'ベータ機能を有効にします。開発中の新機能をテストできます。';
      case 'enableDebugMode':
        return 'デバッグモードを有効にします。開発者向けの情報を表示します。';
      default:
        return '不明なフラグです。';
    }
  }

  /// フラグのカテゴリを取得
  static String getFlagCategory(String key) {
    switch (key) {
      case 'enableExperimentalOCR':
      case 'enableBetaFeatures':
        return '実験機能';
      case 'enableAdvancedStats':
      case 'enableUsageTracking':
        return '分析機能';
      case 'enableDebugMode':
        return '開発者機能';
      default:
        return 'その他';
    }
  }

  /// フラグが変更可能かどうかを取得
  static bool isFlagMutable(String key) {
    switch (key) {
      case 'enableExperimentalOCR':
      case 'enableAdvancedStats':
      case 'enableUsageTracking':
      case 'enableBetaFeatures':
      case 'enableDebugMode':
        return true;
      default:
        return false;
    }
  }

  /// 同期機能が有効かどうか
  static bool get syncEnabled => _getFlag('syncEnabled', false);

  /// デバッグモードが有効かどうか
  static bool get debugMode => _getFlag('debugMode', false);

  /// 同期モックモードが有効かどうか
  static bool get syncMockMode => _getFlag('syncMockMode', false);

  /// 初期化状態
  static bool get isInitialized => _isInitialized;

  /// 高度な分析機能が有効かどうか
  static bool get enableAdvancedAnalytics => _getFlag('enableAdvancedAnalytics', false);

  /// 実験機能が有効かどうか
  static bool get enableExperimentalFeatures => _getFlag('enableExperimentalFeatures', false);
}

/// 機能フラグの状態変更通知用
class FeatureFlagNotifier {
  static final Map<String, List<Function(bool)>> _listeners = {};

  /// リスナーを追加
  static void addListener(String key, Function(bool) listener) {
    _listeners[key] ??= [];
    _listeners[key]!.add(listener);
  }

  /// リスナーを削除
  static void removeListener(String key, Function(bool) listener) {
    _listeners[key]?.remove(listener);
  }

  /// フラグ変更を通知
  static void notifyListeners(String key, bool value) {
    _listeners[key]?.forEach((listener) => listener(value));
  }

  /// 全てのリスナーをクリア
  static void clearAllListeners() {
    _listeners.clear();
  }
}

/// 機能フラグのテスト用ユーティリティ
class FeatureFlagTestUtils {
  /// テスト用にフラグを強制的に設定
  static Future<void> setFlagForTesting(String key, bool value) async {
    await FeatureFlags.setFlag(key, value);
    FeatureFlagNotifier.notifyListeners(key, value);
  }

  /// テスト用に全てのフラグをリセット
  static Future<void> resetAllForTesting() async {
    await FeatureFlags.reset();
    for (final key in [
      'enableExperimentalOCR',
      'enableAdvancedStats',
      'enableUsageTracking',
      'enableBetaFeatures',
      'enableDebugMode'
    ]) {
      FeatureFlagNotifier.notifyListeners(key, false);
    }
  }
}
