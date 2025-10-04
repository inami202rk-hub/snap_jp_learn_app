import 'package:hive/hive.dart';

part 'srs_card.g.dart';

@HiveType(typeId: 1)
class SrsCard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String term;

  @HiveField(2)
  final String reading;

  @HiveField(3)
  final String meaning;

  @HiveField(4)
  final String sourcePostId;

  @HiveField(5)
  final String sourceSnippet;

  @HiveField(6)
  final DateTime createdAt;

  // SRS fields
  @HiveField(7)
  final int interval;

  @HiveField(8)
  final double easeFactor;

  @HiveField(9)
  final int repetition;

  @HiveField(10)
  final DateTime due;

  // Sync metadata fields
  @HiveField(11)
  final String? syncId;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final bool dirty;

  @HiveField(14)
  final bool deleted;

  @HiveField(15)
  final int version;

  SrsCard({
    required this.id,
    required this.term,
    this.reading = '',
    this.meaning = '',
    required this.sourcePostId,
    required this.sourceSnippet,
    required this.createdAt,
    this.interval = 0,
    this.easeFactor = 2.5,
    this.repetition = 0,
    required this.due,
    this.syncId,
    DateTime? updatedAt,
    this.dirty = false,
    this.deleted = false,
    this.version = 0,
  }) : updatedAt = updatedAt ?? DateTime.now();

  SrsCard copyWith({
    String? id,
    String? term,
    String? reading,
    String? meaning,
    String? sourcePostId,
    String? sourceSnippet,
    DateTime? createdAt,
    int? interval,
    double? easeFactor,
    int? repetition,
    DateTime? due,
    String? syncId,
    DateTime? updatedAt,
    bool? dirty,
    bool? deleted,
    int? version,
  }) {
    return SrsCard(
      id: id ?? this.id,
      term: term ?? this.term,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      sourcePostId: sourcePostId ?? this.sourcePostId,
      sourceSnippet: sourceSnippet ?? this.sourceSnippet,
      createdAt: createdAt ?? this.createdAt,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
      repetition: repetition ?? this.repetition,
      due: due ?? this.due,
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      deleted: deleted ?? this.deleted,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'reading': reading,
      'meaning': meaning,
      'sourcePostId': sourcePostId,
      'sourceSnippet': sourceSnippet,
      'createdAt': createdAt.toIso8601String(),
      'interval': interval,
      'easeFactor': easeFactor,
      'repetition': repetition,
      'due': due.toIso8601String(),
      'syncId': syncId,
      'updatedAt': updatedAt.toIso8601String(),
      'dirty': dirty,
      'deleted': deleted,
      'version': version,
    };
  }

  static SrsCard fromJson(Map<String, dynamic> json) {
    return SrsCard(
      id: json['id'] as String,
      term: json['term'] as String,
      reading: json['reading'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      sourcePostId: json['sourcePostId'] as String,
      sourceSnippet: json['sourceSnippet'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      interval: json['interval'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      repetition: json['repetition'] as int? ?? 0,
      due: DateTime.parse(json['due'] as String),
      syncId: json['syncId'] as String?,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      dirty: json['dirty'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      version: json['version'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SrsCard &&
        other.id == id &&
        other.term == term &&
        other.reading == reading &&
        other.meaning == meaning &&
        other.sourcePostId == sourcePostId &&
        other.sourceSnippet == sourceSnippet &&
        other.createdAt == createdAt &&
        other.interval == interval &&
        other.easeFactor == easeFactor &&
        other.repetition == repetition &&
        other.due == due &&
        other.syncId == syncId &&
        other.updatedAt == updatedAt &&
        other.dirty == dirty &&
        other.deleted == deleted &&
        other.version == version;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      term,
      reading,
      meaning,
      sourcePostId,
      sourceSnippet,
      createdAt,
      interval,
      easeFactor,
      repetition,
      due,
      syncId,
      updatedAt,
      dirty,
      deleted,
      version,
    );
  }

  @override
  String toString() {
    return 'SrsCard(id: $id, term: $term, reading: $reading, meaning: $meaning, '
        'sourcePostId: $sourcePostId, sourceSnippet: $sourceSnippet, '
        'createdAt: $createdAt, interval: $interval, easeFactor: $easeFactor, '
        'repetition: $repetition, due: $due, syncId: $syncId, updatedAt: $updatedAt, '
        'dirty: $dirty, deleted: $deleted, version: $version)';
  }

  /// カードが今日レビュー対象かどうか
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(due.year, due.month, due.day);
    return dueDate.isBefore(today) || dueDate.isAtSameMomentAs(today);
  }

  /// カードの難易度レベル（repetition に基づく）
  String get difficultyLevel {
    if (repetition == 0) return 'New';
    if (repetition < 3) return 'Learning';
    if (repetition < 10) return 'Young';
    return 'Mature';
  }

  /// 次回レビューまでの日数
  int get daysUntilReview {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(due.year, due.month, due.day);
    return dueDate.difference(today).inDays;
  }
}
