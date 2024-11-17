#!/bin/bash
set -e

if [ "$CI_WORKFLOW" = "[inspect]SonarCloud Upload at update_ci_scripts" ]; then
  ./sonar_cloud_upload.sh
else
  echo dont upload cause $CI_WORKFLOW is not "SonarCloud Upload"
fi
