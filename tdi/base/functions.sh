function installTDI() {

    local TDI_INSTALL_PACKAGE="$(echo "${TDI_INSTALL_URL}" | awk -F "/" '{print $NF}')"
    local TDI_FIXPACK_PACKAGE="$(echo "${TDI_FIXPACK_URL}" | awk -F "/" '{print $NF}')"
    local DB2_JCC_JAR="$(echo "${DB2_JCC_URL}" | awk -F "/" '{print $NF}')"
    local DB2_JCCLICENSE_JAR="$(echo "${DB2_JCCLICENSE_URL}" | awk -F "/" '{print $NF}')"

    inform "Beginning TDI install..."

    # Download the install packages
    if [[ -z "${TDI_INSTALL_URL}" || -z "${TDI_FIXPACK_URL}" || -z "${DB2_JCC_URL}" || -z "${DB2_JCCLICENSE_URL}" ]]; then
        fail "The following environment variables must be specified when running the container: TDI_INSTALL_URL, TDI_FIXPACK_URL, DB2_JCC_URL and DB2_JCCLICENSE_URL"
        return 1
    else
        inform "Downloading ${TDI_INSTALL_URL}..."
        curl -L -O -J -s -S -f "${TDI_INSTALL_URL}" || { fail "Download of ${TDI_INSTALL_URL} failed"; return 1; }
        inform "Downloading ${TDI_FIXPACK_URL}..."
        curl -L -O -J -s -S -f "${TDI_FIXPACK_URL}" || { fail "Download of ${TDI_FIXPACK_URL} failed"; return 1; }
        inform "Downloading ${DB2_JCC_URL}..."
        curl -L -O -J -s -S -f "${DB2_JCC_URL}" || { fail "Download of ${DB2_JCC_URL} failed"; return 1; }
        inform "Downloading ${DB2_JCCLICENSE_URL}..."
        curl -L -O -J -s -S -f "${DB2_JCCLICENSE_URL}" || { fail "Download of ${DB2_JCCLICENSE_URL} failed"; return 1; }
    fi

    # Extract the install files
    inform "Extracting install files..."
    tar -xf "${TDI_INSTALL_PACKAGE}"
    unzip -qq "${TDI_FIXPACK_PACKAGE}"

    # Build the response file
    inform "Building the TDI silent install file..."
    printf "TDI_UPGRADEPREV=false\n" >> "tdi_install.rsp"
    printf "LICENSE_ACCEPTED=true\n" >> "tdi_install.rsp"
    printf "USER_INSTALL_DIR=${APP_DIR}\n" >> "tdi_install.rsp"
    printf "CHOSEN_INSTALL_SET=Custom\n" >> "tdi_install.rsp"
    printf "CHOSEN_INSTALL_FEATURE_LIST=Server\n" >> "tdi_install.rsp"
    printf "TDI_SOLDIR_HOME=0\n" >> "tdi_install.rsp"
    printf "TDI_SOLDIR_INSTALL=0\n" >> "tdi_install.rsp"
    printf "TDI_SOLDIR_SELECT=0\n" >> "tdi_install.rsp"
    printf "TDI_SELECTED_SOLDIR=${DATA_DIR}\n" >> "tdi_install.rsp"
    printf "TDI_SOLDIR_CWD=1\n" >> "tdi_install.rsp"
    printf "TDI_SERVER_PORT=1099\n" >> "tdi_install.rsp"
    printf "TDI_SYSTEM_STORE_PORT=1527\n" >> "tdi_install.rsp"
    printf "TDI_REST_API_PORT=1098\n" >> "tdi_install.rsp"
    printf "TDI_MQE_SYSTEMQ_PORT=61616\n" >> "tdi_install.rsp"
    printf "TDI_SERVER_SERVICENAME=tdi\n" >> "tdi_install.rsp"
    printf "TDI_HTTP_PORT=13100\n" >> "tdi_install.rsp"
    printf "TDI_HTTPS_PORT=13101\n" >> "tdi_install.rsp"
    printf "TDI_AM_API_PORT=13104\n" >> "tdi_install.rsp"

    # Install TDI base
    inform "Performing TDI install..."
    # "Command Line Arguments contain illegal values" error if you don't change to the binary directory first
    cd "linux_x86_64"
    ./"$(ls .)" -f "${WORK_DIR}/tdi_install.rsp" -i silent -D\$TDI_NOSHORTCUTS\$="true" >"${WORK_DIR}/tdi_install.log" 2>&1
    if [[ "${?}" != 0 ]]; then
        fail "TDI installation failed"
        return 1
    fi
    # Return to the work directory
    cd "${WORK_DIR}"

    # Install TDI fixpack
    inform "Performing TDI fixpack install..."
    local TDI_FIXPACK_DIR="$(echo "${TDI_FIXPACK_PACKAGE}" | awk -F ".zip" '{print $1}')"
    local TDI_FIXPACK_FILE="$(echo "${TDI_FIXPACK_PACKAGE}" | awk -F "-" '{print $3"-"$1"-"$4}')"
    cp -f "${TDI_FIXPACK_DIR}/UpdateInstaller.jar" "${APP_DIR}/maintenance"
    "${APP_DIR}/bin/applyUpdates.sh" -update "${TDI_FIXPACK_DIR}/${TDI_FIXPACK_FILE}" >"${WORK_DIR}/tdi_fixpack_install.log" 2>&1
    if [[ "${?}" != 0 ]]; then
        fail "TDI fixpack installation failed"
        return 1
    fi
    
    # Copy the database JAR files
    inform "Copying DB2 JAR files to TDI..."
    cp -f "${DB2_JCC_JAR}" "${APP_DIR}/jvm/jre/lib/ext"
    cp -f "${DB2_JCCLICENSE_JAR}" "${APP_DIR}/jvm/jre/lib/ext"
    
    # Update ibmdisrv Java heap size
    inform "Updating Java heap size for ibmdisrv..."
    sed -i 's|\(\"$TDI_JAVA_PROGRAM\"\)|\1 -Xms1024M -Xmx2048M|' "${APP_DIR}/ibmdisrv"

    inform "Completed TDI server install"

}
