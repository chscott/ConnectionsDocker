#!/bin/bash

# This is the run script for a TDI container for Connections. Its main job is to configure a solution
# directory for use with Connections.

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="/app"
DATA_DIR="/data"

# Download TDI functions and common utilities. SETUP_URL can be overridden by setting it as an environment variable
curl -L -O -J -s -S -f "${SETUP_URL}/tdi/functions.sh" || { printf "F: Download of ${SETUP_URL}/tdi/functions.sh failed"; exit 1; }
curl -L -O -J -s -S -f "${SETUP_URL}/common/utils.sh" || { printf "F: Download of ${SETUP_URL}/common/utils.sh failed"; exit 1; }

# Source TDI functions and common utilities
. "${WORK_DIR}/functions.sh"
. "${WORK_DIR}/utils.sh"

inform "Starting TDI run script..."

# Set up traps to listen for container stop signals
trap 'inform "SIGTERM received. Stopping..."; exit' SIGTERM
trap 'inform "SIGINT received. Stopping..."; exit' SIGINT
trap 'inform "SIGUSR1 received. Populating users..."; populateUsers' SIGUSR1
trap 'inform "SIGUSR2 received. Synchronizing users..."; synchronizeUsers' SIGUSR2

inform "Run tasks: 1) Create solution directory, 2) Configure solution directory"
createSolutionDir || exit 1
configSolutionDir || exit 1

# Wait for signals (shutdown)
waitForSignals

inform "Completed TDI run script"
