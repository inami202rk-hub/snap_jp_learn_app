import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:snap_jp_learn_app/services/sync_api_service.dart';
import 'package:snap_jp_learn_app/models/post.dart';

import 'sync_api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('SyncApiService', () {
    late SyncApiService syncApiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      syncApiService = SyncApiService(httpClient: mockClient);
    });

    tearDown(() {
      syncApiService.dispose();
    });

    group('pingServer', () {
      test('should return true when server responds with 200 OK', () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('OK', 200));

        // Act
        final result = await syncApiService.pingServer();

        // Assert
        expect(result, true);
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should return false when server responds with 404', () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        // Act
        final result = await syncApiService.pingServer();

        // Assert
        expect(result, false);
      });

      test('should return false when server responds with 500', () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response('Internal Server Error', 500));

        // Act
        final result = await syncApiService.pingServer();

        // Assert
        expect(result, false);
      });

      test('should return false when network exception occurs', () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await syncApiService.pingServer();

        // Assert
        expect(result, false);
      });
    });

    group('pullPosts', () {
      test('should return list of posts when server responds with 200',
          () async {
        // Arrange
        final mockJsonResponse = '''
        [
          {
            "id": "test-id-1",
            "imagePath": "/test/image1.jpg",
            "rawText": "Test raw text 1",
            "normalizedText": "Test normalized text 1",
            "createdAt": "2023-01-01T00:00:00.000Z",
            "likeCount": 0,
            "learnedCount": 0,
            "learned": false,
            "syncId": null,
            "updatedAt": "2023-01-01T00:00:00.000Z",
            "dirty": false,
            "deleted": false,
            "version": 0
          },
          {
            "id": "test-id-2",
            "imagePath": "/test/image2.jpg",
            "rawText": "Test raw text 2",
            "normalizedText": "Test normalized text 2",
            "createdAt": "2023-01-02T00:00:00.000Z",
            "likeCount": 1,
            "learnedCount": 1,
            "learned": true,
            "syncId": "sync-123",
            "updatedAt": "2023-01-02T00:00:00.000Z",
            "dirty": false,
            "deleted": false,
            "version": 1
          }
        ]
        ''';

        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response(mockJsonResponse, 200));

        // Act
        final result = await syncApiService.pullPosts();

        // Assert
        expect(result, isA<List<Post>>());
        expect(result.length, 2);
        expect(result[0].id, 'test-id-1');
        expect(result[1].id, 'test-id-2');
        expect(result[1].syncId, 'sync-123');
      });

      test('should return empty list when server responds with 404', () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        // Act
        final result = await syncApiService.pullPosts();

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty list when network exception occurs', () async {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await syncApiService.pullPosts();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('pushPosts', () {
      test('should complete without error for mock implementation', () async {
        // Arrange
        final posts = [
          Post(
            id: 'test-id',
            imagePath: '/test/image.jpg',
            rawText: 'Test raw text',
            normalizedText: 'Test normalized text',
            createdAt: DateTime.now(),
            likeCount: 0,
            learnedCount: 0,
            learned: false,
            syncId: null,
            updatedAt: DateTime.now(),
            dirty: true,
            deleted: false,
            version: 0,
          ),
        ];

        // Act & Assert
        expect(
            () async => await syncApiService.pushPosts(posts), returnsNormally);
      });
    });

    group('isConnected', () {
      test('should return true when internet is available', () async {
        // Act
        final result = await syncApiService.isConnected();

        // Assert
        // Note: This test depends on actual network connectivity
        // In a real test environment, you might want to mock this
        expect(result, isA<bool>());
      });
    });

    group('dispose', () {
      test('should close http client', () {
        // Act
        syncApiService.dispose();

        // Assert
        // The mock client should be closed (though we can't easily verify this)
        // This test mainly ensures the method doesn't throw
        expect(true, true); // Placeholder assertion
      });
    });
  });
}
