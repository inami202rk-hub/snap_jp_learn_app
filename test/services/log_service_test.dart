import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/log_service.dart';

void main() {
  group('LogService Tests', () {
    late LogService logService;

    setUp(() {
      logService = LogService();
      logService.clearLogs();
    });

    test('LogService is singleton', () {
      final instance1 = LogService();
      final instance2 = LogService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('logInfo adds info log entry', () {
      logService.logInfo('Test info message', tag: 'test');

      final logs = logService.getLogs();
      expect(
          logs.length, equals(2)); // 1 for the test message + 1 for clear log
      expect(logs.last.level, equals(LogLevel.info));
      expect(logs.last.message, equals('Test info message'));
      expect(logs.last.tag, equals('test'));
    });

    test('logWarning adds warning log entry', () {
      logService.logWarning('Test warning message', tag: 'test');

      final logs = logService.getLogs();
      expect(
          logs.length, equals(2)); // 1 for the test message + 1 for clear log
      expect(logs.last.level, equals(LogLevel.warning));
      expect(logs.last.message, equals('Test warning message'));
      expect(logs.last.tag, equals('test'));
    });

    test('logError adds error log entry', () {
      logService.logError('Test error message', tag: 'test');

      final logs = logService.getLogs();
      expect(
          logs.length, equals(2)); // 1 for the test message + 1 for clear log
      expect(logs.last.level, equals(LogLevel.error));
      expect(logs.last.message, equals('Test error message'));
      expect(logs.last.tag, equals('test'));
    });

    test('log entry includes timestamp and data', () {
      final testData = {'key': 'value', 'number': 42};
      logService.logInfo('Test message', tag: 'test', data: testData);

      final logs = logService.getLogs();
      expect(
          logs.length, equals(2)); // 1 for the test message + 1 for clear log
      expect(logs.last.timestamp, isA<DateTime>());
      expect(logs.last.data, equals(testData));
    });

    test('getLogs filters by level', () {
      logService.logInfo('Info message', tag: 'test');
      logService.logWarning('Warning message', tag: 'test');
      logService.logError('Error message', tag: 'test');

      final errorLogs = logService.getLogs(level: LogLevel.error);
      expect(errorLogs.length, equals(1));
      expect(errorLogs.first.message, equals('Error message'));
    });

    test('getLogs filters by tag', () {
      logService.logInfo('Message 1', tag: 'tag1');
      logService.logInfo('Message 2', tag: 'tag2');
      logService.logInfo('Message 3', tag: 'tag1');

      final tag1Logs = logService.getLogs(tag: 'tag1');
      expect(tag1Logs.length, equals(2));
    });

    test('getLogs applies limit', () {
      for (int i = 0; i < 5; i++) {
        logService.logInfo('Message $i');
      }

      final limitedLogs = logService.getLogs(limit: 3);
      expect(limitedLogs.length, equals(3));
    });

    test('clearLogs removes all entries', () {
      logService.logInfo('Message 1');
      logService.logWarning('Message 2');
      logService.logError('Message 3');

      expect(
          logService.getLogs().length, equals(4)); // 3 messages + 1 clear log

      logService.clearLogs();
      expect(logService.getLogs().length, equals(1)); // Clear log entry itself
    });

    test('log buffer has maximum size limit', () {
      // Add more logs than the maximum buffer size
      for (int i = 0; i < 150; i++) {
        logService.logInfo('Message $i');
      }

      final logs = logService.getLogs();
      expect(logs.length, lessThanOrEqualTo(101)); // Max + 1 for clear log
    });

    test('getLogStatistics returns correct statistics', () {
      logService.logInfo('Info message');
      logService.logWarning('Warning message');
      logService.logError('Error message');

      final stats = logService.getLogStatistics();
      expect(stats['totalLogs'], equals(4)); // 3 logs + 1 clear log
      expect(stats['errorCount24h'], equals(1));
      expect(stats['warningCount24h'], equals(1));
    });

    test('getRecentErrorCount returns correct count', () {
      logService.logError('Error 1');
      logService.logInfo('Info message');
      logService.logError('Error 2');

      final errorCount = logService.getRecentErrorCount();
      expect(errorCount, equals(2));
    });

    test('LogEntry toJson and fromJson work correctly', () {
      final originalEntry = LogEntry(
        timestamp: DateTime.now(),
        level: LogLevel.info,
        message: 'Test message',
        tag: 'test',
        data: {'key': 'value'},
      );

      final json = originalEntry.toJson();
      final restoredEntry = LogEntry.fromJson(json);

      expect(restoredEntry.level, equals(originalEntry.level));
      expect(restoredEntry.message, equals(originalEntry.message));
      expect(restoredEntry.tag, equals(originalEntry.tag));
      expect(restoredEntry.data, equals(originalEntry.data));
    });

    test('LogEntry toString includes all information', () {
      final entry = LogEntry(
        timestamp: DateTime(2024, 1, 1, 12, 0, 0),
        level: LogLevel.error,
        message: 'Test message',
        tag: 'test',
        data: {'key': 'value'},
      );

      final string = entry.toString();
      expect(string, contains('ERROR'));
      expect(string, contains('[test]'));
      expect(string, contains('Test message'));
      expect(string, contains('key: value'));
    });
  });
}
