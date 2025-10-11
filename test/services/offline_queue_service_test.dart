import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/models/offline_task.dart';

void main() {
  group('OfflineTask', () {
    test('should create task with correct properties', () {
      // Arrange & Act
      final task = OfflineTask(
        id: 'test-id',
        type: OfflineTaskType.pushPost,
        payload: {'test': 'data'},
        createdAt: DateTime.now(),
      );

      // Assert
      expect(task.id, equals('test-id'));
      expect(task.type, equals(OfflineTaskType.pushPost));
      expect(task.payload, equals({'test': 'data'}));
      expect(task.retryCount, equals(0));
      expect(task.canRetry, isTrue);
      expect(task.isExpired, isFalse);
    });

    test('should detect expired task', () {
      // Arrange & Act
      final expiredDate = DateTime.now().subtract(const Duration(days: 8));
      final task = OfflineTask(
        id: 'test-id',
        type: OfflineTaskType.pushPost,
        payload: {'test': 'data'},
        createdAt: expiredDate,
      );

      // Assert
      expect(task.isExpired, isTrue);
    });

    test('should create retry task with increased retry count', () {
      // Arrange
      final originalTask = OfflineTask(
        id: 'test-id',
        type: OfflineTaskType.pushPost,
        payload: {'test': 'data'},
        createdAt: DateTime.now(),
        retryCount: 1,
      );

      // Act
      final retryTask = originalTask.copyWithRetry();

      // Assert
      expect(retryTask.retryCount, equals(2));
      expect(retryTask.lastRetryAt, isNotNull);
      expect(retryTask.id, equals(originalTask.id));
      expect(retryTask.type, equals(originalTask.type));
      expect(retryTask.payload, equals(originalTask.payload));
    });

    test('should respect max retry count', () {
      // Arrange & Act
      final task = OfflineTask(
        id: 'test-id',
        type: OfflineTaskType.pushPost,
        payload: {'test': 'data'},
        createdAt: DateTime.now(),
        retryCount: OfflineTask.maxRetryCount,
      );

      // Assert
      expect(task.canRetry, isFalse);
    });
  });

  group('OfflineTaskType', () {
    test('should have correct type constants', () {
      expect(OfflineTaskType.pushPost, equals('pushPost'));
      expect(OfflineTaskType.updateReaction, equals('updateReaction'));
      expect(OfflineTaskType.updateLearningHistory,
          equals('updateLearningHistory'));
      expect(OfflineTaskType.deletePost, equals('deletePost'));
    });
  });
}
