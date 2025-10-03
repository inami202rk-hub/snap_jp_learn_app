/// 語彙候補を表すクラス
class VocabCandidate {
  final String term;
  final String snippet;
  final int startIndex;
  final int endIndex;

  const VocabCandidate({
    required this.term,
    required this.snippet,
    required this.startIndex,
    required this.endIndex,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VocabCandidate &&
        other.term == term &&
        other.snippet == snippet &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex;
  }

  @override
  int get hashCode {
    return Object.hash(term, snippet, startIndex, endIndex);
  }

  @override
  String toString() {
    return 'VocabCandidate(term: $term, snippet: $snippet, startIndex: $startIndex, endIndex: $endIndex)';
  }
}

/// 日本語テキストから語彙候補を抽出するサービス
class VocabExtractor {
  /// 正規化されたテキストから語彙候補を抽出
  ///
  /// [normalizedText] 抽出対象のテキスト
  ///
  /// Returns: 語彙候補のリスト（重複除去済み）
  static List<VocabCandidate> extractFrom(String normalizedText) {
    if (normalizedText.isEmpty) return [];

    final candidates = <VocabCandidate>[];

    // 漢字語の抽出（2-8文字）
    candidates.addAll(_extractKanjiTerms(normalizedText));

    // カタカナ語の抽出（2-20文字）
    candidates.addAll(_extractKatakanaTerms(normalizedText));

    // 重複除去（term + snippet の組み合わせでユニーク化）
    final uniqueCandidates = <String, VocabCandidate>{};
    for (final candidate in candidates) {
      final key = '${candidate.term}#${candidate.snippet}';
      if (!uniqueCandidates.containsKey(key)) {
        uniqueCandidates[key] = candidate;
      }
    }

    return uniqueCandidates.values.toList();
  }

  /// 漢字語を抽出
  static List<VocabCandidate> _extractKanjiTerms(String text) {
    final candidates = <VocabCandidate>[];

    // 漢字の正規表現（CJK統合漢字 + CJK拡張A + CJK拡張B）
    final kanjiRegex = RegExp(
      r'[\u4E00-\u9FFF\u3400-\u4DBF\u20000-\u2A6DF]{2,8}',
    );

    for (final match in kanjiRegex.allMatches(text)) {
      final term = match.group(0)!;

      // 除外条件
      if (_shouldExcludeTerm(term)) continue;

      final snippet = _extractSnippet(text, match.start, match.end);
      candidates.add(
        VocabCandidate(
          term: term,
          snippet: snippet,
          startIndex: match.start,
          endIndex: match.end,
        ),
      );
    }

    return candidates;
  }

  /// カタカナ語を抽出
  static List<VocabCandidate> _extractKatakanaTerms(String text) {
    final candidates = <VocabCandidate>[];

    // カタカナの正規表現（カタカナ + 長音符）
    final katakanaRegex = RegExp(r'[ァ-ヴー]{2,20}');

    for (final match in katakanaRegex.allMatches(text)) {
      final term = match.group(0)!;

      // 除外条件
      if (_shouldExcludeTerm(term)) continue;

      final snippet = _extractSnippet(text, match.start, match.end);
      candidates.add(
        VocabCandidate(
          term: term,
          snippet: snippet,
          startIndex: match.start,
          endIndex: match.end,
        ),
      );
    }

    return candidates;
  }

  /// 語彙候補を除外すべきかチェック
  static bool _shouldExcludeTerm(String term) {
    // 数字のみ
    if (RegExp(r'^\d+$').hasMatch(term)) return true;

    // 記号のみ
    if (RegExp(
      r'^[^\w\u4E00-\u9FFF\u3400-\u4DBF\u20000-\u2A6DF\u3040-\u309F\u30A0-\u30FF]+$',
    ).hasMatch(term))
      return true;

    // ひらがなのみ（短すぎる場合）
    if (RegExp(r'^[ひらがな]{1,3}$').hasMatch(term)) return true;

    // よくある除外語
    final excludeTerms = {
      'です',
      'ます',
      'する',
      'なる',
      'ある',
      'いる',
      'ない',
      'だ',
      'である',
      'から',
      'まで',
      'より',
      'ので',
      'のに',
      'ため',
      'とき',
      'こと',
      'もの',
      'これ',
      'それ',
      'あれ',
      'どれ',
      'ここ',
      'そこ',
      'あそこ',
      'どこ',
      'わたし',
      'あなた',
      'かれ',
      'かのじょ',
      'ぼく',
      'おれ',
    };

    return excludeTerms.contains(term);
  }

  /// 語彙の前後から文脈スニペットを抽出
  static String _extractSnippet(String text, int start, int end) {
    const snippetLength = 40; // 前後20文字ずつ

    final snippetStart = (start - snippetLength).clamp(0, text.length);
    final snippetEnd = (end + snippetLength).clamp(0, text.length);

    String snippet = text.substring(snippetStart, snippetEnd);

    // 語彙の位置をマーク
    final termStart = start - snippetStart;
    final termEnd = end - snippetStart;

    if (termStart >= 0 && termEnd <= snippet.length) {
      snippet =
          '${snippet.substring(0, termStart)}【${snippet.substring(termStart, termEnd)}】${snippet.substring(termEnd)}';
    }

    return snippet;
  }

  /// 語彙候補をフィルタリング（長さや頻度に基づく）
  static List<VocabCandidate> filterCandidates(
    List<VocabCandidate> candidates, {
    int minLength = 2,
    int maxLength = 20,
    int maxCandidates = 50,
  }) {
    return candidates
        .where(
          (candidate) =>
              candidate.term.length >= minLength &&
              candidate.term.length <= maxLength,
        )
        .take(maxCandidates)
        .toList();
  }

  /// 語彙候補をスコアリング（将来的な改善用）
  static List<VocabCandidate> scoreCandidates(List<VocabCandidate> candidates) {
    // 現在は単純に長さでスコアリング
    candidates.sort((a, b) {
      // 長い語彙を優先（学習価値が高いと仮定）
      final lengthComparison = b.term.length.compareTo(a.term.length);
      if (lengthComparison != 0) return lengthComparison;

      // 同じ長さなら出現位置でソート
      return a.startIndex.compareTo(b.startIndex);
    });

    return candidates;
  }
}
