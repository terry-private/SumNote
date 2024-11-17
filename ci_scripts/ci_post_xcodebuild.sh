#!/bin/bash
set -e

if [ "$CI_WORKFLOW" = "SonarCloud Upload" ]; then
  ./sonar_cloud_upload.sh
else
  echo dont upload cause $CI_WORKFLOW is not "[inspect]SonarCloud Upload"
fi
