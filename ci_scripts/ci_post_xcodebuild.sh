#!/bin/bash
set -e

echo "Starting SonarCloud coverage upload process..."

brew install sonar-scanner
echo "Installed sonar-scanner"

# デバッグ出力を追加
echo "Creating sonar-project.properties with:"
echo "Project Key: $SONAR_PROJECT_KEY"
echo "Organization: $SONAR_ORGANIZATION"

# sonar-project.propertiesの作成
cat > sonar-project.properties << EOF
sonar.projectKey=${SONAR_PROJECT_KEY}
sonar.organization=${SONAR_ORGANIZATION}
sonar.host.url=https://sonarcloud.io

sonar.sources=$CI_PRIMARY_REPOSITORY_PATH
sonar.swift.coverage.reportPaths=coverage.txt
sonar.exclusions=**/*.generated.swift,**/Pods/**/*,**/*.pb.swift
sonar.swift.file.suffixes=.swift
sonar.sourceEncoding=UTF-8
sonar.projectVersion=${CI_BUILD_NUMBER}
sonar.projectName=${CI_PROJECT_NAME}
EOF

cd $CI_WORKSPACE

# declare variables
SCHEME="BigIntExtensionsTests"
echo $SCHEME
PRODUCT_NAME="Production"
echo $PRODUCT_NAME
WORKSPACE_NAME="SumNote.xcworkspace"
echo $WORKSPACE_NAME

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
xcrun xccov view --report "$XCRESULT_PATH" > coverage.txt
xcrun --run llvm-cov show -instr-profile=${PROFDATA} ${BINARY} > coverage.txt

# SonarCloudスキャンの実行
sonar-scanner \
  -Dsonar.token=${$SONAR_TOKEN} \
  -Dsonar.working.directory=.scannerwork
  
echo "Completed SonarCloud upload"
