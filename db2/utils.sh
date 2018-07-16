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

# Check exit code of database operation. Per the DB2 doc, the -s option
# means an error if the exit code is not 0, 1, 2, or 3 (3 is returned
# when one or more commands result in both codes 1 and 2.
# $1: exit code from DB2
# $2: message
function checkStatusDb() {
    local code="${1}"
    local message="${2}"

    if [[ "${code}" != 0 && "${code}" != 1 && "${code}" != 2 && "${code}" != 3 ]]; then
        printf "E ${message}\n"
        printf "E Exit status: ${code}\n"
        exit 1
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
