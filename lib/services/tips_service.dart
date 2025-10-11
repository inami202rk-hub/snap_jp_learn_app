import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tips表示管理サービス
class TipsService extends ChangeNotifier {
  static const String _tipsPrefix = 'tip_shown_';
  static const Duration _defaultDuration = Duration(seconds: 5);

  SharedPreferences? _prefs;
  final Map<String, Timer> _activeTimers = {};

  /// 初期化
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 特定のTipsが表示済みかどうか
  Future<bool> isTipShown(String tipId) async {
    await _ensureInitialized();
    return _prefs!.getBool('$_tipsPrefix$tipId') ?? false;
  }

  /// Tipsを表示済みとしてマーク
  Future<void> markTipAsShown(String tipId) async {
    await _ensureInitialized();
    await _prefs!.setBool('$_tipsPrefix$tipId', true);
  }

  /// 指定されたTipsを表示可能かどうかチェック
  Future<bool> canShowTip(String tipId) async {
    return !(await isTipShown(tipId));
  }

  /// Tipsを表示（自動で表示済みフラグを設定）
  Future<void> showTip(String tipId) async {
    await markTipAsShown(tipId);
    notifyListeners();
  }

  /// 複数のTipsを一括で表示済みとしてマーク
  Future<void> markMultipleTipsAsShown(List<String> tipIds) async {
    await _ensureInitialized();
    for (final tipId in tipIds) {
      await _prefs!.setBool('$_tipsPrefix$tipId', true);
    }
    notifyListeners();
  }

  /// 特定のTipsの表示済みフラグをリセット
  Future<void> resetTip(String tipId) async {
    await _ensureInitialized();
    await _prefs!.remove('$_tipsPrefix$tipId');
    notifyListeners();
  }

  /// すべてのTipsの表示済みフラグをリセット
  Future<void> resetAllTips() async {
    await _ensureInitialized();
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      if (key.startsWith(_tipsPrefix)) {
        await _prefs!.remove(key);
      }
    }
    notifyListeners();
  }

  /// 表示済みTipsの一覧を取得
  Future<List<String>> getShownTips() async {
    await _ensureInitialized();
    final keys = _prefs!.getKeys();
    return keys
        .where((key) => key.startsWith(_tipsPrefix))
        .map((key) => key.substring(_tipsPrefix.length))
        .toList();
  }

  /// 自動でタイマー付きTipsを表示
  Future<void> showTimedTip(String tipId, {Duration? duration}) async {
    if (await canShowTip(tipId)) {
      await showTip(tipId);

      // タイマーを設定（既存のタイマーがあればキャンセル）
      _activeTimers[tipId]?.cancel();
      _activeTimers[tipId] = Timer(
        duration ?? _defaultDuration,
        () {
          _activeTimers.remove(tipId);
          notifyListeners();
        },
      );
    }
  }

  /// タイマー付きTipsがアクティブかどうか
  bool isTipActive(String tipId) {
    return _activeTimers.containsKey(tipId);
  }

  /// 特定のTipsのタイマーをキャンセル
  void cancelTipTimer(String tipId) {
    _activeTimers[tipId]?.cancel();
    _activeTimers.remove(tipId);
    notifyListeners();
  }

  /// すべてのタイマーをキャンセル
  void cancelAllTimers() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    notifyListeners();
  }

  /// 初期化確認
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// リソース解放
  @override
  void dispose() {
    cancelAllTimers();
    super.dispose();
  }
}

/// Tips ID定数
class TipsId {
  static const String ocrLighting = 'tips_ocr_lighting';
  static const String ocrAngle = 'tips_ocr_angle';
  static const String syncAuto = 'tips_sync_auto';
  static const String cardReview = 'tips_card_review';
  static const String offlineMode = 'tips_offline_mode';
  static const String homeNavigation = 'tips_home_navigation';
  static const String statsProgress = 'tips_stats_progress';
}

/// Tips表示タイミング
enum TipsTiming {
  immediate, // 即座に表示
  delayed, // 少し遅延して表示
  onAction, // アクション時に表示
}
