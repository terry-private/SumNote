#!/bin/bash
set -e

echo "Starting SonarCloud coverage upload process..."

# 環境変数のデバッグ出力
echo "Environment variables:"
echo "CI_DERIVED_DATA_PATH: $CI_DERIVED_DATA_PATH"
echo "CI_WORKSPACE: $CI_WORKSPACE"
echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"
echo "CI_PRODUCT_PATH: $CI_PRODUCT_PATH"

# DerivedDataディレクトリの内容を確認
echo "Listing DerivedData contents:"
ls -la "$CI_DERIVED_DATA_PATH"

# xcresultの検索範囲を広げる
echo "Searching for xcresult files..."
XCRESULT_PATH=$(find "$CI_WORKSPACE" -name "*.xcresult" -type d | head -n 1)

if [ -z "$XCRESULT_PATH" ]; then
    echo "No .xcresult found in workspace, checking derived data..."
    XCRESULT_PATH=$(find "$CI_DERIVED_DATA_PATH" -name "*.xcresult" -type d 2>/dev/null | head -n 1)
fi

if [ -z "$XCRESULT_PATH" ]; then
    echo "Error: No .xcresult file found. Checking alternative locations..."
    
    # Build配下も確認
    if [ -d "Build" ]; then
        XCRESULT_PATH=$(find "Build" -name "*.xcresult" -type d | head -n 1)
    fi
fi

if [ -z "$XCRESULT_PATH" ]; then
    echo "Error: Still no .xcresult file found. Directory structure:"
    ls -R "$CI_WORKSPACE"
    exit 1
fi

echo "Found xcresult at: $XCRESULT_PATH"

# カバレッジレポートの生成
echo "Generating coverage report..."
xcrun xccov view --report "$XCRESULT_PATH" > coverage.txt || {
    echo "Error generating coverage report. xccov output:"
    xcrun xccov view --report "$XCRESULT_PATH"
    exit 1
}

echo "Generated coverage report at: $(pwd)/coverage.txt"
echo "Coverage report contents (first few lines):"
head -n 5 coverage.txt

# sonar-scannerのインストール
echo "Installing sonar-scanner..."
brew install sonar-scanner

# sonar-project.propertiesの作成
echo "Creating sonar-project.properties..."
cat > sonar-project.properties << EOF
sonar.projectKey=${SONAR_PROJECT_KEY}
sonar.organization=${SONAR_ORGANIZATION}
sonar.host.url=https://sonarcloud.io

sonar.sources=${CI_PRIMARY_REPOSITORY_PATH}
sonar.swift.coverage.reportPaths=$(pwd)/coverage.txt
sonar.exclusions=**/*.generated.swift,**/Pods/**/*,**/*.pb.swift
sonar.swift.file.suffixes=.swift
sonar.sourceEncoding=UTF-8
sonar.projectVersion=${CI_BUILD_NUMBER}
sonar.projectName=${CI_PROJECT_NAME}

# デバッグ設定
sonar.verbose=true
EOF

echo "Created sonar-project.properties"
echo "Content of sonar-project.properties:"
cat sonar-project.properties

# SonarCloudスキャンの実行
echo "Running sonar-scanner..."
sonar-scanner \
  -Dsonar.token="$SONAR_TOKEN" \
  -Dsonar.working.directory=.scannerwork \
  -X  # デバッグモード

echo "Completed SonarCloud upload"
