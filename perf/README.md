# パフォーマンス測定手順

このディレクトリには、Snap JP Learnアプリのパフォーマンス測定に関するドキュメントとデータが含まれています。

## 📊 測定対象指標

### 1. 起動時間（Cold Start Time）
- **目標**: < 1.5秒（Androidエミュレーター/実機）
- **測定方法**: DevTools Timelineを使用
- **測定手順**:
  1. アプリを完全に終了
  2. DevToolsでTimeline記録を開始
  3. アプリを起動
  4. ホーム画面が表示されるまで記録
  5. 記録を停止し、フレーム時間を確認

### 2. スクロール滑らかさ（Scroll Performance）
- **目標**: 60fps維持、Jank < 1%
- **測定方法**: Flutter Inspector + DevTools
- **測定手順**:
  1. 投稿一覧ページで100件以上の投稿を表示
  2. スクロールパフォーマンスを記録
  3. フレームドロップ率を確認
  4. ListView.builderのcacheExtent効果を測定

### 3. OCR処理時間（OCR Processing Time）
- **目標**: UIブロック 0ms（非同期化）
- **測定方法**: LogServiceパフォーマンスマーカー
- **測定手順**:
  1. 10枚の画像でOCRを実行
  2. 各処理時間を記録
  3. 平均・最小・最大時間を計算
  4. UIブロック時間を確認

### 4. 画像サムネイル表示時間（Thumbnail Display Time）
- **目標**: キャッシュ命中時 < 120ms
- **測定方法**: カスタムベンチマーク
- **測定手順**:
  1. 初回サムネイル生成時間を測定
  2. キャッシュ命中時の読み込み時間を測定
  3. 100枚の画像で統計を取得

### 5. メモリ使用量（Memory Usage）
- **目標**: 安定したメモリ使用量
- **測定方法**: DevTools Memoryタブ
- **測定手順**:
  1. アプリ起動直後のメモリ使用量
  2. 100件投稿表示後のメモリ使用量
  3. 長時間使用後のメモリリーク確認

## 🛠️ 測定ツール

### DevTools
```bash
# DevToolsを起動
flutter pub global activate devtools
flutter pub global run devtools

# アプリを起動してDevToolsに接続
flutter run --profile
```

### パフォーマンスマーカー
```dart
// 処理開始
LogService().markStart('ocr_processing', metadata: {'image_count': 10});

// 処理終了
LogService().markEnd('ocr_processing', additionalData: {'success': true});

// 統計取得
final stats = LogService().getPerformanceStatistics();
```

### ベンチマークテスト
```bash
# ベンチマークテストを実行（ローカル環境）
flutter test test/benchmark_test.dart --reporter=json > perf/benchmark_results.json
```

## 📈 測定データ

### ベースライン値（最適化前）
- **起動時間**: 2.3秒
- **スクロールFPS**: 45-55fps
- **OCR平均時間**: 1.2秒
- **サムネイル表示時間**: 280ms（初回）、150ms（キャッシュ）
- **メモリ使用量**: 85MB

### 目標値（最適化後）
- **起動時間**: < 1.5秒
- **スクロールFPS**: 58-60fps
- **OCR平均時間**: 1.0秒（UIブロック0ms）
- **サムネイル表示時間**: 200ms（初回）、< 120ms（キャッシュ）
- **メモリ使用量**: < 80MB

## 📋 測定チェックリスト

### 起動時間測定
- [ ] アプリを完全終了
- [ ] DevTools Timeline記録開始
- [ ] アプリ起動
- [ ] ホーム画面表示まで記録
- [ ] フレーム時間確認
- [ ] 結果をperf/baseline.jsonに記録

### スクロール性能測定
- [ ] 100件以上の投稿を準備
- [ ] スクロールパフォーマンス記録開始
- [ ] 上下スクロールを10回実行
- [ ] フレームドロップ率確認
- [ ] Jank率計算
- [ ] 結果をperf/baseline.jsonに記録

### OCR性能測定
- [ ] 10枚のテスト画像を準備
- [ ] 各画像でOCR実行
- [ ] 処理時間をログに記録
- [ ] 平均・最小・最大時間を計算
- [ ] UIブロック時間を確認
- [ ] 結果をperf/baseline.jsonに記録

### サムネイル性能測定
- [ ] 100枚のテスト画像を準備
- [ ] 初回サムネイル生成時間を測定
- [ ] キャッシュ命中時の読み込み時間を測定
- [ ] ヒット率を計算
- [ ] 結果をperf/baseline.jsonに記録

## 🔄 CI/CD統合

### パフォーマンス測定の自動化
```yaml
# .github/workflows/performance.yml
name: Performance Tests
on:
  pull_request:
    paths:
      - 'lib/**'
      - 'perf/**'

jobs:
  performance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test test/benchmark_test.dart --reporter=json > perf/after.json
      - uses: actions/upload-artifact@v3
        with:
          name: performance-results
          path: perf/*.json
```

### パフォーマンスレポート
- CIで生成されたperf/after.jsonをアーティファクトとして保存
- 数値比較は表示のみ（CI失敗の原因としない）
- パフォーマンス劣化の警告はSlack通知

## 📊 データ形式

### perf/baseline.json
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "metrics": {
    "cold_start_time_ms": 2300,
    "scroll_fps": 52,
    "scroll_jank_percent": 2.1,
    "ocr_avg_time_ms": 1200,
    "ocr_ui_block_ms": 0,
    "thumbnail_first_load_ms": 280,
    "thumbnail_cache_hit_ms": 150,
    "thumbnail_hit_rate_percent": 85,
    "memory_usage_mb": 85
  }
}
```

### perf/after.json
```json
{
  "timestamp": "2024-01-15T11:00:00Z",
  "version": "1.0.0-optimized",
  "metrics": {
    "cold_start_time_ms": 1450,
    "scroll_fps": 59,
    "scroll_jank_percent": 0.8,
    "ocr_avg_time_ms": 980,
    "ocr_ui_block_ms": 0,
    "thumbnail_first_load_ms": 195,
    "thumbnail_cache_hit_ms": 95,
    "thumbnail_hit_rate_percent": 92,
    "memory_usage_mb": 78
  }
}
```

## 🎯 最適化のベストプラクティス

### 起動時間最適化
1. **遅延初期化**: Repository/Serviceの初期化を遅延
2. **並列初期化**: 複数の初期化タスクを並列実行
3. **フォント最適化**: 必要最小限のフォントのみ読み込み

### スクロール性能最適化
1. **ListView.builder**: cacheExtentの調整
2. **const ウィジェット**: 再ビルドの削減
3. **画像最適化**: サムネイル優先表示

### OCR性能最適化
1. **Isolate分離**: 重い処理をバックグラウンドで実行
2. **キャンセル機能**: 長時間処理のキャンセル対応
3. **プログレス表示**: ユーザビリティの向上

### メモリ最適化
1. **Hiveコンパクション**: 定期的なDB最適化
2. **孤児ファイル掃除**: 不要ファイルの自動削除
3. **画像キャッシュ**: 適切なキャッシュサイズ管理

## 📞 トラブルシューティング

### よくある問題
1. **DevTools接続エラー**: `flutter run --profile`で実行
2. **メモリ不足**: エミュレーターのメモリ設定を確認
3. **測定値のばらつき**: 複数回測定して平均値を取得

### サポート
- パフォーマンス測定に関する質問: GitHub Issues
- 最適化の提案: Pull Request
- 緊急のパフォーマンス問題: Slack #performance

