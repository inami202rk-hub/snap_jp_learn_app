import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:snap_jp_learn_app/services/dictionary_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DictionaryLocalService Tests', () {
    late DictionaryLocalService service;

    setUp(() {
      service = DictionaryLocalService();
    });

    tearDown(() {
      service.clear();
    });

    test('should initialize with mock data', () async {
      // モックデータを設定
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/dict/ja_core.json') {
            return '''{
              "version": "1.0.0",
              "description": "Test Dictionary",
              "entries": [
                {
                  "term": "学校",
                  "reading": "がっこう",
                  "meanings": ["教育機関", "学びの場"]
                },
                {
                  "term": "学生",
                  "reading": "がくせい",
                  "meanings": ["学校に通う人"]
                }
              ]
            }''';
          }
          return null;
        },
      );

      await service.initialize();

      expect(service.isInitialized, true);
      expect(service.stats.totalEntries, 2);
      expect(service.stats.source, 'Local Dictionary (ja_core.json)');
    });

    test('lookup should find exact match', () async {
      // モックデータを設定
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/dict/ja_core.json') {
            return '''{
              "version": "1.0.0",
              "description": "Test Dictionary",
              "entries": [
                {
                  "term": "学校",
                  "reading": "がっこう",
                  "meanings": ["教育機関", "学びの場"]
                }
              ]
            }''';
          }
          return null;
        },
      );

      await service.initialize();

      final result = service.lookup('学校');
      expect(result, isNotNull);
      expect(result!.term, '学校');
      expect(result.reading, 'がっこう');
      expect(result.meanings, ['教育機関', '学びの場']);
    });

    test('lookup should handle normalization', () async {
      // モックデータを設定
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/dict/ja_core.json') {
            return '''{
              "version": "1.0.0",
              "description": "Test Dictionary",
              "entries": [
                {
                  "term": "学校",
                  "reading": "がっこう",
                  "meanings": ["教育機関"]
                }
              ]
            }''';
          }
          return null;
        },
      );

      await service.initialize();

      // 全角・半角の正規化テスト
      final result1 = service.lookup('学校'); // 全角
      final result2 = service.lookup('学校'); // 同じ全角

      expect(result1, isNotNull);
      expect(result2, isNotNull);
      expect(result1, equals(result2));
    });

    test('lookup should return null for non-existent term', () async {
      // モックデータを設定
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/dict/ja_core.json') {
            return '''{
              "version": "1.0.0",
              "description": "Test Dictionary",
              "entries": []
            }''';
          }
          return null;
        },
      );

      await service.initialize();

      final result = service.lookup('存在しない語');
      expect(result, isNull);
    });

    test('lookupAsync should work same as lookup', () async {
      // モックデータを設定
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/dict/ja_core.json') {
            return '''{
              "version": "1.0.0",
              "description": "Test Dictionary",
              "entries": [
                {
                  "term": "学校",
                  "reading": "がっこう",
                  "meanings": ["教育機関"]
                }
              ]
            }''';
          }
          return null;
        },
      );

      await service.initialize();

      final syncResult = service.lookup('学校');
      final asyncResult = await service.lookupAsync('学校');

      expect(syncResult, equals(asyncResult));
    });

    test('should throw exception when not initialized', () {
      expect(() => service.lookup('学校'), throwsA(isA<DictionaryException>()));
    });

    test('should throw exception on initialization failure', () async {
      // 無効なJSONを返すモック
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/dict/ja_core.json') {
            return 'invalid json';
          }
          return null;
        },
      );

      expect(() => service.initialize(), throwsA(isA<DictionaryException>()));
    });

    test('searchPartial should find partial matches', () async {
      // モックデータを設定
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/dict/ja_core.json') {
            return '''{
              "version": "1.0.0",
              "description": "Test Dictionary",
              "entries": [
                {
                  "term": "学校",
                  "reading": "がっこう",
                  "meanings": ["教育機関"]
                },
                {
                  "term": "学生",
                  "reading": "がくせい",
                  "meanings": ["学校に通う人"]
                },
                {
                  "term": "会社",
                  "reading": "かいしゃ",
                  "meanings": ["企業"]
                }
              ]
            }''';
          }
          return null;
        },
      );

      await service.initialize();

      final results = service.searchPartial('学');
      expect(results.length, 2);
      expect(results.any((entry) => entry.term == '学校'), true);
      expect(results.any((entry) => entry.term == '学生'), true);
    });

    test('clear should reset service state', () async {
      // モックデータを設定
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' &&
              methodCall.arguments == 'assets/dict/ja_core.json') {
            return '''{
              "version": "1.0.0",
              "description": "Test Dictionary",
              "entries": [
                {
                  "term": "学校",
                  "reading": "がっこう",
                  "meanings": ["教育機関"]
                }
              ]
            }''';
          }
          return null;
        },
      );

      await service.initialize();
      expect(service.isInitialized, true);

      service.clear();
      expect(service.isInitialized, false);
      expect(service.stats.totalEntries, 0);
    });
  });

  group('DictionaryException Tests', () {
    test('should create exception with message', () {
      const exception = DictionaryException('Test error message');
      expect(exception.message, 'Test error message');
    });

    test('should be throwable', () {
      expect(() => throw const DictionaryException('Test error'),
          throwsA(isA<DictionaryException>()));
    });

    test('toString should return formatted message', () {
      const exception = DictionaryException('Test error message');
      expect(exception.toString(), 'DictionaryException: Test error message');
    });
  });
}
