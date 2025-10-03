/// スペース整形ルール
class SpaceNormalizer {
  /// 行頭・行末の空白を削除
  static String trimSpaces(String text) {
    List<String> lines = text.split('\n');
    return lines.map((line) => line.trim()).join('\n');
  }

  /// 連続スペースを1個に圧縮
  static String collapseSpaces(String text) {
    return text.replaceAll(RegExp(r' {2,}'), ' ');
  }

  /// 和欧境界にスペースを挿入
  /// 日本語と英数字の境界に1スペースを挿入
  static String manageJaEnBoundaries(String text) {
    String result = text;

    // 日本語文字（ひらがな、カタカナ、漢字）と英数字の境界
    result = result.replaceAllMapped(
      RegExp(r'([\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF])([A-Za-z0-9])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    result = result.replaceAllMapped(
      RegExp(r'([A-Za-z0-9])([\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // 数字と英字の境界（2025EXPO → 2025 EXPO）
    result = result.replaceAllMapped(
      RegExp(r'(\d)([A-Za-z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    result = result.replaceAllMapped(
      RegExp(r'([A-Za-z])(\d)'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    // 例外パターン（iPhone13等の典型パターンはスキップ）
    result = _skipTypicalPatterns(result);

    return result;
  }

  /// 典型的なパターンをスキップ（誤置換を避ける）
  static String _skipTypicalPatterns(String text) {
    String result = text;

    // iPhone13, iPad12 等のパターンを元に戻す
    result = result.replaceAllMapped(
      RegExp(r'iPhone (\d+)'),
      (match) => 'iPhone${match.group(1)}',
    );
    result = result.replaceAllMapped(
      RegExp(r'iPad (\d+)'),
      (match) => 'iPad${match.group(1)}',
    );
    result = result.replaceAllMapped(
      RegExp(r'Mac (\d+)'),
      (match) => 'Mac${match.group(1)}',
    );
    result = result.replaceAllMapped(
      RegExp(r'Windows (\d+)'),
      (match) => 'Windows${match.group(1)}',
    );

    // 年号パターンを元に戻す
    result = result.replaceAllMapped(
      RegExp(r'(\d{4}) 年'),
      (match) => '${match.group(1)}年',
    );
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,2}) 月'),
      (match) => '${match.group(1)}月',
    );
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,2}) 日'),
      (match) => '${match.group(1)}日',
    );

    // 日本語文字と英数字の境界で、英数字が連続している場合は元に戻す
    result = result.replaceAllMapped(
      RegExp(r'([A-Za-z])(\d+) ([A-Za-z])'),
      (match) => '${match.group(1)}${match.group(2)}${match.group(3)}',
    );

    // iPhone13が のようなパターンを元に戻す
    result = result.replaceAllMapped(
      RegExp(r'iPhone(\d+) が'),
      (match) => 'iPhone${match.group(1)}が',
    );
    result = result.replaceAllMapped(
      RegExp(r'iPad(\d+) が'),
      (match) => 'iPad${match.group(1)}が',
    );

    return result;
  }
}

/// 改行整形ルール
class LinebreakNormalizer {
  /// 改行を正規化
  /// - 3連以上の改行を2つまでに圧縮
  /// - OCR誤改行を抑制（文末でない改行を削除）
  /// - 行末の「。」が無い場合でも段落改行は保持
  static String normalizeLinebreaks(String text) {
    String result = text;

    // 3連以上の改行を2つまでに圧縮
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // 行末の空白を削除
    result = result.replaceAll(RegExp(r' +\n'), '\n');

    // 空行の前後の余分な空白を削除
    result = result.replaceAll(RegExp(r'\n +\n'), '\n\n');

    // OCR誤改行を抑制（文末でない改行を削除）
    result = suppressOcrLinebreaks(result);

    return result;
  }

  /// OCR誤改行を抑制
  /// 文末記号（。！？）でない改行を削除
  static String suppressOcrLinebreaks(String text) {
    String result = text;

    // 文末記号でない改行を削除（ただし段落区切りは保持）
    result = result.replaceAllMapped(
      RegExp(r'([^。！？\n])\n([^。！？\n])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return result;
  }
}
