# #!/bin/bash

# # Xcode Cloud環境変数
# DERIVED_DATA_PATH="$CI_DERIVED_DATA_PATH"
# PRODUCT_PATH="$CI_PRODUCT_PATH"
# PRIMARY_REPOSITORY_PATH="$CI_PRIMARY_REPOSITORY_PATH"

# echo "Starting SonarCloud coverage upload process..."

# # カバレッジレポートのパスを特定
# XCRESULT_PATH=$(find "$DERIVED_DATA_PATH" -name "*.xcresult" | head -n 1)
# if [ -z "$XCRESULT_PATH" ]; then
#     echo "Error: No .xcresult file found in $DERIVED_DATA_PATH"
#     exit 1
# fi

# echo "Found xcresult at: $XCRESULT_PATH"

# # テストカバレッジレポートの生成
# xcrun xccov view --report "$XCRESULT_PATH" > coverage.txt
# echo "Generated coverage report"

# # sonar-scannerのインストール
# brew install sonar-scanner
# echo "Installed sonar-scanner"

# # sonar-project.propertiesの作成
# cat > sonar-project.properties << EOF
# sonar.projectKey=${SONAR_PROJECT_KEY}
# sonar.organization=${SONAR_ORGANIZATION}
# sonar.host.url=https://sonarcloud.io

# # ソースコードの場所を指定
# sonar.sources=$CI_PRIMARY_REPOSITORY_PATH
# sonar.swift.coverage.reportPaths=coverage.txt

# # 除外設定
# sonar.exclusions=**/*.generated.swift,**/Pods/**/*,**/*.pb.swift

# # Swift特有の設定
# sonar.swift.file.suffixes=.swift
# sonar.sourceEncoding=UTF-8

# # プロジェクト情報
# sonar.projectVersion=${CI_BUILD_NUMBER}
# sonar.projectName=${CI_PROJECT_NAME}
# EOF

# echo "Created sonar-project.properties"

# # SonarCloudスキャンの実行
# sonar-scanner \
#   -Dsonar.token=${SONAR_TOKEN} \
#   -Dsonar.working.directory=.scannerwork
  
# echo "Completed SonarCloud upload"

echo "Starting SonarCloud coverage upload process..."

cd $CI_WORKSPACE

# declare variables
SCHEME="BigIntExtensionsTests"
PRODUCT_NAME="SumNote"
WORKSPACE_NAME=${PRODUCT_NAME}.xcworkspace
APP_VERSION=$(sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ./${PRODUCT_NAME}.xcodeproj/project.pbxproj)

echo $APP_VERSION
# clean, build and test project
xcodebuild \
  -workspace ${WORKSPACE_NAME} \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
  -scheme ${SCHEME} \
  -derivedDataPath DerivedData/ \
  -enableCodeCoverage YES \
  -resultBundlePath DerivedData/Logs/Test/ResultBundle.xcresult \
  clean build test

# find profdata and binary
PROFDATA=$(find . -name "Coverage.profdata")
BINARY=$(find . -path "*${PRODUCT_NAME}.app/${PRODUCT_NAME}")

# check if we have profdata file
if [[ -z $PROFDATA ]]; then
  echo "ERROR: Unable to find Coverage.profdata. Be sure to execute tests before running this script."
  exit 1
fi

# extract coverage data from project using xcode native tool
xcrun --run llvm-cov show -instr-profile=${PROFDATA} ${BINARY} > sonarqube-coverage.report

# run sonar scanner and upload coverage data with the current app version
sonar-scanner \
  -Dsonar.projectVersion=${APP_VERSION}
