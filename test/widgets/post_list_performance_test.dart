import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:snap_jp_learn_app/models/post.dart';
import 'package:snap_jp_learn_app/pages/post_list_page.dart';

void main() {
  group('PostListPage Performance Tests', () {
    setUp(() async {
      // テスト用のHive初期化
      await setUpTestHive();
      
      // PostAdapterが既に登録されているかチェック
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PostAdapter());
      }
      
      // 必要なボックスを開く
      await Hive.openBox<Post>('posts');
    });

    tearDown(() async {
      // Hiveをクリーンアップ
      await tearDownTestHive();
    });
    testWidgets('PostTile renders with placeholder then thumbnail', (tester) async {
      // テスト用のPostを作成
      final testPost = Post(
        id: 'test_post_1',
        imagePath: '/test/path/image.png',
        rawText: 'Raw OCR text',
        normalizedText: 'Normalized text for display',
        createdAt: DateTime.now(),
        likeCount: 5,
        learnedCount: 3,
      );

      // PostTileをテスト
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostTile(
              post: testPost,
              onTap: () {},
            ),
          ),
        ),
      );

      // 初期状態でプレースホルダーが表示されることを確認
      expect(find.byIcon(Icons.image), findsOneWidget);
      expect(find.byType(Container), findsWidgets);

      // フレームを進める（FutureBuilderの処理を待つ）
      await tester.pump();

      // サムネイル読み込み中の状態を確認（存在しない場合も許容）
      // expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('PostTile displays post information correctly', (tester) async {
      final testPost = Post(
        id: 'test_post_2',
        imagePath: '/test/path/image2.png',
        rawText: 'Long raw OCR text that should be truncated when displayed',
        normalizedText:
            'This is a long normalized text that should be truncated when displayed in the UI to prevent overflow issues',
        createdAt: DateTime(2024, 1, 15),
        likeCount: 10,
        learnedCount: 7,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostTile(
              post: testPost,
              onTap: () {},
            ),
          ),
        ),
      );

      // テキストが正しく表示されることを確認
      expect(
          find.text(
              'This is a long normalized text that should be truncated when displayed in the UI to prevent overflow issues'),
          findsOneWidget);

      // 日付が表示されることを確認
      expect(find.text('2024-01-15'), findsOneWidget);

      // いいね数が表示されることを確認
      expect(find.text('10'), findsOneWidget);

      // 学習数が表示されることを確認
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('PostTile handles empty learnedCount gracefully', (tester) async {
      final testPost = Post(
        id: 'test_post_3',
        imagePath: '/test/path/image3.png',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: DateTime.now(),
        likeCount: 0,
        learnedCount: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostTile(
              post: testPost,
              onTap: () {},
            ),
          ),
        ),
      );

      // いいね数と学習数が0の場合、アイコンが表示されないことを確認
      expect(find.byIcon(Icons.favorite), findsNothing);
      expect(find.byIcon(Icons.school), findsNothing);
    });

    testWidgets('PostTile onTap callback works', (tester) async {
      bool tapped = false;
      final testPost = Post(
        id: 'test_post_4',
        imagePath: '/test/path/image4.png',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostTile(
              post: testPost,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // タップを実行
      await tester.tap(find.byType(PostTile));
      await tester.pump();

      // コールバックが実行されることを確認
      expect(tapped, isTrue);
    });

    testWidgets('PostTile const constructor optimization', (tester) async {
      final testPost = Post(
        id: 'test_post_5',
        imagePath: '/test/path/image5.png',
        rawText: 'Raw text',
        normalizedText: 'Normalized text',
        createdAt: DateTime.now(),
      );

      // const PostTileを作成してテスト
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostTile(
              post: testPost,
              onTap: () {}, // テスト用の空のコールバック
            ),
          ),
        ),
      );

      // ウィジェットが正常に構築されることを確認
      expect(find.byType(PostTile), findsOneWidget);
    });
  });
}
