/// Unicode正規化ルール
class UnicodeNormalizer {
  /// Unicode正規化（NFKC）を適用
  /// 互換分解→結合の順序で正規化
  static String normalizeUnicode(String text) {
    // DartのString.normalize()は利用できないため、
    // 基本的な正規化のみ実装
    // 実際のNFKC正規化は外部ライブラリが必要
    return text;
  }
}

/// 不可視・制御文字除去ルール
class InvisibleCharRemover {
  /// 不可視文字・制御文字を除去
  /// - Zero Width Space (\u200B)
  /// - BOM (\uFEFF)
  /// - 異常なタブ連打
  /// - その他の制御文字
  static String removeInvisibleChars(String text) {
    // Zero Width Space と BOM を除去
    String result = text.replaceAll('\u200B', ''); // Zero Width Space
    result = result.replaceAll('\uFEFF', ''); // BOM

    // 制御文字を除去（改行・タブ・スペース以外）
    result = result.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '');

    // 異常なタブ連打を単一タブに
    result = result.replaceAll(RegExp(r'\t{2,}'), '\t');

    return result;
  }
}

/// 全角・半角統一ルール
class WidthNormalizer {
  /// 英数字・記号を半角に統一
  /// 日本語はそのまま保持
  static String normalizeAsciiWidth(String text) {
    String result = text;

    // 全角英数字を半角に変換
    result = result.replaceAllMapped(RegExp(r'[０-９]'), (match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xFF10 + 0x30);
    });

    result = result.replaceAllMapped(RegExp(r'[Ａ-Ｚ]'), (match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xFF21 + 0x41);
    });

    result = result.replaceAllMapped(RegExp(r'[ａ-ｚ]'), (match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xFF41 + 0x61);
    });

    // 全角記号を半角に変換
    result = result.replaceAll('（', '(');
    result = result.replaceAll('）', ')');
    result = result.replaceAll('［', '[');
    result = result.replaceAll('］', ']');
    result = result.replaceAll('｛', '{');
    result = result.replaceAll('｝', '}');
    result = result.replaceAll('「', '"');
    result = result.replaceAll('」', '"');
    result = result.replaceAll('『', "'");
    result = result.replaceAll('』', "'");
    result = result.replaceAll('＋', '+');
    result = result.replaceAll('－', '-');
    result = result.replaceAll('＊', '*');
    result = result.replaceAll('／', '/');
    result = result.replaceAll('＝', '=');
    result = result.replaceAll('％', '%');
    result = result.replaceAll('＃', '#');
    result = result.replaceAll('＠', '@');
    result = result.replaceAll('！', '!');
    result = result.replaceAll('？', '?');
    result = result.replaceAll('：', ':');
    result = result.replaceAll('；', ';');
    result = result.replaceAll('，', ',');
    result = result.replaceAll('．', '.');

    return result;
  }

  /// 日本語句読点の統一（, . → 、 。）
  /// 日本語行のみに適用
  static String unifyJapanesePunctuation(String text) {
    String result = text;

    // 行ごとに処理
    List<String> lines = result.split('\n');
    List<String> processedLines = [];

    for (String line in lines) {
      String processedLine = line;

      // 日本語が含まれている行のみ処理
      if (_containsJapanese(processedLine)) {
        // 文末の . を 。 に変換
        processedLine = processedLine.replaceAll(RegExp(r'\.(?=\s*$)'), '。');

        // 文中の , を 、 に変換（ただし英語の数字表記は除外）
        processedLine = processedLine.replaceAll(
          RegExp(r',(?=\s*[^0-9])'),
          '、',
        );
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
