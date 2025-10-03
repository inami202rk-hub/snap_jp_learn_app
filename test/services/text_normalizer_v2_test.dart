import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/text_normalizer.dart';
import 'package:snap_jp_learn_app/services/text_normalize_options.dart';

void main() {
  group('TextNormalizer V2 Tests', () {
    group('句読点の日本語標準化', () {
      test('カンマを読点に統一', () {
        const input = '東京，大阪，名古屋';
        const expected = '東京、大阪、名古屋';
        
        final result = TextNormalizer.normalizeOcrText(
          input,
          options: const TextNormalizeOptions(
            unifyJapanesePunctuation: true,
            normalizeEndPunctuation: false,
            suppressOcrLinebreaks: false,
          ),
        );
        
        expect(result, equals(expected));
      });

      test('ピリオドを句点に統一（文末のみ）', () {
        const input = '今日は良い天気です.\n明日も晴れです.';
        const expected = '今日は良い天気です。\n明日も晴れです。';
        
        final result = TextNormalizer.normalizeOcrText(
          input,
          options: const TextNormalizeOptions(
            unifyJapanesePunctuation: true,
            normalizeEndPunctuation: false,
            suppressOcrLinebreaks: false,
          ),
        );
        
        expect(result, equals(expected));
      });

      test('文中のピリオドは変更しない', () {
        const input = 'URL: https://example.com. アクセスしてください.';
        const expected = 'URL: https://example.com. アクセスしてください。';
        
        final result = TextNormalizer.normalizeOcrText(
          input,
          options: const TextNormalizeOptions(
            unifyJapanesePunctuation: true,
            normalizeEndPunctuation: false,
            suppressOcrLinebreaks: false,
          ),
        );
        
        expect(result, equals(expected));
      });
    });

    group('OCR誤改行の抑制', () {
      test('文末でない改行を削除', () {
        const input = '今日は\n良い天気です\n明日も晴れです';
        const expected = '今日は 良い天気です 明日も晴れです';
        
        final result = TextNormalizer.normalizeOcrText(
          input,
          options: const TextNormalizeOptions(
            unifyJapanesePunctuation: false,
            normalizeEndPunctuation: false,
            suppressOcrLinebreaks: true,
          ),
        );
        
        expect(result, equals(expected));
      });

      test('文末記号がある改行は保持', () {
        const input = '今日は良い天気です。\n明日も晴れです。';
        const expected = '今日は良い天気です。\n明日も晴れです。';
        
        final result = TextNormalizer.normalizeOcrText(
          input,
          options: const TextNormalizeOptions(
            unifyJapanesePunctuation: false,
            normalizeEndPunctuation: false,
            suppressOcrLinebreaks: true,
          ),
        );
        
        expect(result, equals(expected));
      });

      test('段落区切りは保持', () {
        const input = '今日は良い天気です。\n\n明日も晴れです。';
        const expected = '今日は良い天気です。\n\n明日も晴れです。';
        
        final result = TextNormalizer.normalizeOcrText(
          input,
          options: const TextNormalizeOptions(
            unifyJapanesePunctuation: false,
            normalizeEndPunctuation: false,
            suppressOcrLinebreaks: true,
          ),
        );
        
        expect(result, equals(expected));
      });
    });

    group('和欧間スペースの改善', () {
      test('東京2025Expo → 東京 2025 Expo', () {
        const input = '東京2025Expo';
        const expected = '東京 2025 Expo';
        
        final result = TextNormalizer.normalizeOcrText(
          input,
          options: const TextNormalizeOptions(
            manageJaEnBoundaries: true,
            unifyJapanesePunctuation: false,
            normalizeEndPunctuation: false,
            suppressOcrLinebreaks: false,
          ),
        );
        
        expect(result, equals(expected));
      });

      test('iPhone13は変更しない', () {
        const input = 'iPhone13が発売されました';
        const expected = 'iPhone13が発売されました';
        
        final result = TextNormalizer.normalizeOcrText(
          input,
          options: const TextNormalizeOptions(
            manageJaEnBoundaries: true,
            unifyJapanesePunctuation: false,
            normalizeEndPunctuation: false,
            suppressOcrLinebreaks: false,
          ),
        );
        
        expect(result, equals(expected));
      });
    });

    group('統合テスト', () {
      test('複数のルールを組み合わせた整形', () {
        const input = '東京2025Expo，開催決定\n詳細は後日発表.';
        const expected = '東京 2025 Expo、開催決定 詳細は後日発表。';
        
        final result = TextNormalizer.normalizeOcrText(input);
        
        expect(result, equals(expected));
      });

      test('デフォルトオプションでの整形', () {
        const input = 'OCRで抽出した\nテキスト，整形テスト.';
        const expected = 'OCR で抽出した テキスト、整形テスト。';
        
        final result = TextNormalizer.normalizeOcrText(input);
        
        expect(result, equals(expected));
      });
    });

    group('TextNormalizeResult', () {
      test('整形結果のメタ情報を取得', () {
        const input = '東京2025Expo，開催決定\n詳細は後日発表.';
        
        final result = TextNormalizer.normalizeWithInfo(input);
        
        expect(result.raw, equals(input));
        expect(result.normalized, isNotEmpty);
        expect(result.hasChanges, isTrue);
        expect(result.changesCount, greaterThan(0));
        expect(result.options, isA<TextNormalizeOptions>());
      });

      test('変更がない場合のメタ情報', () {
        const input = '変更のないテキスト';
        
        final result = TextNormalizer.normalizeWithInfo(input);
        
        expect(result.raw, equals(input));
        expect(result.normalized, equals(input));
        expect(result.hasChanges, isFalse);
        expect(result.changesCount, equals(0));
      });
    });
  });
}
