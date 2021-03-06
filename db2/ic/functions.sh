# Create the DB2 users and groups
function createUsersAndGroups() {

    # Add required groups
    inform "Creating DB2 groups..."
    groupadd -r "db2iadm1" 2>/dev/null || checkUserGroupStatus "${?}" "db2iadm1" || return 1
    groupadd -r "db2fsdm1" 2>/dev/null || checkUserGroupStatus "${?}" "db2fsdm1" || return 1
    groupadd -r "dasadm1" 2>/dev/null ||  checkUserGroupStatus "${?}" "dasadm1" || return 1

    # Add required users
    inform "Creating DB2 users..."
    useradd -r -m -d "${DATA_DIR}/db2inst1" -g "db2iadm1" "db2inst1" 2>/dev/null || checkUserGroupStatus "${?}" "db2inst1" || return 1
    printf "db2inst1:password" | chpasswd
    useradd -r -m -d "${DATA_DIR}/db2fenc1" -g "db2fsdm1" "db2fenc1" 2>/dev/null || checkUserGroupStatus "${?}" "db2fenc1" || return 1
    printf "db2fenc1:password" | chpasswd
    useradd -r -m -d "${DATA_DIR}/dasusr1" -g "dasadm1" "dasusr1" 2>/dev/null || checkUserGroupStatus "${?}" "dasusr1" || return 1
    printf "dasusr1:password" | chpasswd
    useradd -r -m -d "${DATA_DIR}/lcuser" -g "db2iadm1" "lcuser" 2>/dev/null || checkUserGroupStatus "${?}" "lcuser" || return 1
    printf "lcuser:password" | chpasswd
    
}

# Update /etc/security/limits.conf
function updateLimitsFile() {

    inform "Setting open file limits for db2iadm1 in /etc/security/limits.conf..."
    if [[ $(grep -c "@db2iadm1" "/etc/security/limits.conf") == 0 ]]; then
        printf "@db2iadm1\tsoft\tnofile\t16384\n" >> "/etc/security/limits.conf" || warn "Unable to update /etc/security/limits.conf"
        printf "@db2iadm1\thard\tnofile\t65536\n" >> "/etc/security/limits.conf" || warn "Unable to update /etc/security/limits.conf"  
    fi

}

# Create the DB2 instance
function createDB2Instance() {

    local LOG_DIR="${INSTANCE_DIR}/create_instance.log"
    
    # Create the instance if it doesn't already exist
    if [[ ! -d "${INSTANCE_DIR}/sqllib" ]]; then
        inform "Creating DB2 instance..."
        "/app/instance/db2icrt" -u "db2fenc1" "db2inst1" >|"${LOG_DIR}" 2>&1 || { fail "DB2 instance creation failed"; return 1; }
    else
        inform "DB2 instance already exists at /app/db2inst1/db2inst1. Skipping"
    fi

}

# Update ${INSTANCE_DIR}/sqllib/db2nodes.cfg
function updateDB2NodesFile() {

    inform "Generating a new db2nodes.cfg file with hostname $(hostname)..."
    printf "0 %s\n" "$(hostname)" >|"${INSTANCE_DIR}/sqllib/db2nodes.cfg" || { fail "Unable to update db2nodes.cfg"; return 1; }

}

# Update /etc/services
function updateServicesFile() {

    inform "Adding DB2 instance to /etc/services file..."
    if [[ $(grep "db2inst1" "/etc/services" | grep -c 50000) == 0 ]]; then 
        printf "%s\t%s\t\t%s\n" "DB2_db2inst1" "50000/tcp" "# DB2 instance" >>"/etc/services"
    fi

}

# Update DB2 registry
function updateDB2Registry() {

    # Global registry variable must be set as root
    inform "Updating the DB2SYSTEM registry variable with hostname $(hostname)..."
    "${INSTANCE_DIR}/sqllib/adm/db2set" -g "DB2SYSTEM=$(hostname)" || { fail "Unable to update the DB2SYSTEM registry variable"; return 1; }
    
    # Non-global registry variable set as instance owner
    inform "Enabling Unicode codepage..."
    su - "db2inst1" -c "${INSTANCE_DIR}/sqllib/adm/db2set DB2CODEPAGE=1208 >/dev/null" || { fail "Unable to set DB2 codepage"; return 1; }

}

