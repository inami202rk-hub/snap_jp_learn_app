import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:snap_jp_learn_app/services/sync_engine.dart';
import 'package:snap_jp_learn_app/services/sync_api_service.dart';
import 'package:snap_jp_learn_app/models/post.dart';

import 'sync_engine_test.mocks.dart';

@GenerateMocks([SyncApiService])
void main() {
  group('SyncEngine', () {
    late SyncEngine syncEngine;
    late MockSyncApiService mockSyncApiService;
    late Box<Post> postBox;

    setUpAll(() async {
      await setUpTestHive();
      // Register Hive adapters for test
      Hive.registerAdapter(PostAdapter());
    });

    tearDownAll(() async {
      await tearDownTestHive();
    });

    setUp(() async {
      postBox = await Hive.openBox<Post>('posts_test');
      mockSyncApiService = MockSyncApiService();
      syncEngine = SyncEngine(
        syncApiService: mockSyncApiService,
        postBox: postBox,
      );
    });

    tearDown(() async {
      await postBox.clear();
      await postBox.close();
    });

    group('syncAll', () {
      test('should perform full sync successfully', () async {
        // Arrange
        when(mockSyncApiService.pullPosts()).thenAnswer((_) async => []);
        when(mockSyncApiService.pushPosts(any)).thenAnswer((_) async {});

        // Act
        final result = await syncEngine.syncAll();

        // Assert
        expect(result, SyncResult.success);
        verifyNever(
            mockSyncApiService.pushPosts(any)); // No local changes to push
        verify(mockSyncApiService.pullPosts()).called(1);
      });

      test('should handle network failure gracefully', () async {
        // Arrange
        when(mockSyncApiService.pullPosts())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await syncEngine.syncAll();

        // Assert
        expect(
            result, SyncResult.partial); // Push succeeds, pull fails = partial
      });
    });

    group('pushLocalChanges', () {
      test('should push dirty posts to server', () async {
        // Arrange
        final dirtyPost = Post(
          id: 'test-id',
          imagePath: '/test/image.jpg',
          rawText: 'Test raw text',
          normalizedText: 'Test normalized text',
          createdAt: DateTime.now(),
          dirty: true,
        );
        await postBox.put('test-id', dirtyPost);

        when(mockSyncApiService.pushPosts(any)).thenAnswer((_) async {});

        // Act
        final result = await syncEngine.pushLocalChanges();

        // Assert
        expect(result, SyncResult.success);
        verify(mockSyncApiService.pushPosts([dirtyPost])).called(1);

        // Verify dirty flag is cleared
        final updatedPost = postBox.get('test-id');
        expect(updatedPost?.dirty, false);
      });

      test('should push deleted posts to server', () async {
        // Arrange
        final deletedPost = Post(
          id: 'test-id',
          imagePath: '/test/image.jpg',
          rawText: 'Test raw text',
          normalizedText: 'Test normalized text',
          createdAt: DateTime.now(),
          deleted: true,
        );
        await postBox.put('test-id', deletedPost);

        when(mockSyncApiService.pushPosts(any)).thenAnswer((_) async {});

        // Act
        final result = await syncEngine.pushLocalChanges();

        // Assert
        expect(result, SyncResult.success);
        verify(mockSyncApiService.pushPosts([deletedPost])).called(1);

        // Verify deleted post is removed from local storage
        expect(postBox.get('test-id'), null);
      });

      test('should return success when no local changes', () async {
        // Arrange - no posts in box

        // Act
        final result = await syncEngine.pushLocalChanges();

        // Assert
        expect(result, SyncResult.success);
        verifyNever(mockSyncApiService.pushPosts(any));
      });

      test('should handle push failure', () async {
        // Arrange
        final dirtyPost = Post(
          id: 'test-id',
          imagePath: '/test/image.jpg',
          rawText: 'Test raw text',
          normalizedText: 'Test normalized text',
          createdAt: DateTime.now(),
          dirty: true,
        );
        await postBox.put('test-id', dirtyPost);

        when(mockSyncApiService.pushPosts(any))
            .thenThrow(Exception('Push failed'));

        // Act
        final result = await syncEngine.pushLocalChanges();

        // Assert
        expect(result, SyncResult.failed);
      });
    });

    group('pullRemoteUpdates', () {
      test('should pull and add new posts from server', () async {
        // Arrange
        final remotePost = Post(
          id: 'remote-id',
          imagePath: '/remote/image.jpg',
          rawText: 'Remote raw text',
          normalizedText: 'Remote normalized text',
          createdAt: DateTime.now(),
          syncId: 'sync-123',
        );

        when(mockSyncApiService.pullPosts())
            .thenAnswer((_) async => [remotePost]);

        // Act
        final result = await syncEngine.pullRemoteUpdates();

        // Assert
        expect(result, SyncResult.success);

        final localPost = postBox.get('remote-id');
        expect(localPost, isNotNull);
        expect(localPost?.id, 'remote-id');
        expect(localPost?.syncId, 'sync-123');
      });

      test('should update existing posts with newer remote data', () async {
        // Arrange
        final localPost = Post(
          id: 'test-id',
          imagePath: '/local/image.jpg',
          rawText: 'Local raw text',
          normalizedText: 'Local normalized text',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        await postBox.put('test-id', localPost);

        final remotePost = Post(
          id: 'test-id',
          imagePath: '/remote/image.jpg',
          rawText: 'Remote raw text',
          normalizedText: 'Remote normalized text',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(), // Newer timestamp
          syncId: 'sync-456',
        );

        when(mockSyncApiService.pullPosts())
            .thenAnswer((_) async => [remotePost]);

        // Act
        final result = await syncEngine.pullRemoteUpdates();

        // Assert
        expect(result, SyncResult.success);

        final updatedPost = postBox.get('test-id');
        expect(updatedPost?.rawText, 'Remote raw text');
        expect(updatedPost?.syncId, 'sync-456');
      });

      test('should not update local posts with older remote data', () async {
        // Arrange
        final localPost = Post(
          id: 'test-id',
          imagePath: '/local/image.jpg',
          rawText: 'Local raw text',
          normalizedText: 'Local normalized text',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await postBox.put('test-id', localPost);

        final remotePost = Post(
          id: 'test-id',
          imagePath: '/remote/image.jpg',
          rawText: 'Remote raw text',
          normalizedText: 'Remote normalized text',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now()
              .subtract(const Duration(hours: 1)), // Older timestamp
        );

        when(mockSyncApiService.pullPosts())
            .thenAnswer((_) async => [remotePost]);

        // Act
        final result = await syncEngine.pullRemoteUpdates();

        // Assert
        expect(result, SyncResult.success);

        final unchangedPost = postBox.get('test-id');
        expect(unchangedPost?.rawText,
            'Local raw text'); // Should remain unchanged
      });

      test('should apply remote deletion even for newer local data', () async {
        // Arrange
        final localPost = Post(
          id: 'test-id',
          imagePath: '/local/image.jpg',
          rawText: 'Local raw text',
          normalizedText: 'Local normalized text',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(), // Newer than remote
        );
        await postBox.put('test-id', localPost);

        final remotePost = Post(
          id: 'test-id',
          imagePath: '/remote/image.jpg',
          rawText: 'Remote raw text',
          normalizedText: 'Remote normalized text',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now()
              .subtract(const Duration(hours: 1)), // Older timestamp
          deleted: true, // But deleted on remote
        );

        when(mockSyncApiService.pullPosts())
            .thenAnswer((_) async => [remotePost]);

        // Act
        final result = await syncEngine.pullRemoteUpdates();

        // Assert
        expect(result, SyncResult.success);

        // Should be deleted locally due to remote deletion
        expect(postBox.get('test-id'), null);
      });

      test('should return success when no remote updates', () async {
        // Arrange
        when(mockSyncApiService.pullPosts()).thenAnswer((_) async => []);

        // Act
        final result = await syncEngine.pullRemoteUpdates();

        // Assert
        expect(result, SyncResult.success);
      });

      test('should handle pull failure', () async {
        // Arrange
        when(mockSyncApiService.pullPosts())
            .thenThrow(Exception('Pull failed'));

        // Act
        final result = await syncEngine.pullRemoteUpdates();

        // Assert
        expect(result, SyncResult.failed);
      });
    });

    group('markAsDirty', () {
      test('should mark post as dirty', () async {
        // Arrange
        final post = Post(
          id: 'test-id',
          imagePath: '/test/image.jpg',
          rawText: 'Test raw text',
          normalizedText: 'Test normalized text',
          createdAt: DateTime.now(),
          dirty: false,
        );
        await postBox.put('test-id', post);

        // Act
        await syncEngine.markAsDirty('test-id');

        // Assert
        final updatedPost = postBox.get('test-id');
        expect(updatedPost?.dirty, true);
      });

      test('should not affect already dirty posts', () async {
        // Arrange
        final post = Post(
          id: 'test-id',
          imagePath: '/test/image.jpg',
          rawText: 'Test raw text',
          normalizedText: 'Test normalized text',
          createdAt: DateTime.now(),
          dirty: true,
        );
        await postBox.put('test-id', post);

        // Act
        await syncEngine.markAsDirty('test-id');

        // Assert
        final updatedPost = postBox.get('test-id');
        expect(updatedPost?.dirty, true);
      });
    });

    group('markAsDeleted', () {
      test('should mark post as deleted', () async {
        // Arrange
        final post = Post(
          id: 'test-id',
          imagePath: '/test/image.jpg',
          rawText: 'Test raw text',
          normalizedText: 'Test normalized text',
          createdAt: DateTime.now(),
          deleted: false,
          dirty: false,
        );
        await postBox.put('test-id', post);

        // Act
        await syncEngine.markAsDeleted('test-id');

        // Assert
        final updatedPost = postBox.get('test-id');
        expect(updatedPost?.deleted, true);
        expect(updatedPost?.dirty, true);
      });
    });

    group('isConnected', () {
      test('should return connection status from sync api service', () async {
        // Arrange
        when(mockSyncApiService.isConnected()).thenAnswer((_) async => true);

        // Act
        final isConnected = await syncEngine.isConnected();

        // Assert
        expect(isConnected, true);
        verify(mockSyncApiService.isConnected()).called(1);
      });
    });

    group('getSyncStats', () {
      test('should return correct sync statistics', () async {
        // Arrange
        final dirtyPost1 = Post(
          id: 'dirty-1',
          imagePath: '/test/image1.jpg',
          rawText: 'Test raw text 1',
          normalizedText: 'Test normalized text 1',
          createdAt: DateTime.now(),
          dirty: true,
        );
        final dirtyPost2 = Post(
          id: 'dirty-2',
          imagePath: '/test/image2.jpg',
          rawText: 'Test raw text 2',
          normalizedText: 'Test normalized text 2',
          createdAt: DateTime.now(),
          dirty: true,
        );
        final deletedPost = Post(
          id: 'deleted-1',
          imagePath: '/test/image3.jpg',
          rawText: 'Test raw text 3',
          normalizedText: 'Test normalized text 3',
          createdAt: DateTime.now(),
          deleted: true,
        );
        final cleanPost = Post(
          id: 'clean-1',
          imagePath: '/test/image4.jpg',
          rawText: 'Test raw text 4',
          normalizedText: 'Test normalized text 4',
          createdAt: DateTime.now(),
          dirty: false,
          deleted: false,
        );

        await postBox.put('dirty-1', dirtyPost1);
        await postBox.put('dirty-2', dirtyPost2);
        await postBox.put('deleted-1', deletedPost);
        await postBox.put('clean-1', cleanPost);

        // Act
        final stats = await syncEngine.getSyncStats();

        // Assert
        expect(stats.pushedCount,
            2); // 2 dirty (deleted posts are not counted as dirty)
        expect(stats.pulledCount, 0);
        expect(stats.conflictCount, 0);
        expect(stats.errorCount, 0);
      });
    });
  });
}
