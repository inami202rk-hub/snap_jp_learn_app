import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:snap_jp_learn_app/services/backup_service.dart';
import 'package:snap_jp_learn_app/repositories/post_repository.dart';
import 'package:snap_jp_learn_app/repositories/srs_repository.dart';
import 'package:snap_jp_learn_app/models/post.dart';
import 'package:snap_jp_learn_app/models/srs_card.dart';
import 'package:snap_jp_learn_app/models/review_log.dart';
import 'package:snap_jp_learn_app/models/rating.dart' as rating;
import 'dart:io';
import 'dart:convert';

import 'backup_service_test.mocks.dart';

@GenerateMocks([PostRepository, SrsRepository])
void main() {
  group('BackupService Tests', () {
    late BackupService backupService;
    late MockPostRepository mockPostRepository;
    late MockSrsRepository mockSrsRepository;

    setUp(() {
      mockPostRepository = MockPostRepository();
      mockSrsRepository = MockSrsRepository();
      backupService = BackupService(
        postRepository: mockPostRepository,
        srsRepository: mockSrsRepository,
      );
    });

    group('Export Backup', () {
      test('should export backup successfully', () async {
        // モックデータを準備
        final posts = [
          Post(
            id: 'post1',
            imagePath: '/path/to/image1.jpg',
            rawText: 'テスト投稿1',
            normalizedText: 'テスト投稿1',
            createdAt: DateTime(2024, 1, 1),
          ),
        ];

        final cards = [
          SrsCard(
            id: 'card1',
            term: 'テスト',
            reading: 'てすと',
            meaning: 'test',
            sourcePostId: 'post1',
            sourceSnippet: 'テスト投稿1',
            createdAt: DateTime(2024, 1, 1),
            due: DateTime(2024, 1, 2),
          ),
        ];

        final reviewLogs = [
          ReviewLog(
            id: 'log1',
            cardId: 'card1',
            rating: rating.Rating.good.value,
            reviewedAt: DateTime(2024, 1, 1),
          ),
        ];

        // モックの設定
        when(mockPostRepository.getAllPosts()).thenAnswer((_) async => posts);
        when(mockSrsRepository.getAllCards()).thenAnswer((_) async => cards);
        when(mockSrsRepository.getAllReviewLogs())
            .thenAnswer((_) async => reviewLogs);

        // テスト実行
        final result = await backupService.exportBackup();

        // 結果の検証
        expect(result.isSuccess, isTrue);
        expect(result.fileName, isNotNull);
        expect(result.metadata, isNotNull);
        expect(result.metadata!.postCount, equals(1));
        expect(result.metadata!.cardCount, equals(1));
        expect(result.metadata!.reviewLogCount, equals(1));

        // ファイルが作成されていることを確認（getExternalStorageDirectoryがnullの場合を考慮）
        if (result.filePath != null) {
          final file = File(result.filePath!);
          expect(await file.exists(), isTrue);

          // JSONの内容を確認
          final jsonContent = await file.readAsString();
          final backupData = json.decode(jsonContent) as Map<String, dynamic>;
          expect(backupData['version'], equals('1.0'));
          expect(backupData['app'], equals('snap_jp_learn_app'));
          expect(backupData['data'], isNotNull);

          // テスト後にファイルを削除
          await file.delete();
        }
      });

      test('should handle export error', () async {
        // エラーを発生させる
        when(mockPostRepository.getAllPosts())
            .thenThrow(Exception('Database error'));

        // テスト実行
        final result = await backupService.exportBackup();

        // 結果の検証
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('バックアップの作成に失敗しました'));
      });
    });

    group('Import Backup', () {
      test('should import backup successfully', () async {
        // バックアップデータを作成
        final backupData = {
          'version': '1.0',
          'app': 'snap_jp_learn_app',
          'createdAt': DateTime.now().toIso8601String(),
          'data': {
            'posts': [
              {
                'id': 'post1',
                'imagePath': '/path/to/image1.jpg',
                'rawText': 'テスト投稿1',
                'normalizedText': 'テスト投稿1',
                'createdAt': DateTime(2024, 1, 1).toIso8601String(),
                'likeCount': 0,
                'learned': false,
                'learnedCount': 0,
              }
            ],
            'cards': [
              {
                'id': 'card1',
                'term': 'テスト',
                'reading': 'てすと',
                'meaning': 'test',
                'sourcePostId': 'post1',
                'sourceSnippet': 'テスト投稿1',
                'createdAt': DateTime(2024, 1, 1).toIso8601String(),
                'interval': 0,
                'easeFactor': 2.5,
                'repetition': 0,
                'due': DateTime(2024, 1, 2).toIso8601String(),
              }
            ],
            'reviewLogs': [
              {
                'id': 'log1',
                'cardId': 'card1',
                'rating': rating.Rating.good.value,
                'reviewedAt': DateTime(2024, 1, 1).toIso8601String(),
              }
            ],
          },
          'metadata': {
            'postCount': 1,
            'cardCount': 1,
            'reviewLogCount': 1,
          },
        };

        // 一時ファイルを作成
        final tempFile = File('${Directory.systemTemp.path}/test_backup.json');
        await tempFile.writeAsString(json.encode(backupData));

        // モックの設定
        when(mockPostRepository.clearAllPosts()).thenAnswer((_) async {});
        when(mockSrsRepository.clearAllData()).thenAnswer((_) async {});
        when(mockPostRepository.importPosts(any)).thenAnswer((_) async {});
        when(mockSrsRepository.upsertCard(any)).thenAnswer((_) async =>
            SrsCard.fromJson((backupData['data']
                as Map<String, dynamic>)['cards'][0] as Map<String, dynamic>));
        when(mockSrsRepository.createReviewLog(any)).thenAnswer((_) async =>
            ReviewLog.fromJson(
                (backupData['data'] as Map<String, dynamic>)['reviewLogs'][0]
                    as Map<String, dynamic>));

        // テスト実行
        final result = await backupService.importBackup(tempFile.path);

        // 結果の検証
        expect(result.isSuccess, isTrue);
        expect(result.metadata, isNotNull);
        expect(result.metadata!.postCount, equals(1));
        expect(result.metadata!.cardCount, equals(1));
        expect(result.metadata!.reviewLogCount, equals(1));

        // モックが呼ばれたことを確認
        verify(mockPostRepository.clearAllPosts()).called(1);
        verify(mockSrsRepository.clearAllData()).called(1);
        verify(mockPostRepository.importPosts(any)).called(1);
        verify(mockSrsRepository.upsertCard(any)).called(1);
        verify(mockSrsRepository.createReviewLog(any)).called(1);

        // テスト後にファイルを削除
        await tempFile.delete();
      });

      test('should handle invalid JSON file', () async {
        // 無効なJSONファイルを作成
        final tempFile =
            File('${Directory.systemTemp.path}/invalid_backup.json');
        await tempFile.writeAsString('invalid json content');

        // テスト実行
        final result = await backupService.importBackup(tempFile.path);

        // 結果の検証
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('無効なJSONファイルです'));

        // テスト後にファイルを削除
        await tempFile.delete();
      });

      test('should handle wrong app backup file', () async {
        // 間違ったアプリのバックアップファイルを作成
        final backupData = {
          'version': '1.0',
          'app': 'wrong_app',
          'createdAt': DateTime.now().toIso8601String(),
          'data': {'posts': [], 'cards': [], 'reviewLogs': []},
        };

        final tempFile =
            File('${Directory.systemTemp.path}/wrong_app_backup.json');
        await tempFile.writeAsString(json.encode(backupData));

        // テスト実行
        final result = await backupService.importBackup(tempFile.path);

        // 結果の検証
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('このアプリのバックアップファイルではありません'));

        // テスト後にファイルを削除
        await tempFile.delete();
      });

      test('should handle empty file', () async {
        // 空ファイルを作成
        final tempFile = File('${Directory.systemTemp.path}/empty_backup.json');
        await tempFile.writeAsString('');

        // テスト実行
        final result = await backupService.importBackup(tempFile.path);

        // 結果の検証
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('ファイルが空です'));

        // テスト後にファイルを削除
        await tempFile.delete();
      });

      test('should handle non-existent file', () async {
        // テスト実行
        final result =
            await backupService.importBackup('/non/existent/file.json');

        // 結果の検証
        expect(result.isSuccess, isFalse);
        expect(result.message, contains('ファイルが見つかりません'));
      });
    });

    group('Get Backup Info', () {
      test('should get backup info successfully', () async {
        // バックアップデータを作成
        final backupData = {
          'version': '1.0',
          'app': 'snap_jp_learn_app',
          'createdAt': DateTime(2024, 1, 1).toIso8601String(),
          'metadata': {
            'postCount': 5,
            'cardCount': 10,
            'reviewLogCount': 15,
          },
        };

        final tempFile = File('${Directory.systemTemp.path}/info_backup.json');
        await tempFile.writeAsString(json.encode(backupData));

        // テスト実行
        final info = await backupService.getBackupInfo(tempFile.path);

        // 結果の検証
        expect(info.fileName, equals('info_backup.json'));
        expect(info.version, equals('1.0'));
        expect(info.postCount, equals(5));
        expect(info.cardCount, equals(10));
        expect(info.reviewLogCount, equals(15));
        expect(info.fileSize, greaterThan(0));

        // テスト後にファイルを削除
        await tempFile.delete();
      });

      test('should handle get backup info error', () async {
        // テスト実行
        expect(
          () => backupService.getBackupInfo('/non/existent/file.json'),
          throwsA(isA<BackupException>()),
        );
      });
    });
  });
}
