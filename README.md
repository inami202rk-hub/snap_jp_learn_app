# Snap JP Learn App

スナップ日記と日本語学習を組み合わせたFlutterアプリです。写真を撮影してOCR（光学文字認識）でテキストを抽出し、日本語学習に活用できます。

## 機能概要

- **写真撮影とOCR**: カメラで撮影した画像からML Kitを使用してテキストを抽出
- **ギャラリー選択**: 既存の画像からもテキスト抽出が可能
- **SRS学習システム**: 間隔反復学習（Spaced Repetition System）でのプレビュー機能
- **設定管理**: SharedPreferencesを使用した永続化設定
- **5タブナビゲーション**: Home / Feed / Learn / Stats / Settings

## 技術スタック

- **Flutter**: 3.19以上
- **Dart**: 3.x（null-safety対応）
- **ML Kit**: google_mlkit_text_recognition（日本語対応）
- **カメラ**: camera + image_picker
- **権限管理**: permission_handler
- **状態管理**: Provider
- **永続化**: SharedPreferences

## セットアップ

### 0. 必要な環境

**初回セットアップは Android SDK 36 / NDK 27.0.12077973 が必要です**

- Android Studio で Android SDK 36 をインストール
- Android NDK 27.0.12077973 をインストール
- Flutter 3.19以上
- Dart 3.x（null-safety対応）

### 1. 依存関係のインストール

```bash
flutter pub get
```

### 2. カメラ権限の設定

#### Android
- `android/app/src/main/AndroidManifest.xml`に以下の権限が設定済み：
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

#### iOS
- `ios/Runner/Info.plist`に以下の権限説明が設定済み：
```xml
<key>NSCameraUsageDescription</key>
<string>写真を撮影して日本語学習に使用します</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>写真を選択して日本語学習に使用します</string>
```

### 3. 実行

```bash
flutter run
```

## 開発環境でのカメラ機能

### Android エミュレータ
1. AVD Managerでエミュレータを作成時に「Advanced Settings」→「Camera」を設定
2. Front Camera / Back Camera を「Webcam0」または「Emulated」に設定
3. エミュレータ起動後、Extended Controls（...ボタン）→ Camera で仮想カメラを設定可能

### iOS Simulator
1. iOS Simulatorではカメラハードウェアをエミュレートできません
2. 代替手段：
   - Device → Photos → Add Photos でテスト画像を追加
   - ギャラリー選択機能でテスト可能
   - 実機でのテストを推奨

### ギャラリー機能の使用方法
1. **ホーム画面**の「ギャラリー」ボタンをタップ
2. 端末のフォトライブラリから画像を選択
3. 自動的にOCR処理が開始され、結果がダイアログで表示
4. **対応形式**: JPEG, PNG, GIF, WebP
5. **ファイルサイズ制限**: 最大10MB

### 実機での動作確認
- **Android**: USB デバッグを有効にして実機接続
- **iOS**: Xcode経由で実機にデプロイ

## 回避運用プラン（最低限の安全性を保つ）

**現在の状況**: CIのDart SDK不一致問題により開発が停滞
**目標**: 最低限の安全性を保ちながら開発を再開

### 🚨 現在の回避策

**1. SDK条件を一時的に広げる**
- `pubspec.yaml`: `sdk: ">=3.3.0 <4.0.0"` (CIのDart 3.3.0を許容)
- 依存解決の失敗を回避

**2. CIを最低限の安全性チェックに簡素化**
- **フォーマット + 解析のみ**を必須化
- **テストは一時的に任意**（ローカルで実行）
- 文法崩れ・未フォーマットの事故は防止

**3. ローカル強制ゲート**
```powershell
# PR作成前の必須チェック
.\check-local.ps1
```

### 📋 PRごとのチェックリスト

- [ ] 依存取得済み (`flutter pub get`)
- [ ] フォーマット差分なし (`dart format --set-exit-if-changed .`)
- [ ] 解析エラーなし (`flutter analyze --no-fatal-infos`)
- [ ] ローカルテスト緑 (`flutter test`)
- [ ] CIのフォーマット+解析が緑

### 🔄 復旧計画（落ち着いたら戻す）

**課題**: CIのDart/Flutterバージョン統一
**受け入れ基準**:
- CIログに"Flutter 3.35.5 / Dart 3.8.x"が表示
- `pubspec.yaml`のSDK条件を本来の3.8系に戻してもCIが緑
- ブランチ保護でテストを再び必須化

**手段**:
- ランナーのプリインFlutter/Dartを確実に無効化
- Dockerでバージョン固定
- FVMでローカル/CIのバージョン統一

