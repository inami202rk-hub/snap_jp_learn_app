import '../models/dictionary_entry.dart';

/// 辞書サービスの抽象インターフェース
/// 同期・非同期のどちらでも差し替え可能
abstract class DictionaryService {
  /// 指定された語句の辞書エントリを検索
  ///
  /// [term] 検索する語句（正規化済み）
  ///
  /// 戻り値: 見つかった場合はDictionaryEntry、見つからない場合はnull
  DictionaryEntry? lookup(String term);

  /// 非同期版の辞書検索（将来のAPI連携用）
  ///
  /// [term] 検索する語句（正規化済み）
  ///
  /// 戻り値: 見つかった場合はDictionaryEntry、見つからない場合はnull
  Future<DictionaryEntry?> lookupAsync(String term);

  /// 辞書が初期化済みかどうか
  bool get isInitialized;

  /// 辞書を初期化（必要に応じて非同期）
  Future<void> initialize();

  /// 辞書の統計情報
  DictionaryStats get stats;
}

/// 辞書の統計情報
class DictionaryStats {
  final int totalEntries;
  final DateTime lastUpdated;
  final String source;

  const DictionaryStats({
    required this.totalEntries,
    required this.lastUpdated,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'lastUpdated': lastUpdated.toIso8601String(),
      'source': source,
    };
  }

  factory DictionaryStats.fromJson(Map<String, dynamic> json) {
    return DictionaryStats(
      totalEntries: json['totalEntries'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      source: json['source'] as String,
    );
  }

  @override
  String toString() {
    return 'DictionaryStats(totalEntries: $totalEntries, lastUpdated: $lastUpdated, source: $source)';
  }
}