# Check exit code of database operation. Per the DB2 doc, the -s option means an error if the exit code is not 0, 1, 2, or 3 
# (3 is returned when one or more commands result in both codes 1 and 2)
function checkStatusDb() {

    local code="${1}"
    local message="${2}"

    if [[ "${code}" != 0 && "${code}" != 1 && "${code}" != 2 && "${code}" != 3 ]]; then
        fail "${message}. Exit code: ${code}"
        return 1
    fi

}

# Helper function to determine if all Connections databases have been created
function areAllDbsCreated() {

    local requiredDbs=("HOMEPAGE" "FILES" "PNS" "OPNACT" "BLOGS" "DOGEAR" "SNCOMM" "FORUM" "METRICS" "MOBILE" "PEOPLEDB" "WIKIS" "FNGCD" "FNOS")
    local installedDbs="($(su - "db2inst1" -c "db2 list database directory"))"

    # Loop through the databases and test if each exists. If any database does not exist, immediately return false
    for db in "${requiredDbs[@]}"; do
        local count=$(echo "${installedDbs}" | grep "Database name" | grep -c "${db}")
        if [[ "${count}" == 0 ]]; then
            return 1
        fi
    done
    
}

# Create the specified database
function createDatabase() {

    local dbName="${1}"
    local dbDir="${2}"
    local DB_SCRIPT_DIR="${WORK_DIR}/Wizards/connections.sql"
    local LOG_DIR="${INSTANCE_DIR}/init_dbs.log"
    
    inform "Creating ${dbName} database..."
    
    count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c \"${dbName}\"")
    if [[ "${count}" > 0 ]]; then
        warn "${dbName} database is already created. Skipping"
    else
        su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/${dbDir}/db2/createDb.sql\" >|\"${LOG_DIR}\" 2>&1"
        checkStatusDb "${?}" "Unable to create database: ${dbName}" || return 1
        su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/${dbDir}/db2/appGrants.sql\" >>\"${LOG_DIR}\" 2>&1"
        checkStatusDb "${?}" "Unable to grant rights on database: ${dbName}" || return 1
        # Special handling for HOMEPAGE
        if [[ "${dbName}" == "HOMEPAGE" ]]; then
            su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/${dbDir}/db2/initData.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to initialize data for database: ${dbName}" || return 1
            su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/${dbDir}/db2/reorg.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to run reorg on database: ${dbName}" || return 1
            su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/${dbDir}/db2/updateStats.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to update stats for database: ${dbName}" || return 1
        fi
        # Special handling for SNCOMM
        if [[ "${dbName}" == "SNCOMM" ]]; then
            su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/${dbDir}/db2/calendar-createDb.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to create table: Calendar" || return 1
            su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/${dbDir}/db2/calendar-appGrants.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to grant rights on table: Calendar" || return 1
        fi
    fi
    
}

# Create the Connections databases
function createDatabases() {

    local DB_WIZARDS_PACKAGE="$(echo "${DB_WIZARDS_URL}" | awk -F "/" '{print $NF}')"
    
    # If all databases are already created, just return
    inform "Checking to see if databases need to be created..."
    areAllDbsCreated && inform "Databases are already created" && return 0
    
    inform "Creating Connections databases..."
    
    # Download database wizard package
    if [[ -z "${DB_WIZARDS_URL}" ]]; then
        fail "The DB_WIZARDS_URL environment variable must be specified to create Connections databases"
        return 1
    else
        inform "Downloading ${DB_WIZARDS_URL}..." 
        curl -L -O -J -s -S -f "${DB_WIZARDS_URL}" || { fail "Download of ${DB_WIZARDS_URL} failed"; return 1; }
    fi

    # Unpack the database creation scripts
    inform "Unpacking database creation scripts..."
    tar -xf "${DB_WIZARDS_PACKAGE}"
    chown -R "db2inst1.db2iadm1" "${DB_WIZARDS_PACKAGE}"
    
    # Create the databases
    createDatabase "HOMEPAGE" "homepage" || return 1
    createDatabase "FILES" "files" || return 1
    createDatabase "PNS" "pushnotification" || return 1
    createDatabase "OPNACT" "activities" || return 1
    createDatabase "BLOGS" "blogs" || return 1
    createDatabase "DOGEAR" "dogear" || return 1
    createDatabase "SNCOMM" "communities" || return 1
    createDatabase "FORUM" "forum" || return 1
    createDatabase "METRICS" "metrics" || return 1
    createDatabase "MOBILE" "mobile" || return 1
    createDatabase "PEOPLEDB" "profiles" || return 1
    createDatabase "WIKIS" "wikis" || return 1
    createDatabase "FNGCD" "library.gcd" || return 1
    createDatabase "FNOS" "library.os" || return 1
    
    inform "Completed creating Connections databases"

}

