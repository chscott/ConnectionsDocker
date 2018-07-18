#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source prereq scripts
. "${WORK_DIR}/setup.conf"
. "${WORK_DIR}/utils.sh"

# Add required groups
inform "Creating DB2 groups..."
groupadd -r "${db2InstanceGroup}" 2>/dev/null || checkUserGroupStatus "${?}" "${db2InstanceGroup}"
groupadd -r "${db2FencedGroup}" 2>/dev/null || checkUserGroupStatus "${?}" "${db2FencedGroup}"
groupadd -r "${db2DASGroup}" 2>/dev/null || checkUserGroupStatus "${?}" "${db2DASGroup}"

# Add required users
inform "Creating DB2 users..."
useradd -r -m -d "${db2DataDir}/${db2InstanceUser}" -g "${db2InstanceGroup}" "${db2InstanceUser}" 2>/dev/null ||
	checkUserGroupStatus "${?}" "${db2InstanceUser}"
printf "${db2InstanceUser}:${defaultPwd}" | chpasswd
useradd -r -m -d "${db2DataDir}/${db2FencedUser}" -g "${db2FencedGroup}" "${db2FencedUser}" 2>/dev/null ||
	checkUserGroupStatus "${?}" "${db2FencedUser}"
printf "${db2FencedUser}:${defaultPwd}" | chpasswd
useradd -r -m -d "${db2DataDir}/${db2DASUser}" -g "${db2DASGroup}" "${db2DASUser}" 2>/dev/null ||
	checkUserGroupStatus "${?}" "${db2DASUser}"
printf "${db2DASUser}:${defaultPwd}" | chpasswd
useradd -r -m -d "${db2DataDir}/lcuser" -g "${db2InstanceGroup}" "lcuser" 2>/dev/null ||
	checkUserGroupStatus "${?}" "lcuser" 
printf "lcuser:${defaultPwd}" | chpasswd

# Increase open file limit for instance owner group
inform "Setting open file limits for ${db2InstanceGroup} in /etc/security/limits.conf..."
printf "@${db2InstanceGroup}\tsoft\tnofile\t16384" >> "/etc/security/limits.conf"
printf "@${db2InstanceGroup}\thard\tnofile\t65536" >> "/etc/security/limits.conf"