/// OCRテキスト整形のオプション設定
class TextNormalizeOptions {
  /// 英数記号の半角化（全角→半角）
  final bool normalizeAsciiWidth;

  /// 日本語句読点の統一（, . → 、 。）
  final bool unifyJaPunct;

  /// 引用符の統一（" " → 「 」（日本語行のみ））
  final bool unifyQuotes;

  /// 行頭・行末の空白削除
  final bool trimSpaces;

  /// 連続スペースの圧縮（複数→1個）
  final bool collapseSpaces;

  /// 和欧境界のスペース挿入（東京2025 → 東京 2025）
  final bool manageJaEnBoundaries;

  /// ダッシュ/長音の正規化（— – → ー または -）
  final bool normalizeDashes;

  /// 中黒の統一（･ • → ・）
  final bool normalizeBullets;

  /// 改行ルールの適用（3連以上→2つまで）
  final bool linebreakRules;

  /// 末尾句読点の連続正規化（。。 → 。）
  final bool normalizeEndPunctuation;

  const TextNormalizeOptions({
    this.normalizeAsciiWidth = true,
    this.unifyJaPunct = true,
    this.unifyQuotes = true,
    this.trimSpaces = true,
    this.collapseSpaces = true,
    this.manageJaEnBoundaries = true,
    this.normalizeDashes = true,
    this.normalizeBullets = true,
    this.linebreakRules = true,
    this.normalizeEndPunctuation = true,
  });

  /// デフォルト設定（すべて有効）
  static const TextNormalizeOptions defaultOptions = TextNormalizeOptions();

  /// 最小限の設定（基本的な整形のみ）
  static const TextNormalizeOptions minimalOptions = TextNormalizeOptions(
    normalizeAsciiWidth: true,
    trimSpaces: true,
    collapseSpaces: true,
    unifyJaPunct: false,
    unifyQuotes: false,
    manageJaEnBoundaries: false,
    normalizeDashes: false,
    normalizeBullets: false,
    linebreakRules: false,
    normalizeEndPunctuation: false,
  );

  /// カスタム設定のコピー
  TextNormalizeOptions copyWith({
    bool? normalizeAsciiWidth,
    bool? unifyJaPunct,
    bool? unifyQuotes,
    bool? trimSpaces,
    bool? collapseSpaces,
    bool? manageJaEnBoundaries,
    bool? normalizeDashes,
    bool? normalizeBullets,
    bool? linebreakRules,
    bool? normalizeEndPunctuation,
  }) {
    return TextNormalizeOptions(
      normalizeAsciiWidth: normalizeAsciiWidth ?? this.normalizeAsciiWidth,
      unifyJaPunct: unifyJaPunct ?? this.unifyJaPunct,
      unifyQuotes: unifyQuotes ?? this.unifyQuotes,
      trimSpaces: trimSpaces ?? this.trimSpaces,
      collapseSpaces: collapseSpaces ?? this.collapseSpaces,
      manageJaEnBoundaries: manageJaEnBoundaries ?? this.manageJaEnBoundaries,
      normalizeDashes: normalizeDashes ?? this.normalizeDashes,
      normalizeBullets: normalizeBullets ?? this.normalizeBullets,
      linebreakRules: linebreakRules ?? this.linebreakRules,
      normalizeEndPunctuation:
          normalizeEndPunctuation ?? this.normalizeEndPunctuation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextNormalizeOptions &&
        other.normalizeAsciiWidth == normalizeAsciiWidth &&
        other.unifyJaPunct == unifyJaPunct &&
        other.unifyQuotes == unifyQuotes &&
        other.trimSpaces == trimSpaces &&
        other.collapseSpaces == collapseSpaces &&
        other.manageJaEnBoundaries == manageJaEnBoundaries &&
        other.normalizeDashes == normalizeDashes &&
        other.normalizeBullets == normalizeBullets &&
        other.linebreakRules == linebreakRules &&
        other.normalizeEndPunctuation == normalizeEndPunctuation;
  }

  @override
  int get hashCode {
    return Object.hash(
      normalizeAsciiWidth,
      unifyJaPunct,
      unifyQuotes,
      trimSpaces,
      collapseSpaces,
      manageJaEnBoundaries,
      normalizeDashes,
      normalizeBullets,
      linebreakRules,
      normalizeEndPunctuation,
    );
  }

  @override
  String toString() {
    return 'TextNormalizeOptions('
        'normalizeAsciiWidth: $normalizeAsciiWidth, '
        'unifyJaPunct: $unifyJaPunct, '
        'unifyQuotes: $unifyQuotes, '
        'trimSpaces: $trimSpaces, '
        'collapseSpaces: $collapseSpaces, '
        'manageJaEnBoundaries: $manageJaEnBoundaries, '
        'normalizeDashes: $normalizeDashes, '
        'normalizeBullets: $normalizeBullets, '
        'linebreakRules: $linebreakRules, '
        'normalizeEndPunctuation: $normalizeEndPunctuation'
        ')';
  }
}
