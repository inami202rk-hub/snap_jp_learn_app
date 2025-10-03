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

  ReviewLog({
    required this.id,
    required this.cardId,
    required this.reviewedAt,
    required this.rating,
  });

  ReviewLog copyWith({
    String? id,
    String? cardId,
    DateTime? reviewedAt,
    String? rating,
  }) {
    return ReviewLog(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardId': cardId,
      'reviewedAt': reviewedAt.toIso8601String(),
      'rating': rating,
    };
  }

  static ReviewLog fromJson(Map<String, dynamic> json) {
    return ReviewLog(
      id: json['id'] as String,
      cardId: json['cardId'] as String,
      reviewedAt: DateTime.parse(json['reviewedAt'] as String),
      rating: json['rating'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReviewLog &&
        other.id == id &&
        other.cardId == cardId &&
        other.reviewedAt == reviewedAt &&
        other.rating == rating;
  }

  @override
  int get hashCode {
    return Object.hash(id, cardId, reviewedAt, rating);
  }

  @override
  String toString() {
    return 'ReviewLog(id: $id, cardId: $cardId, reviewedAt: $reviewedAt, rating: $rating)';
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
