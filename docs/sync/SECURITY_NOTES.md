# 同期機能セキュリティ設計

## 概要

Snap JP Learn Appの同期機能におけるセキュリティ要件と対策について説明します。

## 現在の実装（Mock）

### セキュリティ状況

- ✅ **外部接続なし**: モックサーバーはメモリ内のみ
- ✅ **データ漏洩リスクゼロ**: ネットワーク通信なし
- ✅ **プライバシー保護**: すべてローカル処理

### 制限事項

- 外部サーバーとの通信なし
- 認証機能なし
- 暗号化なし（不要）

## 将来の実装（HTTP）

### セキュリティ要件

#### 通信セキュリティ

- **TLS 1.3以上**: すべての通信を暗号化
- **証明書ピニング**: 中間者攻撃を防止
- **HSTS**: 強制HTTPS接続

```dart
class SecureHttpClient {
  static HttpClient createSecureClient() {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) {
      // 証明書ピニング実装
      return _validateCertificate(cert, host);
    };
    return client;
  }
  
  static bool _validateCertificate(X509Certificate cert, String host) {
    // 証明書の検証ロジック
    return true; // 実装例
  }
}
```

#### 認証・認可

- **デバイストークン**: 匿名アカウント用
- **JWT**: トークンベース認証
- **リフレッシュトークン**: セッション管理

```dart
class AuthManager {
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;
  
  Future<String> getValidToken() async {
    if (_isTokenExpired()) {
      await _refreshToken();
    }
    return _accessToken!;
  }
  
  bool _isTokenExpired() {
    return _tokenExpiry == null || 
           DateTime.now().isAfter(_tokenExpiry!);
  }
}
```

### データ保護

#### 暗号化

- **転送時暗号化**: TLS
- **保存時暗号化**: デバイストークンの暗号化保存
- **メモリ保護**: 機密データの即座削除

```dart
class SecureStorage {
  static const String _key = 'device_token';
  
  Future<void> storeDeviceToken(String token) async {
    final encrypted = await _encrypt(token);
    await _storage.write(key: _key, value: encrypted);
  }
  
  Future<String?> getDeviceToken() async {
    final encrypted = await _storage.read(key: _key);
    if (encrypted != null) {
      return await _decrypt(encrypted);
    }
    return null;
  }
  
  Future<String> _encrypt(String data) async {
    // AES暗号化実装
    return data; // 実装例
  }
}
```

#### データ最小化

- **必要最小限のデータのみ送信**
- **個人情報の除外**
- **自動削除機能**

```dart
class DataSanitizer {
  static Map<String, dynamic> sanitizePost(Post post) {
    return {
      'id': post.id,
      'rawText': post.rawText,
      'normalizedText': post.normalizedText,
      'createdAt': post.createdAt.toIso8601String(),
      'updatedAt': post.updatedAt.toIso8601String(),
      // 個人情報は除外
      // 'imagePath': post.imagePath, // 除外
    };
  }
}
```

### プライバシー保護

#### 匿名化

- **デバイスID**: UUID v4（ランダム）
- **ユーザー追跡なし**: 個人特定不可
- **ログ匿名化**: 個人情報除外

```dart
class PrivacyProtection {
  static String generateAnonymousDeviceId() {
    // UUID v4でランダムなデバイスIDを生成
    return Uuid().v4();
  }
  
  static Map<String, dynamic> anonymizeLog(Map<String, dynamic> log) {
    final anonymized = Map<String, dynamic>.from(log);
    // 個人情報フィールドを削除
    anonymized.remove('userId');
    anonymized.remove('email');
    anonymized.remove('deviceName');
    return anonymized;
  }
}
```

#### 同意管理

- **明示的同意**: 同期機能の有効化
- **オプトアウト**: いつでも無効化可能
- **透明性**: データ使用目的の明示

```dart
class ConsentManager {
  static const String _syncConsentKey = 'sync_consent';
  
  Future<bool> hasSyncConsent() async {
    return await _storage.read(key: _syncConsentKey) == 'true';
  }
  
  Future<void> setSyncConsent(bool consent) async {
    await _storage.write(
      key: _syncConsentKey, 
      value: consent.toString(),
    );
  }
  
  Future<void> revokeSyncConsent() async {
    await setSyncConsent(false);
    // 既存の同期データを削除
    await _clearSyncData();
  }
}
```

## サーバー側セキュリティ

### API設計

#### レート制限

```dart
class RateLimiter {
  static const Map<String, RateLimit> limits = {
    'sync': RateLimit(requests: 100, window: Duration(minutes: 1)),
    'pull': RateLimit(requests: 50, window: Duration(minutes: 1)),
    'push': RateLimit(requests: 200, window: Duration(minutes: 1)),
  };
  
  static bool isAllowed(String endpoint, String deviceId) {
    // レート制限チェック
    return true; // 実装例
  }
}
```

#### 入力検証

```dart
class InputValidator {
  static ValidationResult validateSyncRequest(Map<String, dynamic> data) {
    final errors = <String>[];
    
    // 必須フィールドチェック
    if (!data.containsKey('entries')) {
      errors.add('entries field is required');
    }
    
    // データ型チェック
    if (data['entries'] is! List) {
      errors.add('entries must be a list');
    }
    
    // サイズ制限チェック
    final entries = data['entries'] as List;
    if (entries.length > 100) {
      errors.add('too many entries (max 100)');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}
```

### データベースセキュリティ

#### 暗号化

- **保存時暗号化**: データベースレベル
- **バックアップ暗号化**: 自動バックアップ
- **アクセス制御**: 最小権限の原則

#### 監査ログ

