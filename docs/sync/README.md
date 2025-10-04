# クラウド同期アーキテクチャ

## 概要

Snap JP Learn Appのクラウド同期機能は、ローカル完結MVPを維持しつつ、後日クラウド同期を安全に導入できる土台を提供します。

## アーキテクチャ

### クライアント主導型同期

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   クライアント    │    │   変更ジャーナル   │    │   モックサーバー   │
│                 │    │                 │    │                 │
│  Post/SrsCard/  │───▶│  ChangeJournal  │───▶│   MockSyncApi   │
│  ReviewLog      │    │                 │    │                 │
│                 │    │  QueuePump      │◀───│                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 同期フロー

1. **変更検出**: Repository層でデータ変更時に自動的にジャーナルに記録
2. **キューイング**: `QueuePump`がバックグラウンドで順次処理
3. **プッシュ**: ローカル変更をサーバーに送信
4. **プル**: サーバー変更をローカルに取得
5. **衝突解決**: Last Write Wins (LWW) ポリシーで解決

## データモデル

### 同期メタフィールド

すべてのエンティティ（Post, SrsCard, ReviewLog）に以下のフィールドを追加：

```dart
@HiveField(x)
final String? syncId;        // サーバー側UUID（未同期はnull）

@HiveField(x+1)
final DateTime updatedAt;    // クライアント更新時刻

@HiveField(x+2)
final bool dirty;           // 変更あり＝true

@HiveField(x+3)
final bool deleted;         // 論理削除

@HiveField(x+4)
final int version;          // 楽観ロック用（既定0）
```

### 前方互換性

- すべての同期フィールドはnullableまたはデフォルト値
- 既存データの破壊なし
- Hiveの軽量マイグレーション対応

## 変更ジャーナル

### ChangeJournalEntry

```dart
class ChangeJournalEntry {
  final String id;                    // 一意ID
  final String entityType;           // エンティティタイプ
  final String entityId;             // エンティティID
  final ChangeOperation operation;   // 操作種別
  final DateTime timestamp;          // タイムスタンプ
  final int attempt;                 // 試行回数
  final Map<String, dynamic>? metadata; // メタデータ
}
```

### 操作種別

- `create`: 新規作成
- `update`: 更新
- `delete`: 削除

## キューシステム

### QueuePump

- バックグラウンドで順次フラッシュ
- 指数バックオフ（1s → 5s → 30s → 5m）
- 最大試行回数: 5回
- 自動リトライ

### スケジュール

- アプリ起動時
- フォアグラウンド復帰時
- 手動「今すぐ同期」

## ネットワーク層

### 抽象インターフェース

```dart
abstract class SyncApi {
  Future<SyncResult> pushPosts(List<ChangeJournalEntry> entries);
  Future<SyncResult> pushSrsCards(List<ChangeJournalEntry> entries);
  Future<SyncResult> pushReviewLogs(List<ChangeJournalEntry> entries);
  Future<SyncResult> pullPosts(DateTime since);
  Future<SyncResult> pullSrsCards(DateTime since);
  Future<SyncResult> pullReviewLogs(DateTime since);
  Future<bool> isConnected();
  Future<SyncStatus> getSyncStatus();
}
```

### 実装

- **MockSyncApi**: メモリ内シミュレーション（開発用）
- **HttpSyncApi**: 実HTTPサーバー通信（将来実装）

## 衝突解決ポリシー

### Last Write Wins (LWW)

1. **墓石優先**: `deleted=true`は最優先
2. **時刻比較**: `updatedAt`で比較
3. **バージョン比較**: 同時刻の場合は`version`で比較
4. **クライアント優先**: 同時刻・同バージョンの場合はクライアント優先

### エンティティ別の扱い

- **Post**: 完全なLWW
- **SrsCard**: 完全なLWW
- **ReviewLog**: 追加のみ（衝突なし）

## 安全ガード

### ID体系

- **クライアントID**: ローカルUUID（Post.id/SrsCard.id）
- **サーバーID**: サーバー発行UUID（syncId）
- **二相アップサート**: クライアントIDで送信 → サーバーIDで受信

### 時刻管理

- `updatedAt`: 常にクライアント時刻で記録
- サーバー側でも受信時刻を併記（将来実装）

### 論理削除

- ローカル一覧から即非表示
- 後で同期時に墓石送信

## 設定・フラグ

### FeatureFlags

```dart
class FeatureFlags {
  static const bool syncEnabled = false;        // デフォルト無効
  static const SyncPolicy syncPolicy = SyncPolicy.lastWriteWins;
  static const bool syncMockMode = true;        // モックAPI使用
}
```

### 起動時DI

```dart
// 将来の実装例
final syncApi = FeatureFlags.syncMockMode 
    ? MockSyncApi() 
    : HttpSyncApi(baseUrl: 'https://api.example.com');

final syncService = SyncService(
  journal: changeJournal,
  pump: queuePump,
  api: syncApi,
  policy: FeatureFlags.syncPolicy,
);
```

## オフライン対応

### ネットワーク未接続時

- 静かにスキップ（トースト不要）
- 設定ページで「未同期◯件」表示
- 従来のローカル操作は完全に動作

### 失敗時

- バックオフ後に自動再試行
- ユーザー操作は不要
- エラーはログに記録

## テスト戦略

### ユニットテスト

- ジャーナル記録: 作成/更新/削除でdirtyとイベント記録
- 衝突解決: 同一レコードの双方更新→LWWで勝者決定
- 墓石: 削除→pullで復活しない

### 結合テスト（モックAPI使用）

- 新規端末: pullでサーバーデータ取得
- 既存端末: push→サーバー側syncId付与→ローカル反映
- オフライン→オンライン復帰で自動同期

### 回帰ガード

- 同期オフ時、従来のローカル操作は一切変わらず動作
- 既存テストがすべて緑

## 将来の拡張

### 段階導入手順

1. **Mock**: 現在の実装（完了）
2. **HTTP**: 実サーバーとの通信
3. **認証**: 匿名アカウント/端末紐付け
4. **差分同期**: 効率的な同期

### 追加ポリシー

- **Server Wins**: サーバー権威型
- **Merge**: マージ型（複雑な競合解決）

### セキュリティ

- 当面は認証なし（外部接続しないため）
- 将来: TLS前提、匿名アカウント

## パフォーマンス

### 最適化ポイント

- バッチ処理: 複数エントリをまとめて送信
- 差分同期: 変更されたデータのみ送信
- 圧縮: 大きなペイロードの圧縮
- 並列処理: 複数エンティティタイプの並列同期

### メトリクス

- 同期件数
- 残Dirty件数
- 最後の成功時刻
- エラー率
- 同期時間

## トラブルシューティング

### よくある問題

1. **同期が止まる**: ネットワーク接続を確認
2. **データが重複**: 衝突解決ポリシーを確認
3. **削除されたデータが復活**: 墓石の優先度を確認

### デバッグ

- 同期ステータスの確認
- ジャーナルエントリの確認
- ネットワークログの確認

## まとめ

この同期アーキテクチャにより：

- ✅ **ローカル完結MVPを維持**
- ✅ **後日クラウド同期を安全に導入可能**
- ✅ **前方互換性を保証**
- ✅ **オフライン対応**
- ✅ **衝突解決**
- ✅ **テスト可能**

段階的な導入により、リスクを最小化しながら将来のクラウド同期機能を準備できます。
