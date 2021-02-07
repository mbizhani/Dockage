#!/bin/bash

# NOTE: on symlink, the 'dirname' must be replaced with full name
source $(dirname "$0")/.env

find "${VOL_BASE_DIR}"/nexus/BACK_UP_DB -type f -mtime +2 -exec rm {} \;