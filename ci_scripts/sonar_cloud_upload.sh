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

# Profdata ファイルの検索
PROFDATA_FILE=$(find "$CI_DERIVED_DATA_PATH" -name "*.profdata" | head -n 1)
if [ -z "$PROFDATA_FILE" ]; then
    echo "Error: No .profdata file found"
    exit 1
fi
echo "Found profdata file: $PROFDATA_FILE"

# Binary ファイルの検索（複数の場所を確認）
echo "Searching for binary file..."

# 可能性のあるパスを列挙
BINARY_PATHS=(
    "$CI_DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/SumNote.app/SumNote"
    "$CI_DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/*.app/SumNote"
    "$CI_DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/*.app/*"
    "$CI_DERIVED_DATA_PATH/Build/Products/*/*.app/SumNote"
)

BINARY_FILE=""
for path in "${BINARY_PATHS[@]}"; do
    echo "Checking path: $path"
    found_file=$(find $(dirname "$path") -name $(basename "$path") -type f 2>/dev/null | head -n 1)
    if [ ! -z "$found_file" ]; then
        BINARY_FILE="$found_file"
        break
    fi
done

if [ -z "$BINARY_FILE" ]; then
    echo "Listing contents of Build/Products directory:"
    ls -R "$CI_DERIVED_DATA_PATH/Build/Products"
    echo "Error: No binary file found"
    exit 1
fi

echo "Found binary file: $BINARY_FILE"

# バイナリファイルの実行権限を確認
if [ ! -x "$BINARY_FILE" ]; then
    echo "Adding executable permission to binary file"
    chmod +x "$BINARY_FILE"
fi

# カバレッジデータをXML形式に変換
echo "Converting coverage data to SonarCloud format..."
echo '<?xml version="1.0" ?>' > "$COVERAGE_FILE"
echo '<coverage version="1">' >> "$COVERAGE_FILE"

# llvm-covを使用してカバレッジ情報を取得
xcrun llvm-cov show "$BINARY_FILE" \
    -instr-profile="$PROFDATA_FILE" \
    -format=text > "$TEMP_DIR/raw_coverage.txt"

# カバレッジデータの処理
while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*([0-9]+)\|.*$ ]]; then
        file_path=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        line_number=$(echo "$line" | awk -F'|' '{print $1}' | tr -d ' ')
        execution_count=$(echo "$line" | awk '{print $NF}')
        
        if [[ "$file_path" == *".swift" ]] && [[ ! "$file_path" == *"Test"* ]]; then
            covered="false"
            if [ "$execution_count" -gt "0" ]; then
                covered="true"
            fi
            
            if [ ! -f "$COVERAGE_FILE.${file_path}" ]; then
                echo "  <file path=\"$file_path\">" > "$COVERAGE_FILE.${file_path}"
            fi
            echo "    <lineToCover lineNumber=\"$line_number\" covered=\"$covered\"/>" >> "$COVERAGE_FILE.${file_path}"
        fi
    fi
done < "$TEMP_DIR/raw_coverage.txt"

# ファイルごとのカバレッジ情報を結合
for partial in "$COVERAGE_FILE".*; do
    cat "$partial" >> "$COVERAGE_FILE"
    echo "  </file>" >> "$COVERAGE_FILE"
    rm "$partial"
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
sonar.projectName=SumNote

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
