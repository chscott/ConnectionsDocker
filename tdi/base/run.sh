#!/bin/bash

# This is the install script used to build a container with TDI installed. Once TDI has been installed the container 
# can be committed to a new image that is then used to provision a TDI for Connection container.

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="/app"
DATA_DIR="/data"

# Download TDI functions and common utilities. SETUP_URL can be overridden by setting it as an environment variable
curl -L -O -J -s -S -f "${SETUP_URL}/tdi/base/functions.sh" || { printf "F: Download of ${SETUP_URL}/tdi/base/functions.sh failed"; exit 1; }
curl -L -O -J -s -S -f "${SETUP_URL}/common/utils.sh" || { printf "F: Download of ${SETUP_URL}/common/utils.sh failed"; exit 1; }

# Source TDI functions and common utilities
. "${WORK_DIR}/functions.sh"
. "${WORK_DIR}/utils.sh"

# See if TDI has already been installed
if [[ -f "${APP_DIR}/tdi_install.log" ]]; then
    # TDI is already installed, so skip the install
    inform "TDI has already been installed. Skipping install"
else
    # TDI is not installed, so do the install
    inform "Starting TDI install..."
    installTDI
    if [[ "${?}" != 0 ]]; then
        fail "TDI install failed"
        exit 1
    else
        inform "TDI install succeeded"
    fi
fi