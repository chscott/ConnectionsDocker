# Create the solution directory to ${DATA_DIR}
function createSolutionDir() {

    local TDISOL_PACKAGE="$(echo "${TDISOL_URL}" | awk -F "/" '{print $NF}')"
    
    # If the solution directory already exists, just return
    inform "Checking to see if TDI solution directory needs to be created..."
    if [[ -n "$(ls -A "${DATA_DIR}")" ]]; then
        inform "Solution directory already exists" && return 0
    fi
    
    inform "Creating TDI solution directory..."
    
    # Download solution package
    if [[ -z "${TDISOL_URL}" ]]; then
        fail "The TDISOL_URL environment variable must be specified to create the solution directory"
        return 1
    else
        inform "Downloading ${TDISOL_URL}..." 
        curl -L -O -J -s -S -f "${TDISOL_URL}" || { fail "Download of ${TDISOL_URL} failed"; return 1; }
    fi

    # Unpack the solution package
    inform "Unpacking solution directory..."
    tar -xf "${TDISOL_PACKAGE}" --directory "${DATA_DIR}" --strip-components=1
    chmod -R u+x "${DATA_DIR}"/*.sh
    chmod u+x "${DATA_DIR}/netstore"

}

# Configure the solution directory for Connections
function configSolutionDir() {

    # Update tdienv.sh with the correct path
    sed -i "s|\(TDIPATH=\).*|\1\"${APP_DIR}\"|" "${DATA_DIR}/tdienv.sh" || { fail "Unable to update tdienv.sh"; return 1; }
    
    # Update profiles_tdi.properties if the environment values were provided
    if [[ -z "${LDAP_HOST}" || -z "${LDAP_PORT}" || -z "${LDAP_BIND_DN}" || -z "${LDAP_BIND_PWD}" ||
          -z "${LDAP_SEARCH_BASE}" || -z "${LDAP_SEARCH_FILTER}" || -z "${DB2_HOST}" ||
          -z "${DB2_PORT}" || -z "${DB2_PROFILES_USER}" || -z "${DB2_PROFILES_PWD}" ]]
    then
        warn "TDI configuration properties were not provided. Manual configuration of ${DATA_DIR}/profiles_tdi.properties is required"
    else
        inform "Updating profiles_tdi.properties..."
        sed -i "s|^\(source_ldap_url=\).*|\1ldap:\/\/${LDAP_HOST}:${LDAP_PORT}|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|^\(source_ldap_user_login=\).*|\1${LDAP_BIND_DN}|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|^\({protect}-source_ldap_user_password=\).*|\1${LDAP_BIND_PWD}|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|^\(source_ldap_search_base=\).*|\1${LDAP_SEARCH_BASE}|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|^\(source_ldap_search_filter=\).*|\1${LDAP_SEARCH_FILTER}|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|^\(dbrepos_jdbc_url=\).*|\1jdbc:db2://${DB2_HOST}:${DB2_PORT}/peopledb|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|^\(dbrepos_username=\).*|\1${DB2_PROFILES_USER}|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|^\({protect}-dbrepos_password=\).*|\1${DB2_PROFILES_PWD}|" "${DATA_DIR}/profiles_tdi.properties"
    fi 

    # Replace map_dbrepos_from_source.properties with one preconfigured for the requested LDAP, if provided
    if [[ -z "${LDAP_TYPE}" ]]; then
        warn "LDAP type was not provided. Manual configuration of ${DATA_DIR}/map_dbrepos_from_source.properties is required"
    else
        inform "Updating map_dbrepos_from_source.properties..."
        if [[ "${LDAP_TYPE}" == "AD" ]]; then
            sed -i "s|^\(guid=\).*|\1\{function_map_from_objectGUID\}|" "${DATA_DIR}/map_dbrepos_from_source.properties"
            sed -i "s|^\(uid=\).*|\1sAMAccountName|" "${DATA_DIR}/map_dbrepos_from_source.properties"
        elif [[ "${LDAP_TYPE}" == "DOMINO" ]]; then
            sed -i "s|^\(guid=\).*|\1\{function_map_from_dominoUNID\}|" "${DATA_DIR}/map_dbrepos_from_source.properties"
            sed -i "s|^\(uid=\).*|\1uid|" "${DATA_DIR}/map_dbrepos_from_source.properties"
        elif [[ "${LDAP_TYPE}" == "SDS" ]]; then
            sed -i "s|^\(guid=\).*|\1nsUniqueId|" "${DATA_DIR}/map_dbrepos_from_source.properties"
            sed -i "s|^\(uid=\).*|\1uid|" "${DATA_DIR}/map_dbrepos_from_source.properties"
        elif [[ "${LDAP_TYPE}" == "DSEE" ]]; then
            sed -i "s|^\(guid=\).*|\1ibm-entryUuid|" "${DATA_DIR}/map_dbrepos_from_source.properties"
            sed -i "s|^\(uid=\).*|\1uid|" "${DATA_DIR}/map_dbrepos_from_source.properties"
        else
            warn "Auto-configuration of ${LDAP_TYPE} not supported. Manual configuration of ${DATA_DIR}/map_dbrepos_from_source.properties is required"
        fi

    fi
    
}

# Synchronize users with LDAP
function synchronizeUsers() {

    # Sync the users
    "${DATA_DIR}/sync_all_dns.sh" >/dev/null 2>&1
    if [[ "${?}" == 0 ]]; then
        inform "Successfully synchronized users with LDAP"
    else
        fail "User synchronization with LDAP failed"
    fi 
    
    inform "Waiting for signals from Docker engine..."

}