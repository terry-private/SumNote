#!/bin/bash
set -e

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

# カバレッジデータをSonarCloud形式に変換
echo "Converting coverage data to SonarCloud format..."
echo '<?xml version="1.0" ?>' > "$COVERAGE_FILE"
echo '<coverage version="1">' >> "$COVERAGE_FILE"

# xccovからJSONデータを取得して変換
xcrun xccov view --json "$RESULT_BUNDLE_PATH" | jq -r '.targets[] | select(.name | contains("Test") | not) | .files[]' | while read -r file; do
    file_path=$(echo "$file" | jq -r '.path')
    file_coverage=$(echo "$file" | jq -r '.coverage')
    
    if [[ "$file_path" == *".swift" ]]; then
        echo "  <file path=\"$file_path\">" >> "$COVERAGE_FILE"
        
        # 行ごとのカバレッジデータを取得
        line_coverage=$(xcrun xccov view --file "$file_path" "$RESULT_BUNDLE_PATH")
        line_number=1
        
        echo "$line_coverage" | while read -r line; do
            if [[ $line =~ ^[0-9]+: ]]; then
                coverage_count=$(echo "$line" | cut -d: -f1)
                if [ "$coverage_count" != "0" ]; then
                    echo "    <lineToCover lineNumber=\"$line_number\" covered=\"true\" branchCover=\"true\"/>" >> "$COVERAGE_FILE"
                else
                    echo "    <lineToCover lineNumber=\"$line_number\" covered=\"false\" branchCover=\"false\"/>" >> "$COVERAGE_FILE"
                fi
            fi
            line_number=$((line_number + 1))
        done
        
        echo "  </file>" >> "$COVERAGE_FILE"
    fi
done

echo '</coverage>' >> "$COVERAGE_FILE"

# sonar-project.propertiesの更新
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

# SonarCloudスキャンの実行
cd "$CI_PRIMARY_REPOSITORY_PATH"
sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.working.directory="$TEMP_DIR/.scannerwork" \
  -Dproject.settings="$TEMP_DIR/sonar-project.properties" \
  -Dsonar.scm.disabled=true \
  -X

echo "Completed SonarCloud upload"
