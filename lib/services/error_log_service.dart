import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// エラーログの種類
enum ErrorLogType {
  crash,
  exception,
  warning,
  info,
}

/// エラーログエントリ
class ErrorLogEntry {
  final String id;
  final ErrorLogType type;
  final String message;
  final String? stackTrace;
  final Map<String, dynamic>? context;
  final DateTime timestamp;
  final String? userId;

  ErrorLogEntry({
    required this.id,
    required this.type,
    required this.message,
    this.stackTrace,
    this.context,
    required this.timestamp,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'message': message,
        'stackTrace': stackTrace,
        'context': context,
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
      };

  factory ErrorLogEntry.fromJson(Map<String, dynamic> json) => ErrorLogEntry(
        id: json['id'] as String,
        type: ErrorLogType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ErrorLogType.info,
        ),
        message: json['message'] as String,
        stackTrace: json['stackTrace'] as String?,
        context: json['context'] as Map<String, dynamic>?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        userId: json['userId'] as String?,
      );
}

/// エラーログサービス
class ErrorLogService {
  static const String _boxName = 'error_logs';
  static const String _userIdKey = 'error_log_user_id';
  static const String _enabledKey = 'error_log_enabled';
  static const int _maxOfflineLogs = 100;

  static ErrorLogService? _instance;
  static ErrorLogService get instance => _instance ??= ErrorLogService._();

  ErrorLogService._();

  Box<ErrorLogEntry>? _box;
  String? _userId;
  bool _isEnabled = true;
  Timer? _retryTimer;

  /// 初期化
  Future<void> initialize() async {
    try {
      // Hiveボックスを開く
      _box = await Hive.openBox<ErrorLogEntry>(_boxName);

      // ユーザーIDを取得または生成
      await _loadUserId();

      // 設定を読み込み
      await _loadSettings();

      // オフラインログを送信
      await _sendOfflineLogs();

      // 定期的な再送処理を開始
      _startRetryTimer();

      debugPrint('[ErrorLogService] Initialized with user ID: $_userId');
    } catch (e) {
      debugPrint('[ErrorLogService] Initialization failed: $e');
    }
  }

  /// ユーザーIDを読み込みまたは生成
  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString(_userIdKey);

      if (_userId == null) {
        _userId = const Uuid().v4();
        await prefs.setString(_userIdKey, _userId!);
        debugPrint('[ErrorLogService] Generated new user ID: $_userId');
      }
    } catch (e) {
      debugPrint('[ErrorLogService] Failed to load/generate user ID: $e');
    }
  }

  /// 設定を読み込み
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_enabledKey) ?? true;
    } catch (e) {
      debugPrint('[ErrorLogService] Failed to load settings: $e');
    }
  }

  /// ログ送信の有効/無効を設定
  Future<void> setEnabled(bool enabled) async {
    try {
      _isEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);

      if (enabled) {
        // 有効化時はオフラインログを送信
        await _sendOfflineLogs();
      }

      debugPrint(
          '[ErrorLogService] Logging ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('[ErrorLogService] Failed to update settings: $e');
    }
  }

  /// ログ送信が有効かどうか
  bool get isEnabled => _isEnabled;

  /// ユーザーIDを取得
  String? get userId => _userId;

  /// エラーログを記録
  Future<void> logError({
    required ErrorLogType type,
    required String message,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (!_isEnabled) {
      debugPrint('[ErrorLogService] Logging disabled, skipping: $message');
      return;
    }

    try {
      final entry = ErrorLogEntry(
        id: const Uuid().v4(),
        type: type,
        message: message,
        stackTrace: stackTrace,
        context: context,
        timestamp: DateTime.now(),
        userId: _userId,
      );

      // オンライン時は即座に送信
      if (await _isOnline()) {
        await _sendLog(entry);
      } else {
        // オフライン時はローカルに保存
        await _saveOfflineLog(entry);
      }

      debugPrint('[ErrorLogService] Logged: ${type.name} - $message');
    } catch (e) {
      debugPrint('[ErrorLogService] Failed to log error: $e');
    }
  }

  /// オンライン状態を確認
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// ログを送信
  Future<void> _sendLog(ErrorLogEntry entry) async {
    try {
      // Sentryに送信
      await Sentry.captureMessage(
        entry.message,
        level: _getSentryLevel(entry.type),
        withScope: (scope) {
          scope.setTag('error_type', entry.type.name);
          scope.setTag('user_id', entry.userId ?? 'unknown');
          if (entry.context != null) {
            scope.setContexts('error_context', entry.context!);
          }
          if (entry.stackTrace != null) {
            scope.addBreadcrumb(Breadcrumb(
              message: 'Stack trace',
              data: {'stack_trace': entry.stackTrace},
            ));
          }
        },
      );

      debugPrint('[ErrorLogService] Sent log to Sentry: ${entry.id}');
    } catch (e) {
      debugPrint('[ErrorLogService] Failed to send log: $e');
      // 送信失敗時はオフライン保存
      await _saveOfflineLog(entry);
    }
  }

  /// Sentryレベルを取得
  SentryLevel _getSentryLevel(ErrorLogType type) {
    switch (type) {
      case ErrorLogType.crash:
        return SentryLevel.fatal;
      case ErrorLogType.exception:
        return SentryLevel.error;
      case ErrorLogType.warning:
        return SentryLevel.warning;
      case ErrorLogType.info:
        return SentryLevel.info;
    }
  }

  /// オフラインログを保存
  Future<void> _saveOfflineLog(ErrorLogEntry entry) async {
    try {
      if (_box == null) return;

      // 最大保存数を超える場合は古いログを削除
      if (_box!.length >= _maxOfflineLogs) {
        final oldestKey = _box!.keys.first;
        await _box!.delete(oldestKey);
      }

      await _box!.put(entry.id, entry);
      debugPrint('[ErrorLogService] Saved offline log: ${entry.id}');
    } catch (e) {
      debugPrint('[ErrorLogService] Failed to save offline log: $e');
    }
  }

  /// オフラインログを送信
  Future<void> _sendOfflineLogs() async {
    if (_box == null || !_isEnabled) return;

    try {
      final entries = _box!.values.toList();
      if (entries.isEmpty) return;

      debugPrint('[ErrorLogService] Sending ${entries.length} offline logs...');

      for (final entry in entries) {
        await _sendLog(entry);
        await _box!.delete(entry.id);
      }

      debugPrint('[ErrorLogService] Sent all offline logs');
    } catch (e) {
      debugPrint('[ErrorLogService] Failed to send offline logs: $e');
    }
  }

  /// 再送タイマーを開始
  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_isEnabled && await _isOnline()) {
        await _sendOfflineLogs();
      }
    });
  }

  /// リソースを解放
  Future<void> dispose() async {
    _retryTimer?.cancel();
    await _box?.close();
  }
}
