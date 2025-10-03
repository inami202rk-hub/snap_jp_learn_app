import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/dictionary_entry.dart';
import '../../lib/services/dictionary_service.dart';

void main() {
  group('DictionaryEntry Tests', () {
    test('should be created with required fields', () {
      const entry = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関', '学びの場'],
      );

      expect(entry.term, '学校');
      expect(entry.reading, 'がっこう');
      expect(entry.meanings, ['教育機関', '学びの場']);
    });

    test('copyWith should create new instance with updated fields', () {
      const original = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関'],
      );

      final updated = original.copyWith(
        reading: 'がっこう（小学校）',
        meanings: ['教育機関', '学びの場'],
      );

      expect(updated.term, '学校');
      expect(updated.reading, 'がっこう（小学校）');
      expect(updated.meanings, ['教育機関', '学びの場']);
    });

    test('toJson should serialize correctly', () {
      const entry = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関', '学びの場'],
      );

      final json = entry.toJson();

      expect(json['term'], '学校');
      expect(json['reading'], 'がっこう');
      expect(json['meanings'], ['教育機関', '学びの場']);
    });

    test('fromJson should deserialize correctly', () {
      final json = {
        'term': '学校',
        'reading': 'がっこう',
        'meanings': ['教育機関', '学びの場'],
      };

      final entry = DictionaryEntry.fromJson(json);

      expect(entry.term, '学校');
      expect(entry.reading, 'がっこう');
      expect(entry.meanings, ['教育機関', '学びの場']);
    });

    test('equality should work correctly', () {
      const entry1 = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関'],
      );

      const entry2 = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関'],
      );

      const entry3 = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関', '学びの場'],
      );

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
    });

    test('toString should return readable string', () {
      const entry = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関'],
      );

      final str = entry.toString();

      expect(str, contains('学校'));
      expect(str, contains('がっこう'));
      expect(str, contains('教育機関'));
    });
  });

  group('DictionaryStats Tests', () {
    test('should be created with required fields', () {
      final stats = DictionaryStats(
        totalEntries: 100,
        lastUpdated: DateTime(2024, 1, 1),
        source: 'Test Dictionary',
      );

      expect(stats.totalEntries, 100);
      expect(stats.lastUpdated, DateTime(2024, 1, 1));
      expect(stats.source, 'Test Dictionary');
    });

    test('toJson should serialize correctly', () {
      final stats = DictionaryStats(
        totalEntries: 100,
        lastUpdated: DateTime(2024, 1, 1),
        source: 'Test Dictionary',
      );

      final json = stats.toJson();

      expect(json['totalEntries'], 100);
      expect(json['lastUpdated'], '2024-01-01T00:00:00.000');
      expect(json['source'], 'Test Dictionary');
    });

    test('fromJson should deserialize correctly', () {
      final json = {
        'totalEntries': 100,
        'lastUpdated': '2024-01-01T00:00:00.000',
        'source': 'Test Dictionary',
      };

      final stats = DictionaryStats.fromJson(json);

      expect(stats.totalEntries, 100);
      expect(stats.lastUpdated, DateTime(2024, 1, 1));
      expect(stats.source, 'Test Dictionary');
    });
  });
}
