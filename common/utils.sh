# Function to put script in a loop, waiting for shutdown signal from Docker
function waitForSignals() {

    inform "Waiting for signals from Docker engine..."
    while true; do
        sleep 1
    done
    
}

# Print a log message with severity
function log() {

    local severity="${1}"
    local message="${2}"
    local now="$(date '+%F %T')"
    
    NORMAL_COLOR=$'\e[0m'
    WARN_COLOR=$'\e[1;33m'
    FAIL_COLOR=$'\e[1;31m'
    
    if [[ "${severity}" == "I" ]]; then
        printf "%s %s: %s\n" "${now}" "${severity}" "${message}"
    elif [[ "${severity}" == "W" ]]; then
        printf "${WARN_COLOR}%s %s: %s${NORMAL_COLOR}\n" "${now}" "${severity}" "${message}"
    elif [[ "${severity}" == "F" ]]; then
        printf "${FAIL_COLOR}%s %s: %s${NORMAL_COLOR}\n" "${now}" "${severity}" "${message}"
    fi
        
}

# Print an information message
function inform() {

    local message="${1}"
    log "I" "${message}"

}

# Print a warning message
function warn() {

    local message="${1}"    
    log "W" "${message}"

}

# Print a failure message
function fail() {

    local message="${1}"  
    log "F" "${message}"

}

# Check status after adding/deleting user or group (some errors are not real errors)
function checkUserGroupStatus() {

    local code="${1}"
    local entity="${2}"

    if [[ "${code}" != 0 ]]; then
        # Non-fatal error
        if [[ "${code}" == 9 ]]; then
            warn "${entity} already exists. Continuing"  
        # Fatal
        else
            fail "Unable to create ${entity}. Exit code: ${code}"
            return 1
        fi
    fi

}