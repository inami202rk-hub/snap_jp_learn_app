import '../models/srs_card.dart';
import '../models/dictionary_entry.dart';
import '../services/dictionary_service.dart';
import '../services/vocab_extractor.dart';

/// SRSカード作成サービス
/// 語彙抽出と辞書検索を組み合わせてカードを作成
class SrsCardCreationService {
  final DictionaryService _dictionaryService;

  SrsCardCreationService({
    required DictionaryService dictionaryService,
  }) : _dictionaryService = dictionaryService;

  /// テキストから語彙候補を抽出し、辞書検索結果付きで返す
  Future<List<VocabCandidateWithDictionary>> extractCandidatesWithDictionary(
    String text,
  ) async {
    // 語彙候補を抽出
    final candidates = VocabExtractor.extractFrom(text);

    // 各候補に対して辞書検索
    final results = <VocabCandidateWithDictionary>[];

    for (final candidate in candidates) {
      final dictionaryEntry = _dictionaryService.lookup(candidate.term);
      results.add(VocabCandidateWithDictionary(
        candidate: candidate,
        dictionaryEntry: dictionaryEntry,
      ));
    }

    return results;
  }

  /// 語彙候補からSRSカードを作成
  SrsCard createCardFromCandidate(
      VocabCandidateWithDictionary candidateWithDict) {
    final candidate = candidateWithDict.candidate;
    final dictionaryEntry = candidateWithDict.dictionaryEntry;

    return SrsCard(
      id: '', // UUIDは呼び出し元で生成
      term: candidate.term,
      reading: dictionaryEntry?.reading ?? '',
      meaning: dictionaryEntry?.meanings.join('; ') ?? '',
      sourcePostId: '', // 呼び出し元で設定
      sourceSnippet: candidate.snippet,
      createdAt: DateTime.now(),
      interval: 0,
      easeFactor: 2.5,
      repetition: 0,
      due: DateTime.now(),
    );
  }

  /// 複数の語彙候補からSRSカードを一括作成
  List<SrsCard> createCardsFromCandidates(
    List<VocabCandidateWithDictionary> candidatesWithDict,
  ) {
    return candidatesWithDict.map(createCardFromCandidate).toList();
  }
}

/// 語彙候補と辞書検索結果の組み合わせ
class VocabCandidateWithDictionary {
  final VocabCandidate candidate;
  final DictionaryEntry? dictionaryEntry;

  const VocabCandidateWithDictionary({
    required this.candidate,
    this.dictionaryEntry,
  });

  /// 辞書にヒットしたかどうか
  bool get hasDictionaryEntry => dictionaryEntry != null;

  /// 読みが取得できるかどうか
  bool get hasReading => dictionaryEntry?.reading.isNotEmpty ?? false;

  /// 意味が取得できるかどうか
  bool get hasMeanings => dictionaryEntry?.meanings.isNotEmpty ?? false;

  /// 辞書情報の要約
  String get dictionarySummary {
    if (dictionaryEntry == null) {
      return '未登録（後で編集可能）';
    }

    final reading = dictionaryEntry!.reading;
    final meanings = dictionaryEntry!.meanings;

    if (meanings.isEmpty) {
      return '読み: $reading';
    }

    final firstMeaning = meanings.first;
    if (meanings.length == 1) {
      return '読み: $reading, 意味: $firstMeaning';
    } else {
      return '読み: $reading, 意味: $firstMeaning 他${meanings.length - 1}件';
    }
  }

  @override
  String toString() {
    return 'VocabCandidateWithDictionary(candidate: $candidate, dictionaryEntry: $dictionaryEntry)';
  }
}
