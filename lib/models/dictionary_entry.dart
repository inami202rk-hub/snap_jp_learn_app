/// 辞書エントリのモデル
class DictionaryEntry {
  final String term;
  final String reading;
  final List<String> meanings;

  const DictionaryEntry({
    required this.term,
    required this.reading,
    required this.meanings,
  });

  DictionaryEntry copyWith({
    String? term,
    String? reading,
    List<String>? meanings,
  }) {
    return DictionaryEntry(
      term: term ?? this.term,
      reading: reading ?? this.reading,
      meanings: meanings ?? this.meanings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'term': term,
      'reading': reading,
      'meanings': meanings,
    };
  }

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      term: json['term'] as String,
      reading: json['reading'] as String,
      meanings: List<String>.from(json['meanings'] as List),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DictionaryEntry &&
        other.term == term &&
        other.reading == reading &&
        other.meanings.length == meanings.length &&
        other.meanings.every((meaning) => meanings.contains(meaning));
  }

  @override
  int get hashCode => Object.hash(term, reading, meanings);

  @override
  String toString() {
    return 'DictionaryEntry(term: $term, reading: $reading, meanings: $meanings)';
  }
}
