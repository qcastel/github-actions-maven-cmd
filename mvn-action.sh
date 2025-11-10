#!/bin/bash
set -e

pwd

# Start PostgreSQL if it's available and enabled
if command -v pg_ctl &> /dev/null && [ "${USE_LOCAL_POSTGRES:-false}" = "true" ]; then
    echo "Starting PostgreSQL..."
    
    # Create /run/postgresql directory for Unix socket lock files
    mkdir -p /run/postgresql
    chown -R postgres:postgres /run/postgresql
    
    # Ensure log directory exists and has correct permissions
    mkdir -p /var/lib/postgresql/data
    chown -R postgres:postgres /var/lib/postgresql/data
    
    # Check if PostgreSQL is already running
    if su-exec postgres pg_isready -U postgres &> /dev/null; then
        echo "PostgreSQL is already running."
    else
        # Clean up any stale lock files
        if [ -f /var/lib/postgresql/data/postmaster.pid ]; then
            echo "Removing stale postmaster.pid file..."
            rm -f /var/lib/postgresql/data/postmaster.pid
        fi
        
        # Check if data directory is initialized
        if [ ! -f /var/lib/postgresql/data/PG_VERSION ]; then
            echo "Initializing PostgreSQL data directory..."
            su-exec postgres initdb -D /var/lib/postgresql/data
            
            # Configure PostgreSQL for local connections (as postgres user)
            su-exec postgres sh -c 'echo "host all all 127.0.0.1/32 trust" >> /var/lib/postgresql/data/pg_hba.conf'
            su-exec postgres sh -c 'echo "host all all ::1/128 trust" >> /var/lib/postgresql/data/pg_hba.conf'
            su-exec postgres sh -c 'echo "local all all trust" >> /var/lib/postgresql/data/pg_hba.conf'
            su-exec postgres sh -c 'echo "listen_addresses=\"*\"" >> /var/lib/postgresql/data/postgresql.conf'
        fi
        
        # Start PostgreSQL with wait flag and check for errors
        if ! su-exec postgres pg_ctl -D /var/lib/postgresql/data -l /var/lib/postgresql/data/logfile start -w; then
            echo "ERROR: Failed to start PostgreSQL. Checking log file..."
            if [ -f /var/lib/postgresql/data/logfile ]; then
                cat /var/lib/postgresql/data/logfile
            fi
            exit 1
        fi
        
        echo "Waiting for PostgreSQL to be ready..."
        until su-exec postgres pg_isready -U postgres; do 
            sleep 1
        done
        echo "PostgreSQL is ready."
    fi
fi

if [ -d "${M2_HOME_FOLDER}" ]; then
     echo "INFO - M2 folder '${M2_HOME_FOLDER}' not empty. We therefore will beneficy from the CI cache";
     ls -l ${M2_HOME_FOLDER};
else
     echo "WARN - No M2 folder '${M2_HOME_FOLDER}' found. We therefore won't beneficy from the CI cache";
fi

# Verify JAVA_HOME is set and valid
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk/
# Add Java to PATH
export PATH="$JAVA_HOME/bin:$PATH"

echo "JAVA_HOME = $JAVA_HOME"
java -version

# Execute Maven command
mvn -ntp $*

# Capture exit code
EXIT_CODE=$?

# Stop PostgreSQL if it was started
if command -v pg_ctl &> /dev/null && [ "${USE_LOCAL_POSTGRES:-false}" = "true" ]; then
    echo "Stopping PostgreSQL..."
    if su-exec postgres pg_isready -U postgres &> /dev/null; then
        su-exec postgres pg_ctl -D /var/lib/postgresql/data stop
    else
        echo "PostgreSQL is not running."
    fi
fi

exit $EXIT_CODE
