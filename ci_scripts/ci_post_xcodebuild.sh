#!/bin/bash
set -e

# Xcode Cloud環境変数
DERIVED_DATA_PATH="$CI_DERIVED_DATA_PATH"
PRODUCT_PATH="$CI_PRODUCT_PATH"
PRIMARY_REPOSITORY_PATH="$CI_PRIMARY_REPOSITORY_PATH"

echo "Starting SonarCloud coverage upload process..."
# カバレッジレポートのパスを特定
XCRESULT_PATH=$(find "$DERIVED_DATA_PATH" -name "*.xcresult" | head -n 1)
if [ -z "$XCRESULT_PATH" ]; then
    echo "Error: No .xcresult file found in $DERIVED_DATA_PATH"
    exit 1
fi

echo "Found xcresult at: $XCRESULT_PATH"

# テストカバレッジレポートの生成
xcrun xccov view --report "$XCRESULT_PATH" > coverage.txt
echo "Generated coverage report"

# sonar-scannerのインストール
brew install sonar-scanner
echo "Installed sonar-scanner"

# sonar-project.propertiesの作成
cat > sonar-project.properties << EOF
sonar.projectKey=${SONAR_PROJECT_KEY}
sonar.organization=${SONAR_ORGANIZATION}
sonar.host.url=https://sonarcloud.io

# ソースコードの場所を指定
sonar.sources=$CI_PRIMARY_REPOSITORY_PATH
sonar.swift.coverage.reportPaths=coverage.txt

# 除外設定
sonar.exclusions=**/*.generated.swift,**/Pods/**/*,**/*.pb.swift

# Swift特有の設定
sonar.swift.file.suffixes=.swift
sonar.sourceEncoding=UTF-8

# プロジェクト情報
sonar.projectVersion=${CI_BUILD_NUMBER}
sonar.projectName=${CI_PROJECT_NAME}
EOF

echo "Created sonar-project.properties"

# SonarCloudスキャンの実行
sonar-scanner \
  -Dsonar.token=${SONAR_TOKEN} \
  -Dsonar.working.directory=.scannerwork
  
echo "Completed SonarCloud upload"
