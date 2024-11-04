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

# ビルド設定の確認
echo "Checking build settings..."

# ビルドとテストの実行
xcodebuild \
  -scheme "$SCHEME_NAME" \
  -destination "id=$SIMULATOR_ID" \
  -derivedDataPath $CI_DERIVED_DATA_PATH \
  -enableCodeCoverage YES \
  -resultBundlePath $RESULT_BUNDLE_PATH \
  clean build test

echo "Starting SonarCloud coverage upload process..."

# 環境変数のデバッグ出力
echo "Environment variables:"
echo "CI_DERIVED_DATA_PATH: $CI_DERIVED_DATA_PATH"
echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"
echo "Current directory: $(pwd)"
echo "RESULT_BUNDLE_PATH: $RESULT_BUNDLE_PATH"

XCRESULT_PATH="$RESULT_BUNDLE_PATH"

echo "XCRESULT_PATH content:"
ls -la "$XCRESULT_PATH"

# カバレッジレポートの生成
echo "Generating coverage report..."
TEMP_DIR="$CI_DERIVED_DATA_PATH/sonar_temp"
mkdir -p "$TEMP_DIR"
COVERAGE_FILE="$TEMP_DIR/coverage.txt"

# カバレッジデータの抽出
echo "Extracting coverage data..."
if ! xcrun xccov view --report "$XCRESULT_PATH" > "$COVERAGE_FILE"; then
    echo "Warning: Standard coverage export failed with error code $?. Trying alternative format..."
    xcrun xccov view --json "$XCRESULT_PATH" > "$TEMP_DIR/coverage.json" || {
        echo "Error: Both standard and JSON coverage exports failed."
        exit 1
    }
    cat "$TEMP_DIR/coverage.json" | grep -v "^null" > "$COVERAGE_FILE"
fi

if [ ! -s "$COVERAGE_FILE" ]; then
    echo "Error: Coverage file is empty. Raw xcresult contents:"
    xcrun xcresulttool get --path "$XCRESULT_PATH" --format json
    exit 1
fi

echo "Generated coverage report at: $COVERAGE_FILE"
echo "Coverage report contents (full):"
cat "$COVERAGE_FILE"

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
sonar.scm.provider=git
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
cd "$CI_PRIMARY_REPOSITORY_PATH"
sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.working.directory="$TEMP_DIR/.scannerwork" \
  -Dproject.settings="$SONAR_PROPS" \
  -X

echo "Completed SonarCloud upload"