## アーキテクチャ

### OCRサービス
```
OcrService (interface)
├── OcrServiceMlkit (ML Kit実装)
└── OcrServiceMock (テスト用モック)
```

### ディレクトリ構造
```
lib/
├── app.dart                           # メインアプリ
├── main.dart                          # エントリーポイント
├── pages/                             # 画面
│   ├── home_page.dart                 # ホーム画面（OCR機能）
│   ├── feed_page.dart
│   ├── learn_page.dart
│   ├── stats_page.dart
│   └── settings_page.dart
├── services/                          # サービス層
│   ├── ocr_service.dart               # OCRインターフェース
│   ├── ocr_service_mlkit.dart         # ML Kit実装
│   ├── ocr_service_mock.dart          # モック実装
│   └── camera_permission_service.dart # カメラ権限管理
├── features/settings/                 # Settings機能
│   ├── data/settings_repository.dart
│   └── services/settings_service.dart
└── widgets/                           # 共通ウィジェット
    ├── srs_preview_card.dart
    └── help_info_icon.dart
```

## テスト

### 単体テスト
```bash
flutter test test/services/
```

### ウィジェットテスト
```bash
flutter test test/widget_test.dart
```

### 静的解析
```bash
flutter analyze
```

## トラブルシューティング

### カメラ権限エラー
- Android: 設定 → アプリ → 権限 → カメラ を確認
- iOS: 設定 → プライバシーとセキュリティ → カメラ を確認

### ML Kit エラー
- インターネット接続を確認（初回ダウンロード時）
- デバイスの空き容量を確認
- アプリの再起動を試行

### ビルドエラー
```bash
flutter clean
flutter pub get
flutter run
```

## OCRテキスト整形機能

### 整形ポリシー（v1）

OCRで取得したテキストを日本語向けルールベースで整形し、読みやすく・後段のSRS抽出で扱いやすい形に正規化します。

#### 適用ルール（順序固定）

1. **Unicode正規化（NFKC）**: 互換分解→結合の順序で正規化
2. **不可視・制御文字除去**: Zero Width Space、BOM、異常タブ連打等を除去
3. **全角・半角統一**: 英数字・記号を半角化、日本語はそのまま保持
4. **句読点統一**: 日本語行の `, .` を `、 。` に統一
5. **スペース整形**: 行頭・行末空白削除、連続スペース圧縮、和欧境界スペース挿入
6. **改行整形**: 3連以上の改行を2つまでに圧縮
7. **ダッシュ・中黒正規化**: 日本語語中は `ー`、英語/数式は `-` に統一
8. **引用符統一**: 日本語行は `「 」`、英語行は `"` を維持
9. **末尾句読点正規化**: 連続する句読点を1つに統一

#### 安全側の原則

- **誤置換を避ける**: `一` と `ー`、`O` と `0` 等の誤補正は行わない
- **不確実な修正はしない**: 将来のAIリライト段階に委譲
- **典型的パターンを保護**: `iPhone13`、`2025年` 等はスキップ

#### 使用例

```dart
// 基本的な使用
String normalized = TextNormalizer.normalizeOcrText(rawText);

// カスタムオプション
final options = TextNormalizeOptions(
  normalizeAsciiWidth: true,
  unifyJaPunct: false,
);
String custom = TextNormalizer.normalizeOcrText(rawText, options: options);

// 整形情報付き
TextNormalizeResult result = TextNormalizer.normalizeWithInfo(rawText);
print('Changes: ${result.changesCount}');
```

#### UI機能

- **Raw/Normalized切替**: OCR結果ダイアログで生テキストと整形テキストを切り替え表示
- **クリップボードコピー**: 整形されたテキストをワンタップでコピー
- **整形情報表示**: テキストが整形された場合の視覚的フィードバック

### 将来の拡張予定

- **AIリライト機能**: `TextRewriteService` による高度な文書整形
- **形態素解析**: 文境界判定によるより精密な整形
- **誤字訂正**: 辞書ベースの誤字検出・修正
- **カスタムルール**: ユーザー定義の整形ルール

## 開発運用

### プッシュ前のチェック

**PowerShell**:
```powershell
.\check.ps1
```

**Git Bash**:
```bash
./check.sh
```

### 手動チェック（逐次実行）

**PowerShell**:
```powershell
dart format .
flutter analyze
flutter test
git add -A
git commit -m "feat: description"
git push
```

**Git Bash**:
```bash
dart format . && flutter analyze && flutter test
git add -A
git commit -m "feat: description"
git push
```

