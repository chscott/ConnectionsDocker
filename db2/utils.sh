# Check status after adding/deleting user or group.
# $1: Exit code from user/group management command
# $2: Log message
# $3: User or group name
function checkUserGroupStatus() {

    local code="${1}"
    local message="${2}"
    local entity="${3}"
    local operation="${4}"

    if [[ "${code}" != 0 ]]; then
        # Non-fatal error
        if [[ "${code}" == 9 ]]; then
            printf "W ${entity} already exists. Continuing...\n"	
        # Fatal
        else
            printf "${message} ${entity}\n"
            printf "E Exit status: ${code}\n"
            exit 1
        fi
    fi

}

# Download a file from FTP
# $1: FTP directory
# $2: file name
function downloadFile() {

    local server="${1}"
    local dir="${2}"
    local file="${3}"
    curl -O -J "ftp://${server}/${dir}/${file}" || printf "E Download failed. Exiting\n"
	 
}
