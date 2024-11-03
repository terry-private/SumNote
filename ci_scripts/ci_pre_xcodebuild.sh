#!/bin/bash
set -e

echo "Setting up test environment..."

# プロジェクトのルートディレクトリに移動
cd "$CI_PRIMARY_REPOSITORY_PATH"

# テストカバレッジを有効化
defaults write com.apple.dt.Xcode EnableCodeCoverage YES
defaults write com.apple.dt.XCTest EnableCodeCoverage YES

# ビルド設定の確認
echo "Checking build settings..."
xcodebuild -scheme "Production" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
  -showBuildSettings | grep -i "coverage"

echo "Test environment setup completed"
