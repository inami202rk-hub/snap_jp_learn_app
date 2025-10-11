import 'package:hive/hive.dart';

part 'offline_task.g.dart';

/// オフライン中にキューに保存されるタスクのモデル
@HiveType(typeId: 10)
class OfflineTask extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final Map<String, dynamic> payload;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int retryCount;

  @HiveField(5)
  final DateTime? lastRetryAt;

  OfflineTask({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastRetryAt,
  });

  /// タスクの最大リトライ回数
  static const int maxRetryCount = 3;

  /// リトライ可能かどうか
  bool get canRetry => retryCount < maxRetryCount;

  /// タスクの有効期限（7日）
  bool get isExpired {
    final expirationDate = createdAt.add(const Duration(days: 7));
    return DateTime.now().isAfter(expirationDate);
  }

  /// タスクをコピーしてリトライ回数を増加
  OfflineTask copyWithRetry() {
    return OfflineTask(
      id: id,
      type: type,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount + 1,
      lastRetryAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'OfflineTask(id: $id, type: $type, retryCount: $retryCount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfflineTask && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// オフラインタスクのタイプ定数
class OfflineTaskType {
  static const String pushPost = 'pushPost';
  static const String updateReaction = 'updateReaction';
  static const String updateLearningHistory = 'updateLearningHistory';
  static const String deletePost = 'deletePost';
}
