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

# バージョン情報の取得（スキームを指定）
APP_VERSION=$(sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ./Production/Production.xcodeproj/project.pbxproj)

echo "Using app version: $APP_VERSION"

# スキーム名の取得（簡略化）
SCHEME_NAME=${CI_XCODE_SCHEME:-$(xcodebuild -list | awk '/Schemes:/{getline; print $1}')}
echo "Using scheme: $SCHEME_NAME"

# シミュレーター設定
SIMULATOR_ID=$(xcrun simctl list devices | grep "$COVERAGE_BUILD_DEVICE_NAME" | grep -oE '[0-9A-F-]{36}' | head -n 1)

[ -z "$SIMULATOR_ID" ] && {
    echo "Error: $COVERAGE_BUILD_DEVICE_NAME <Simulator ID: $SIMULATOR_ID> not found."
    exit 1
}

echo "Boot $COVERAGE_BUILD_DEVICE_NAME <Simulator ID: $SIMULATOR_ID>"
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
COVERAGE_FILE="$TEMP_DIR/coverage.xml"

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

# sonar-project.properties生成
cat > "$TEMP_DIR/sonar-project.properties" << EOF
sonar.projectKey=${SONAR_PROJECT_KEY}
sonar.organization=${SONAR_ORGANIZATION}
sonar.host.url=https://sonarcloud.io
sonar.sources=${CI_PRIMARY_REPOSITORY_PATH}
sonar.swift.coverage.reportPath=${COVERAGE_FILE}
sonar.coverageReportPaths=${COVERAGE_FILE}
sonar.exclusions=**/*.generated.swift,**/Pods/**/*,**/*.pb.swift,**/*Tests/**,**Package.swift
sonar.test.inclusions=**/*Tests/**
sonar.swift.file.suffixes=.swift
sonar.scm.provider=git
sonar.sourceEncoding=UTF-8
sonar.projectVersion=${APP_VERSION}
sonar.projectName=SumNote
sonar.verbose=true
EOF

# SonarCloudスキャン実行
export PATH="$PATH:/usr/local/bin"
command -v sonar-scanner >/dev/null 2>&1 || {
    echo "Error: sonar-scanner not found in PATH (PATH: $PATH)"
    exit 1
}

sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.working.directory="$TEMP_DIR/.scannerwork" \
  -Dproject.settings="$TEMP_DIR/sonar-project.properties" \
  -Dsonar.scm.disabled=true \
  -X

echo "Successfully uploaded coverage to SonarCloud"
