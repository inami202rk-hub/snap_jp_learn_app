import 'package:hive/hive.dart';

part 'post.g.dart';

@HiveType(typeId: 0)
class Post extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String rawText;

  @HiveField(3)
  final String normalizedText;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int likeCount;

  @HiveField(6)
  final int learnedCount;

  @HiveField(7)
  final bool learned;

  // Sync metadata fields
  @HiveField(8)
  final String? syncId;

  @HiveField(9)
  final DateTime updatedAt;

  @HiveField(10)
  final bool dirty;

  @HiveField(11)
  final bool deleted;

  @HiveField(12)
  final int version;

  Post({
    required this.id,
    required this.imagePath,
    required this.rawText,
    required this.normalizedText,
    required this.createdAt,
    this.likeCount = 0,
    this.learnedCount = 0,
    this.learned = false,
    this.syncId,
    DateTime? updatedAt,
    this.dirty = false,
    this.deleted = false,
    this.version = 0,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Post copyWith({
    String? id,
    String? imagePath,
    String? rawText,
    String? normalizedText,
    DateTime? createdAt,
    int? likeCount,
    int? learnedCount,
    bool? learned,
    String? syncId,
    DateTime? updatedAt,
    bool? dirty,
    bool? deleted,
    int? version,
  }) {
    return Post(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      rawText: rawText ?? this.rawText,
      normalizedText: normalizedText ?? this.normalizedText,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      learnedCount: learnedCount ?? this.learnedCount,
      learned: learned ?? this.learned,
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
      'imagePath': imagePath,
      'rawText': rawText,
      'normalizedText': normalizedText,
      'createdAt': createdAt.toIso8601String(),
      'likeCount': likeCount,
      'learnedCount': learnedCount,
      'learned': learned,
      'syncId': syncId,
      'updatedAt': updatedAt.toIso8601String(),
      'dirty': dirty,
      'deleted': deleted,
      'version': version,
    };
  }

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      rawText: json['rawText'] as String,
      normalizedText: json['normalizedText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likeCount: json['likeCount'] as int? ?? 0,
      learnedCount: json['learnedCount'] as int? ?? 0,
      learned: json['learned'] as bool? ?? false,
      syncId: json['syncId'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      dirty: json['dirty'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
      version: json['version'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Post &&
        other.id == id &&
        other.imagePath == imagePath &&
        other.rawText == rawText &&
        other.normalizedText == normalizedText &&
        other.createdAt == createdAt &&
        other.likeCount == likeCount &&
        other.learnedCount == learnedCount &&
        other.learned == learned &&
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
      imagePath,
      rawText,
      normalizedText,
      createdAt,
      likeCount,
      learnedCount,
      learned,
      syncId,
      updatedAt,
      dirty,
      deleted,
      version,
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, imagePath: $imagePath, rawText: $rawText, '
        'normalizedText: $normalizedText, createdAt: $createdAt, '
        'likeCount: $likeCount, learnedCount: $learnedCount, learned: $learned, '
        'syncId: $syncId, updatedAt: $updatedAt, dirty: $dirty, '
        'deleted: $deleted, version: $version)';
  }
}
