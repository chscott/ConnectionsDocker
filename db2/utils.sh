# Print a log message with severity
function log() {
	local severity="${1}"
	local message="${2}"
	printf "%s: %s\n" "${severity}" "${message}"
}

# Print an information message
function inform() {
	local message="${1}"
	log "INFO" "${message}"
}

# Print a warning message
function warn() {
	local message="${1}"	
	log "WARN" "${message}"
}

# Print a failure message
function fail() {
	local message="${1}"	
	log "FAIL" "${message}"
}

# Check status after adding/deleting user or group.
# $1: Exit code from user/group management command
# $2: User or group name
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
            exit 1
        fi
    fi
}

# Check exit code of database operation. Per the DB2 doc, the -s option
# means an error if the exit code is not 0, 1, 2, or 3 (3 is returned
# when one or more commands result in both codes 1 and 2.
# $1: exit code from DB2
# $2: message
function checkStatusDb() {
    local code="${1}"
    local message="${2}"
    if [[ "${code}" != 0 && "${code}" != 1 && "${code}" != 2 && "${code}" != 3 ]]; then
        fail "${message}. Exit code: ${code}"
        exit 1
    fi
}

# Download a file
# $1: download URL
function download() {

	local url="${1}"
	curl -O -J -s -S "${url}"

}