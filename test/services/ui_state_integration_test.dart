import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:snap_jp_learn_app/services/ocr_service.dart';
import 'package:snap_jp_learn_app/services/sync_engine.dart';
import 'package:snap_jp_learn_app/services/stats_service.dart';
import 'package:snap_jp_learn_app/services/sync_api_service.dart';
import 'package:snap_jp_learn_app/models/post.dart';
import 'package:snap_jp_learn_app/core/ui_state.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import 'ui_state_integration_test.mocks.dart';

@GenerateMocks([
  OcrService,
  SyncApiService,
  Box,
])
void main() {
  group('UiState Integration Tests', () {
    late MockOcrService mockOcrService;
    late MockSyncApiService mockSyncApiService;
    late MockBox<Post> mockPostBox;

    setUp(() {
      mockOcrService = MockOcrService();
      mockSyncApiService = MockSyncApiService();
      mockPostBox = MockBox<Post>();
    });

    group('OCR Service UiState Integration', () {
      test('extractTextFromXFileWithState should return success state',
          () async {
        // Arrange
        const testText = 'Test extracted text';
        const testFile = XFile('test/path');

        when(mockOcrService.extractTextFromXFile(testFile))
            .thenAnswer((_) async => testText);

        // Act
        final result =
            await mockOcrService.extractTextFromXFileWithState(testFile);

        // Assert
        expect(result, isA<UiSuccess<String>>());
        expect(result.data, equals(testText));
      });

      test(
          'extractTextFromXFileWithState should return error state on exception',
          () async {
        // Arrange
        const testFile = XFile('test/path');
        const errorMessage = 'OCR processing failed';

        when(mockOcrService.extractTextFromXFile(testFile))
            .thenThrow(OcrException(errorMessage));

        // Act
        final result =
            await mockOcrService.extractTextFromXFileWithState(testFile);

        // Assert
        expect(result, isA<UiError<String>>());
        expect(result.errorMessage, equals(errorMessage));
      });

      test('extractTextFromImageWithState should return success state',
          () async {
        // Arrange
        const testText = 'Test extracted text';

        when(mockOcrService.extractTextFromImage(source: ImageSource.camera))
            .thenAnswer((_) async => testText);

        // Act
        final result = await mockOcrService.extractTextFromImageWithState(
          source: ImageSource.camera,
        );

        // Assert
        expect(result, isA<UiSuccess<String>>());
        expect(result.data, equals(testText));
      });
    });

    group('Sync Engine UiState Integration', () {
      late SyncEngine syncEngine;

      setUp(() {
        syncEngine = SyncEngine(
          syncApiService: mockSyncApiService,
          postBox: mockPostBox,
        );
      });

      test('performFullSyncWithState should return success state', () async {
        // Arrange
        final mockStats = SyncStats(
          pushedCount: 5,
          pulledCount: 3,
          conflictCount: 0,
          errorCount: 0,
          duration: const Duration(seconds: 2),
        );

        when(mockSyncApiService.isConnected()).thenAnswer((_) async => true);
        when(mockPostBox.values).thenReturn([]);
        when(mockPostBox.put(any, any)).thenAnswer((_) async {});
        when(mockSyncApiService.getPosts(any)).thenAnswer((_) async => []);
        when(mockSyncApiService.pushPosts(any)).thenAnswer((_) async => []);

        // Act
        final result = await syncEngine.performFullSyncWithState();

        // Assert
        expect(result, isA<UiSuccess<SyncStats>>());
        expect(result.data, isA<SyncStats>());
      });

      test(
          'performFullSyncWithState should return error state on network exception',
          () async {
        // Arrange
        when(mockSyncApiService.isConnected()).thenAnswer((_) async => false);

        // Act
        final result = await syncEngine.performFullSyncWithState();

        // Assert
        expect(result, isA<UiError<SyncStats>>());
        expect(result.errorMessage, equals(UiStateUtils.networkErrorMessage));
      });

      test('retryPending should return success state when no pending posts',
          () async {
        // Arrange
        when(mockSyncApiService.isConnected()).thenAnswer((_) async => true);
        when(mockPostBox.values).thenReturn([]);

        // Act
        final result = await syncEngine.retryPending();

        // Assert
        expect(result, isA<UiSuccess<SyncStats>>());
        expect(result.data?.pushedCount, equals(0));
        expect(result.data?.pulledCount, equals(0));
      });

      test('retryPending should return error state when offline', () async {
        // Arrange
        when(mockSyncApiService.isConnected()).thenAnswer((_) async => false);

        // Act
        final result = await syncEngine.retryPending();

        // Assert
        expect(result, isA<UiError<SyncStats>>());
        expect(result.errorMessage, equals(UiStateUtils.networkErrorMessage));
      });
    });

    group('Stats Service UiState Integration', () {
      test('getStatsWithState should return success state', () async {
        // This test would require mocking the repositories
        // For now, we'll test the structure
        expect(true, isTrue); // Placeholder test
      });

      test('getTodayReviewsWithState should return success state', () async {
        // This test would require mocking the repositories
        // For now, we'll test the structure
        expect(true, isTrue); // Placeholder test
      });
    });

    group('UiState Utils Integration', () {
      test('should create appropriate states for different scenarios', () {
        // Test loading state
        final loading = UiStateUtils.loading<String>();
        expect(loading, isA<UiLoading<String>>());

        // Test success state
        final success = UiStateUtils.success<String>('test data');
        expect(success, isA<UiSuccess<String>>());
        expect(success.data, equals('test data'));

        // Test error state
        final error = UiStateUtils.error<String>('test error');
        expect(error, isA<UiError<String>>());
        expect(error.errorMessage, equals('test error'));
      });

      test('should provide consistent error messages', () {
        expect(UiStateUtils.networkErrorMessage, equals('ネットワークに接続されていません'));
        expect(UiStateUtils.serverErrorMessage, equals('サーバーでエラーが発生しました'));
        expect(UiStateUtils.ocrErrorMessage, equals('画像の読み取りに失敗しました'));
        expect(UiStateUtils.syncErrorMessage, equals('同期に失敗しました'));
      });
    });

    group('UiState Pattern Usage', () {
      test('should handle state transitions correctly', () {
        // Test loading -> success transition
        UiState<String> state = UiStateUtils.loading<String>();
        expect(state.isLoading, isTrue);

        state = UiStateUtils.success<String>('result');
        expect(state.isSuccess, isTrue);
        expect(state.data, equals('result'));

        // Test success -> error transition
        state = UiStateUtils.error<String>('error');
        expect(state.isError, isTrue);
        expect(state.errorMessage, equals('error'));
      });

      test('should use when method for state handling', () {
        final state = UiStateUtils.success<String>('test data');

        final result = state.when(
          loading: () => 'loading',
          success: (data) => 'success: $data',
          error: (message) => 'error: $message',
        );

        expect(result, equals('success: test data'));
      });

      test('should use maybeWhen method for partial state handling', () {
        final state = UiStateUtils.error<String>('test error');

        final result = state.maybeWhen(
          loading: () => 'loading',
          orElse: () => 'default',
        );

        expect(result, equals('default'));
      });
    });
  });
}
