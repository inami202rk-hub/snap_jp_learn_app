# ローカル強制ゲートスクリプト (PowerShell版)
# PRごとの必須チェックリスト実行

Write-Host "🔍 ローカル強制ゲート実行開始..." -ForegroundColor Cyan
Write-Host "最低限の安全性チェック: 依存取得 → フォーマット → 解析 → テスト" -ForegroundColor Yellow

# 1. 依存取得
Write-Host "📦 依存取得..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 依存取得エラー" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 依存取得OK" -ForegroundColor Green

# 2. フォーマットチェック
Write-Host "📝 フォーマットチェック..." -ForegroundColor Yellow
dart format --set-exit-if-changed .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ フォーマットエラー - 差分があります" -ForegroundColor Red
    Write-Host "修正方法: dart format ." -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ フォーマットOK" -ForegroundColor Green

# 3. 静的解析
Write-Host "🔍 静的解析..." -ForegroundColor Yellow
flutter analyze --no-fatal-infos
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 静的解析エラー" -ForegroundColor Red
    exit 1
}
Write-Host "✅ 静的解析OK" -ForegroundColor Green

# 4. テスト実行
Write-Host "🧪 テスト実行..." -ForegroundColor Yellow
flutter test --no-pub --reporter expanded
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ テストエラー" -ForegroundColor Red
    Write-Host "注意: テスト失敗は保留にしないでください" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ テストOK" -ForegroundColor Green

Write-Host "🎉 ローカル強制ゲート完了！" -ForegroundColor Green
Write-Host "PR作成前にこのスクリプトを必ず実行してください" -ForegroundColor Cyan
