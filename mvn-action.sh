#!/bin/bash
set -e

pwd

if [ -d "${M2_HOME_FOLDER}" ]; then
     echo "INFO - M2 folder '${M2_HOME_FOLDER}' not empty. We therefore will beneficy from the CI cache";
     ls -l ${M2_HOME_FOLDER};
else
     echo "WARN - No M2 folder '${M2_HOME_FOLDER}' found. We therefore won't beneficy from the CI cache";
fi

echo "JAVA_HOME = $JAVA_HOME"
JAVA_HOME="/usr/java/openjdk-21/"

# Do the copyright verification
mvn -ntp $*
