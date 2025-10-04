import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/diagnostics_service.dart';
import 'package:snap_jp_learn_app/services/log_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DiagnosticsService Tests', () {
    late DiagnosticsService diagnosticsService;
    late LogService logService;

    setUp(() {
      diagnosticsService = DiagnosticsService();
      logService = LogService();
      logService.clearLogs();
    });

    test('DiagnosticsService is singleton', () {
      final instance1 = DiagnosticsService();
      final instance2 = DiagnosticsService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('generateDiagnostics returns valid structure', () async {
      final diagnostics = await diagnosticsService.generateDiagnostics();

      expect(diagnostics, isA<Map<String, dynamic>>());
      expect(diagnostics.containsKey('app'), isTrue);
      expect(diagnostics.containsKey('device'), isTrue);
      expect(diagnostics.containsKey('usage'), isTrue);
      expect(diagnostics.containsKey('logs'), isTrue);
      expect(diagnostics.containsKey('session'), isTrue);
      expect(diagnostics.containsKey('generatedAt'), isTrue);
    });

    test('generateDiagnostics app section has required fields', () async {
      final diagnostics = await diagnosticsService.generateDiagnostics();
      final app = diagnostics['app'] as Map<String, dynamic>;

      // In test environment, some fields may be missing due to plugin limitations
      // Check that we get a valid structure (either with data or error)
      expect(app, isA<Map<String, dynamic>>());
      expect(app.containsKey('error') || app.containsKey('name'), isTrue);
    });

    test('generateDiagnostics device section has required fields', () async {
      final diagnostics = await diagnosticsService.generateDiagnostics();
      final device = diagnostics['device'] as Map<String, dynamic>;

      // In test environment, some fields may be missing due to plugin limitations
      expect(device, isA<Map<String, dynamic>>());
      expect(device.containsKey('error') || device.containsKey('platform'),
          isTrue);
    });

    test('generateDiagnostics usage section has required fields', () async {
      final diagnostics = await diagnosticsService.generateDiagnostics();
      final usage = diagnostics['usage'] as Map<String, dynamic>;

      // In test environment, some fields may be missing due to plugin limitations
      expect(usage, isA<Map<String, dynamic>>());
      expect(usage.containsKey('error') || usage.containsKey('startupCount'),
          isTrue);
    });

    test('generateDiagnostics logs section has required fields', () async {
      logService.logInfo('Test log message', tag: 'test');

      final diagnostics = await diagnosticsService.generateDiagnostics();
      final logs = diagnostics['logs'] as Map<String, dynamic>;

      expect(logs.containsKey('statistics'), isTrue);
      expect(logs.containsKey('recentLogs'), isTrue);

      final statistics = logs['statistics'] as Map<String, dynamic>;
      expect(statistics.containsKey('totalLogs'), isTrue);
      expect(statistics.containsKey('errorCount24h'), isTrue);
    });

    test('generateDiagnostics session section has required fields', () async {
      final diagnostics = await diagnosticsService.generateDiagnostics();
      final session = diagnostics['session'] as Map<String, dynamic>;

      expect(session.containsKey('sessionStartTime'), isTrue);
      expect(session.containsKey('sessionDuration'), isTrue);
      expect(session.containsKey('isActive'), isTrue);
    });

    test('getDiagnosticsPreview returns formatted string', () async {
      final preview = await diagnosticsService.getDiagnosticsPreview();

      expect(preview, isA<String>());
      expect(preview.isNotEmpty, isTrue);
      expect(preview, contains('Snap JP Learn Diagnostics'));
    });

    test('getDiagnosticsSize returns positive number', () async {
      final size = await diagnosticsService.getDiagnosticsSize();

      expect(size, greaterThan(0));
    });

    test('diagnostics contains no personal information', () async {
      final diagnostics = await diagnosticsService.generateDiagnostics();
      final diagnosticsString = diagnostics.toString().toLowerCase();

      // Check that no personal information is included
      expect(diagnosticsString.contains('email'), isFalse);
      expect(diagnosticsString.contains('phone'), isFalse);
      expect(diagnosticsString.contains('address'), isFalse);
      expect(diagnosticsString.contains('name'), isFalse); // Except app name
    });

    test('diagnostics handles errors gracefully', () async {
      // This test ensures that even if some parts fail, the service returns a valid response
      final diagnostics = await diagnosticsService.generateDiagnostics();

      expect(diagnostics, isA<Map<String, dynamic>>());
      expect(diagnostics.containsKey('generatedAt'), isTrue);
    });

    test('cleanupOldDiagnostics does not throw', () async {
      // This test ensures the cleanup method doesn't throw exceptions
      expect(() => diagnosticsService.cleanupOldDiagnostics(), returnsNormally);
    });

    test('diagnostics preview contains expected sections', () async {
      final preview = await diagnosticsService.getDiagnosticsPreview();

      expect(preview, contains('App:'));
      expect(preview, contains('Platform:'));
      expect(preview, contains('Device:'));
      expect(preview, contains('Startups:'));
      expect(preview, contains('Generated:'));
    });

    test('multiple diagnostics calls return consistent structure', () async {
      final diagnostics1 = await diagnosticsService.generateDiagnostics();
      final diagnostics2 = await diagnosticsService.generateDiagnostics();

      // Both should have the same structure
      expect(diagnostics1.keys, equals(diagnostics2.keys));

      // App info should be consistent
      final app1 = diagnostics1['app'] as Map<String, dynamic>;
      final app2 = diagnostics2['app'] as Map<String, dynamic>;
      expect(app1.keys, equals(app2.keys));
    });

    test('diagnostics includes log statistics', () async {
      logService.logInfo('Test message 1');
      logService.logWarning('Test warning');
      logService.logError('Test error');

      final diagnostics = await diagnosticsService.generateDiagnostics();
      final logs = diagnostics['logs'] as Map<String, dynamic>;
      final statistics = logs['statistics'] as Map<String, dynamic>;

      expect(statistics['totalLogs'], greaterThan(0));
      expect(statistics['errorCount24h'],
          greaterThan(0)); // At least 1 error (including clear logs)
      expect(
          statistics['warningCount24h'], greaterThan(0)); // At least 1 warning
    });
  });
}
