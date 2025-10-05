import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:snap_jp_learn_app/widgets/srs_preview_card.dart';
import 'package:snap_jp_learn_app/theme/app_theme.dart';

void main() {
  group('SrsPreviewCard Golden Tests', () {
    testGoldens('SrsPreviewCard looks correct in light theme', (tester) async {
      await tester.pumpWidgetBuilder(
        const SrsPreviewCard(),
        wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
        surfaceSize: const Size(400, 300),
      );

      await screenMatchesGolden(tester, 'srs_preview_card_light');
    });

    testGoldens('SrsPreviewCard looks correct in dark theme', (tester) async {
      await tester.pumpWidgetBuilder(
        const SrsPreviewCard(),
        wrapper: materialAppWrapper(theme: AppTheme.darkTheme),
        surfaceSize: const Size(400, 300),
      );

      await screenMatchesGolden(tester, 'srs_preview_card_dark');
    });
  });
}