### CI品質ゲート

- ✅ **フォーマット**: `dart format --set-exit-if-changed .`
- ✅ **解析**: `flutter analyze --no-fatal-infos`
- ✅ **テスト**: `flutter test --no-pub --reporter expanded`

### VS Code設定

`.vscode/settings.json`で保存時自動フォーマットが有効化されています。

### Gitフック設定（一度だけ）

```bash
git config core.hooksPath .githooks
```

これでコミット前に自動的にフォーマット・解析・テストが実行されます。

## ストア提出準備

### 📱 権限・プライバシー対応

#### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>OCRで文字抽出を行うためにカメラを使用します。</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>OCRの対象画像を選ぶために写真ライブラリへアクセスします。</string>
```

#### Android (AndroidManifest.xml)
```xml
<!-- OCRで文字抽出を行うためにカメラを使用します -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- OCRの対象画像を選ぶために写真ライブラリへアクセスします -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<!-- バックアップファイルの保存に使用します（ユーザーが明示的にエクスポートを選択した場合のみ） -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### 📄 法務ドキュメント

#### アプリ内表示
- **プライバシーポリシー**: `assets/legal/privacy-ja.md`
- **利用規約**: `assets/legal/terms-ja.md`
- **権限の使いみち**: 設定画面からアクセス可能

#### 審査用メモ
- **iOS審査用**: `store/ios_review_notes.md`
- **Google Play データセーフティ**: `store/play_data_safety.yml`

### 🔍 提出前チェック

開発ビルドでは設定画面に「提出前チェック」機能が表示されます：
- アプリ情報の確認
- 権限設定の確認
- 法務ドキュメントの確認
- ストア提出準備の確認

### 📋 ストア提出チェックリスト

#### 必須項目
- [ ] アプリアイコンが設定されている
- [ ] スクリーンショットが撮影されている
- [ ] アプリ説明文が作成されている
- [ ] キーワードが設定されている
- [ ] 年齢制限が適切に設定されている
- [ ] カテゴリが適切に選択されている
- [ ] 価格が設定されている（有料の場合）
- [ ] プライバシーポリシーURLが設定されている
- [ ] サポートURLが設定されている
- [ ] 開発者情報が設定されている

#### よくある質問への回答

**Q: アプリは何のデータを収集しますか？**
A: 個人情報や行動データは一切収集しません。撮影・選択した画像と学習データは端末内にのみ保存されます。

**Q: インターネット接続は必要ですか？**
A: 基本的には不要です。課金機能使用時のみ接続が必要です。

**Q: データは外部に送信されますか？**
A: 一切送信されません。すべてのデータは端末内にのみ保存されます。

**Q: 広告は表示されますか？**
A: 広告は一切表示されません。トラッキングも行いません。

## ストア提出フロー

### 提出前チェック

アプリ内の設定画面から「提出前チェック」を実行し、以下を確認：

- ✅ アプリアイコンが設定されている
- ✅ スプラッシュスクリーンが設定されている
- ✅ スクリーンショットが生成されている
- ✅ 説明文が作成されている
- ✅ キーワードが設定されている
- ✅ カテゴリが設定されている
- ✅ 英語説明文が作成されている
- ✅ プライバシーポリシー・利用規約が存在する
- ✅ 権限説明文が設定されている

### 提出手順

#### 1. テスト提出
1. **TestFlight (iOS)**:
   - App Store Connectでアプリを登録
   - TestFlightで内部テストを実施
   - フィードバックを収集・修正

2. **内部テスト (Android)**:
   - Google Play Consoleでアプリを登録
   - 内部テストトラックでテスト実施
   - フィードバックを収集・修正

#### 2. 本番提出
1. **App Store**:
   - アプリ情報を入力（英語説明文使用）
   - スクリーンショットをアップロード
   - 審査に提出

2. **Google Play**:
   - ストアリスティングを入力（英語説明文使用）
   - スクリーンショットをアップロード
   - 審査に提出

### バージョン管理

- 現在のバージョン: `1.0.0+1`
- 初回提出用として設定済み
- CIでバージョン番号を自動出力

### 説明文について

- **英語版**: 今回のPRで追加済み（ストア提出優先）
- **日本語版**: 次のPRで追加予定

## 今後の実装予定

- [ ] 日本語説明文の追加
- [ ] 多言語対応（中国語、韓国語等）
- [ ] 実際のSRS学習システム連携
- [ ] 抽出テキストの編集・保存機能
- [ ] 学習進捗の統計表示
- [ ] ユーザー認証とクラウド同期
- [ ] UI/UXの改善

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
