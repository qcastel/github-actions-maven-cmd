#!/bin/bash
set -e

pwd

# Start PostgreSQL if it's available and enabled
if command -v pg_ctl &> /dev/null && [ "${USE_LOCAL_POSTGRES:-false}" = "true" ]; then
    echo "Starting PostgreSQL..."
    su-exec postgres pg_ctl -D /var/lib/postgresql/data -l /var/lib/postgresql/data/logfile start
    
    echo "Waiting for PostgreSQL to be ready..."
    until su-exec postgres pg_isready -U postgres; do 
        sleep 1
    done
    echo "PostgreSQL is ready."
fi

if [ -d "${M2_HOME_FOLDER}" ]; then
     echo "INFO - M2 folder '${M2_HOME_FOLDER}' not empty. We therefore will beneficy from the CI cache";
     ls -l ${M2_HOME_FOLDER};
else
     echo "WARN - No M2 folder '${M2_HOME_FOLDER}' found. We therefore won't beneficy from the CI cache";
fi

echo "JAVA_HOME = $JAVA_HOME"
JAVA_HOME="/usr/java/openjdk-21/"

# Execute Maven command
mvn -ntp $*

# Capture exit code
EXIT_CODE=$?

# Stop PostgreSQL if it was started
if command -v pg_ctl &> /dev/null && [ "${USE_LOCAL_POSTGRES:-false}" = "true" ]; then
    echo "Stopping PostgreSQL..."
    su-exec postgres pg_ctl -D /var/lib/postgresql/data stop
fi

exit $EXIT_CODE
