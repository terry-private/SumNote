#!/bin/bash
set -e

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

# ビルドとテストの実行
xcodebuild \
  -scheme "$SCHEME_NAME" \
  -destination "id=$SIMULATOR_ID" \
  -derivedDataPath $CI_DERIVED_DATA_PATH \
  -enableCodeCoverage YES \
  -resultBundlePath $RESULT_BUNDLE_PATH \
  clean build test

TEMP_DIR="$CI_DERIVED_DATA_PATH/sonar_temp"
mkdir -p "$TEMP_DIR"
COVERAGE_FILE="$TEMP_DIR/coverage.xml"

# カバレッジデータの抽出と変換
echo "Extracting coverage data..."

# まずJSONフォーマットでカバレッジデータを取得
COVERAGE_JSON="$TEMP_DIR/coverage.json"
xcrun xccov view --json "$RESULT_BUNDLE_PATH" > "$COVERAGE_JSON"

if [ ! -s "$COVERAGE_JSON" ]; then
    echo "Error: Failed to generate coverage JSON"
    exit 1
fi

# カバレッジデータをXML形式に変換
echo "Converting coverage data to SonarCloud format..."
echo '<?xml version="1.0" ?>' > "$COVERAGE_FILE"
echo '<coverage version="1">' >> "$COVERAGE_FILE"

# JSONからファイルごとのカバレッジ情報を抽出
jq -r '.targets[] | select(.name | contains("Test") | not) | .files[]' "$COVERAGE_JSON" | while read -r file_json; do
    file_path=$(echo "$file_json" | jq -r '.path')
    
    if [[ "$file_path" == *".swift" ]]; then
        echo "Processing file: $file_path"
        echo "  <file path=\"$file_path\">" >> "$COVERAGE_FILE"
        
        # ファイルの行カバレッジ情報を取得
        xcrun xccov view --file "$file_path" "$RESULT_BUNDLE_PATH" 2>/dev/null | \
        while IFS=: read -r line_coverage line_content; do
            line_number=$(echo "$line_content" | awk '{print NR}')
            if [[ $line_coverage =~ ^[0-9]+$ ]]; then
                covered="false"
                if [ "$line_coverage" -gt "0" ]; then
                    covered="true"
                fi
                echo "    <lineToCover lineNumber=\"$line_number\" covered=\"$covered\"/>" >> "$COVERAGE_FILE"
            fi
        done
        
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
sonar.projectVersion=${CI_BUILD_NUMBER}
sonar.projectName=${CI_PROJECT_NAME}

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
