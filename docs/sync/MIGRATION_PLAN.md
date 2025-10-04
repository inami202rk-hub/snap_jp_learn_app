# 同期機能段階導入手順

## 概要

クラウド同期機能を段階的に導入し、リスクを最小化しながら本格運用に移行する計画です。

## フェーズ1: Mock基盤（現在）

### 実装済み

- ✅ データモデルの同期メタフィールド追加
- ✅ 変更ジャーナルとキューシステム
- ✅ モックAPI実装
- ✅ 衝突解決ポリシー（LWW）
- ✅ 設定画面の同期ステータス表示
- ✅ ユニット・結合テスト

### 検証項目

- [ ] 既存機能への影響なし（回帰テスト）
- [ ] 同期フラグ無効時の動作確認
- [ ] モックサーバーでのE2Eテスト
- [ ] パフォーマンステスト

### 完了条件

- CI（format/analyze/test）が緑
- 既存の全テストが通過
- モック同期のE2Eテストが通過

## フェーズ2: HTTP実装

### 実装予定

```dart
class HttpSyncApi implements SyncApi {
  final String baseUrl;
  final String? authToken;
  
  @override
  Future<SyncResult> pushPosts(List<ChangeJournalEntry> entries) async {
    // POST /api/sync/posts/upsert
    final response = await http.post(
      Uri.parse('$baseUrl/api/sync/posts/upsert'),
      headers: {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
    
    if (response.statusCode == 200) {
      return SyncResult.success(message: 'Posts synced');
    } else {
      return SyncResult.failure(error: 'HTTP ${response.statusCode}');
    }
  }
  
  // 他のメソッドも同様に実装
}
```

### エンドポイント設計

#### POST /api/sync/posts/upsert

```json
{
  "entries": [
    {
      "clientId": "uuid",
      "version": 1,
      "payload": {
        "id": "uuid",
        "imagePath": "path/to/image.jpg",
        "rawText": "テキスト内容",
        "normalizedText": "正規化テキスト",
        "createdAt": "2024-01-01T00:00:00Z",
        "updatedAt": "2024-01-01T00:00:00Z",
        "likeCount": 0,
        "learnedCount": 0,
        "learned": false,
        "deleted": false
      },
      "operation": "create"
    }
  ]
}
```

#### レスポンス

```json
{
  "results": [
    {
      "clientId": "uuid",
      "syncId": "server-uuid",
      "version": 2,
      "serverUpdatedAt": "2024-01-01T00:00:00Z",
      "wasCreated": true
    }
  ],
  "serverTime": "2024-01-01T00:00:00Z"
}
```

#### GET /api/sync/posts?since=timestamp

```json
{
  "entities": [
    {
      "syncId": "server-uuid",
      "id": "client-uuid",
      "imagePath": "path/to/image.jpg",
      "rawText": "テキスト内容",
      "updatedAt": "2024-01-01T00:00:00Z",
      "version": 2,
      "deleted": false
    }
  ],
  "serverTime": "2024-01-01T00:00:00Z",
  "hasMore": false
}
```

### 実装手順

1. **HTTPクライアント追加**
   ```yaml
   dependencies:
     http: ^1.1.0
   ```

2. **HttpSyncApi実装**
   - エラーハンドリング
   - タイムアウト設定
   - リトライロジック

3. **設定追加**
   ```dart
   class SyncConfig {
     static const String baseUrl = 'https://api.snapjp.app';
     static const Duration timeout = Duration(seconds: 30);
     static const int maxRetries = 3;
   }
   ```

4. **テスト追加**
   - HTTPモックテスト
   - エラーケーステスト
   - タイムアウトテスト

### 検証項目

- [ ] HTTP通信の正常動作
- [ ] エラーハンドリング
- [ ] タイムアウト処理
- [ ] ネットワーク障害時の動作
- [ ] レスポンス時間の測定

## フェーズ3: 認証・セキュリティ

### 実装予定

#### 匿名アカウント

```dart
class AuthService {
  String? _deviceToken;
  
  Future<String> getDeviceToken() async {
    if (_deviceToken == null) {
      _deviceToken = await _generateDeviceToken();
      await _storeDeviceToken(_deviceToken!);
    }
    return _deviceToken!;
  }
  
  String _generateDeviceToken() {
    // UUID v4を生成
    return Uuid().v4();
  }
}
```

