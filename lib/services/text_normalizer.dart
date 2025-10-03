import 'text_normalize_options.dart';
import 'text_rules/unicode.dart';
import 'text_rules/spaces.dart';
import 'text_rules/punctuation.dart';

/// OCRテキスト整形サービス
///
/// 日本語向けルールベースでテキストを整形し、
/// 読みやすく・後段のSRS抽出で扱いやすい形に正規化します。
class TextNormalizer {
  /// OCRで取得したテキストを整形
  ///
  /// [raw] 生のOCRテキスト
  /// [options] 整形オプション（nullの場合はデフォルト設定）
  ///
  /// 戻り値: 整形されたテキスト
  static String normalizeOcrText(String raw, {TextNormalizeOptions? options}) {
    final opts = options ?? TextNormalizeOptions.defaultOptions;
    String result = raw;

    // ルール適用順序（重要：順序依存）

    // ① Unicode正規化 NFKC（互換分解→結合）
    result = UnicodeNormalizer.normalizeUnicode(result);

    // ② 不可視/制御文字の除去
    result = InvisibleCharRemover.removeInvisibleChars(result);

    // ③ 全角/半角の統一
    if (opts.normalizeAsciiWidth) {
      result = WidthNormalizer.normalizeAsciiWidth(result);
    }

    if (opts.unifyJaPunct) {
      result = WidthNormalizer.unifyJapanesePunctuation(result);
    }

    // ④ スペース整形
    if (opts.trimSpaces) {
      result = SpaceNormalizer.trimSpaces(result);
    }

    if (opts.collapseSpaces) {
      result = SpaceNormalizer.collapseSpaces(result);
    }

    if (opts.manageJaEnBoundaries) {
      result = SpaceNormalizer.manageJaEnBoundaries(result);
    }

    // ⑤ 改行整形
    if (opts.linebreakRules) {
      result = LinebreakNormalizer.normalizeLinebreaks(result);
    }

    // ⑥ ダッシュ/長音/中黒の正規化
    if (opts.normalizeDashes) {
      result = DashNormalizer.normalizeDashes(result);
    }

    if (opts.normalizeBullets) {
      result = BulletNormalizer.normalizeBullets(result);
    }

    // ⑦ 引用符の統一
    if (opts.unifyQuotes) {
      result = QuoteNormalizer.unifyQuotes(result);
    }

    // ⑧ OCR誤認の軽微補正（安全側）
    // 一 と ー の誤混同は置換しない（誤補正のほうが痛い）
    // O/0、l/1/I は置換しない（将来のAIリライトへ委譲）

    // ⑨ 句読点の日本語標準化（，→、、．→。）
    if (opts.unifyJapanesePunctuation) {
      result = PunctuationNormalizer.unifyJapanesePunctuation(result);
    }

    // ⑩ 末尾の不要な句読点の連続を1つに
    if (opts.normalizeEndPunctuation) {
      result = PunctuationNormalizer.normalizeEndPunctuation(result);
    }

    // ⑪ OCR誤改行の抑制
    if (opts.suppressOcrLinebreaks) {
      result = LinebreakNormalizer.suppressOcrLinebreaks(result);
    }

    return result;
  }

  /// 簡易整形（基本的な整形のみ）
  ///
  /// Unicode正規化、不可視文字除去、スペース整形のみを適用
  static String normalizeMinimal(String raw) {
    return normalizeOcrText(raw, options: TextNormalizeOptions.minimalOptions);
  }

  /// 整形前後の比較情報を取得
  ///
  /// [raw] 生のOCRテキスト
  /// [options] 整形オプション
  ///
  /// 戻り値: 整形結果とメタ情報
  static TextNormalizeResult normalizeWithInfo(
    String raw, {
    TextNormalizeOptions? options,
  }) {
    final normalized = normalizeOcrText(raw, options: options);

    return TextNormalizeResult(
      raw: raw,
      normalized: normalized,
      changesCount: _countChanges(raw, normalized),
      options: options ?? TextNormalizeOptions.defaultOptions,
    );
  }

  /// 変更箇所数をカウント（簡易）
  static int _countChanges(String raw, String normalized) {
    if (raw == normalized) return 0;

    // 簡易的な変更カウント（文字数差の絶対値）
    return (raw.length - normalized.length).abs();
  }
}

/// 整形結果とメタ情報
class TextNormalizeResult {
  /// 生のOCRテキスト
  final String raw;

  /// 整形されたテキスト
  final String normalized;

  /// 変更箇所数（概算）
  final int changesCount;

  /// 使用されたオプション
  final TextNormalizeOptions options;

  const TextNormalizeResult({
    required this.raw,
    required this.normalized,
    required this.changesCount,
    required this.options,
  });

  /// 整形が適用されたかどうか
  bool get hasChanges => raw != normalized;

  /// 整形前後の文字数差
  int get lengthDifference => normalized.length - raw.length;

  @override
  String toString() {
    return 'TextNormalizeResult('
        'raw: ${raw.length} chars, '
        'normalized: ${normalized.length} chars, '
        'changes: $changesCount, '
        'hasChanges: $hasChanges'
        ')';
  }
}
