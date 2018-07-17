#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_SCRIPT_DIR="${WORK_DIR}/Wizards/connections.sql"
IC_DBS_PACKAGE="$(echo "${IC_DBS_URL}" | awk -F "/" '{print $NF}')"

# Source prereq scripts
. "${WORK_DIR}/setup.conf"
. "${WORK_DIR}/utils.sh"

# Unpack the database creation scripts
inform "Unpacking database creation scripts..."
tar -xf "${IC_DBS_PACKAGE}"
chown -R "${db2InstanceUser}.${db2InstanceGroup}" "${IC_DBS_PACKAGE}"

# Homepage
inform "Creating HOMEPAGE database..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'HOMEPAGE'"; result="${?}"
if [[ "${result}" == 0 ]]; then
    warn "HOMEPAGE database is already created. Skipping"
else
    su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/createDb.sql\" >/dev/null"; result="${?}"
    checkStatusDb "${result}" "Unable to create database: Homepage"
    su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/appGrants.sql\" >/dev/null"; result="${?}" 
    checkStatusDb "${result}" "Unable to grant rights on database: Homepage" 
    su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/initData.sql\" >/dev/null"; result="${?}"
    checkStatusDb "${result}" "Unable to initialize data for database: Homepage"
    su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/reorg.sql\" >/dev/null"; result="${?}"
    checkStatusDb "${result}" "Unable to run reorg on database: Homepage"
    su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/updateStats.sql\" >/dev/null"; result="${?}"
    checkStatusDb "${result}" "Unable to update stats for database: Homepage"
fi

# Files
inform "Creating FILES database..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'FILES'"; result="${?}"
if [[ "${result}" == 0 ]]; then
    warn "FILES database is already created. Skipping"
else
    su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/files/db2/createDb.sql\" >/dev/null"; result="${?}"
    checkStatusDb "${result}" "Unable to create database: Files" 
    su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/files/db2/appGrants.sql\" >/dev/null"; result="${?}" 
    checkStatusDb "${result}" "Unable to grant rights on database: Files" 
fi

# Push Notification
inform "Creating PNS database..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'PNS'"; result="${?}"
if [[ "${result}" == 0 ]]; then
    warn "PNS database is already created. Skipping"
else
    su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/pushnotification/db2/createDb.sql\" >/dev/null"; result="${?}"
    checkStatusDb "${result}" "Unable to create database: Push Notification" 
    su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/pushnotification/db2/appGrants.sql\" >/dev/null"; result="${?}" 
    checkStatusDb "${result}" "Unable to grant rights on database: Push Notification" 
fi

# Activities
inform "Creating database for Activities..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'OPNACT'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "OPNACT database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/activities/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: Activities" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/activities/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: Activities" 
fi

# Blogs
inform "Creating database for Blogs..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'BLOGS'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "BLOGS database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/blogs/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: Blogs" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/blogs/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: Blogs" 
fi

# Bookmarks
inform "Creating database for Bookmarks..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'DOGEAR'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "DOGEAR database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/dogear/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: Bookmarks" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/dogear/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: Bookmarks" 
fi

# Communities
inform "Creating database for Communities..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'SNCOMM'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "SNCOMM database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/communities/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: Communities" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/communities/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: Communities" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/communities/db2/calendar-createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create table: Calendar"
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/communities/db2/calendar-appGrants.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to grant rights on table: Calendar"
fi

# Forums
inform "Creating database for Forum..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'FORUM'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "FORUM database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/forum/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: Forum" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/forum/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: Forum" 
fi

# Metrics
inform "Creating database for Metrics..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'METRICS'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "METRICS database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/metrics/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: Metrics" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/metrics/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: Metrics" 
fi

# Mobile
inform "Creating database for Mobile..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'MOBILE'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "MOBILE database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/mobile/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: Mobile" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/mobile/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: Mobile" 
fi

# Profiles
inform "Creating database for Profiles..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'PEOPLEDB'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "PEOPLEDB database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/profiles/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: Profiles" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/profiles/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: Profiles" 
fi

# Wikis
inform "Creating database for Wikis..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'WIKIS'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "WIKIS database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/wikis/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: Wikis" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/wikis/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: Wikis" 
fi

# CCM - GCD
inform "Creating database for CCM GCD..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'FNGCD'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "FNGCD database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/library.gcd/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: GCD" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/library.gcd/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: GCD" 
fi

# CCM - OS
inform "Creating database for CCM OS..."
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'FNOS'"; result="${?}"
if [[ "${result}" == 0 ]]; then
   warn "FNOS database is already created. Skipping"
else
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/library.os/db2/createDb.sql\" >/dev/null"; result="${?}"
   checkStatusDb "${result}" "Unable to create database: OS" 
   su - "${db2InstanceUser}" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/library.os/db2/appGrants.sql\" >/dev/null"; result="${?}" 
   checkStatusDb "${result}" "Unable to grant rights on database: OS" 
fi