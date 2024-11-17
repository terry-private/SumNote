#!/bin/bash
set -e

# CI_XCODEBUILD_ACTIONのチェック
if [ "$CI_XCODEBUILD_ACTION" = "test-without-building" ]; then
    echo "CI_XCODEBUILD_ACTION is set to 'test-without-building'. Exiting without building."
    exit 0
fi

# 必要なツールのインストール
brew install sonar-scanner jq || {
    echo "Failed to install sonar-scanner or jq"
    exit 1
}

cd "$CI_PRIMARY_REPOSITORY_PATH"

# スキーム名の取得（簡略化）
SCHEME_NAME=${CI_XCODE_SCHEME:-$(xcodebuild -list | awk '/Schemes:/{getline; print $1}')}
echo "Using scheme: $SCHEME_NAME"

# シミュレーター設定
DEVICE_NAME="iPhone 16 Plus"
SIMULATOR_ID=$(xcrun simctl list devices | grep "$DEVICE_NAME" | grep -oE '[0-9A-F-]{36}' | head -n 1)

[ -z "$SIMULATOR_ID" ] && {
    echo "Error: Simulator ID for $DEVICE_NAME not found."
    exit 1
}

xcrun simctl boot $SIMULATOR_ID

# テスト実行
RESULT_BUNDLE_PATH=$CI_DERIVED_DATA_PATH/Logs/Test/ResultBundle.xcresult
xcodebuild \
  -scheme "$SCHEME_NAME" \
  -destination "id=$SIMULATOR_ID" \
  -derivedDataPath $CI_DERIVED_DATA_PATH \
  -enableCodeCoverage YES \
  -resultBundlePath $RESULT_BUNDLE_PATH \
  clean test

# SonarCloud用の一時ディレクトリとファイル設定
TEMP_DIR="$CI_DERIVED_DATA_PATH/sonar_temp"
mkdir -p "$TEMP_DIR"

export PROJECT_ROOT="$CI_PRIMARY_REPOSITORY_PATH"
export COVERAGE_FILE="$TEMP_DIR/coverage.xml"
export SONAR_PROJECT_VERSION="${CI_BUILD_NUMBER:-1.0.0}"

# カバレッジレポート生成
{
    echo '<?xml version="1.0" ?>'
    echo '<coverage version="1">'
    
    xcrun xccov view --report --json "$RESULT_BUNDLE_PATH" > "$TEMP_DIR/coverage.json"
    
    jq -r '.targets[] | select(.name != null) | .files[] | select(.path != null and (.path | endswith(".swift")) and (.path | contains("Test") | not)) | 
        .path as $path | .functions[] | 
        "\($path)|\(.coveredLines)|\(.executableLines)"' "$TEMP_DIR/coverage.json" | while IFS='|' read -r file_path covered_lines total_lines; do
        echo "  <file path=\"$file_path\">"
        for line in $(seq 1 $total_lines); do
            covered=$([[ $line -le $covered_lines ]] && echo "true" || echo "false")
            echo "    <lineToCover lineNumber=\"$line\" covered=\"$covered\"/>"
        done
        echo "  </file>"
    done
    
    echo '</coverage>'
} > "$COVERAGE_FILE"

# SonarCloudスキャン実行
export PATH="$PATH:/usr/local/bin"
command -v sonar-scanner >/dev/null 2>&1 || {
    echo "Error: sonar-scanner not found in PATH (PATH: $PATH)"
    exit 1
}

# バージョン情報の取得
VERSION=$(xcodebuild -showBuildSettings | grep MARKETING_VERSION | tr -d '[A-Z_= ]')
BUILD=$(xcodebuild -showBuildSettings | grep CURRENT_PROJECT_VERSION | tr -d '[A-Z_= ]')
COMMIT_HASH=$(git rev-parse --short HEAD)

sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.projectVersion="$COMMIT_HASH" \
  -Dsonar.analysis.appVersion="$VERSION" \
  -Dsonar.analysis.buildNumber="$BUILD" \
  -Dsonar.working.directory="$TEMP_DIR/.scannerwork" \
  -Dsonar.scm.disabled=true \
  -X

echo "Successfully uploaded coverage to SonarCloud"
