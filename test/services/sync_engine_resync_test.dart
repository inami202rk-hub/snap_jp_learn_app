import 'package:flutter_test/flutter_test.dart';
import 'package:snap_jp_learn_app/models/offline_task.dart';
import 'package:snap_jp_learn_app/services/offline_queue_service.dart';

void main() {
  group('OfflineQueueStatus', () {
    test('should have correct status values', () {
      // Assert
      expect(OfflineQueueStatus.idle.toString(), contains('idle'));
      expect(OfflineQueueStatus.processing.toString(), contains('processing'));
      expect(OfflineQueueStatus.completed.toString(), contains('completed'));
      expect(OfflineQueueStatus.error.toString(), contains('error'));
    });

    test('should support equality comparison', () {
      // Assert
      expect(OfflineQueueStatus.idle, equals(OfflineQueueStatus.idle));
      expect(OfflineQueueStatus.processing, equals(OfflineQueueStatus.processing));
      expect(OfflineQueueStatus.completed, equals(OfflineQueueStatus.completed));
      expect(OfflineQueueStatus.error, equals(OfflineQueueStatus.error));
    });
  });
}