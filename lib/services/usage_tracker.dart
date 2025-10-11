import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// 利用状況トラッキングサービス
/// アプリ内の主要行動を匿名・ローカルで計測
class UsageTracker {
  static const String _boxName = 'usage_events';
  static const int _maxEvents = 10000; // 最大イベント数（メモリ節約）

  static final UsageTracker _instance = UsageTracker._internal();
  factory UsageTracker() => _instance;
  UsageTracker._internal();

  Box<UsageEvent>? _box;
  final _uuid = const Uuid();

  /// 初期化
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox<UsageEvent>(_boxName);

      // 古いイベントを削除（メモリ節約）
      await _cleanupOldEvents();

      print('[UsageTracker] Initialized successfully');
    } catch (e) {
      print('[UsageTracker] Failed to initialize: $e');
    }
  }

  /// イベントを記録
  Future<void> trackEvent(String type, {Map<String, dynamic>? metadata}) async {
    if (_box == null) {
      print('[UsageTracker] Box not initialized, skipping event: $type');
      return;
    }

    try {
      final event = UsageEvent(
        id: _uuid.v4(),
        type: type,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      await _box!.add(event);

      // メモリ節約のため定期的にクリーンアップ
      if (_box!.length > _maxEvents) {
        await _cleanupOldEvents();
      }

      print('[UsageTracker] Tracked event: $type');
    } catch (e) {
      print('[UsageTracker] Failed to track event: $e');
    }
  }

  /// 複数のイベントを一括取得
  Future<List<UsageEvent>> getEvents({
    String? type,
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    if (_box == null) return [];

    try {
      List<UsageEvent> events = _box!.values.toList();

      // フィルタリング
      if (type != null) {
        events = events.where((e) => e.type == type).toList();
      }

      if (from != null) {
        events = events.where((e) => e.timestamp.isAfter(from)).toList();
      }

      if (to != null) {
        events = events.where((e) => e.timestamp.isBefore(to)).toList();
      }

      // ソート（新しい順）
      events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // リミット
      if (limit != null && events.length > limit) {
        events = events.take(limit).toList();
      }

      return events;
    } catch (e) {
      print('[UsageTracker] Failed to get events: $e');
      return [];
    }
  }

  /// イベント数を取得
  Future<int> getEventCount({String? type}) async {
    if (_box == null) return 0;

    try {
      if (type == null) {
        return _box!.length;
      } else {
        return _box!.values.where((e) => e.type == type).length;
      }
    } catch (e) {
      print('[UsageTracker] Failed to get event count: $e');
      return 0;
    }
  }

  /// 古いイベントを削除
  Future<void> _cleanupOldEvents() async {
    if (_box == null) return;

    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      final toDelete = <int>[];

      for (int i = 0; i < _box!.length; i++) {
        final event = _box!.getAt(i);
        if (event != null && event.timestamp.isBefore(cutoffDate)) {
          toDelete.add(i);
        }
      }

      // 逆順で削除（インデックスがずれないように）
      for (int i = toDelete.length - 1; i >= 0; i--) {
        await _box!.deleteAt(toDelete[i]);
      }

      print('[UsageTracker] Cleaned up ${toDelete.length} old events');
    } catch (e) {
      print('[UsageTracker] Failed to cleanup old events: $e');
    }
  }

  /// 全データをリセット
  Future<void> reset() async {
    if (_box == null) return;

    try {
      await _box!.clear();
      print('[UsageTracker] All usage data reset');
    } catch (e) {
      print('[UsageTracker] Failed to reset usage data: $e');
    }
  }

  /// リソースを解放
  Future<void> dispose() async {
    try {
      await _box?.close();
      _box = null;
      print('[UsageTracker] Disposed');
    } catch (e) {
      print('[UsageTracker] Failed to dispose: $e');
    }
  }
}

/// 利用状況イベント
class UsageEvent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final Map<String, dynamic> metadata;

  UsageEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.metadata,
  });

  @override
  String toString() {
    return 'UsageEvent(id: $id, type: $type, timestamp: $timestamp, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsageEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// イベントタイプ定数
class UsageEventType {
  static const String appLaunch = 'app_launch';
  static const String appClose = 'app_close';
  static const String ocrUsed = 'ocr_used';
  static const String postCreated = 'post_created';
  static const String cardCompleted = 'card_completed';
  static const String syncCompleted = 'sync_completed';
  static const String paywallShown = 'paywall_shown';
  static const String purchaseCompleted = 'purchase_completed';
  static const String restoreCompleted = 'restore_completed';
  static const String settingsOpened = 'settings_opened';
  static const String tutorialStarted = 'tutorial_started';
  static const String tutorialCompleted = 'tutorial_completed';
}

/// UsageEvent用のHiveアダプター
class UsageEventAdapter extends TypeAdapter<UsageEvent> {
  @override
  final int typeId = 100; // 他のアダプターと重複しないID

  @override
  UsageEvent read(BinaryReader reader) {
    return UsageEvent(
      id: reader.readString(),
      type: reader.readString(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      metadata: Map<String, dynamic>.from(reader.readMap()),
    );
  }

  @override
  void write(BinaryWriter writer, UsageEvent obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.type);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
    writer.writeMap(obj.metadata);
  }
}
