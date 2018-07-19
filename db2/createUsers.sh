#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source prereq scripts
. "${WORK_DIR}/utils.sh"

# Add required groups
inform "Creating DB2 groups..."
groupadd -r "db2iadm1" 2>/dev/null || checkUserGroupStatus "${?}" "db2iadm1"
groupadd -r "db2fsdm1" 2>/dev/null || checkUserGroupStatus "${?}" "db2fsdm1"
groupadd -r "dasadm1" 2>/dev/null || checkUserGroupStatus "${?}" "dasadm1"

# Add required users
inform "Creating DB2 users..."
useradd -r -m -d "/data/db2inst1" -g "db2iadm1" "db2inst1" 2>/dev/null || checkUserGroupStatus "${?}" "db2inst1"
printf "db2inst1:password" | chpasswd
useradd -r -m -d "/data/db2fenc1" -g "db2fsdm1" "db2fenc1" 2>/dev/null || checkUserGroupStatus "${?}" "db2fenc1"
printf "db2fenc1:password" | chpasswd
useradd -r -m -d "/data/dasusr1" -g "dasadm1" "dasusr1" 2>/dev/null || checkUserGroupStatus "${?}" "dasusr1"
printf "dasusr1:password" | chpasswd
useradd -r -m -d "/data/lcuser" -g "db2inst1" "lcuser" 2>/dev/null || checkUserGroupStatus "${?}" "lcuser" 
printf "lcuser:password" | chpasswd

# Increase open file limit for instance owner group
inform "Setting open file limits for db2iadm1 in /etc/security/limits.conf..."
printf "@db2iadm1\tsoft\tnofile\t16384\n" >> "/etc/security/limits.conf"
printf "@db2iadm1\thard\tnofile\t65536\n" >> "/etc/security/limits.conf"