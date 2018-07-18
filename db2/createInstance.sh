#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source prereq scripts
. "${WORK_DIR}/setup.conf"
. "${WORK_DIR}/utils.sh"

# Create the instance if it doesn't already exist
if [[ ! -d "${db2DataDir}/${db2InstanceUser}/${db2InstanceUser}" ]]; then
	inform "Beginning creation of DB2 instance..."
	"${db2InstallDir}/instance/db2icrt" -u "${db2FencedUser}" "${db2InstanceUser}" || { fail "DB2 instance creation failed"; exit 1; }
else
	warn "DB2 instance already exists at ${db2DataDir}/${db2InstanceUser}/${db2InstanceUser}. Skipping"
fi

# Create a new db2nodes.cfg file (needed because the image ID is there currently and will cause SQL6031N)
printf "0 %s\n" "$(hostname)" >|"${db2DataDir}/${db2InstanceUser}/sqllib/db2nodes.cfg"

# Update the /etc/services file to include the port mapping for the instance (also to prevent SQL6031N)
printf "%s\t%s\t\t%s\n" "DB2_${db2InstanceUser}" "50000/tcp" "# DB2 instance" >>"/etc/services"

# Start the DB2 instance
inform "Starting DB2 instance..."
su - "${db2InstanceUser}" -c "db2start"

# Enable Unicode
inform "Enabling Unicode codepage..."
su - "${db2InstanceUser}" -c "\"${db2DataDir}/${db2InstanceUser}/sqllib/adm/db2set\" DB2CODEPAGE=1208 >/dev/null 2>&1" || \
    warn "Unable to set DB2 codepage"

inform "Completed creation of DB2 instance"
