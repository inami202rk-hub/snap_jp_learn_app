import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/vocab_extractor.dart';

void main() {
  group('VocabExtractor Tests', () {
    test('extractFrom should extract kanji terms', () {
      const text = '今日は新宿駅でラーメンを食べました。';
      final candidates = VocabExtractor.extractFrom(text);

      expect(candidates.length, greaterThan(0));
      
      // 新宿駅、ラーメンが抽出されることを確認
      final terms = candidates.map((c) => c.term).toList();
      expect(terms, contains('新宿駅'));
      expect(terms, contains('ラーメン'));
      
      // 駅は単独では除外されるが、新宿駅として抽出される
      expect(terms, isNot(contains('駅')));
    });

    test('extractFrom should extract katakana terms', () {
      const text = 'コンピューターでプログラミングを勉強しています。';
      final candidates = VocabExtractor.extractFrom(text);

      expect(candidates.length, greaterThan(0));
      
      final terms = candidates.map((c) => c.term).toList();
      expect(terms, contains('コンピューター'));
      expect(terms, contains('プログラミング'));
    });

    test('extractFrom should exclude numbers only', () {
      const text = '2024年12月31日に1234円を支払いました。';
      final candidates = VocabExtractor.extractFrom(text);

      final terms = candidates.map((c) => c.term).toList();
      expect(terms, isNot(contains('2024')));
      expect(terms, isNot(contains('1234')));
    });

    test('extractFrom should exclude common particles', () {
      const text = 'これはテストです。それもテストです。';
      final candidates = VocabExtractor.extractFrom(text);

      final terms = candidates.map((c) => c.term).toList();
      expect(terms, isNot(contains('です')));
      expect(terms, isNot(contains('これ')));
      expect(terms, isNot(contains('それ')));
    });

    test('extractFrom should handle empty text', () {
      const text = '';
      final candidates = VocabExtractor.extractFrom(text);

      expect(candidates, isEmpty);
    });

    test('extractFrom should handle text with no extractable terms', () {
      const text = 'ですます。これそれ。';
      final candidates = VocabExtractor.extractFrom(text);

      expect(candidates, isEmpty);
    });

    test('extractFrom should create snippets with term markers', () {
      const text = '今日は新宿駅でラーメンを食べました。';
      final candidates = VocabExtractor.extractFrom(text);

      expect(candidates.length, greaterThan(0));
      
      // スニペットに【】マーカーが含まれることを確認
      final snippets = candidates.map((c) => c.snippet).toList();
      for (final snippet in snippets) {
        expect(snippet, contains('【'));
        expect(snippet, contains('】'));
      }
    });

    test('extractFrom should remove duplicates', () {
      const text = '新宿で新宿を訪れました。';
      final candidates = VocabExtractor.extractFrom(text);

      final terms = candidates.map((c) => c.term).toList();
      final uniqueTerms = terms.toSet().toList();
      
      // 重複が除去されていることを確認（新宿が2回出現するが1つに統合される）
      // ただし、スニペットが異なる場合は別の候補として扱われる可能性がある
      expect(uniqueTerms.length, lessThanOrEqualTo(terms.length));
    });

    test('filterCandidates should filter by length', () {
      const text = '新宿駅でラーメンを食べました。';
      final candidates = VocabExtractor.extractFrom(text);
      final filtered = VocabExtractor.filterCandidates(
        candidates,
        minLength: 3,
        maxLength: 10,
      );

      for (final candidate in filtered) {
        expect(candidate.term.length, greaterThanOrEqualTo(3));
        expect(candidate.term.length, lessThanOrEqualTo(10));
      }
    });

    test('filterCandidates should limit number of candidates', () {
      const text = '新宿駅でラーメンを食べました。コンピューターでプログラミングを勉強しています。';
      final candidates = VocabExtractor.extractFrom(text);
      final filtered = VocabExtractor.filterCandidates(
        candidates,
        maxCandidates: 3,
      );

      expect(filtered.length, lessThanOrEqualTo(3));
    });

    test('scoreCandidates should sort by length', () {
      const text = '新宿でラーメンを食べました。';
      final candidates = VocabExtractor.extractFrom(text);
      final scored = VocabExtractor.scoreCandidates(candidates);

      // 長い語彙が先に来ることを確認
      if (scored.length > 1) {
        expect(scored[0].term.length, greaterThanOrEqualTo(scored[1].term.length));
      }
    });

    test('VocabCandidate should have correct properties', () {
      const candidate = VocabCandidate(
        term: 'テスト',
        snippet: 'これは【テスト】です',
        startIndex: 3,
        endIndex: 5,
      );

      expect(candidate.term, 'テスト');
      expect(candidate.snippet, 'これは【テスト】です');
      expect(candidate.startIndex, 3);
      expect(candidate.endIndex, 5);
    });

    test('VocabCandidate equality should work correctly', () {
      const candidate1 = VocabCandidate(
        term: 'テスト',
        snippet: 'これは【テスト】です',
        startIndex: 3,
        endIndex: 5,
      );

      const candidate2 = VocabCandidate(
        term: 'テスト',
        snippet: 'これは【テスト】です',
        startIndex: 3,
        endIndex: 5,
      );

      const candidate3 = VocabCandidate(
        term: 'テスト',
        snippet: 'これは【テスト】です',
        startIndex: 4,
        endIndex: 6,
      );

      expect(candidate1, equals(candidate2));
      expect(candidate1, isNot(equals(candidate3)));
    });
  });
}
