#!/bin/bash
set -e

if [ "${SONAR_CLOUD_UPLOAD+x}" ]; then
  ./sonar_cloud_upload.sh
else
  echo "環境変数'SONAR_CLOUD_UPLOAD'が見つからないのでSonarCloudアップロードはスキップされました。"
fi
