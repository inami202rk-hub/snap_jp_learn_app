import 'package:flutter/material.dart';

/// アプリケーション全体で使用する共通テーマ
class AppTheme {
  AppTheme._();

  /// ライトテーマ
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      // カスタムカラー
      extensions: <ThemeExtension<dynamic>>[
        CustomColors.light,
      ],
    );
  }

  /// ダークテーマ
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      // カスタムカラー
      extensions: <ThemeExtension<dynamic>>[
        CustomColors.dark,
      ],
    );
  }
}

/// カスタムカラーパレット
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.cardBackground,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
    required this.infoColor,
  });

  final Color cardBackground;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;
  final Color infoColor;

  /// ライトテーマ用のカスタムカラー
  static const CustomColors light = CustomColors(
    cardBackground: Color(0xFFF8F9FA),
    successColor: Color(0xFF4CAF50),
    warningColor: Color(0xFFFF9800),
    errorColor: Color(0xFFF44336),
    infoColor: Color(0xFF2196F3),
  );

  /// ダークテーマ用のカスタムカラー
  static const CustomColors dark = CustomColors(
    cardBackground: Color(0xFF2D2D2D),
    successColor: Color(0xFF81C784),
    warningColor: Color(0xFFFFB74D),
    errorColor: Color(0xFFE57373),
    infoColor: Color(0xFF64B5F6),
  );

  @override
  CustomColors copyWith({
    Color? cardBackground,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? infoColor,
  }) {
    return CustomColors(
      cardBackground: cardBackground ?? this.cardBackground,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      infoColor: infoColor ?? this.infoColor,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
    );
  }

  /// 現在のコンテキストからカスタムカラーを取得
  static CustomColors of(BuildContext context) {
    return Theme.of(context).extension<CustomColors>()!;
  }
}
