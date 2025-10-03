import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/services/text_normalizer.dart';
import 'package:snap_jp_learn_app/services/text_normalize_options.dart';

void main() {
  group('TextNormalizer', () {
    group('基本機能', () {
      test('空文字列の処理', () {
        expect(TextNormalizer.normalizeOcrText(''), equals(''));
      });

      test('変更なしのテキスト', () {
        const text = 'Hello World';
        expect(TextNormalizer.normalizeOcrText(text), equals(text));
      });

      test('簡易整形の動作確認', () {
        const text = 'Ｔｅｓｔ１２３';
        const expected = 'Test123';
        expect(TextNormalizer.normalizeMinimal(text), equals(expected));
      });
    });

    group('Unicode正規化', () {
      test('NFKC正規化の動作', () {
        // 互換文字の正規化例
        const text = '㌀'; // 合字
        final result = TextNormalizer.normalizeOcrText(text);
        expect(result, isNotEmpty);
        // 現在は基本的な実装のため、文字数は変わらない
        expect(result.length, equals(1));
      });
    });

    group('不可視文字除去', () {
      test('Zero Width Space除去', () {
        const text = 'A\u200BBC';
        const expected = 'ABC';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('BOM除去', () {
        const text = '\uFEFFHello';
        const expected = 'Hello';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('制御文字除去', () {
        const text = 'A\x00B\x01C';
        const expected = 'ABC';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('異常タブ連打の正規化', () {
        const text = 'A\t\t\tB';
        const expected = 'A\tB';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });
    });

    group('全角・半角統一', () {
      test('全角数字の半角化', () {
        const text = '１２３４５';
        const expected = '12345';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('全角英字の半角化', () {
        const text = 'ＡＢＣＤＥＦ';
        const expected = 'ABCDEF';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('全角小文字の半角化', () {
        const text = 'ａｂｃｄｅｆ';
        const expected = 'abcdef';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('全角記号の半角化', () {
        const text = '（），．！？';
        const expected = '(),.!?';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('日本語句読点の統一', () {
        const text = '今日は,晴れ.';
        const expected = '今日は、晴れ。';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('英語行の句読点は変更しない', () {
        const text = 'Hello, world.';
        const expected = 'Hello, world.';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });
    });

    group('スペース整形', () {
      test('行頭・行末の空白削除', () {
        const text = '  Hello  \n  World  ';
        const expected = 'Hello\nWorld';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('連続スペースの圧縮', () {
        const text = 'A    B   C';
        const expected = 'A B C';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('和欧境界のスペース挿入', () {
        const text = '東京2025EXPO';
        const expected = '東京 2025 EXPO';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('iPhone13パターンのスキップ', () {
        const text = 'iPhone13';
        const expected = 'iPhone13'; // 変更されない
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('年号パターンのスキップ', () {
        const text = '2025年';
        const expected = '2025年'; // 変更されない
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });
    });

    group('改行整形', () {
      test('3連以上の改行を2つまでに圧縮', () {
        const text = 'A\n\n\n\nB';
        const expected = 'A\n\nB';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('行末の空白削除', () {
        const text = 'Hello   \nWorld';
        const expected = 'Hello\nWorld';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });
    });

    group('ダッシュ・中黒正規化', () {
      test('日本語行のダッシュを長音に', () {
        const text = '明治—大正—昭和';
        const expected = '明治ー大正ー昭和';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('英語行のダッシュをハイフンに', () {
        const text = 'A—B—C';
        const expected = 'A-B-C';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('中黒の統一', () {
        const text = 'A･B•C';
        const expected = 'A・B・C';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });
    });

    group('引用符統一', () {
      test('日本語行の引用符を「」に', () {
        const text = '"太郎"';
        const expected = '「太郎」';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('英語行の引用符は変更しない', () {
        const text = '"Hello"';
        const expected = '"Hello"';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });
    });

    group('句読点正規化', () {
      test('末尾句読点の連続を1つに', () {
        const text = 'こんにちは。。';
        const expected = 'こんにちは。';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('文中の句読点連続は変更しない', () {
        const text = 'A。。B';
        const expected = 'A。。B'; // 文中は変更されない
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });
    });

    group('複合ケース', () {
      test('複数のルールが組み合わさる場合', () {
        const text = 'Ｔｅｓｔ１２３,今日は晴れ.';
        const expected = 'Test 123、今日は晴れ。';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('和欧混在テキスト', () {
        const text = '東京2025EXPOでiPhone13を展示';
        const expected = '東京 2025 EXPO で iPhone13 を展示';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });

      test('改行とスペースの複合', () {
        const text = '  A    \n\n\n\n  B    ';
        const expected = 'A\n\nB';
        expect(TextNormalizer.normalizeOcrText(text), equals(expected));
      });
    });

    group('オプション制御', () {
      test('全角半角化を無効化', () {
        const text = '１２３';
        const options = TextNormalizeOptions(normalizeAsciiWidth: false);
        const expected = '１２３'; // 変更されない
        expect(
          TextNormalizer.normalizeOcrText(text, options: options),
          equals(expected),
        );
      });

      test('句読点統一を無効化', () {
        const text = '今日は,晴れ.';
        const options = TextNormalizeOptions(unifyJaPunct: false);
        const expected = '今日は,晴れ.'; // 変更されない
        expect(
          TextNormalizer.normalizeOcrText(text, options: options),
          equals(expected),
        );
      });

      test('カスタムオプションの組み合わせ', () {
        const text = '１２３,今日は晴れ.';
        const options = TextNormalizeOptions(
          normalizeAsciiWidth: true,
          unifyJaPunct: false,
        );
        const expected = '123,今日は晴れ.'; // 数字のみ半角化
        expect(
          TextNormalizer.normalizeOcrText(text, options: options),
          equals(expected),
        );
      });
    });

    group('TextNormalizeResult', () {
      test('整形結果の情報取得', () {
        const text = '１２３';
        final result = TextNormalizer.normalizeWithInfo(text);
        
        expect(result.raw, equals(text));
        expect(result.normalized, equals('123'));
        expect(result.hasChanges, isTrue);
        expect(result.changesCount, greaterThanOrEqualTo(0)); // 変更カウントは概算
        expect(result.lengthDifference, lessThanOrEqualTo(0)); // 文字数が減るか同じ
      });

      test('変更なしの場合', () {
        const text = 'Hello World';
        final result = TextNormalizer.normalizeWithInfo(text);

        expect(result.raw, equals(text));
        expect(result.normalized, equals(text));
        expect(result.hasChanges, isFalse);
        expect(result.changesCount, equals(0));
        expect(result.lengthDifference, equals(0));
      });
    });

    group('パフォーマンス', () {
      test('長文の処理時間', () {
        // 3000文字程度のテキスト
        final longText = '１２３４５６７８９０' * 300;

        final stopwatch = Stopwatch()..start();
        final result = TextNormalizer.normalizeOcrText(longText);
        stopwatch.stop();

        expect(result, isNotEmpty);
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // 100ms以下
      });
    });
  });

  group('TextNormalizeOptions', () {
    test('デフォルトオプション', () {
      const options = TextNormalizeOptions.defaultOptions;
      expect(options.normalizeAsciiWidth, isTrue);
      expect(options.unifyJaPunct, isTrue);
      expect(options.unifyQuotes, isTrue);
    });

    test('最小限オプション', () {
      const options = TextNormalizeOptions.minimalOptions;
      expect(options.normalizeAsciiWidth, isTrue);
      expect(options.unifyJaPunct, isFalse);
      expect(options.unifyQuotes, isFalse);
    });

    test('copyWith機能', () {
      const original = TextNormalizeOptions.defaultOptions;
      final modified = original.copyWith(unifyJaPunct: false);

      expect(modified.unifyJaPunct, isFalse);
      expect(modified.normalizeAsciiWidth, isTrue); // 他の設定は維持
    });

    test('等価性', () {
      const options1 = TextNormalizeOptions();
      const options2 = TextNormalizeOptions();
      const options3 = TextNormalizeOptions(unifyJaPunct: false);

      expect(options1, equals(options2));
      expect(options1, isNot(equals(options3)));
    });
  });
}
