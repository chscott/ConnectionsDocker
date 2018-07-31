#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If the SETUP_URL environment variable has not been set, use the default URL
if [[ -z "${SETUP_URL}" ]]; then
    export SETUP_URL="https://raw.githubusercontent.com/chscott/ConnectionsDocker/master"
fi

# Download the run script and utilities
curl -L -O -J -s -S -f "${SETUP_URL}/db2/run.sh" || printf "WARN: Unable to download ${SETUP_URL}/db2/run.sh. Trying local run.sh...\n"

if [[ -f "${WORK_DIR}/run.sh" ]]; then
    # Make the run script executable
    chmod +x "${WORK_DIR}/run.sh"
    # Replace this process with run.sh
    exec "${WORK_DIR}/run.sh" || { printf "FAIL: Error encountered trying to run run.sh. Exiting\n"; exit 1; }
else
    printf "FAIL: ${WORK_DIR}/run.sh does not exist. Exiting\n"
    exit 1
fi
