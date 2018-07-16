# Check status after adding/deleting user or group.
# $1: Exit code from user/group management command
# $2: Log message
# $3: User or group name
function checkUserGroupStatus() {

    local code=${1}
    local message=${2}
    local entity=${3}
    local operation=${4}

    if [[ ${code} != 0 ]]; then
        # Non-fatal error
        if [[ ${code} == 9 ]]; then
            echo "W ${entity} already exists. Continuing..."	
        # Fatal
        else
            echo "${message} ${entity}"
            echo "E Exit status: ${code}"
            exit 1
        fi
    fi

}
