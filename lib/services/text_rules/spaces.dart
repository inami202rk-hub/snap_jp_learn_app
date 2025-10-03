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
    result = result.replaceAll(
      RegExp(r'([\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF])([A-Za-z0-9])'),
      r'$1 $2',
    );
    result = result.replaceAll(
      RegExp(r'([A-Za-z0-9])([\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF])'),
      r'$1 $2',
    );

    // 例外パターン（iPhone13等の典型パターンはスキップ）
    result = _skipTypicalPatterns(result);

    return result;
  }

  /// 典型的なパターンをスキップ（誤置換を避ける）
  static String _skipTypicalPatterns(String text) {
    String result = text;
    
    // iPhone13, iPad12 等のパターンを元に戻す
    result = result.replaceAllMapped(RegExp(r'iPhone (\d+)'), (match) => 'iPhone${match.group(1)}');
    result = result.replaceAllMapped(RegExp(r'iPad (\d+)'), (match) => 'iPad${match.group(1)}');
    result = result.replaceAllMapped(RegExp(r'Mac (\d+)'), (match) => 'Mac${match.group(1)}');
    result = result.replaceAllMapped(RegExp(r'Windows (\d+)'), (match) => 'Windows${match.group(1)}');
    
    // 年号パターンを元に戻す
    result = result.replaceAllMapped(RegExp(r'(\d{4}) 年'), (match) => '${match.group(1)}年');
    result = result.replaceAllMapped(RegExp(r'(\d{1,2}) 月'), (match) => '${match.group(1)}月');
    result = result.replaceAllMapped(RegExp(r'(\d{1,2}) 日'), (match) => '${match.group(1)}日');
    
    return result;
  }
}

/// 改行整形ルール
class LinebreakNormalizer {
  /// 改行を正規化
  /// - 3連以上の改行を2つまでに圧縮
  /// - 行末の「。」が無い場合でも段落改行は保持
  static String normalizeLinebreaks(String text) {
    String result = text;

    // 3連以上の改行を2つまでに圧縮
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // 行末の空白を削除
    result = result.replaceAll(RegExp(r' +\n'), '\n');

    // 空行の前後の余分な空白を削除
    result = result.replaceAll(RegExp(r'\n +\n'), '\n\n');

    return result;
  }
}
