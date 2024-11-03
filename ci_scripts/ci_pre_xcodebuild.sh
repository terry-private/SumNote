#!/bin/bash
set -e

echo "Setting up test environment..."

# プロジェクトのルートディレクトリに移動
cd "$CI_PRIMARY_REPOSITORY_PATH"

# テストカバレッジを有効化
defaults write com.apple.dt.Xcode EnableCodeCoverage YES
defaults write com.apple.dt.XCTest EnableCodeCoverage YES

# スキーム名の取得
SCHEME_NAME=${CI_XCODE_SCHEME:-$(xcodebuild -list | grep -A 1 "Schemes:" | tail -n 1 | xargs)}
echo "Using scheme: $SCHEME_NAME"

# ビルド設定の確認
echo "Checking build settings..."
xcodebuild -scheme "$SCHEME_NAME" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
  -showBuildSettings | grep -i "coverage"

echo "Test environment setup completed"
