import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
// import 'package:path_provider/path_provider.dart'; // 未使用のためコメントアウト
import 'package:image/image.dart' as img;
import 'package:snap_jp_learn_app/services/image_store.dart';

void main() {
  group('ImageStore Performance Tests', () {
    late Directory tempDir;
    late File testImageFile;

    setUpAll(() async {
      // テスト用の一時ディレクトリを作成
      tempDir = await Directory.systemTemp.createTemp('image_store_test_');

      // テスト用の画像ファイルを作成（100x100のPNG）
      testImageFile = File('${tempDir.path}/test_image.png');
      final testImage = img.Image(width: 100, height: 100);
      img.fill(testImage, color: img.ColorRgb8(255, 0, 0)); // 赤色で塗りつぶし
      final pngBytes = img.encodePng(testImage);
      await testImageFile.writeAsBytes(pngBytes);
    });

    tearDownAll(() async {
      // 一時ディレクトリを削除
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('thumbnail generation - cache hit for identical images', () async {
      // 同じ画像でサムネイルを2回生成
      final thumbnail1 = await ImageStore.getOrCreateThumbnail(
        testImageFile.path,
        maxWidth: 50,
        maxHeight: 50,
      );

      final thumbnail2 = await ImageStore.getOrCreateThumbnail(
        testImageFile.path,
        maxWidth: 50,
        maxHeight: 50,
      );

      // 同じパスが返されることを確認（キャッシュ命中）
      expect(thumbnail1, equals(thumbnail2));

      // サムネイルファイルが存在することを確認
      expect(await File(thumbnail1).exists(), isTrue);
    });

    test('thumbnail generation - different sizes create different thumbnails',
        () async {
      final thumbnail1 = await ImageStore.getOrCreateThumbnail(
        testImageFile.path,
        maxWidth: 50,
        maxHeight: 50,
      );

      final thumbnail2 = await ImageStore.getOrCreateThumbnail(
        testImageFile.path,
        maxWidth: 75,
        maxHeight: 75,
      );

      // 異なるサイズのサムネイルは異なるパスになることを確認
      expect(thumbnail1, isNot(equals(thumbnail2)));
    });

    test('thumbnail bytes retrieval', () async {
      // サムネイルを生成
      await ImageStore.getOrCreateThumbnail(
        testImageFile.path,
        maxWidth: 50,
        maxHeight: 50,
      );

      // サムネイルバイトを取得
      final thumbnailBytes = await ImageStore.getThumbnailBytes(
        testImageFile.path,
        maxWidth: 50,
        maxHeight: 50,
      );

      expect(thumbnailBytes, isNotNull);
      expect(thumbnailBytes, isA<Uint8List>());
      expect(thumbnailBytes.isNotEmpty, isTrue);
    });

    test('orphan cleanup removes thumbnails for deleted images', () async {
      // テスト用の画像を作成
      final tempImageFile = File('${tempDir.path}/temp_image.png');
      final testImage = img.Image(width: 80, height: 80);
      img.fill(testImage, color: img.ColorRgb8(0, 255, 0)); // 緑色で塗りつぶし
      final pngBytes = img.encodePng(testImage);
      await tempImageFile.writeAsBytes(pngBytes);

      // サムネイルを生成
      final thumbnailPath = await ImageStore.getOrCreateThumbnail(
        tempImageFile.path,
        maxWidth: 40,
        maxHeight: 40,
      );

      // サムネイルが存在することを確認
      expect(await File(thumbnailPath).exists(), isTrue);

      // 元の画像を削除
      await tempImageFile.delete();

      // 孤児サムネイルのクリーンアップを実行
      final cleanupResult = await ImageStore.cleanupOrphanThumbnails();

      // サムネイルが削除されることを確認
      expect(await File(thumbnailPath).exists(), isFalse);
      expect(cleanupResult, greaterThan(0));
    });

    test('thumbnail deletion removes all sizes', () async {
      // 複数のサイズのサムネイルを生成
      final thumbnail1 = await ImageStore.getOrCreateThumbnail(
        testImageFile.path,
        maxWidth: 30,
        maxHeight: 30,
      );

      final thumbnail2 = await ImageStore.getOrCreateThumbnail(
        testImageFile.path,
        maxWidth: 60,
        maxHeight: 60,
      );

      // 両方のサムネイルが存在することを確認
      expect(await File(thumbnail1).exists(), isTrue);
      expect(await File(thumbnail2).exists(), isTrue);

      // サムネイルを削除
      await ImageStore.deleteThumbnail(testImageFile.path);

      // 両方のサムネイルが削除されることを確認
      expect(await File(thumbnail1).exists(), isFalse);
      expect(await File(thumbnail2).exists(), isFalse);
    });

    test('thumbnails directory size calculation', () async {
      // いくつかのサムネイルを生成
      await ImageStore.getOrCreateThumbnail(
        testImageFile.path,
        maxWidth: 25,
        maxHeight: 25,
      );

      await ImageStore.getOrCreateThumbnail(
        testImageFile.path,
        maxWidth: 35,
        maxHeight: 35,
      );

      // ディレクトリサイズを取得
      final size = await ImageStore.getThumbnailsDirectorySize();

      expect(size, greaterThan(0));
    });

    test('thumbnail generation performance', () async {
      final stopwatch = Stopwatch()..start();

      // 複数のサムネイルを生成
      for (int i = 0; i < 5; i++) {
        await ImageStore.getOrCreateThumbnail(
          testImageFile.path,
          maxWidth: 20 + i * 10,
          maxHeight: 20 + i * 10,
        );
      }

      stopwatch.stop();

      // 5個のサムネイル生成が2秒以内に完了することを確認
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
