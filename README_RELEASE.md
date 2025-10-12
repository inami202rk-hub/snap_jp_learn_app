# Snap JP Learn App - Release v1.0.0

## 🚀 リリース概要

**Snap JP Learn App v1.0.0** は、AI-powered OCRを使用した日本語学習アプリです。
カメラで撮影した日本語テキストを自動認識し、SRS（間隔反復学習）システムで効率的に学習できます。

### 🎯 主要機能
- **AI-powered OCR**: Google ML Kitを使用した高精度な日本語テキスト認識
- **SRS学習システム**: 科学的根拠に基づく間隔反復学習
- **Pro機能**: 無制限カード作成、詳細統計、データバックアップ
- **多言語対応**: 英語・日本語のUI切り替え
- **オフライン対応**: インターネット接続なしでも学習可能

## 📱 プラットフォーム対応

- **Android**: API 23+ (Android 6.0+)
- **iOS**: iOS 17+
- **Flutter**: 3.19+
- **Dart**: 3.x

## 🔧 ビルド手順

### Android App Bundle (推奨)
```bash
flutter build appbundle --release
```
出力: `build/app/outputs/bundle/release/app-release.aab`

### Android APK
```bash
flutter build apk --release
```
出力: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA
```bash
flutter build ipa --release
```
出力: `build/ios/ipa/snap_jp_learn_app.ipa`

## 📋 ストア提出手順

### Google Play Store

1. **Google Play Console にアクセス**
   - https://play.google.com/console
   - アプリを選択または新規作成

2. **アプリ情報を入力**
   ```
   アプリ名: Snap JP Learn
   短い説明: Learn Japanese through your lens - AI-powered OCR for Japanese text learning
   完全な説明: [詳細説明文を入力]
   カテゴリ: 教育
   ```

3. **アプリバンドルをアップロード**
   - `app-release.aab` をアップロード
   - リリースノート: "Initial release with AI-powered OCR and SRS learning system"

4. **ストアリスティング**
   - スクリーンショット: 各画面のスクリーンショット
   - アプリアイコン: 高解像度版
   - フィーチャー画像: メイン機能の紹介

5. **コンテンツレーティング**
   - 年齢制限: 3歳以上
   - コンテンツ: 教育・学習

6. **課金設定**
   - 商品ID: `pro_monthly`, `pro_lifetime`
   - 価格設定: 地域別価格
   - サブスクリプション管理: 有効

### App Store Connect

1. **App Store Connect にアクセス**
   - https://appstoreconnect.apple.com
   - アプリを選択または新規作成

2. **アプリ情報を入力**
   ```
   アプリ名: Snap JP Learn
   サブタイトル: Learn Japanese with AI OCR
   キーワード: japanese,learning,ocr,education,language
   カテゴリ: 教育
   ```

3. **IPAをアップロード**
   - XcodeまたはTransporterを使用
   - `snap_jp_learn_app.ipa` をアップロード

4. **App Store情報**
   - 説明文: [詳細説明文を入力]
   - スクリーンショット: 各デバイスサイズ対応
   - アプリアイコン: 1024x1024px

5. **課金設定**
   - サブスクリプション: 月額プラン設定
   - ワンタイム購入: ライフタイムプラン設定

## 📊 リリース後モニタリング

### 主要KPI
- **ダウンロード数**: 日次・週次・月次
- **アクティブユーザー**: DAU/WAU/MAU
- **課金率**: 無料→有料変換率
- **リテンション**: 1日、7日、30日後
- **クラッシュ率**: < 1%

### 分析ツール
- **Firebase Analytics**: ユーザー行動分析
- **Firebase Crashlytics**: クラッシュ監視
- **Google Play Console**: Android分析
- **App Store Connect**: iOS分析

## 🔍 トラブルシューティング

### よくある問題

#### ビルドエラー
```bash
# 依存関係のクリーンアップ
flutter clean
flutter pub get

# キャッシュのクリア
flutter pub cache clean
```

#### OCR認識精度の問題
- カメラの焦点を確認
- 十分な光量を確保
- テキストが水平になるよう調整

#### 課金機能の問題
- テスト環境での動作確認
- サンドボックスアカウントでの検証
- 商品IDの設定確認

## 📞 サポート

### ユーザーサポート
- **FAQ**: アプリ内FAQページ
- **フィードバック**: アプリ内フィードバック機能
- **レビュー**: ストアレビューでの対応

### 開発者連絡先
- **GitHub Issues**: 技術的な問題
- **Email**: [開発者連絡先]

## 📄 ライセンス

このプロジェクトは [ライセンス名] の下でライセンスされています。
詳細は [LICENSE](LICENSE) ファイルを参照してください。

## 🙏 謝辞

- **Google ML Kit**: OCR機能の提供
- **Flutter Team**: フレームワークの提供
- **Open Source Community**: 使用しているオープンソースライブラリ

---

**リリース日**: 2024年予定  
**バージョン**: 1.0.0 (100)  
**最終更新**: 2024-10-12
