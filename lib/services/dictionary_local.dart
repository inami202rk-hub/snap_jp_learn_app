import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dictionary_entry.dart';
import '../services/text_normalizer.dart';
import 'dictionary_service.dart';

/// ローカル辞書サービスの実装
/// assets/dict/ja_core.jsonから辞書データを読み込んで検索
class DictionaryLocalService implements DictionaryService {
  final Map<String, DictionaryEntry> _dictionary = {};
  bool _isInitialized = false;
  DateTime? _lastUpdated;

  @override
  bool get isInitialized => _isInitialized;

  @override
  DictionaryStats get stats => DictionaryStats(
        totalEntries: _dictionary.length,
        lastUpdated: _lastUpdated ?? DateTime.now(),
        source: 'Local Dictionary (ja_core.json)',
      );

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // assets/dict/ja_core.jsonを読み込み
      final String jsonString =
          await rootBundle.loadString('assets/dict/ja_core.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 辞書データをパース
      final List<dynamic> entries = jsonData['entries'] as List;

      for (final entry in entries) {
        final DictionaryEntry dictEntry = DictionaryEntry.fromJson(entry);

        // 正規化された語句をキーとして保存
        final normalizedTerm = TextNormalizer.normalizeOcrText(dictEntry.term);
        _dictionary[normalizedTerm] = dictEntry;
      }

      _lastUpdated = DateTime.now();
      _isInitialized = true;
    } catch (e) {
      throw DictionaryException('Failed to initialize dictionary: $e');
    }
  }

  @override
  DictionaryEntry? lookup(String term) {
    if (!_isInitialized) {
      throw DictionaryException(
          'Dictionary not initialized. Call initialize() first.');
    }

    // 語句を正規化して検索
    final normalizedTerm = TextNormalizer.normalizeOcrText(term);
    return _dictionary[normalizedTerm];
  }

  @override
  Future<DictionaryEntry?> lookupAsync(String term) async {
    // ローカル辞書では同期版と同じ
    return lookup(term);
  }

  /// 部分一致検索（将来の拡張用）
  List<DictionaryEntry> searchPartial(String partialTerm) {
    if (!_isInitialized) {
      throw DictionaryException(
          'Dictionary not initialized. Call initialize() first.');
    }

    final normalizedPartial = TextNormalizer.normalizeOcrText(partialTerm);
    final results = <DictionaryEntry>[];

    for (final entry in _dictionary.values) {
      if (entry.term.contains(normalizedPartial) ||
          entry.reading.contains(normalizedPartial)) {
        results.add(entry);
      }
    }

    return results;
  }

  /// 辞書の内容をクリア（テスト用）
  void clear() {
    _dictionary.clear();
    _isInitialized = false;
    _lastUpdated = null;
  }
}

/// 辞書関連の例外
class DictionaryException implements Exception {
  final String message;

  const DictionaryException(this.message);

  @override
  String toString() => 'DictionaryException: $message';
}
