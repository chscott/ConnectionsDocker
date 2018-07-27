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
    
    # Update tdienv.sh with the correct path
    sed -i "s|\(TDIPATH=\).*|\1\"${DATA_DIR}\"|" "${DATA_DIR}/tdienv.sh" || { fail "Unable to update tdienv.sh"; return 1; }

}

# Configure the solution directory for Connections
function configSolutionDir() {

    # Update profiles_tdi.properties if the environment values were provided
    if [[ -z "${LDAP_HOST}" || -z "${LDAP_PORT}" || -z "${LDAP_BIND_DN}" || -z "${LDAP_BIND_PWD}" ||
          -z "${LDAP_SEARCH_BASE}" || -z "${LDAP_SEARCH_FILTER}" || -z "${DB2_SERVER_FQDN}" ||
          -z "${DB2_INSTANCE_USER}" || -z "${DB2_INSTANCE_PWD}" ]]
    then
        warn "TDI configuration properties were not provided. Manual configuration of profiles_tdi.properties is required"
    else
        inform "Updating profiles_tdi.properties..."
        sed -i "s|\(source_ldap_url=\).*|\1ldap:\/\/\"${LDAP_HOST}:${LDAP_PORT}\"|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|\(source_ldap_user_login=\).*|\1\"${LDAP_BIND_DN}\"|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|\(source_ldap_user_password=\).*|\1\"${LDAP_BIND_PWD}\"|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|\(source_ldap_search_base=\).*|\1\"${LDAP_SEARCH_BASE}\"|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|\(source_ldap_search_filter=\).*|\1\"${LDAP_SEARCH_FILTER}\"|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|\(dbrepos_jdbc_url=\).*|\1jdbc:db2://\"${DB2_SERVER_FQDN}:50000/peopledb\"|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|\(dbrepos_username=\).*|\1\"${DB2_INSTANCE_USER}\"|" "${DATA_DIR}/profiles_tdi.properties"
        sed -i "s|\(dbrepos_password=\).*|\1\"${DB2_INSTANCE_PWD}\"|" "${DATA_DIR}/profiles_tdi.properties"
    fi 

    # Replace map_dbrepos_from_source.properties with one preconfigured for the requested LDAP, if provided
    if [[ -z "${LDAP_TYPE}" ]]; then
        warn "TDI configuration properties were not provided. Manual configuration of map_dbrepos_from_source.properties is required"
    else
        inform "Updating map_dbrepos_from_source.properties..."
        if [[ "${LDAP_TYPE}" == "AD" ]]; then
            curl -L -J -s -S -f "${SETUP_URL}/rsp/map_dbrepos_from_ad.properties" >|"${WORK_DIR}/map_dbrepos_from_source.properties" || downloadFailed=true
        elif [[ "${LDAP_TYPE}" == "DOMINO" ]]; then
            curl -L -J -s -S -f -o "${WORK_DIR}/map_dbrepos_from_domino.properties" >|"${WORK_DIR}/map_dbrepos_from_source.properties" || downloadFailed=true
        elif [[ "${LDAP_TYPE}" == "SDS" ]]; then
            curl -L -J -s -S -f -o "${WORK_DIR}/map_dbrepos_from_sds.properties" >|"${WORK_DIR}/map_dbrepos_from_source.properties" || downloadFailed=true
        elif [[ "${LDAP_TYPE}" == "DSEE" ]]; then
            curl -L -J -s -S -f -o "${WORK_DIR}/map_dbrepos_from_dsee.properties" >|"${WORK_DIR}/map_dbrepos_from_source.properties"  || downloadFailed=true
        else
            warn "Invalid LDAP type ${LDAP_TYPE} provided. Manual configuration of map_dbrepos_from_source.properties is required"
        fi
        if [[ "${downloadFailed}" == "true" ]]; then
            warn "Download of ${SETUP_URL}/rsp/map_dbrepos_from_ad.properties failed. Manual configuration of map_dbrepos_from_source.properties is required"
        fi

    fi
    
}