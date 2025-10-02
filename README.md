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

## 今後の実装予定

- [ ] 実際のSRS学習システム連携
- [ ] 抽出テキストの編集・保存機能
- [ ] 学習進捗の統計表示
- [ ] ユーザー認証とクラウド同期
- [ ] UI/UXの改善

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。
