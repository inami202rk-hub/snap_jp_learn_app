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

  Post({
    required this.id,
    required this.imagePath,
    required this.rawText,
    required this.normalizedText,
    required this.createdAt,
    this.likeCount = 0,
    this.learnedCount = 0,
    this.learned = false,
  });

  Post copyWith({
    String? id,
    String? imagePath,
    String? rawText,
    String? normalizedText,
    DateTime? createdAt,
    int? likeCount,
    int? learnedCount,
    bool? learned,
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
        other.learned == learned;
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
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, imagePath: $imagePath, rawText: $rawText, '
        'normalizedText: $normalizedText, createdAt: $createdAt, '
        'likeCount: $likeCount, learnedCount: $learnedCount, learned: $learned)';
  }
}
