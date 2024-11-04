#!/bin/bash
set -e

# デバッグ出力を有効化
set -x

# 必要なツールのインストール
echo "Installing required tools..."
brew install sonar-scanner jq || {
    echo "Failed to install sonar-scanner or jq"
    exit 1
}

# CI_XCODEBUILD_ACTIONが"test-without-building"の場合は早期終了
if [ "$CI_XCODEBUILD_ACTION" = "test-without-building" ]; then
    echo "CI_XCODEBUILD_ACTION is set to 'test-without-building'. Exiting without building."
    exit 0
fi

echo "Setting up test environment..."

# プロジェクトのルートディレクトリに移動
cd "$CI_PRIMARY_REPOSITORY_PATH"

# スキーム名の取得
SCHEME_NAME=${CI_XCODE_SCHEME:-$(xcodebuild -list | grep -A 1 "Schemes:" | tail -n 1 | xargs)}
echo "Using scheme: $SCHEME_NAME"

DEVICE_NAME="iPhone 16 Plus"

# シミュレーターの一覧を取得
SIMULATOR_ID=$(xcrun simctl list devices | grep 'iPhone 16 Plus' | grep -oE '([0-9A-F-]{36})' | head -n 1)
echo "SIMULATOR_ID: $SIMULATOR_ID"

if [ -z "$SIMULATOR_ID" ]; then
    echo "Error: Simulator ID for $DEVICE_NAME not found."
    exit 1
fi

xcrun simctl boot $SIMULATOR_ID

# xcresultファイルのパスを指定
RESULT_BUNDLE_PATH=$CI_DERIVED_DATA_PATH/Logs/Test/ResultBundle.xcresult
echo "RESULT_BUNDLE_PATH: $RESULT_BUNDLE_PATH"

# ビルドとテストの実行（カバレッジを有効に）
xcodebuild \
  -scheme "$SCHEME_NAME" \
  -destination "id=$SIMULATOR_ID" \
  -derivedDataPath $CI_DERIVED_DATA_PATH \
  -enableCodeCoverage YES \
  -resultBundlePath $RESULT_BUNDLE_PATH \
  clean test

TEMP_DIR="$CI_DERIVED_DATA_PATH/sonar_temp"
mkdir -p "$TEMP_DIR"
COVERAGE_FILE="$TEMP_DIR/coverage.xml"

echo "Converting coverage data to SonarCloud format..."
echo '<?xml version="1.0" ?>' > "$COVERAGE_FILE"
echo '<coverage version="1">' >> "$COVERAGE_FILE"

# xcresultからカバレッジデータを抽出
echo "Extracting coverage data from xcresult..."
xcrun xccov view --report --json "$RESULT_BUNDLE_PATH" > "$TEMP_DIR/coverage.json"

# カバレッジデータの処理
jq -r '.targets[] | select(.name != null) | .files[] | select(.path != null) | .path as $path | .functions[] | .coveredLines as $covered | .executableLines as $total | "\($path)|\($covered)|\($total)"' "$TEMP_DIR/coverage.json" | while IFS='|' read -r file_path covered_lines total_lines; do
    if [[ "$file_path" == *".swift" ]] && [[ ! "$file_path" == *"Test"* ]]; then
        echo "  <file path=\"$file_path\">" >> "$COVERAGE_FILE"
        
        # 行ごとのカバレッジ情報を生成
        if [ "$total_lines" -gt 0 ]; then
            for line in $(seq 1 $total_lines); do
                covered="false"
                if [ "$line" -le "$covered_lines" ]; then
                    covered="true"
                fi
                echo "    <lineToCover lineNumber=\"$line\" covered=\"$covered\"/>" >> "$COVERAGE_FILE"
            done
        fi
        
        echo "  </file>" >> "$COVERAGE_FILE"
    fi
done

echo '</coverage>' >> "$COVERAGE_FILE"

echo "Coverage report generated at: $COVERAGE_FILE"
echo "Coverage report contents (first 10 lines):"
head -n 10 "$COVERAGE_FILE"

# sonar-project.propertiesの作成
echo "Creating sonar-project.properties..."
cat > "$TEMP_DIR/sonar-project.properties" << EOF
sonar.projectKey=${SONAR_PROJECT_KEY}
sonar.organization=${SONAR_ORGANIZATION}
sonar.host.url=https://sonarcloud.io

sonar.sources=${CI_PRIMARY_REPOSITORY_PATH}
sonar.swift.coverage.reportPath=${COVERAGE_FILE}
sonar.coverageReportPaths=${COVERAGE_FILE}
sonar.exclusions=**/*.generated.swift,**/Pods/**/*,**/*.pb.swift,**/*Tests/**
sonar.test.inclusions=**/*Tests/**
sonar.swift.file.suffixes=.swift
sonar.scm.provider=git
sonar.sourceEncoding=UTF-8
sonar.projectVersion=${CI_BUILD_NUMBER:-1.0.0}
sonar.projectName=Production

# デバッグ設定
sonar.verbose=true
EOF

# PATH設定の確認と更新
export PATH="$PATH:/usr/local/bin"
which sonar-scanner || {
    echo "Error: sonar-scanner not found in PATH"
    echo "Current PATH: $PATH"
    exit 1
}

# SonarCloudスキャンの実行
echo "Running sonar-scanner..."
cd "$CI_PRIMARY_REPOSITORY_PATH"
sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.working.directory="$TEMP_DIR/.scannerwork" \
  -Dproject.settings="$TEMP_DIR/sonar-project.properties" \
  -Dsonar.scm.disabled=true \
  -X

echo "Completed SonarCloud upload"
