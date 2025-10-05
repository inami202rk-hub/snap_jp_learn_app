import 'package:hive/hive.dart';

part 'review_log.g.dart';

@HiveType(typeId: 2)
class ReviewLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String cardId;

  @HiveField(2)
  final DateTime reviewedAt;

  @HiveField(3)
  final String rating;

  // Sync metadata fields
  @HiveField(4)
  final String? syncId;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final bool dirty;

  @HiveField(7)
  final bool deleted;

  @HiveField(8)
  final int version;

  ReviewLog({
    required this.id,
    required this.cardId,
    required this.reviewedAt,
    required this.rating,
    this.syncId,
    DateTime? updatedAt,
    this.dirty = false,
    this.deleted = false,
    this.version = 0,
  }) : updatedAt = updatedAt ?? DateTime.now();

  ReviewLog copyWith({
    String? id,
    String? cardId,
    DateTime? reviewedAt,
    String? rating,
    String? syncId,
    DateTime? updatedAt,
    bool? dirty,
    bool? deleted,
    int? version,
  }) {
    return ReviewLog(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rating: rating ?? this.rating,
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
      'cardId': cardId,
      'reviewedAt': reviewedAt.toIso8601String(),
      'rating': rating,
      'syncId': syncId,
      'updatedAt': updatedAt.toIso8601String(),
      'dirty': dirty,
      'deleted': deleted,
      'version': version,
    };
  }

  static ReviewLog fromJson(Map<String, dynamic> json) {
    return ReviewLog(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      reviewedAt: DateTime.parse(json['reviewedAt'] as String),
      rating: json['rating'] as String,
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
    return other is ReviewLog &&
        other.id == id &&
        other.cardId == cardId &&
        other.reviewedAt == reviewedAt &&
        other.rating == rating &&
        other.syncId == syncId &&
        other.updatedAt == updatedAt &&
        other.dirty == dirty &&
        other.deleted == deleted &&
        other.version == version;
  }

  @override
  int get hashCode {
    return Object.hash(id, cardId, reviewedAt, rating, syncId, updatedAt, dirty,
        deleted, version);
  }

  @override
  String toString() {
    return 'ReviewLog(id: $id, cardId: $cardId, reviewedAt: $reviewedAt, rating: $rating, '
        'syncId: $syncId, updatedAt: $updatedAt, dirty: $dirty, deleted: $deleted, version: $version)';
  }
}

/// レビューの評価レベル
enum Rating {
  again('again'),
  hard('hard'),
  good('good'),
  easy('easy');

  const Rating(this.value);
  final String value;

  static Rating fromString(String value) {
    switch (value) {
      case 'again':
        return Rating.again;
      case 'hard':
        return Rating.hard;
      case 'good':
        return Rating.good;
      case 'easy':
        return Rating.easy;
      default:
        throw ArgumentError('Invalid rating: $value');
    }
  }

  /// 評価の日本語表示名
  String get displayName {
    switch (this) {
      case Rating.again:
        return 'もう一度';
      case Rating.hard:
        return '難しい';
      case Rating.good:
        return '良い';
      case Rating.easy:
        return '簡単';
    }
  }

  /// 評価の色（UI用）
  String get colorName {
    switch (this) {
      case Rating.again:
        return 'red';
      case Rating.hard:
        return 'orange';
      case Rating.good:
        return 'blue';
      case Rating.easy:
        return 'green';
    }
  }
}
