#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB2_INSTALL_PACKAGE="$(echo "${DB2_INSTALL_URL}" | awk -F "/" '{print $NF}')"
DB2_LICENSE_PACKAGE="$(echo "${DB2_LICENSE_URL}" | awk -F "/" '{print $NF}')"

# Source prereq scripts
. "${WORK_DIR}/setup.conf"
. "${WORK_DIR}/utils.sh"

# Exit if DB2 has already been installed
if [[ -f "${db2InstallDir}/logs/db2install.history" ]]; then
    inform "DB2 has already been installed. Exiting"
    exit 0
fi

inform "Beginning installation of DB2 server..."

# Extract the product install files
inform "Extracting product install files..."
tar -xzf "${DB2_INSTALL_PACKAGE}"
unzip -qq "${DB2_LICENSE_PACKAGE}"

# Build the response file
inform "Building the DB2 silent install file..."
printf "PROD = DB2_SERVER_EDITION\n" >> "db2_install.rsp"
printf "LIC_AGREEMENT = ACCEPT\n" >> "db2_install.rsp"
printf "INSTALL_TYPE = TYPICAL\n" >> "db2_install.rsp"
printf "FILE = ${db2InstallDir}\n" >> "db2_install.rsp"

# Install DB2
inform "Performing DB2 install..."
"server_t/db2setup" \
    -l "db2_install.log" \
    -t "db2_install.trace" \
    -r "db2_install.rsp" || \
    { fail "DB2 installation failed"; cat "db2_install.log"; exit 1; }

# Update the pam.d files
inform "Updating /etc/pam.d files..."
grep "pam_limits.so" "/etc/pam.d/sshd" >/dev/null 2>&1 || printf "session\trequired\tpam_limits.so\n" >>/etc/pam.d/sshd
grep "pam_limits.so" "/etc/pam.d/su" >/dev/null 2>&1 || printf "session\trequired\tpam_limits.so\n" >>/etc/pam.d/su
grep "pam_limits.so" "/etc/pam.d/sudo" >/dev/null 2>&1 || printf "session\trequired\tpam_limits.so\n" >>/etc/pam.d/sudo

# Validate the install
inform "Validating DB2 install..."
"${db2InstallDir}/bin/db2val" -a -l "db2val.log"
grep "DBI1335I" "db2val.log" || { fail "DB2 validation failed"; exit 1; }

# Apply the DB2 license
inform "Applying DB2 license..."
"${db2InstallDir}/adm/db2licm" -a "aese_u/db2/license/db2aese_u.lic" || { fail "DB2 license installation failed"; exit 1; }

inform "Completed installation of DB2 server..."
