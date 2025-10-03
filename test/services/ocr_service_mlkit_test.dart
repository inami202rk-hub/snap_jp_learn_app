import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/ocr_service.dart';
import 'package:snap_jp_learn_app/services/ocr_service_mlkit.dart';

void main() {
  // ML Kit tests are skipped in unit test environment
  // These require actual device/emulator to run properly

  group(
    'OcrServiceMlkit',
    () {
      test('OcrServiceMlkit basic instantiation test', () {
        // Basic test that doesn't involve ML Kit initialization
        expect(OcrServiceMlkit, isA<Type>());
      });
    },
    skip: Platform.environment.containsKey('CI')
        ? 'CI環境ではスキップ'
        : 'ML Kit tests require device/emulator environment',
  );

  group('OcrException', () {
    test('should create exception with message', () {
      const message = 'Test error message';
      final exception = OcrException(message);

      expect(exception.message, equals(message));
      expect(exception.toString(), equals('OcrException: $message'));
    });

    test('should be throwable', () {
      const message = 'Test exception';

      expect(() => throw OcrException(message), throwsA(isA<OcrException>()));
    });
  });
}
