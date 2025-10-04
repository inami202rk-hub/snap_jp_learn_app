import '../sync/sync_service.dart';

/// 機能フラグ管理
class FeatureFlags {
  // 同期機能のフラグ
  static const bool syncEnabled = false; // デフォルトは無効
  static const SyncPolicy syncPolicy = SyncPolicy.lastWriteWins;
  static const bool syncMockMode = true; // モックAPIを使用

  // その他の機能フラグ
  static const bool debugMode =
      bool.fromEnvironment('dart.vm.product') == false;
  static const bool performanceTracking = true;
  static const bool crashReporting = true;
}
