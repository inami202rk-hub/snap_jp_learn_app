import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'log_service.dart';
import 'entitlement_service.dart';

/// 診断情報サービス
class DiagnosticsService {
  static final DiagnosticsService _instance = DiagnosticsService._internal();
  factory DiagnosticsService() => _instance;
  DiagnosticsService._internal();

  final LogService _logService = LogService();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 診断情報を生成
  Future<Map<String, dynamic>> generateDiagnostics() async {
    try {
      final diagnostics = <String, dynamic>{};

      // アプリ情報
      diagnostics['app'] = await _getAppInfo();

      // 端末情報
      diagnostics['device'] = await _getDeviceInfo();

      // 機能使用統計
      diagnostics['usage'] = await _getUsageStatistics();

      // ログ情報
      diagnostics['logs'] = _getLogInfo();

      // パフォーマンス情報
      diagnostics['performance'] = _getPerformanceInfo();

      // セッション情報
      diagnostics['session'] = _getSessionInfo();

      // 生成時刻
      diagnostics['generatedAt'] = DateTime.now().toIso8601String();

      return diagnostics;
    } catch (e) {
      _logService.logError('Failed to generate diagnostics: $e',
          tag: 'diagnostics');
      return {
        'error': 'Failed to generate diagnostics: $e',
        'generatedAt': DateTime.now().toIso8601String(),
      };
    }
  }

