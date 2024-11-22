#!/bin/bash
set -e

if [ -n "$SONAR_CLOUD_UPLOAD" ]; then
  ./sonar_cloud_upload.sh
else
  echo "SonarCloudアップロードはスキップされました。"
fi
