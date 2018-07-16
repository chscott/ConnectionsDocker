#!/bin/bash

scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source prereq files
. "${scriptDir}/setup.conf"

"${scriptDir}/createInstance.sh"
su - "${db2InstanceUser}" -c "db2start"
