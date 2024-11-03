#!/bin/bash
set -e

echo "Setting up test environment..."

# プロジェクトのルートディレクトリに移動
cd "$CI_PRIMARY_REPOSITORY_PATH"

# スキーム名の取得
SCHEME_NAME=${CI_XCODE_SCHEME:-$(xcodebuild -list | grep -A 1 "Schemes:" | tail -n 1 | xargs)}
echo "Using scheme: $SCHEME_NAME"
xcodebuild -scheme "$SCHEME_NAME" -showdestinations

# ビルド設定の確認
echo "Checking build settings..."
xcodebuild test -scheme "$SCHEME_NAME" \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.1' \
    -derivedDataPath DerivedData/ \
    -enableCodeCoverage YES \
    -resultBundlePath DerivedData/Logs/Test/ResultBundle.xcresult \
    clean build test

echo "Test environment setup completed"

echo "Starting SonarCloud coverage upload process..."

# 環境変数のデバッグ出力
echo "Environment variables:"
echo "CI_DERIVED_DATA_PATH: $CI_DERIVED_DATA_PATH"
echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"
echo "Current directory: $(pwd)"

# 複数の場所で.xcresultを検索
echo "Searching for xcresult files in multiple locations..."
SEARCH_PATHS=(
    "$CI_DERIVED_DATA_PATH/Logs/Test"
    "$CI_DERIVED_DATA_PATH/Build"
    "$CI_DERIVED_DATA_PATH"
)

XCRESULT_PATH=""
for path in "${SEARCH_PATHS[@]}"; do
    echo "Searching in: $path"
    if [ -d "$path" ]; then
        ls -la "$path"
        FOUND_PATH=$(find "$path" -name "*.xcresult" -type d 2>/dev/null | head -n 1)
        if [ ! -z "$FOUND_PATH" ]; then
            XCRESULT_PATH="$FOUND_PATH"
            echo "Found xcresult at: $XCRESULT_PATH"
            break
        fi
    fi
done

if [ -z "$XCRESULT_PATH" ]; then
    echo "Error: No .xcresult file found. Showing directory structure:"
    echo "DerivedData contents:"
    ls -R "$CI_DERIVED_DATA_PATH"
    exit 1
fi

# カバレッジレポートの生成
echo "Generating coverage report..."
TEMP_DIR="$CI_DERIVED_DATA_PATH/sonar_temp"
mkdir -p "$TEMP_DIR"
COVERAGE_FILE="$TEMP_DIR/coverage.txt"

# カバレッジデータの抽出
echo "Extracting coverage data..."
xcrun xccov view --report "$XCRESULT_PATH" > "$COVERAGE_FILE" 2>&1 || {
    echo "Warning: Standard coverage export failed, trying alternative format..."
    xcrun xccov view --json "$XCRESULT_PATH" > "$TEMP_DIR/coverage.json" 2>&1
    # JSONから必要なデータを抽出
    cat "$TEMP_DIR/coverage.json" | grep -v "^null" > "$COVERAGE_FILE"
}

if [ ! -s "$COVERAGE_FILE" ]; then
    echo "Error: Coverage file is empty. Raw xcresult contents:"
    xcrun xcresulttool get --path "$XCRESULT_PATH" --format json
    exit 1
fi

echo "Generated coverage report at: $COVERAGE_FILE"
echo "Coverage report contents (first few lines):"
head -n 5 "$COVERAGE_FILE"

# sonar-scannerのインストール
echo "Installing sonar-scanner..."
brew install sonar-scanner

# sonar-project.propertiesの作成
echo "Creating sonar-project.properties..."
SONAR_PROPS="$TEMP_DIR/sonar-project.properties"

cat > "$SONAR_PROPS" << EOF
sonar.projectKey=${SONAR_PROJECT_KEY}
sonar.organization=${SONAR_ORGANIZATION}
sonar.host.url=https://sonarcloud.io

sonar.sources=${CI_PRIMARY_REPOSITORY_PATH}
sonar.swift.coverage.reportPaths=${COVERAGE_FILE}
sonar.exclusions=**/*.generated.swift,**/Pods/**/*,**/*.pb.swift,**/*Tests/**
sonar.test.inclusions=**/*Tests/**
sonar.swift.file.suffixes=.swift
sonar.sourceEncoding=UTF-8
sonar.projectVersion=${CI_BUILD_NUMBER}
sonar.projectName=${CI_PROJECT_NAME}

# デバッグ設定
sonar.verbose=true
EOF

echo "Created sonar-project.properties at: $SONAR_PROPS"
echo "Content of sonar-project.properties:"
cat "$SONAR_PROPS"

# SonarCloudスキャンの実行
echo "Running sonar-scanner..."
cd "$TEMP_DIR"
sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.working.directory="$TEMP_DIR/.scannerwork" \
  -Dproject.settings="$SONAR_PROPS" \
  -X

echo "Completed SonarCloud upload"