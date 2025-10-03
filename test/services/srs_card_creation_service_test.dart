import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/srs_card_creation_service.dart';
import 'package:snap_jp_learn_app/models/dictionary_entry.dart';
import 'package:snap_jp_learn_app/services/dictionary_service.dart';
import 'package:snap_jp_learn_app/services/vocab_extractor.dart';

// モック辞書サービス
class MockDictionaryService implements DictionaryService {
  final Map<String, DictionaryEntry> _entries = {};

  void addEntry(String term, DictionaryEntry entry) {
    _entries[term] = entry;
  }

  @override
  DictionaryEntry? lookup(String term) {
    return _entries[term];
  }

  @override
  Future<DictionaryEntry?> lookupAsync(String term) async {
    return lookup(term);
  }

  @override
  bool get isInitialized => true;

  @override
  Future<void> initialize() async {}

  @override
  DictionaryStats get stats => DictionaryStats(
        totalEntries: 0,
        lastUpdated: DateTime.now(),
        source: 'Mock Dictionary',
      );
}

void main() {
  group('SrsCardCreationService Tests', () {
    late SrsCardCreationService service;
    late MockDictionaryService mockDictionary;

    setUp(() {
      mockDictionary = MockDictionaryService();
      service = SrsCardCreationService(dictionaryService: mockDictionary);
    });

    test(
        'extractCandidatesWithDictionary should return candidates with dictionary info',
        () async {
      // モック辞書にエントリを追加
      mockDictionary.addEntry(
          '学校',
          const DictionaryEntry(
            term: '学校',
            reading: 'がっこう',
            meanings: ['教育機関', '学びの場'],
          ));

      mockDictionary.addEntry(
          '学生',
          const DictionaryEntry(
            term: '学生',
            reading: 'がくせい',
            meanings: ['学校に通う人'],
          ));

      final text = '学校で学生が勉強している。';
      final results = await service.extractCandidatesWithDictionary(text);

      expect(results.length, greaterThan(0));

      // 学校がヒットすることを確認
      final schoolResult = results.firstWhere(
        (r) => r.candidate.term == '学校',
        orElse: () => throw Exception('学校が見つからない'),
      );
      expect(schoolResult.hasDictionaryEntry, true);
      expect(schoolResult.dictionaryEntry!.reading, 'がっこう');
      expect(schoolResult.dictionaryEntry!.meanings, ['教育機関', '学びの場']);
    });

    test(
        'extractCandidatesWithDictionary should handle terms not in dictionary',
        () async {
      // 辞書にエントリを追加しない（空の辞書）
      final text = '未知の語彙が含まれている。';
      final results = await service.extractCandidatesWithDictionary(text);

      expect(results.length, greaterThan(0));

      // すべての結果が辞書にヒットしないことを確認
      for (final result in results) {
        expect(result.hasDictionaryEntry, false);
        expect(result.dictionarySummary, '未登録（後で編集可能）');
      }
    });

    test('createCardFromCandidate should create card with dictionary info', () {
      const candidate = VocabCandidate(
        term: '学校',
        snippet: '学校で勉強する',
        startIndex: 0,
        endIndex: 2,
      );

      const dictionaryEntry = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関', '学びの場'],
      );

      final candidateWithDict = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: dictionaryEntry,
      );

      final card = service.createCardFromCandidate(candidateWithDict);

      expect(card.term, '学校');
      expect(card.reading, 'がっこう');
      expect(card.meaning, '教育機関; 学びの場');
      expect(card.sourceSnippet, '学校で勉強する');
      expect(card.repetition, 0);
      expect(card.interval, 0);
    });

    test('createCardFromCandidate should create card without dictionary info',
        () {
      const candidate = VocabCandidate(
        term: '未知の語',
        snippet: '未知の語が使われている',
        startIndex: 0,
        endIndex: 3,
      );

      final candidateWithDict = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: null,
      );

      final card = service.createCardFromCandidate(candidateWithDict);

      expect(card.term, '未知の語');
      expect(card.meaning, '');
      expect(card.sourceSnippet, '未知の語が使われている');
    });

    test('createCardsFromCandidates should create multiple cards', () {
      final candidatesWithDict = [
        VocabCandidateWithDictionary(
          candidate: const VocabCandidate(
            term: '学校',
            snippet: '学校で勉強する',
            startIndex: 0,
            endIndex: 2,
          ),
          dictionaryEntry: const DictionaryEntry(
            term: '学校',
            reading: 'がっこう',
            meanings: ['教育機関'],
          ),
        ),
        VocabCandidateWithDictionary(
          candidate: const VocabCandidate(
            term: '学生',
            snippet: '学生が勉強する',
            startIndex: 0,
            endIndex: 2,
          ),
          dictionaryEntry: const DictionaryEntry(
            term: '学生',
            reading: 'がくせい',
            meanings: ['学校に通う人'],
          ),
        ),
      ];

      final cards = service.createCardsFromCandidates(candidatesWithDict);

      expect(cards.length, 2);
      expect(cards[0].term, '学校');
      expect(cards[0].reading, 'がっこう');
      expect(cards[1].term, '学生');
      expect(cards[1].reading, 'がくせい');
    });
  });

  group('VocabCandidateWithDictionary Tests', () {
    test('should be created with candidate and dictionary entry', () {
      const candidate = VocabCandidate(
        term: '学校',
        snippet: '学校で勉強する',
        startIndex: 0,
        endIndex: 2,
      );

      const dictionaryEntry = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関'],
      );

      final candidateWithDict = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: dictionaryEntry,
      );

      expect(candidateWithDict.candidate, candidate);
      expect(candidateWithDict.dictionaryEntry, dictionaryEntry);
    });

    test('hasDictionaryEntry should return correct value', () {
      const candidate = VocabCandidate(
        term: '学校',
        snippet: '学校で勉強する',
        startIndex: 0,
        endIndex: 2,
      );

      // 辞書エントリあり
      final withEntry = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: const DictionaryEntry(
          term: '学校',
          reading: 'がっこう',
          meanings: ['教育機関'],
        ),
      );
      expect(withEntry.hasDictionaryEntry, true);

      // 辞書エントリなし
      final withoutEntry = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: null,
      );
      expect(withoutEntry.hasDictionaryEntry, false);
    });

    test('hasReading should return correct value', () {
      const candidate = VocabCandidate(
        term: '学校',
        snippet: '学校で勉強する',
        startIndex: 0,
        endIndex: 2,
      );

      // 読みあり
      final withReading = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: const DictionaryEntry(
          term: '学校',
          reading: 'がっこう',
          meanings: ['教育機関'],
        ),
      );
      expect(withReading.hasReading, true);

      // 読みなし
      final withoutReading = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: const DictionaryEntry(
          term: '学校',
          reading: '',
          meanings: ['教育機関'],
        ),
      );
      expect(withoutReading.hasReading, false);

      // 辞書エントリなし
      final withoutEntry = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: null,
      );
      expect(withoutEntry.hasReading, false);
    });

    test('hasMeanings should return correct value', () {
      const candidate = VocabCandidate(
        term: '学校',
        snippet: '学校で勉強する',
        startIndex: 0,
        endIndex: 2,
      );

      // 意味あり
      final withMeanings = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: const DictionaryEntry(
          term: '学校',
          reading: 'がっこう',
          meanings: ['教育機関'],
        ),
      );
      expect(withMeanings.hasMeanings, true);

      // 意味なし
      final withoutMeanings = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: const DictionaryEntry(
          term: '学校',
          reading: 'がっこう',
          meanings: [],
        ),
      );
      expect(withoutMeanings.hasMeanings, false);

      // 辞書エントリなし
      final withoutEntry = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: null,
      );
      expect(withoutEntry.hasMeanings, false);
    });

    test('dictionarySummary should return correct summary', () {
      const candidate = VocabCandidate(
        term: '学校',
        snippet: '学校で勉強する',
        startIndex: 0,
        endIndex: 2,
      );

      // 辞書エントリなし
      final withoutEntry = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: null,
      );
      expect(withoutEntry.dictionarySummary, '未登録（後で編集可能）');

      // 読みのみ
      final readingOnly = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: const DictionaryEntry(
          term: '学校',
          reading: 'がっこう',
          meanings: [],
        ),
      );
      expect(readingOnly.dictionarySummary, '読み: がっこう');

      // 読みと意味1つ
      final singleMeaning = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: const DictionaryEntry(
          term: '学校',
          reading: 'がっこう',
          meanings: ['教育機関'],
        ),
      );
      expect(singleMeaning.dictionarySummary, '読み: がっこう, 意味: 教育機関');

      // 読みと意味複数
      final multipleMeanings = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: const DictionaryEntry(
          term: '学校',
          reading: 'がっこう',
          meanings: ['教育機関', '学びの場', '学習施設'],
        ),
      );
      expect(multipleMeanings.dictionarySummary, '読み: がっこう, 意味: 教育機関 他2件');
    });

    test('toString should return readable string', () {
      const candidate = VocabCandidate(
        term: '学校',
        snippet: '学校で勉強する',
        startIndex: 0,
        endIndex: 2,
      );

      const dictionaryEntry = DictionaryEntry(
        term: '学校',
        reading: 'がっこう',
        meanings: ['教育機関'],
      );

      final candidateWithDict = VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: dictionaryEntry,
      );

      final str = candidateWithDict.toString();
      expect(str, contains('学校'));
      expect(str, contains('がっこう'));
    });
  });
}
