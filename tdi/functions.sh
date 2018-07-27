# Create the solution directory to ${DATA_DIR}
function createSolutionDir() {

    local TDISOL_PACKAGE="$(echo "${TDISOL_URL}" | awk -F "/" '{print $NF}')"
    
    # If the solution directory already exists, just return
    inform "Checking to see if TDI solution directory needs to be created..."
    if [[ -d "${DATA_DIR}/tdisol" ]]; then
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
    tar -xf "${TDISOL_PACKAGE}" --directory "${DATA_DIR}/tdisol" --strip-components=1
    chmod -R u+x "${DATA_DIR}/tdisol/*.sh"
    chmod u+x "${DATA_DIR}/tdisol/netstore"
    
    # Update tdienv.sh with the correct path
    sed -i "s|\(TDIPATH=\).*|\1\"${DATA_DIR}\"|" "${DATA_DIR}/tdisol/tdienv.sh" || { fail "Unable to update tdienv.sh"; return 1; }

}

# Configure the solution directory for Connections
function configSolutionDir() {

    warn "Configuration not yet implemented"

}