function installDB2() {

    local DB2_INSTALL_PACKAGE="$(echo "${DB2_INSTALL_URL}" | awk -F "/" '{print $NF}')"
    local DB2_LICENSE_PACKAGE="$(echo "${DB2_LICENSE_URL}" | awk -F "/" '{print $NF}')"

    inform "Beginning DB2 install..."

    # Download the install packages
    if [[ -z "${DB2_INSTALL_URL}" || -z "${DB2_LICENSE_URL}" ]]; then
        fail "The DB2_INSTALL_URL and DB2_LICENSE_URL environment variables must be specified when running the container"
        return 1
    else
        inform "Downloading ${DB2_INSTALL_URL}..."
        curl -L -O -J -s -S -f "${DB2_INSTALL_URL}" || { fail "Download of ${DB2_INSTALL_URL} failed"; return 1; }
        inform "Downloading ${DB2_LICENSE_URL}..."
        curl -L -O -J -s -S -f "${DB2_LICENSE_URL}" || { fail "Download of ${DB2_LICENSE_URL} failed"; return 1; }
    fi

    # Extract the install files
    inform "Extracting install files..."
    tar -xzf "${DB2_INSTALL_PACKAGE}"
    unzip -qq "${DB2_LICENSE_PACKAGE}"

    # Build the response file
    inform "Building the DB2 silent install file..."
    printf "PROD = DB2_SERVER_EDITION\n" >> "db2_install.rsp"
    printf "LIC_AGREEMENT = ACCEPT\n" >> "db2_install.rsp"
    printf "INSTALL_TYPE = TYPICAL\n" >> "db2_install.rsp"
    printf "FILE = ${APP_DIR}\n" >> "db2_install.rsp"

    # Install DB2
    inform "Performing DB2 install..."
    "server_t/db2setup" -l "db2_install.log" -t "db2_install.trace" -r "db2_install.rsp" >/dev/null 2>&1
    if [[ "${?}" != 0 ]]; then
        fail "DB2 installation failed"
        cat "db2_install.log"
        return 1
    fi

    # Update the pam.d files
    inform "Updating /etc/pam.d files..."
    grep "pam_limits.so" "/etc/pam.d/sshd" >/dev/null 2>&1 || printf "session\trequired\tpam_limits.so\n" >>/etc/pam.d/sshd
    grep "pam_limits.so" "/etc/pam.d/su" >/dev/null 2>&1 || printf "session\trequired\tpam_limits.so\n" >>/etc/pam.d/su
    grep "pam_limits.so" "/etc/pam.d/sudo" >/dev/null 2>&1 || printf "session\trequired\tpam_limits.so\n" >>/etc/pam.d/sudo

    # Validate the install
    inform "Validating DB2 install..."
    "${APP_DIR}/bin/db2val" -a -l "db2val.log" >/dev/null
    grep "DBI1335I" "db2val.log" >/dev/null || { fail "DB2 validation failed"; return 1; }

    # Apply the DB2 license
    inform "Applying DB2 license..."
    "${APP_DIR}/adm/db2licm" -a "aese_u/db2/license/db2aese_u.lic" >/dev/null || { fail "DB2 license installation failed"; return 1; }

    inform "Completed DB2 server install"

}