  /// 診断情報をJSONファイルに保存
  Future<String?> saveDiagnosticsToFile() async {
    try {
      final diagnostics = await generateDiagnostics();
      final directory = await getApplicationDocumentsDirectory();
      final supportDir = Directory('${directory.path}/support');

      if (!await supportDir.exists()) {
        await supportDir.create(recursive: true);
      }

      final timestamp =
          DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final file = File('${supportDir.path}/diag-$timestamp.json');

      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(diagnostics),
      );

      _logService.logInfo('Diagnostics saved to file: ${file.path}',
          tag: 'diagnostics');
      return file.path;
    } catch (e) {
      _logService.logError('Failed to save diagnostics to file: $e',
          tag: 'diagnostics');
      return null;
    }
  }

  /// アプリ情報を取得
  Future<Map<String, dynamic>> _getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final isPro = await EntitlementService.isPro();

      return {
        'name': packageInfo.appName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'packageName': packageInfo.packageName,
        'isPro': isPro,
        'platform': defaultTargetPlatform.name,
        'isDebugMode': kDebugMode,
      };
    } catch (e) {
      _logService.logError('Failed to get app info: $e', tag: 'diagnostics');
      return {'error': 'Failed to get app info: $e'};
    }
  }

  /// 端末情報を取得（個人特定情報は除外）
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfo = <String, dynamic>{};

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceInfo.addAll({
          'platform': 'Android',
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'locale': Platform.localeName,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceInfo.addAll({
          'platform': 'iOS',
          'version': iosInfo.systemVersion,
          'model': iosInfo.model,
          'locale': Platform.localeName,
        });
      } else {
        deviceInfo.addAll({
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
          'locale': Platform.localeName,
        });
      }

      return deviceInfo;
    } catch (e) {
      _logService.logError('Failed to get device info: $e', tag: 'diagnostics');
      return {'error': 'Failed to get device info: $e'};
    }
  }

  /// 使用統計を取得
  Future<Map<String, dynamic>> _getUsageStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'startupCount': await _logService.getStartupCount(),
        'sessionDuration': _logService.sessionDuration,
        'recentErrors': _logService.getRecentErrorCount(
          since: const Duration(hours: 24),
        ),
        'lastBackupDate': prefs.getString('last_backup_date'),
        'preferences': {
          'srsPreviewEnabled': prefs.getBool('srs_preview_enabled') ?? false,
          'darkMode': prefs.getBool('dark_mode') ?? false,
        },
      };
    } catch (e) {
      _logService.logError('Failed to get usage statistics: $e',
          tag: 'diagnostics');
      return {'error': 'Failed to get usage statistics: $e'};
    }
  }

  /// ログ情報を取得
  Map<String, dynamic> _getLogInfo() {
    try {
      final logStats = _logService.getLogStatistics();
      final recentLogs = _logService
          .getLogs(
            limit: 20,
          )
          .map((log) => log.toJson())
          .toList();

      return {
        'statistics': logStats,
        'recentLogs': recentLogs,
      };
    } catch (e) {
      _logService.logError('Failed to get log info: $e', tag: 'diagnostics');
      return {'error': 'Failed to get log info: $e'};
    }
  }

  /// パフォーマンス情報を取得
  Map<String, dynamic> _getPerformanceInfo() {
    try {
      final perfStats = _logService.getPerformanceStatistics();
      final activeMarkers = _logService.getActiveMarkers();

      return {
        'statistics': perfStats,
        'activeMarkers': activeMarkers,
        'hasData': perfStats.isNotEmpty,
      };
    } catch (e) {
      _logService.logError('Failed to get performance info: $e',
          tag: 'diagnostics');
      return {'error': 'Failed to get performance info: $e'};
    }
  }

  /// セッション情報を取得
  Map<String, dynamic> _getSessionInfo() {
    try {
      return {
        'sessionStartTime': _logService.sessionStartTime,
        'sessionDuration': _logService.sessionDuration,
        'isActive': true,
      };
    } catch (e) {
      _logService.logError('Failed to get session info: $e',
          tag: 'diagnostics');
      return {'error': 'Failed to get session info: $e'};
    }
  }

  /// 診断情報を簡潔な文字列として取得（プレビュー用）
  Future<String> getDiagnosticsPreview() async {
    try {
      final diagnostics = await generateDiagnostics();

      final buffer = StringBuffer();
      buffer.writeln('=== Snap JP Learn Diagnostics ===');
      buffer.writeln();

      // アプリ情報
      if (diagnostics['app'] is Map) {
        final app = diagnostics['app'] as Map<String, dynamic>;
        buffer.writeln(
            'App: ${app['name']} v${app['version']} (${app['buildNumber']})');
        buffer.writeln('Platform: ${app['platform']}');
        buffer.writeln('Pro: ${app['isPro']}');
      }

      buffer.writeln();

      // 端末情報
      if (diagnostics['device'] is Map) {
        final device = diagnostics['device'] as Map<String, dynamic>;
        buffer.writeln('Device: ${device['platform']} ${device['version']}');
        buffer.writeln('Model: ${device['model']}');
        buffer.writeln('Locale: ${device['locale']}');
      }

      buffer.writeln();

      // 使用統計
      if (diagnostics['usage'] is Map) {
        final usage = diagnostics['usage'] as Map<String, dynamic>;
        buffer.writeln('Startups: ${usage['startupCount']}');
        buffer.writeln(
            'Session: ${(usage['sessionDuration'] as int? ?? 0) ~/ 1000}s');
        buffer.writeln('Recent Errors: ${usage['recentErrors']}');
      }

      buffer.writeln();

      // ログ統計
      if (diagnostics['logs'] is Map &&
          diagnostics['logs']['statistics'] is Map) {
        final logStats =
            diagnostics['logs']['statistics'] as Map<String, dynamic>;
        buffer.writeln(
            'Logs: ${logStats['totalLogs']} total, ${logStats['errorCount24h']} errors (24h)');
      }

      buffer.writeln();
      buffer.writeln('Generated: ${diagnostics['generatedAt']}');

      return buffer.toString();
    } catch (e) {
      return 'Failed to generate diagnostics preview: $e';
    }
  }

  /// 診断情報のサイズを取得（バイト単位）
  Future<int> getDiagnosticsSize() async {
    try {
      final diagnostics = await generateDiagnostics();
      final jsonString = const JsonEncoder().convert(diagnostics);
      return utf8.encode(jsonString).length;
    } catch (e) {
      return 0;
    }
  }

  /// 診断ファイルをクリーンアップ（古いファイルを削除）
  Future<void> cleanupOldDiagnostics({int keepDays = 7}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final supportDir = Directory('${directory.path}/support');

      if (!await supportDir.exists()) return;

      final cutoff = DateTime.now().subtract(Duration(days: keepDays));
      final files = await supportDir.list().toList();

      for (final file in files) {
        if (file is File && file.path.contains('diag-')) {
          final stat = await file.stat();
          if (stat.modified.isBefore(cutoff)) {
            await file.delete();
            _logService.logInfo('Cleaned up old diagnostics file: ${file.path}',
                tag: 'diagnostics');
          }
        }
      }
    } catch (e) {
      _logService.logError('Failed to cleanup old diagnostics: $e',
          tag: 'diagnostics');
    }
  }
}
