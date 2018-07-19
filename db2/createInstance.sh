#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source prereq scripts
. "${WORK_DIR}/utils.sh"

# Create the instance if it doesn't already exist
if [[ ! -d "/data/db2inst1/db2inst1" ]]; then
    inform "Beginning creation of DB2 instance..."
    "/app/instance/db2icrt" -u "db2fenc1" "db2inst1" >/dev/null || { fail "DB2 instance creation failed"; exit 1; }
else
    warn "DB2 instance already exists at /app/db2inst1/db2inst1. Skipping"
fi

# Create a new db2nodes.cfg file (needed because the image ID is there currently and will cause SQL6031N)
printf "0 %s\n" "$(hostname)" >|"/data/db2inst1/sqllib/db2nodes.cfg"

# Update the /etc/services file to include the port mapping for the instance (also to prevent SQL6031N)
printf "%s\t%s\t\t%s\n" "DB2_db2inst1" "50000/tcp" "# DB2 instance" >>"/etc/services"

# Start the DB2 instance
inform "Starting DB2 instance..."
su - "db2inst1" -c "db2start >/dev/null" || { fail "Unable to start DB2 instance. Exiting"; exit 1; }

# Enable Unicode
inform "Enabling Unicode codepage..."
su - "db2inst1" -c "/data/db2inst1/sqllib/adm/db2set" DB2CODEPAGE=1208 >/dev/null" ||
    warn "Unable to set DB2 codepage"

inform "Completed creation of DB2 instance"
