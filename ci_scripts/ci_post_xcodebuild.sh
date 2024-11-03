#!/bin/bash
set -e

# Xcode Cloud環境変数のデバッグ出力
echo "Checking environment variables..."
echo "CI_DERIVED_DATA_PATH: $CI_DERIVED_DATA_PATH"
echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"
echo "SONAR_PROJECT_KEY: $SONAR_PROJECT_KEY"
