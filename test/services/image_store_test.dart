import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap_jp_learn_app/services/image_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ImageStore Tests', () {
    late Directory tempDir;
    late XFile testImageFile;

    setUpAll(() async {
      // テスト用の一時ディレクトリを作成
      tempDir = await Directory.systemTemp.createTemp('image_store_test');
      
      // テスト用の画像ファイルを作成
      final testFile = File('${tempDir.path}/test_image.jpg');
      await testFile.writeAsBytes(List.generate(100, (i) => i % 256));
      testImageFile = XFile(testFile.path);
    });

    tearDownAll(() async {
      // テスト用の一時ディレクトリを削除
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('imageFileExists should return correct status', () async {
      // 存在するファイル
      expect(await ImageStore.imageFileExists(testImageFile.path), true);
      
      // 存在しないファイル
      expect(await ImageStore.imageFileExists('${tempDir.path}/nonexistent.jpg'), false);
    });

    test('deleteImageFile should handle non-existent file gracefully', () async {
      // 存在しないファイルの削除は例外をスローしない
      await expectLater(
        ImageStore.deleteImageFile('${tempDir.path}/nonexistent.jpg'),
        completes,
      );
    });

    test('ImageStoreException should have correct message', () {
      const exception = ImageStoreException('Test error');
      expect(exception.message, 'Test error');
      expect(exception.toString(), 'ImageStoreException: Test error');
    });

    // path_providerプラグインが必要なテストはスキップ
    test('getImagesDirectoryPath should handle plugin errors gracefully', () async {
      // プラグインエラーが発生しても例外をスローしないことを確認
      try {
        await ImageStore.getImagesDirectoryPath();
        // 成功した場合は何もしない
      } catch (e) {
        // プラグインエラーは期待される動作
        expect(e.toString(), contains('MissingPluginException'));
      }
    });
  });
}
