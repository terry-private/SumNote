#!/bin/bash
set -e

echo "Starting SonarCloud coverage upload process..."

# 環境変数のデバッグ出力
echo "Environment variables:"
echo "CI_DERIVED_DATA_PATH: $CI_DERIVED_DATA_PATH"
echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"

# DerivedData/Buildディレクトリの内容を確認
echo "Listing DerivedData/Build contents:"
ls -la "$CI_DERIVED_DATA_PATH/Build"

# xcresultの検索（DerivedData/Build配下に限定）
echo "Searching for xcresult files in Build directory..."
XCRESULT_PATH=$(find "$CI_DERIVED_DATA_PATH/Build" -name "*.xcresult" -type d 2>/dev/null | head -n 1)

if [ -z "$XCRESULT_PATH" ]; then
    echo "Error: No .xcresult file found in Build directory. Contents of Build directory:"
    ls -R "$CI_DERIVED_DATA_PATH/Build"
    exit 1
fi

echo "Found xcresult at: $XCRESULT_PATH"

# カバレッジレポートの生成
echo "Generating coverage report..."
# 一時的なディレクトリを作成
TEMP_DIR="$CI_DERIVED_DATA_PATH/sonar_temp"
mkdir -p "$TEMP_DIR"
COVERAGE_FILE="$TEMP_DIR/coverage.txt"

xcrun xccov view --report "$XCRESULT_PATH" > "$COVERAGE_FILE" || {
    echo "Error generating coverage report. xccov output:"
    xcrun xccov view --report "$XCRESULT_PATH"
    exit 1
}

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
sonar.exclusions=**/*.generated.swift,**/Pods/**/*,**/*.pb.swift
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
cd "$TEMP_DIR"  # 作業ディレクトリを変更
sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.working.directory="$TEMP_DIR/.scannerwork" \
  -Dproject.settings="$SONAR_PROPS" \
  -X  # デバッグモード

echo "Completed SonarCloud upload"