# Start DB2
function startDB2() {

    inform "Starting DB2 instance..."
    su - "db2inst1" -c "exec db2start >/dev/null" || { fail "Unable to start DB2 instance. Exiting"; return 1; } 
    inform "DB2 has started successfully"

}

# Stop DB2
function stopDB2() {

    inform "Stopping DB2 instance..."
    su - "db2inst1" -c "exec db2stop >/dev/null" || { fail "Unable to stop DB2 instance. Exiting"; return 1; } 
    inform "DB2 has stopped successfully"

}

# Initialize DB2 for Connections
function init() {

    inform "Beginning Connections database initialization..."

    # Create the DB2 users and groups
    createUsersAndGroups || return 1
    
    # Increase open file limit for instance owner group
    updateLimitsFile || return 1

    # Create the DB2 instance
    createDB2Instance || return 1
    
    # Create a new db2nodes.cfg file (needed because the image ID is there currently and will cause SQL6031N)
    updateDB2NodesFile || return 1

    # Update the /etc/services file to include the port mapping for the instance (also to prevent SQL6031N)
    updateServicesFile || return 1

    # Start the DB2 instance (must be started to update the registry in the next step)
    startDB2 || return 1
    
    # Update the DB2SYSTEM registry variable (has to occur here, after starting DB2, and must run as root)
    updateDB2Registry || return 1    

    # Create the Connections databases
    createDatabases || return 1
    
    # Stop the DB2 instance (stopping here to provide consistent behavior for all run.sh cases)
    stopDB2 || return 1

    # Leave a marker in the container to indicate init is complete
    touch "${WORK_DIR}/init_complete"

    inform "Completed Connections database initialization..."

}

# Apply CR1 database updates
function applyCR1Updates() {

    local CR1_UPDATE_PACKAGE="$(echo "${CR1_UPDATE_URL}" | awk -F "/" '{print $NF}')"
    local CR1_UPDATE_DIR="${WORK_DIR}/60cr1-database-updates_20171128-1036/From-60"
    local LOG_DIR="${INSTANCE_DIR}/cr1_updates.log"
    
    # See if CR1 was already applied. If so, do nothing
    if [[ -f "${INSTANCE_DIR}/sqllib/log/cr1_complete" ]]; then
        warn "CR1 update was requested, but it was previously applied. Skipping"
        return 0
    fi
    
    inform "Beginning CR1 database updates..."

    # Download update package
    inform "Downloading ${CR1_UPDATE_URL}..." 
    curl -L -O -J -s -S -f "${CR1_UPDATE_URL}" || { fail "Download of ${CR1_UPDATE_URL} failed"; return 1; }
    
    # Unpack the update package
    inform "Unpacking database update scripts..."
    unzip -oqq "${CR1_UPDATE_PACKAGE}"
    chown -R "db2inst1.db2iadm1" "${WORK_DIR}/60cr1-database-updates_20171128-1036"
    
    # Start the DB2 instance
    inform "Starting DB2 instance..."
    su - "db2inst1" -c "db2start >/dev/null" || { fail "Unable to start DB2 instance. Exiting"; return 1; }

    # Apply the updates
    su - "db2inst1" -c "db2 -td@ -vf \"${CR1_UPDATE_DIR}/db2/60-CR1-activities-db2.sql\" >|\"${LOG_DIR}\" 2>&1"
        checkStatusDb "${?}" "Unable to apply CR1 updates to Activities" || return 1
    su - "db2inst1" -c "db2 -td@ -vf \"${CR1_UPDATE_DIR}/db2/60-CR1-homepage-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
        checkStatusDb "${?}" "Unable to apply CR1 updates to Homepage" || return 1
        
    # Stop the DB2 instance
    inform "Stopping DB2 instance..."
    su - "db2inst1" -c "db2stop >/dev/null" || { fail "Unable to stop DB2 instance. Exiting"; return 1; }
    
    # Leave a marker in the container to indicate CR1 updates are complete
    touch "${INSTANCE_DIR}/sqllib/log/cr1_complete"
    
    inform "Completed CR1 database updates"

}

