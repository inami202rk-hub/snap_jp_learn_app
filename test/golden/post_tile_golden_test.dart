import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:snap_jp_learn_app/models/post.dart';
import 'package:snap_jp_learn_app/pages/post_list_page.dart';
import 'package:snap_jp_learn_app/theme/app_theme.dart';

void main() {
  group('PostTile Golden Tests', () {
    testGoldens('PostTile looks correct in light theme', (tester) async {
      await tester.pumpWidgetBuilder(
        PostTile(
          post: Post(
            id: 'test-1',
            imagePath: 'test/path',
            rawText: 'これはテスト用の投稿テキストです。日本語のOCR認識結果を表示しています。',
            normalizedText: 'これはテスト用の投稿テキストです。日本語のOCR認識結果を表示しています。',
            createdAt: DateTime.now(),
            likeCount: 5,
            learnedCount: 2,
            learned: false,
          ),
          onTap: () {},
        ),
        wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
        surfaceSize: const Size(400, 120),
      );

      await screenMatchesGolden(tester, 'post_tile_light');
    });

    testGoldens('PostTile looks correct in dark theme', (tester) async {
      await tester.pumpWidgetBuilder(
        PostTile(
          post: Post(
            id: 'test-2',
            imagePath: 'test/path',
            rawText: 'これはテスト用の投稿テキストです。日本語のOCR認識結果を表示しています。',
            normalizedText: 'これはテスト用の投稿テキストです。日本語のOCR認識結果を表示しています。',
            createdAt: DateTime.now(),
            likeCount: 5,
            learnedCount: 2,
            learned: false,
          ),
          onTap: () {},
        ),
        wrapper: materialAppWrapper(theme: AppTheme.darkTheme),
        surfaceSize: const Size(400, 120),
      );

      await screenMatchesGolden(tester, 'post_tile_dark');
    });

    testGoldens('PostTile with long text', (tester) async {
      await tester.pumpWidgetBuilder(
        PostTile(
          post: Post(
            id: 'test-3',
            imagePath: 'test/path',
            rawText: 'これは非常に長いテキストの投稿です。' * 10,
            normalizedText: 'これは非常に長いテキストの投稿です。' * 10,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            likeCount: 15,
            learnedCount: 8,
            learned: true,
          ),
          onTap: () {},
        ),
        wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
        surfaceSize: const Size(400, 120),
      );

      await screenMatchesGolden(tester, 'post_tile_long_text');
    });

    testGoldens('PostTile learned state', (tester) async {
      await tester.pumpWidgetBuilder(
        PostTile(
          post: Post(
            id: 'test-4',
            imagePath: 'test/path',
            rawText: '学習済みの投稿です。',
            normalizedText: '学習済みの投稿です。',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            likeCount: 0,
            learnedCount: 1,
            learned: true,
          ),
          onTap: () {},
        ),
        wrapper: materialAppWrapper(theme: AppTheme.lightTheme),
        surfaceSize: const Size(400, 120),
      );

      await screenMatchesGolden(tester, 'post_tile_learned');
    });
  });
}
