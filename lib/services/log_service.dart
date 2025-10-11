import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ログレベル
enum LogLevel {
  info('INFO'),
  warning('WARNING'),
  error('ERROR');

  const LogLevel(this.name);
  final String name;
}

/// ログエントリ
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? data;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'tag': tag,
      'data': data,
    };
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp']),
      level: LogLevel.values.firstWhere(
        (level) => level.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'],
      tag: json['tag'],
      data: json['data'],
    );
  }

  @override
  String toString() {
    final tagStr = tag != null ? '[$tag] ' : '';
    final dataStr = data != null ? ' ${data.toString()}' : '';
    return '${timestamp.toIso8601String()} [${level.name}] $tagStr$message$dataStr';
  }
}

/// パフォーマンスマーカー
class PerformanceMarker {
  final String name;
  final DateTime startTime;
  final Map<String, dynamic>? metadata;

  PerformanceMarker({
    required this.name,
    required this.startTime,
    this.metadata,
  });

  Duration getElapsedTime() => DateTime.now().difference(startTime);
  int getElapsedMilliseconds() => getElapsedTime().inMilliseconds;
}

/// ログサービス（シングルトン）
class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  static const int _maxLogEntries = 100;
  final Queue<LogEntry> _logBuffer = Queue<LogEntry>();
  final Map<String, PerformanceMarker> _activeMarkers = {};
  final Map<String, List<int>> _performanceHistory = {}; // 処理時間の履歴
  bool _isInitialized = false;
  int _sessionStartTime = 0;

  /// 初期化
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // セッション開始時刻を記録
      _sessionStartTime = DateTime.now().millisecondsSinceEpoch;

      // アプリクラッシュハンドラーを設定
      if (!kDebugMode) {
        FlutterError.onError = (FlutterErrorDetails details) {
          logError(
            'Flutter Error: ${details.exception}',
            tag: 'flutter',
            data: {
              'stackTrace': details.stack.toString(),
              'library': details.library,
            },
          );
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          logError(
            'Platform Error: $error',
            tag: 'platform',
            data: {
              'stackTrace': stack.toString(),
            },
          );
          return true;
        };
      }

      // 起動ログを記録
      await _loadStartupCount();
      await _incrementStartupCount();
      logInfo('App started', tag: 'app');

      _isInitialized = true;
    } catch (e) {
      // ログサービス自体のエラーはコンソールに出力
      debugPrint('LogService initialization failed: $e');
    }
  }

  /// 情報ログを記録
  void logInfo(String message, {String? tag, Map<String, dynamic>? data}) {
    _addLog(LogLevel.info, message, tag: tag, data: data);
  }

  /// 警告ログを記録
  void logWarning(String message, {String? tag, Map<String, dynamic>? data}) {
    _addLog(LogLevel.warning, message, tag: tag, data: data);
  }

  /// エラーログを記録
  void logError(String message, {String? tag, Map<String, dynamic>? data}) {
    _addLog(LogLevel.error, message, tag: tag, data: data);
  }

  /// ログエントリを追加
  void _addLog(LogLevel level, String message,
      {String? tag, Map<String, dynamic>? data}) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      data: data,
    );

    _logBuffer.add(entry);

    // バッファサイズが上限を超えた場合、古いエントリを削除
    while (_logBuffer.length > _maxLogEntries) {
      _logBuffer.removeFirst();
    }

    // デバッグモードではコンソールにも出力
    if (kDebugMode) {
      debugPrint(entry.toString());
    }
  }

  /// ログエントリを取得
  List<LogEntry> getLogs({LogLevel? level, String? tag, int? limit}) {
    var logs = _logBuffer.toList();

    // レベルでフィルタ
    if (level != null) {
      logs = logs.where((log) => log.level == level).toList();
    }

    // タグでフィルタ
    if (tag != null) {
      logs = logs.where((log) => log.tag == tag).toList();
    }

    // 制限を適用
    if (limit != null && logs.length > limit) {
      logs = logs.skip(logs.length - limit).toList();
    }

    return logs;
  }

  /// ログエントリをクリア
  void clearLogs() {
    _logBuffer.clear();
    logInfo('Log buffer cleared', tag: 'log_service');
  }

  /// ログをJSONファイルに保存
  Future<String?> saveLogsToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final supportDir = Directory('${directory.path}/support');
      if (!await supportDir.exists()) {
        await supportDir.create(recursive: true);
      }

      final timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final file = File('${supportDir.path}/logs-$timestamp.json');

      final logsJson = _logBuffer.map((entry) => entry.toJson()).toList();
      await file.writeAsString(
        '${logsJson.map((log) => log.toString()).join('\n')}\n',
      );

      logInfo('Logs saved to file: ${file.path}', tag: 'log_service');
      return file.path;
    } catch (e) {
      logError('Failed to save logs to file: $e', tag: 'log_service');
      return null;
    }
  }

  /// 起動回数を取得
  Future<int> getStartupCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('app_startup_count') ?? 0;
  }

  /// 起動回数を増加
  Future<void> _incrementStartupCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('app_startup_count') ?? 0;
    await prefs.setInt('app_startup_count', current + 1);
  }

  /// 起動回数を読み込み
  Future<void> _loadStartupCount() async {
    final count = await getStartupCount();
    logInfo('App startup count: $count',
        tag: 'app', data: {'startupCount': count});
  }

  /// セッション開始時刻を取得
  int get sessionStartTime => _sessionStartTime;

  /// セッション時間を取得（ミリ秒）
  int get sessionDuration =>
      DateTime.now().millisecondsSinceEpoch - _sessionStartTime;

  /// 直近のエラーログ数を取得
  int getRecentErrorCount({Duration? since}) {
    final cutoff = since != null
        ? DateTime.now().subtract(since)
        : DateTime.now().subtract(const Duration(hours: 24));

    return _logBuffer
        .where((log) =>
            log.level == LogLevel.error && log.timestamp.isAfter(cutoff))
        .length;
  }

  /// ログ統計情報を取得
  Map<String, dynamic> getLogStatistics() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    final last7d = now.subtract(const Duration(days: 7));

    final logs24h =
        _logBuffer.where((log) => log.timestamp.isAfter(last24h)).toList();
    final logs7d =
        _logBuffer.where((log) => log.timestamp.isAfter(last7d)).toList();

    return {
      'totalLogs': _logBuffer.length,
      'logsLast24h': logs24h.length,
      'logsLast7d': logs7d.length,
      'errorCount24h':
          logs24h.where((log) => log.level == LogLevel.error).length,
      'errorCount7d': logs7d.where((log) => log.level == LogLevel.error).length,
      'warningCount24h':
          logs24h.where((log) => log.level == LogLevel.warning).length,
      'sessionDuration': sessionDuration,
    };
  }

  // === パフォーマンスマーカーAPI ===

  /// パフォーマンス測定を開始
  void markStart(String name, {Map<String, dynamic>? metadata}) {
    _activeMarkers[name] = PerformanceMarker(
      name: name,
      startTime: DateTime.now(),
      metadata: metadata,
    );
    logInfo('Performance marker started: $name', tag: 'perf', data: metadata);
  }

  /// パフォーマンス測定を終了
  void markEnd(String name, {Map<String, dynamic>? additionalData}) {
    final marker = _activeMarkers.remove(name);
    if (marker == null) {
      logWarning('Performance marker not found: $name', tag: 'perf');
      return;
    }

    final elapsedMs = marker.getElapsedMilliseconds();

    // 履歴に追加（最大50件保持）
    _performanceHistory.putIfAbsent(name, () => []);
    _performanceHistory[name]!.add(elapsedMs);
    if (_performanceHistory[name]!.length > 50) {
      _performanceHistory[name]!.removeAt(0);
    }

    final data = {
      'elapsedMs': elapsedMs,
      'elapsedSec': (elapsedMs / 1000).toStringAsFixed(2),
      ...?marker.metadata,
      ...?additionalData,
    };

    logInfo('Performance marker ended: $name (${elapsedMs}ms)',
        tag: 'perf', data: data);
  }

  /// パフォーマンス統計を取得
  Map<String, dynamic> getPerformanceStatistics() {
    final stats = <String, dynamic>{};

    for (final entry in _performanceHistory.entries) {
      final name = entry.key;
      final times = entry.value;

      if (times.isEmpty) continue;

      times.sort();
      final avg = times.reduce((a, b) => a + b) / times.length;
      final min = times.first;
      final max = times.last;
      final median = times.length % 2 == 0
          ? (times[times.length ~/ 2 - 1] + times[times.length ~/ 2]) / 2
          : times[times.length ~/ 2].toDouble();

      stats[name] = {
        'count': times.length,
        'avgMs': avg.toStringAsFixed(1),
        'minMs': min,
        'maxMs': max,
        'medianMs': median.toStringAsFixed(1),
        'recentTimes': times.skip(times.length - 10).toList(), // 直近10回
      };
    }

    return stats;
  }

  /// 特定のパフォーマンスマーカーの統計を取得
  Map<String, dynamic>? getMarkerStatistics(String name) {
    final times = _performanceHistory[name];
    if (times == null || times.isEmpty) return null;

    times.sort();
    final avg = times.reduce((a, b) => a + b) / times.length;
    final min = times.first;
    final max = times.last;
    final median = times.length % 2 == 0
        ? (times[times.length ~/ 2 - 1] + times[times.length ~/ 2]) / 2
        : times[times.length ~/ 2].toDouble();

    return {
      'count': times.length,
      'avgMs': avg.toStringAsFixed(1),
      'minMs': min,
      'maxMs': max,
      'medianMs': median.toStringAsFixed(1),
      'recentTimes': times.skip(times.length - 10).toList(),
    };
  }

  /// アクティブなパフォーマンスマーカーを取得
  Map<String, int> getActiveMarkers() {
    final now = DateTime.now();
    final active = <String, int>{};

    for (final entry in _activeMarkers.entries) {
      active[entry.key] = now.difference(entry.value.startTime).inMilliseconds;
    }

    return active;
  }

  /// パフォーマンス履歴をクリア
  void clearPerformanceHistory() {
    _performanceHistory.clear();
    _activeMarkers.clear();
    logInfo('Performance history cleared', tag: 'perf');
  }

  /// 購入関連イベントをログに記録
  void logPurchaseEvent(String eventType, {Map<String, dynamic>? data}) {
    final eventData = {
      'event_type': eventType,
      'timestamp': DateTime.now().toIso8601String(),
      if (data != null) ...data,
    };

    logInfo(
      'Purchase Event: $eventType',
      tag: 'purchase',
      data: eventData,
    );
  }

  /// ロック関連イベントをログに記録
  void logLockEvent(String feature, String reason,
      {Map<String, dynamic>? data}) {
    final eventData = {
      'feature': feature,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
      if (data != null) ...data,
    };

    logInfo(
      'Lock Event: $feature - $reason',
      tag: 'lock',
      data: eventData,
    );
  }
}
