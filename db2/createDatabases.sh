#!/bin/bash

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
icDbScriptDir="${scriptDir}/db2/Wizards/connections.sql"

# Source prereq scripts
. "${scriptDir}/setup.conf"
. "${scriptDir}/utils.sh"

# Unpack the database creation scripts
printf "I Unpacking database creation scripts...\n"
tar -xf "${FTP_FILE}"
chown -R "${db2InstanceUser}.${db2InstanceGroup}" "${FTP_FILE}"

# Create the Core databases (these are mandatory since Core is mandatory)
printf "I Creating databases for Core...\n"
# Homepage
su - "${db2InstanceUser}" -c "db2 list database directory | grep 'Database name' | grep 'HOMEPAGE'"; result="${?}"
if [[ "${result}" == 0 ]]; then
    printf "W HOMEPAGE database is already created. Skipping\n"
else
    su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/createDb.sql"; result="${?}"
    checkStatusDb "${result}" "E Unable to create database: Homepage. Exiting"
    su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/appGrants.sql"; result="${?}" 
    checkStatusDb "${result}" "E Unable to grant rights on database: Homepage. Exiting." 
    su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/initData.sql"; result="${?}"
    checkStatusDb "${result}" "E Unable to initialize data for database: Homepage. Exiting."
    su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/reorg.sql"; result="${?}"
    checkStatusDb "${result}" "E Unable to run reorg on database: Homepage. Exiting."
    su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/homepage/db2/updateStats.sql"; result="${?}"
    checkStatusDb "${result}" "E Unable to update stats for database: Homepage. Exiting."
fi
# Files
su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'FILES'"; result="${?}"
if [[ "${result}" || 0 ]]; then
    printf "W FILES database is already created. Skipping\n"
else
    su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/files/db2/createDb.sql"; result="${?}"
    checkStatusDb "${result}" "E Unable to create database: Files. Exiting." 
    su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/files/db2/appGrants.sql"; result="${?}" 
    checkStatusDb "${result}" "E Unable to grant rights on database: Files. Exiting." 
fi
# Push Notification
su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'PNS'"; result="${?}"
if [[ "${result}" || 0 ]]; then
    printf "W PNS database is already created. Skipping\n"
else
    su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/pushnotification/db2/createDb.sql"; result="${?}"
    checkStatusDb "${result}" "E Unable to create database: Push Notification. Exiting." 
    su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/pushnotification/db2/appGrants.sql"; result="${?}" 
    checkStatusDb "${result}" "E Unable to grant rights on database: Push Notification. Exiting." 
fi

# Create the Activities database
if [[ "${installIcActivities}" == "true" ]]; then
    printf "I Creating database for Activities...\n"
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'OPNACT'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W OPNACT database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/activities/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: Activities. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/activities/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: Activities. Exiting." 
    fi
else
    printf "I Will not create database for Activities since it is not being installed\n"
fi

# Create the Blogs database
if [[ "${installIcBlogs}" == "true" ]]; then
    printf "I Creating database for Blogs...\n"
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'BLOGS'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W BLOGS database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/blogs/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: Blogs. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/blogs/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: Blogs. Exiting." 
    fi
else
    printf "I Will not create database for Blogs since it is not being installed\n"
fi

# Create the Bookmarks database
if [[ "${installIcBookmarks}" == "true" ]]; then
    printf "I Creating database for Bookmarks...\n"
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'DOGEAR'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W DOGEAR database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/dogear/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: Bookmarks. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/dogear/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: Bookmarks. Exiting." 
    fi
else
    printf "I Will not create database for Bookmarks since it is not being installed\n"
fi

# Create the Communities database
if [[ "${installIcCommunities}" == "true" ]]; then
    printf "I Creating database for Communities...\n"
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'SNCOMM'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W SNCOMM database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: Communities. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: Communities. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/calendar-createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create table: Calendar. Exiting."
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/communities/db2/calendar-appGrants.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to grant rights on table: Calendar. Exiting."
    fi
else
    printf "I Will not create database for Communities since it is not being installed\n"
fi

# Create the Forum database
if [[ "${installIcForum}" == "true" ]]; then
    printf "I Creating database for Forum...\n"
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'FORUM'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W FORUM database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/forum/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: Forum. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/forum/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: Forum. Exiting." 
    fi
else
    printf "I Will not create database for Forum since it is not being installed\n"
fi

# Create the Metrics database
if [[ "${installIcMetrics}" == "true" ]]; then
    printf "I Creating database for Metrics...\n"
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'METRICS'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W METRICS database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/metrics/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: Metrics. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/metrics/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: Metrics. Exiting." 
    fi
else
    printf "I Will not create database for Metrics since it is not being installed\n"
fi

# Create the Mobile database
if [[ "${installIcMobile}" == "true" ]]; then
    printf "I Creating database for Mobile...\n"
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'MOBILE'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W MOBILE database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/mobile/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: Mobile. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/mobile/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: Mobile. Exiting." 
    fi
else
    printf "I Will not create database for Mobile since it is not being installed\n"
fi

# Create the Profiles database
if [[ "${installIcProfiles}" == "true" ]]; then
    printf "I Creating database for Profiles...\n"
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'PEOPLEDB'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W PEOPLEDB database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/profiles/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: Profiles. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/profiles/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: Profiles. Exiting." 
    fi
else
    printf "I Will not create database for Profiles since it is not being installed\n"
fi

# Create the Wikis database
if [[ "${installIcWikis}" == "true" ]]; then
    printf "I Creating database for Wikis...\n"
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'WIKIS'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W WIKIS database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/wikis/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: Wikis. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/wikis/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: Wikis. Exiting." 
    fi
else
    printf "I Will not create database for Wikis since it is not being installed\n"
fi

# Create the CCM databases
if [[ "${installIcCCM}" == "true" ]]; then
    printf "I Creating databases for CCM...\n"
    # GCD
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'FNGCD'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W FNGCD database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/library.gcd/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: GCD. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/library.gcd/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: GCD. Exiting." 
    fi
    # OS
    su - "${db2InstanceUser}" -c "db2 list database directory | ${grep} 'Database name' | ${grep} 'FNOS'"; result="${?}"
    if [[ "${result}" || 0 ]]; then
        printf "W FNOS database is already created. Skipping\n"
    else
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/library.os/db2/createDb.sql"; result="${?}"
        checkStatusDb "${result}" "E Unable to create database: OS. Exiting." 
        su - "${db2InstanceUser}" -c "db2 -td@ -sf ${icDbScriptDir}/library.os/db2/appGrants.sql"; result="${?}" 
        checkStatusDb "${result}" "E Unable to grant rights on database: OS. Exiting." 
    fi
else
    printf "I Will not create databases for CCM since it is not being installed\n"
fi