#!/bin/bash

# This is the install script used to build a container with DB2 installed. Once DB2 has been installed the container 
# can be committed to a new image that is then used to provision a DB2 for Connection container.

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="/app"
DATA_DIR="/data"

# Download DB2 functions and common utilities. SETUP_URL can be overridden by setting it as an environment variable
curl -L -O -J -s -S -f "${SETUP_URL}/db2/base/functions.sh" || { printf "F: Download of ${SETUP_URL}/db2/base/functions.sh failed"; exit 1; }
curl -L -O -J -s -S -f "${SETUP_URL}/common/utils.sh" || { printf "F: Download of ${SETUP_URL}/common/utils.sh failed"; exit 1; }

# Source DB2 functions and common utilities
. "${WORK_DIR}/functions.sh"
. "${WORK_DIR}/utils.sh"

# See if DB2 has already been installed
if [[ -f "/app/logs/db2install.history" ]]; then
    # DB2 is already installed, so skip the install
    inform "DB2 has already been installed. Skipping install"
else
    # DB2 is not installed, so do the install
    inform "Starting DB2 install..."
    installDB2
    if [[ "${?}" != 0 ]]; then
        fail "DB2 install failed"
        exit 1
    else
        inform "DB2 install succeeded"
    fi
fi

# Wait for user input
waitForSignals
