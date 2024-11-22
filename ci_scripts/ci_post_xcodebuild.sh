#!/bin/bash
set -e

if [ "${SONAR_CLOUD_UPLOAD+x}" ]; then
  ./sonar_cloud_upload.sh
else
  echo "SonarCloudアップロードはスキップされました。"
fi
