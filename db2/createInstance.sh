#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source prereq scripts
. "${WORK_DIR}/setup.conf"
. "${WORK_DIR}/utils.sh"

# Add required groups
inform "Creating DB2 groups..."
groupadd -r "${db2InstanceGroup}"; checkUserGroupStatus "${?}" "${db2InstanceGroup}"
groupadd -r "${db2FencedGroup}"; checkUserGroupStatus "${?}" "${db2FencedGroup}"
groupadd -r "${db2DASGroup}"; checkUserGroupStatus "${?}" "${db2DASGroup}"

# Add required users
inform "Creating DB2 users..."
useradd -r -m -d "${db2DataDir}/${db2InstanceUser}" -g "${db2InstanceGroup}" "${db2InstanceUser}"
checkUserGroupStatus "${?}" "${db2InstanceUser}"
printf "${db2InstanceUser}:${defaultPwd}" | chpasswd
useradd -r -m -d "${db2DataDir}/${db2FencedUser}" -g "${db2FencedGroup}" "${db2FencedUser}"
checkUserGroupStatus "${?}" "${db2FencedUser}"
printf "${db2FencedUser}:${defaultPwd}" | chpasswd
useradd -r -m -d "${db2DataDir}/${db2DASUser}" -g "${db2DASGroup}" "${db2DASUser}"
checkUserGroupStatus "${?}" "${db2DASUser}"
printf "${db2DASUser}:${defaultPwd}" | chpasswd
useradd -r -m -d "${db2DataDir}/lcuser" -g "${db2InstanceGroup}" "lcuser"
checkUserGroupStatus "${?}" "lcuser" 
printf "lcuser:${defaultPwd}" | chpasswd

# Increase open file limit for instance owner group
inform "Setting open file limits for ${db2InstanceGroup} in /etc/security/limits.conf..."
printf "@${db2InstanceGroup}\tsoft\tnofile\t16384" >> "/etc/security/limits.conf"
printf "@${db2InstanceGroup}\thard\tnofile\t65536" >> "/etc/security/limits.conf"

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
