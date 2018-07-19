#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DB_SCRIPT_DIR="${WORK_DIR}/Wizards/connections.sql"
IC_DBWIZARD_PACKAGE="$(echo "${IC_DBWIZARD_URL}" | awk -F "/" '{print $NF}')"

# Source prereq scripts
. "${WORK_DIR}/utils.sh"

# Unpack the database creation scripts
inform "Unpacking database creation scripts..."
tar -xf "${IC_DBWIZARD_PACKAGE}"
chown -R "db2inst1.db2iadm1" "${IC_DBWIZARD_PACKAGE}"

# Homepage
inform "Creating HOMEPAGE database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'HOMEPAGE'")
if [[ "${count}" > 0 ]]; then
    warn "HOMEPAGE database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Homepage"
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/appGrants.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to grant rights on database: Homepage" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/initData.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to initialize data for database: Homepage"
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/reorg.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to run reorg on database: Homepage"
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/homepage/db2/updateStats.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to update stats for database: Homepage"
fi

# Files
inform "Creating FILES database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'FILES'")
if [[ "${count}" > 0 ]]; then
    warn "FILES database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/files/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Files" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/files/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Files" 
fi

# Push Notification
inform "Creating PNS database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'PNS'")
if [[ "${count}" > 0 ]]; then
    warn "PNS database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/pushnotification/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Push Notification" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/pushnotification/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Push Notification" 
fi

# Activities
inform "Creating OPNACT database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'OPNACT'")
if [[ "${count}" > 0 ]]; then
    warn "OPNACT database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/activities/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Activities" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/activities/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Activities" 
fi

# Blogs
inform "Creating BLOGS database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'BLOGS'")
if [[ "${count}" > 0 ]]; then
    warn "BLOGS database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/blogs/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Blogs" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/blogs/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Blogs" 
fi

# Bookmarks
inform "Creating DOGEAR database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'DOGEAR'")
if [[ "${count}" > 0 ]]; then
    warn "DOGEAR database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/dogear/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Bookmarks" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/dogear/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Bookmarks" 
fi

# Communities
inform "Creating SNCOMM database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'SNCOMM'")
if [[ "${count}" > 0 ]]; then
    warn "SNCOMM database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/communities/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Communities" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/communities/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Communities" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/communities/db2/calendar-createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create table: Calendar"
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/communities/db2/calendar-appGrants.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to grant rights on table: Calendar"
fi

# Forums
inform "Creating FORUM database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'FORUM'")
if [[ "${count}" > 0 ]]; then
    warn "FORUM database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/forum/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Forum" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/forum/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Forum" 
fi

# Metrics
inform "Creating METRICS database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'METRICS'")
if [[ "${count}" > 0 ]]; then
    warn "METRICS database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/metrics/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Metrics" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/metrics/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Metrics" 
fi

# Mobile
inform "Creating MOBILE database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'MOBILE'")
if [[ "${count}" > 0 ]]; then
    warn "MOBILE database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/mobile/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Mobile" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/mobile/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Mobile" 
fi

# Profiles
inform "Creating PEOPLEDB database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'PEOPLEDB'")
if [[ "${count}" > 0 ]]; then
    warn "PEOPLEDB database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/profiles/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Profiles" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/profiles/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Profiles" 
fi

# Wikis
inform "Creating WIKIS database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'WIKIS'")
if [[ "${count}" > 0 ]]; then
    warn "WIKIS database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/wikis/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: Wikis" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/wikis/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: Wikis" 
fi

# CCM - GCD
inform "Creating FNGCD database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'FNGCD'")
if [[ "${count}" > 0 ]]; then
    warn "FNGCD database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/library.gcd/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: GCD" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/library.gcd/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: GCD" 
fi

# CCM - OS
inform "Creating FNOS database..."
count=$(su - "db2inst1" -c "db2 list database directory | grep 'Database name' | grep -c 'FNOS'")
if [[ "${count}" > 0 ]]; then
    warn "FNOS database is already created. Skipping"
else
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/library.os/db2/createDb.sql\" >/dev/null"
    checkStatusDb "${?}" "Unable to create database: OS" 
    su - "db2inst1" -c "db2 -td@ -sf \"${DB_SCRIPT_DIR}/library.os/db2/appGrants.sql\" >/dev/null" 
    checkStatusDb "${?}" "Unable to grant rights on database: OS" 
fi