import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../services/text_normalizer.dart';
import '../services/text_normalize_options.dart';

/// 重い処理をIsolateで実行するためのヘルパー
class IsolateHelper {
  /// テキスト正規化をIsolateで実行
  ///
  /// [rawText] 生のOCRテキスト
  /// [options] 正規化オプション
  ///
  /// Returns: 正規化されたテキスト
  static Future<String> normalizeTextInIsolate(
    String rawText, {
    TextNormalizeOptions? options,
  }) async {
    try {
      return await compute(_normalizeTextInIsolate, {
        'rawText': rawText,
        'options': options,
      });
    } catch (e) {
      // Isolateでの処理に失敗した場合は、メインスレッドで処理
      return TextNormalizer.normalizeOcrText(rawText, options: options);
    }
  }

  /// OCR処理とテキスト正規化を組み合わせてIsolateで実行
  ///
  /// [imagePath] 画像ファイルのパス
  ///
  /// Returns: 正規化されたテキスト
  static Future<String> processImageAndNormalizeInIsolate(
      String imagePath) async {
    try {
      return await compute(_processImageAndNormalizeInIsolate, imagePath);
    } catch (e) {
      throw Exception('Isolate processing failed: $e');
    }
  }

  /// 複数のテキストを並列で正規化
  ///
  /// [texts] 正規化するテキストのリスト
  /// [options] 正規化オプション
  ///
  /// Returns: 正規化されたテキストのリスト
  static Future<List<String>> normalizeTextsInParallel(
    List<String> texts, {
    TextNormalizeOptions? options,
  }) async {
    if (texts.isEmpty) return [];

    // 大量のテキストの場合は並列処理
    if (texts.length > 5) {
      final futures = texts
          .map((text) => normalizeTextInIsolate(text, options: options))
          .toList();
      return await Future.wait(futures);
    } else {
      // 少数のテキストの場合はメインスレッドで処理
      return texts
          .map(
              (text) => TextNormalizer.normalizeOcrText(text, options: options))
          .toList();
    }
  }

  /// バッチ処理でテキスト正規化
  ///
  /// [texts] 正規化するテキストのリスト
  /// [batchSize] バッチサイズ（デフォルト: 10）
  /// [options] 正規化オプション
  ///
  /// Returns: 正規化されたテキストのリスト
  static Future<List<String>> normalizeTextsInBatches(
    List<String> texts, {
    int batchSize = 10,
    TextNormalizeOptions? options,
  }) async {
    if (texts.isEmpty) return [];

    final results = <String>[];

    for (int i = 0; i < texts.length; i += batchSize) {
      final batch = texts.skip(i).take(batchSize).toList();
      final batchResults =
          await normalizeTextsInParallel(batch, options: options);
      results.addAll(batchResults);
    }

    return results;
  }
}

/// Isolateで実行されるテキスト正規化関数
Future<String> _normalizeTextInIsolate(Map<String, dynamic> params) async {
  final rawText = params['rawText'] as String;
  final options = params['options'] as TextNormalizeOptions?;

  return TextNormalizer.normalizeOcrText(rawText, options: options);
}

/// Isolateで実行される画像処理＋正規化関数
Future<String> _processImageAndNormalizeInIsolate(String imagePath) async {
  // この関数は実際のOCR処理と正規化を組み合わせる
  // 現在はプレースホルダー実装
  await Future.delayed(const Duration(milliseconds: 100));
  return 'Processed text from $imagePath';
}

/// キャンセル可能なIsolate処理
class CancellableIsolateTask<T> {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _sendPort;
  bool _isCancelled = false;
  Completer<T>? _completer;

  /// 処理を開始
  Future<T> start(Future<T> Function() task) async {
    if (_isCancelled) {
      throw Exception('Task has been cancelled');
    }

    _completer = Completer<T>();

    try {
      _receivePort = ReceivePort();
      _isolate = await Isolate.spawn(_runTaskInIsolate, _receivePort!.sendPort);

      _sendPort = await _receivePort!.first as SendPort;

      if (_isCancelled) {
        throw Exception('Task was cancelled during setup');
      }

      // タスクを送信
      _sendPort!.send(task);

      // 結果を待機
      final result = await _receivePort!.first as T;

      if (_isCancelled) {
        throw Exception('Task was cancelled');
      }

      _completer!.complete(result);
      return result;
    } catch (e) {
      if (!_completer!.isCompleted) {
        _completer!.completeError(e);
      }
      rethrow;
    } finally {
      _cleanup();
    }
  }

  /// 処理をキャンセル
  void cancel() {
    _isCancelled = true;
    _cleanup();

    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(Exception('Task was cancelled'));
    }
  }

  /// リソースをクリーンアップ
  void _cleanup() {
    _receivePort?.close();
    _isolate?.kill();
    _receivePort = null;
    _isolate = null;
    _sendPort = null;
  }
}

/// Isolateでタスクを実行する関数
void _runTaskInIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    if (message is Future Function()) {
      try {
        final result = await message();
        sendPort.send(result);
      } catch (e) {
        sendPort.send(e);
      }
    }
  });
}