# Apply CR2 database updates
function applyCR2Updates() {

    local CR2_UPDATE_PACKAGE="$(echo "${CR2_UPDATE_URL}" | awk -F "/" '{print $NF}')"
    local LOG_DIR="${INSTANCE_DIR}/cr2_updates.log"
    
    # See if CR2 was already applied. If so, do nothing
    if [[ -f "${INSTANCE_DIR}/sqllib/log/cr2_complete" ]]; then
        warn "CR2 update was requested, but it was previously applied. Skipping"
        return 0
    fi
    
    inform "Beginning CR2 database updates..."

    # Download update package
    inform "Downloading ${CR2_UPDATE_URL}..." 
    curl -L -O -J -s -S -f "${CR2_UPDATE_URL}" || { fail "Download of ${CR2_UPDATE_URL} failed"; return 1; }
    
    # Unpack the update package
    inform "Unpacking database update scripts..."
    unzip -oqq "${CR2_UPDATE_PACKAGE}"
    chown -R "db2inst1.db2iadm1" "${WORK_DIR}/60cr2-database-updates"
    
    # Start the DB2 instance
    inform "Starting DB2 instance..."
    su - "db2inst1" -c "db2start >/dev/null" || { fail "Unable to start DB2 instance. Exiting"; return 1; }
    
    # See if CR1 was already applied. If so, the updates need to be from CR1. If not, they are from the base release
    if [[ -f "${INSTANCE_DIR}/sqllib/log/cr1_complete" ]]; then 
        inform "CR1 was previously applied. Will apply CR1 to CR2 updates"
        local CR2_UPDATE_DIR="${WORK_DIR}/60cr2-database-updates/From-60CR1-60IFR1"
        # Apply the updates
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-communities-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Communities" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-files-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Files" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-files_appGrants-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Files" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-homepage-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Homepage" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-metrics-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Metrics" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-wikis-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Wikis" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-wikis_appGrants-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Wikis" || return 1
    else
        inform "CR1 was not previously applied. Will apply Base to CR2 updates"
        local CR2_UPDATE_DIR="${WORK_DIR}/60cr2-database-updates/From-60"
        # Apply the updates
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR1-activities-db2.sql\" >|\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Activities" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR1-homepage-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Homepage" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-communities-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Communities" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-files-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Files" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-files_appGrants-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Files" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-homepage-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Homepage" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-metrics-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Metrics" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-wikis-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Wikis" || return 1
        su - "db2inst1" -c "db2 -td@ -vf \"${CR2_UPDATE_DIR}/db2/60-CR2-wikis_appGrants-db2.sql\" >>\"${LOG_DIR}\" 2>&1"
            checkStatusDb "${?}" "Unable to apply CR2 updates to Wikis" || return 1
    fi
        
    # Stop the DB2 instance
    inform "Stopping DB2 instance..."
    su - "db2inst1" -c "db2stop >/dev/null" || { fail "Unable to stop DB2 instance. Exiting"; return 1; }
    
    # Leave a marker in the container to indicate CR2 updates are complete
    touch "${INSTANCE_DIR}/sqllib/log/cr2_complete"
    
    inform "Completed CR2 database updates"

}