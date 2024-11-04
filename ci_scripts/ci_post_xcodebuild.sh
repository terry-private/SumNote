#!/bin/bash
set -e

if [ $CI_WORKFLOW = "SonarCloud Upload" ]; then
  ./sonar_cloud_upload.sh
fi