```dart
class AuditLogger {
  static void logSyncEvent({
    required String deviceId,
    required String operation,
    required String entityType,
    required int entityCount,
    required bool success,
  }) {
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'deviceId': _hashDeviceId(deviceId), // ハッシュ化
      'operation': operation,
      'entityType': entityType,
      'entityCount': entityCount,
      'success': success,
    };
    
    // ログ出力
    _writeAuditLog(logEntry);
  }
  
  static String _hashDeviceId(String deviceId) {
    // SHA-256ハッシュ化
    return sha256.convert(utf8.encode(deviceId)).toString();
  }
}
```

## 脅威モデル

### 脅威の分類

#### 通信の脅威

- **中間者攻撃**: TLS + 証明書ピニングで対策
- **リプレイ攻撃**: タイムスタンプ + ナンスで対策
- **DoS攻撃**: レート制限で対策

#### データの脅威

- **データ漏洩**: 暗号化 + アクセス制御で対策
- **データ改ざん**: チェックサム + 署名で対策
- **データ損失**: バックアップ + 冗長化で対策

#### 認証の脅威

- **トークン盗難**: 短期間有効期限で対策
- **ブルートフォース**: レート制限で対策
- **セッションハイジャック**: リフレッシュトークンで対策

### 対策マトリックス

| 脅威 | 対策 | 実装 |
|------|------|------|
| 中間者攻撃 | TLS + 証明書ピニング | HttpClient設定 |
| リプレイ攻撃 | タイムスタンプ + ナンス | リクエスト署名 |
| DoS攻撃 | レート制限 | API Gateway |
| データ漏洩 | 暗号化 + アクセス制御 | AES + RBAC |
| データ改ざん | チェックサム + 署名 | HMAC |
| トークン盗難 | 短期間有効期限 | JWT Expiry |

## コンプライアンス

### プライバシー法対応

#### GDPR（EU一般データ保護規則）

- **データ主体の権利**: アクセス・削除・修正権
- **データポータビリティ**: データエクスポート機能
- **同意管理**: 明示的同意の取得・撤回

#### CCPA（カリフォルニア消費者プライバシー法）

- **透明性**: データ収集目的の明示
- **オプトアウト**: データ販売の停止
- **アクセス権**: データアクセス・削除権

#### 日本の個人情報保護法

- **目的外利用の禁止**: 明示された目的のみ
- **適切な取得**: 必要最小限のデータ収集
- **安全管理措置**: 技術的・物理的・人的措置

### 実装例

```dart
class ComplianceManager {
  // データ削除要求への対応
  static Future<void> handleDataDeletionRequest(String deviceId) async {
    // 1. デバイスIDに関連するすべてのデータを削除
    await _deleteUserData(deviceId);
    
    // 2. ログから個人情報を匿名化
    await _anonymizeLogs(deviceId);
    
    // 3. バックアップからも削除
    await _deleteFromBackups(deviceId);
    
    // 4. 削除完了を記録
    await _logDeletionCompletion(deviceId);
  }
  
  // データエクスポート要求への対応
  static Future<Map<String, dynamic>> exportUserData(String deviceId) async {
    final userData = await _getUserData(deviceId);
    return {
      'deviceId': deviceId,
      'posts': userData.posts,
      'srsCards': userData.srsCards,
      'reviewLogs': userData.reviewLogs,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }
}
```

## セキュリティ監査

### 定期監査項目

#### コード監査

- [ ] 入力検証の実装
- [ ] エラーハンドリング
- [ ] ログ出力（機密情報除外）
- [ ] 暗号化の実装

#### 設定監査

- [ ] TLS設定
- [ ] 証明書設定
- [ ] アクセス制御設定
- [ ] ログ設定

#### 運用監査

- [ ] セキュリティログの監視
- [ ] 異常アクセスの検知
- [ ] インシデント対応手順
- [ ] バックアップ・復旧手順

### セキュリティテスト

#### 自動テスト

```dart
void main() {
  group('Security Tests', () {
    test('should encrypt sensitive data', () async {
      final storage = SecureStorage();
      const sensitiveData = 'device_token_123';
      
      await storage.storeDeviceToken(sensitiveData);
      final retrieved = await storage.getDeviceToken();
      
      expect(retrieved, sensitiveData);
      // 実際の暗号化テストは実装に依存
    });
    
    test('should validate input data', () {
      final validator = InputValidator();
      final invalidData = {'invalid': 'data'};
      
      final result = validator.validateSyncRequest(invalidData);
      
      expect(result.isValid, false);
      expect(result.errors, isNotEmpty);
    });
    
    test('should sanitize personal information', () {
      final post = Post(/* ... */);
      final sanitized = DataSanitizer.sanitizePost(post);
      
      expect(sanitized.containsKey('imagePath'), false);
      expect(sanitized.containsKey('id'), true);
    });
  });
}
```

#### ペネトレーションテスト

- 脆弱性スキャン
- セキュリティテストツール
- 手動テスト
- 外部セキュリティ監査

## インシデント対応

### 対応手順

1. **検知**: 自動監視・アラート
2. **分析**: 影響範囲・原因の特定
3. **対応**: 緊急措置・修復
4. **復旧**: サービス復旧・データ復元
5. **報告**: 関係者への報告・記録

### 連絡体制

- **セキュリティチーム**: 24/7対応
- **開発チーム**: 技術的対応
- **法務チーム**: 法的対応
- **広報チーム**: 外部対応

## まとめ

### セキュリティ原則

- **最小権限**: 必要最小限のアクセス権
- **多層防御**: 複数の対策の組み合わせ
- **継続的改善**: 定期的な見直し・更新
- **透明性**: ユーザーへの適切な情報提供

### 実装優先度

1. **高**: TLS暗号化・入力検証
2. **中**: 認証・アクセス制御
3. **低**: 監査ログ・コンプライアンス

段階的な実装により、セキュリティを確保しながら機能を提供します。
