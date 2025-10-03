/// ダッシュ・長音正規化ルール
class DashNormalizer {
  /// ダッシュ・長音を正規化
  /// 日本語語中は ー、英語/数式は - に統一
  static String normalizeDashes(String text) {
    String result = text;

    // 行ごとに処理
    List<String> lines = result.split('\n');
    List<String> processedLines = [];

    for (String line in lines) {
      String processedLine = line;

      // 日本語が含まれている行は長音に統一
      if (_containsJapanese(processedLine)) {
        processedLine = processedLine.replaceAll('—', 'ー'); // em dash
        processedLine = processedLine.replaceAll('–', 'ー'); // en dash
        processedLine = processedLine.replaceAll(
          'ｰ',
          'ー',
        ); // half-width katakana
      } else {
        // 英語行はハイフンに統一
        processedLine = processedLine.replaceAll('—', '-'); // em dash
        processedLine = processedLine.replaceAll('–', '-'); // en dash
        processedLine = processedLine.replaceAll(
          'ｰ',
          '-',
        ); // half-width katakana
      }

      processedLines.add(processedLine);
    }

    return processedLines.join('\n');
  }

  /// 日本語文字が含まれているかチェック
  static bool _containsJapanese(String text) {
    return RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(text);
  }
}

/// 中黒正規化ルール
class BulletNormalizer {
  /// 中黒を統一（･ • → ・）
  static String normalizeBullets(String text) {
    String result = text;

    result = result.replaceAll('･', '・'); // half-width katakana middle dot
    result = result.replaceAll('•', '・'); // bullet

    return result;
  }
}

/// 引用符統一ルール
class QuoteNormalizer {
  /// 引用符を統一
  /// 日本語行は「 」、英語行は " を維持
  static String unifyQuotes(String text) {
    String result = text;

    // 行ごとに処理
    List<String> lines = result.split('\n');
    List<String> processedLines = [];

    for (String line in lines) {
      String processedLine = line;

      // 日本語が含まれている行は「 」に統一
      if (_containsJapanese(processedLine)) {
        // 最初の " を「に、最後の " を」に変換
        processedLine = processedLine.replaceFirst('"', '「');
        processedLine = processedLine.replaceAll('"', '」');
      }
      // 英語行は " を維持（変更なし）

      processedLines.add(processedLine);
    }

    return processedLines.join('\n');
  }

  /// 日本語文字が含まれているかチェック
  static bool _containsJapanese(String text) {
    return RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]').hasMatch(text);
  }
}

/// 句読点正規化ルール
class PunctuationNormalizer {
  /// 末尾の句読点連続を1つに正規化（。。 → 。）
  static String normalizeEndPunctuation(String text) {
    String result = text;

    // 文末の句読点連続を1つに（行末のみ）
    result = result.replaceAll(RegExp(r'。{2,}(?=\s*$)'), '。');
    result = result.replaceAll(RegExp(r'、{2,}(?=\s*$)'), '、');
    result = result.replaceAll(RegExp(r'！{2,}(?=\s*$)'), '！');
    result = result.replaceAll(RegExp(r'？{2,}(?=\s*$)'), '？');

    return result;
  }

  /// 句読点を日本語標準に統一
  /// 「，」→「、」、「．」→「。」
  static String unifyJapanesePunctuation(String text) {
    String result = text;

    // カンマを読点に統一
    result = result.replaceAll('，', '、');

    // ピリオドを句点に統一（行末のみ）
    result = result.replaceAllMapped(
      RegExp(r'\.(?=\s*$)'),
      (match) => '。',
    );

    return result;
  }
}
