import 'package:hive/hive.dart';

part 'change_journal.g.dart';

/// 同期用の変更ジャーナルエントリ
@HiveType(typeId: 10)
class ChangeJournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String entityType;

  @HiveField(2)
  final String entityId;

  @HiveField(3)
  final ChangeOperation operation;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final int attempt;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  ChangeJournalEntry({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.timestamp,
    this.attempt = 0,
    this.metadata,
  });

  ChangeJournalEntry copyWith({
    String? id,
    String? entityType,
    String? entityId,
    ChangeOperation? operation,
    DateTime? timestamp,
    int? attempt,
    Map<String, dynamic>? metadata,
  }) {
    return ChangeJournalEntry(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      timestamp: timestamp ?? this.timestamp,
      attempt: attempt ?? this.attempt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangeJournalEntry &&
        other.id == id &&
        other.entityType == entityType &&
        other.entityId == entityId &&
        other.operation == operation &&
        other.timestamp == timestamp &&
        other.attempt == attempt;
  }

  @override
  int get hashCode {
    return Object.hash(id, entityType, entityId, operation, timestamp, attempt);
  }

  @override
  String toString() {
    return 'ChangeJournalEntry(id: $id, entityType: $entityType, entityId: $entityId, '
        'operation: $operation, timestamp: $timestamp, attempt: $attempt)';
  }
}

/// 変更操作の種類
@HiveType(typeId: 11)
enum ChangeOperation {
  @HiveField(0)
  create,

  @HiveField(1)
  update,

  @HiveField(2)
  delete,
}

/// 変更ジャーナルを管理するサービス
class ChangeJournal {
  static const String _boxName = 'change_journal';
  Box<ChangeJournalEntry>? _box;

  /// ジャーナルボックスを初期化
  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(ChangeJournalEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(ChangeOperationAdapter());
    }

    _box = await Hive.openBox<ChangeJournalEntry>(_boxName);
  }

  /// ジャーナルを閉じる
  Future<void> close() async {
    await _box?.close();
  }

  /// 変更エントリを追加
  Future<void> addEntry({
    required String entityType,
    required String entityId,
    required ChangeOperation operation,
    Map<String, dynamic>? metadata,
  }) async {
    final box = _box;
    if (box == null) {
      throw StateError('ChangeJournal not initialized');
    }

    final entry = ChangeJournalEntry(
      id: _generateId(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await box.put(entry.id, entry);
  }

  /// 未処理のエントリを取得
  List<ChangeJournalEntry> getPendingEntries() {
    final box = _box;
    if (box == null) {
      return [];
    }

    return box.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// エントリを削除（処理完了後）
  Future<void> removeEntry(String entryId) async {
    final box = _box;
    if (box == null) {
      return;
    }

    await box.delete(entryId);
  }

  /// エントリの試行回数を増加
  Future<void> incrementAttempt(String entryId) async {
    final box = _box;
    if (box == null) {
      return;
    }

    final entry = box.get(entryId);
    if (entry != null) {
      final updatedEntry = entry.copyWith(attempt: entry.attempt + 1);
      await box.put(entryId, updatedEntry);
    }
  }

  /// 特定のエンティティのエントリを取得
  List<ChangeJournalEntry> getEntriesForEntity(
      String entityType, String entityId) {
    final box = _box;
    if (box == null) {
      return [];
    }

    return box.values
        .where((entry) =>
            entry.entityType == entityType && entry.entityId == entityId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// ジャーナルの統計情報を取得
  Map<String, int> getStatistics() {
    final box = _box;
    if (box == null) {
      return {};
    }

    final stats = <String, int>{
      'total': box.length,
      'create': 0,
      'update': 0,
      'delete': 0,
    };

    for (final entry in box.values) {
      switch (entry.operation) {
        case ChangeOperation.create:
          stats['create'] = (stats['create'] ?? 0) + 1;
          break;
        case ChangeOperation.update:
          stats['update'] = (stats['update'] ?? 0) + 1;
          break;
        case ChangeOperation.delete:
          stats['delete'] = (stats['delete'] ?? 0) + 1;
          break;
      }
    }

    return stats;
  }

  /// 古いエントリをクリーンアップ（処理済みのもの）
  Future<void> cleanupProcessedEntries(
      {Duration maxAge = const Duration(days: 7)}) async {
    final box = _box;
    if (box == null) {
      return;
    }

    final cutoff = DateTime.now().subtract(maxAge);
    final keysToDelete = <String>[];

    for (final entry in box.values) {
      if (entry.timestamp.isBefore(cutoff)) {
        keysToDelete.add(entry.id);
      }
    }

    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  /// 一意のIDを生成
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}
