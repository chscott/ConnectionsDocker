#!/bin/bash

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source prereq scripts
. "${scriptDir}/setup.conf"
. "${scriptDir}/utils.sh"

# Add required groups
printf "I Creating DB2 groups...\n"
groupadd -r "${db2InstanceGroup}"; checkUserGroupStatus ${?} "Unable to create" "${db2InstanceGroup}"
groupadd -r "${db2FencedGroup}"; checkUserGroupStatus ${?} "Unable to create" "${db2FencedGroup}"
groupadd -r "${db2DASGroup}"; checkUserGroupStatus ${?} "Unable to create" "${db2DASGroup}"

# Add required users
printf "I Creating DB2 users...\n"
useradd -r -m -d "${db2DataDir}/${db2InstanceUser}" -g "${db2InstanceGroup}" "${db2InstanceUser}"
checkUserGroupStatus ${?} "Unable to create" "${db2InstanceUser}"
printf "${db2InstanceUser}:${defaultPwd}" | chpasswd
useradd -r -m -d "${db2DataDir}/${db2FencedUser}" -g "${db2FencedGroup}" "${db2FencedUser}"
checkUserGroupStatus ${?} "Unable to create" "${db2FencedUser}"
printf "${db2FencedUser}:${defaultPwd}" | chpasswd
useradd -r -m -d "${db2DataDir}/${db2DASUser}" -g "${db2DASGroup}" "${db2DASUser}"
checkUserGroupStatus ${?} "Unable to create" "${db2DASUser}"
printf "${db2DASUser}:${defaultPwd}" | chpasswd
useradd -r -m -d "${db2DataDir}/lcuser" -g "${db2InstanceGroup}" "lcuser"
checkUserGroupStatus ${?} "Unable to create" "lcuser" 
printf "lcuser:${defaultPwd}" | chpasswd

# Increase open file limit for instance owner group
printf "I Setting open file limits for ${db2InstanceGroup} in /etc/security/limits.conf...\n"
printf "@${db2InstanceGroup}\tsoft\tnofile\t16384" >> "/etc/security/limits.conf"
printf "@${db2InstanceGroup}\thard\tnofile\t65536" >> "/etc/security/limits.conf"

# Create the instance
printf "Beginning creation of DB2 instance...\n"
"${db2InstallDir}/instance/db2icrt" -u "${db2FencedUser}" "${db2InstanceUser}" || { printf "E DB2 instance created failed"; exit 1; }

# Enable Unicode
printf "I Enabling Unicode codepage...\n"
su - "${db2InstanceUser}" -c "\"${db2DataDir}/${db2InstanceUser}/sqllib/adm/db2set\" DB2CODEPAGE=1208 >/dev/null 2>&1" || \
    printf "W Unable to set DB2 codepage\n"

printf "Completed creation of DB2 instance\n"
