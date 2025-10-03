#!/bin/bash
# ローカル開発用の品質チェックスクリプト
# CIの代わりにローカルで実行

echo "🔍 ローカル品質チェック開始..."

# 1. フォーマットチェック
echo "📝 フォーマットチェック..."
dart format --set-exit-if-changed .
if [ $? -ne 0 ]; then
    echo "❌ フォーマットエラー"
    exit 1
fi
echo "✅ フォーマットOK"

# 2. 静的解析
echo "🔍 静的解析..."
flutter analyze --no-fatal-infos
if [ $? -ne 0 ]; then
    echo "❌ 静的解析エラー"
    exit 1
fi
echo "✅ 静的解析OK"

# 3. テスト実行
echo "🧪 テスト実行..."
flutter test --no-pub --reporter expanded
if [ $? -ne 0 ]; then
    echo "❌ テストエラー"
    exit 1
fi
echo "✅ テストOK"

echo "🎉 すべての品質チェックが完了しました！"
