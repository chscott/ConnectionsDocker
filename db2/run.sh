#!/bin/bash

# This is the run script for a DB2 container. Its main job is to launch DB2, and how this is done depends
# upon the current state and container run-time arguments. At a high level...
#
# If init has not occurred, do the init. This should only occur the first time the container is started.
# The init process will create the database users and groups, create the instance, and create Connections
# databases. At the end of init, an init_complete file will be created in the instance log directory as a 
# flag to indicate init has already been done.

# If update environment variables are set, the corresponding updates for that release level will be 
# applied. Update variables take the form CR*_UPDATE_URL, where * is the Cumulative Refresh number
# (e.g. CR1, CR2, etc.) and the value of the variable is a URL to the internally hosted update package.
# For example, CR1_UPDATE_URL=ftp://ftp.example.com/db2/60cr1-database-updates_20171128.zip. These
# environment variables can be used whether or not init has occurred. If init has not occurred, it will
# be done prior to applying the updates.

# At the end of performing init (if required) and update (if requested via environment variable), the
# DB2 instance will be started and available for use.

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Download common utilities. SETUP_URL can be overridden by setting it as an environment variable when running
# the container. For example, SETUP_URL=ftp://ftp.example.com/db2. If this is done, it is expected that all
# resources needed for setup will be available at the provided location. See 
# https://github.com/chscott/ConnectionsDocker/tree/master/db2 for a list of resources.
curl -L -O -J -s -S -f "${SETUP_URL}/utils.sh" || { printf "F: Download of ${SETUP_URL}/utils.sh failed"; exit 1; }

# Source common utilities
. "${WORK_DIR}/utils.sh"

inform "Starting DB2 run script..."

# Set up traps to listen for container stop signals
trap "echo Received SIGTERM signal; stopDB2" SIGTERM
trap "echo Received SIGKILL signal; stopDB2" SIGKILL

# Order matters here. Each CR should be added before the prior one.
# For example, specifing CR2 means that CR1 is ignored, if specified.

# Init has already occurred
if [[ ! -z "${CR2_UPDATE_URL}" && -f "${WORK_DIR}/init_complete" ]]; then
    inform "Run tasks: 1) Apply CR2 updates, 2) Start DB2"
    applyCR2Updates || warn "CR2 database updates failed"
    startDB2 || { fail "Unable to start DB2. Exiting"; exit 1; } 
elif [[ ! -z "${CR1_UPDATE_URL}" && -f "${WORK_DIR}/init_complete" ]]; then
    inform "Run tasks: 1) Apply CR1 updates, 2) Start DB2"
    applyCR1Updates || warn "CR1 database updates failed"
    startDB2 || { fail "Unable to start DB2. Exiting"; exit 1; }
elif [[ -f "${WORK_DIR}/init_complete" ]]; then
    inform "Run tasks: 1) Start DB2"
    startDB2 || { fail "Unable to start DB2. Exiting"; exit 1; }
# Init has not already occurred   
elif [[ ! -z "${CR2_UPDATE_URL}" && ! -f "${WORK_DIR}/init_complete" ]]; then
    inform "Run tasks: 1) Initialize DB2 for Connections, 2) Apply CR2 updates, 3) Start DB2"
    init || { fail "DB2 init failed. Exiting"; exit 1; }
    applyCR2Updates "CR2 database updates failed"
    startDB2 || { fail "Unable to start DB2. Exiting"; exit 1; }   
elif [[ ! -z "${CR1_UPDATE_URL}" && ! -f "${WORK_DIR}/init_complete" ]]; then
    inform "Run tasks: 1) Initialize DB2 for Connections, 2) Apply CR1 updates, 3) Start DB2"
    init || { fail "DB2 init failed. Exiting"; exit 1; }
    applyCR1Updates warn "CR1 database updates failed"
    startDB2 || { fail "Unable to start DB2. Exiting"; exit 1; }    
elif [[ ! -f "${WORK_DIR}/init_complete" ]]; then
    inform "Run tasks: 1) Initialize DB2 for Connections, 2) Start DB2"
    init || { fail "DB2 init failed. Exiting"; exit 1; }
    startDB2 || { fail "Unable to start DB2. Exiting"; exit 1; }
fi 

inform "Completed DB2 run script"

# Wait for signals (shutdown)
waitForSignals