#### 端末紐付け

```dart
class DeviceBinding {
  final String deviceId;
  final String deviceName;
  final String platform;
  final DateTime createdAt;
  
  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'deviceName': deviceName,
    'platform': platform,
    'createdAt': createdAt.toIso8601String(),
  };
}
```

### セキュリティ要件

- TLS 1.3以上
- 証明書ピニング
- APIキーレート制限
- デバイストークンの暗号化保存

### 実装手順

1. **認証フロー実装**
   - デバイストークン生成
   - 初回登録フロー
   - トークン更新フロー

2. **セキュリティ強化**
   - 証明書ピニング
   - リクエスト署名
   - レート制限

3. **プライバシー対応**
   - データ最小化
   - 自動削除
   - ユーザー同意取得

## フェーズ4: 差分同期

### 実装予定

#### チェンジセット

```dart
class ChangeSet {
  final DateTime since;
  final List<EntityChange> changes;
  final String checksum;
  
  Map<String, dynamic> toJson() => {
    'since': since.toIso8601String(),
    'changes': changes.map((c) => c.toJson()).toList(),
    'checksum': checksum,
  };
}

class EntityChange {
  final String syncId;
  final String operation; // create, update, delete
  final Map<String, dynamic> data;
  final DateTime timestamp;
}
```

#### 効率化

- 圧縮（gzip）
- バッチ処理
- 差分計算
- キャッシュ戦略

### 実装手順

1. **チェンジセット実装**
   - 差分計算ロジック
   - チェックサム生成
   - 圧縮処理

2. **最適化**
   - バッチサイズ調整
   - 並列処理
   - キャッシュ戦略

3. **監視・メトリクス**
   - 同期時間測定
   - データ転送量
   - エラー率

## フェーズ5: 本格運用

### 運用準備

#### 監視

```dart
class SyncMetrics {
  static void recordSyncDuration(Duration duration) {
    // メトリクス収集
  }
  
  static void recordSyncError(String error) {
    // エラー追跡
  }
  
  static void recordDataTransfer(int bytes) {
    // 転送量監視
  }
}
```

#### アラート

- 同期失敗率 > 5%
- 平均同期時間 > 30秒
- データ転送量異常

#### ログ

```dart
class SyncLogger {
  static void logSyncStart() {
    // 同期開始ログ
  }
  
  static void logSyncComplete(SyncSummary summary) {
    // 同期完了ログ
  }
  
  static void logSyncError(String error) {
    // エラーログ
  }
}
```

### ロールアウト戦略

1. **ベータテスト**
   - 開発者向けフラグ
   - 限定ユーザーテスト
   - フィードバック収集

2. **段階的リリース**
   - 5% → 25% → 50% → 100%
   - 問題発生時の即座ロールバック

3. **本格運用**
   - 全ユーザー有効化
   - 24/7監視
   - 定期メンテナンス

## リスク管理

### 技術リスク

- **データ損失**: バックアップ・復旧手順
- **パフォーマンス**: 負荷テスト・監視
- **セキュリティ**: セキュリティ監査・テスト

### ビジネスリスク

- **ユーザー体験**: A/Bテスト・段階的リリース
- **コスト**: サーバーコスト監視
- **法規制**: プライバシー法準拠

### 対策

- ロールバック計画
- 緊急時連絡体制
- 定期レビュー・改善

## 成功指標

### 技術指標

- 同期成功率 > 99%
- 平均同期時間 < 10秒
- エラー率 < 1%

### ビジネス指標

- ユーザー満足度向上
- データ損失ゼロ
- サポート問い合わせ減少

### 運用指標

- サーバー稼働率 > 99.9%
- レスポンス時間 < 500ms
- セキュリティインシデントゼロ

## まとめ

段階的な導入により：

- ✅ **リスクを最小化**
- ✅ **品質を確保**
- ✅ **ユーザー体験を向上**
- ✅ **運用体制を整備**

各フェーズで十分な検証を行い、本格運用への移行を実現します。
