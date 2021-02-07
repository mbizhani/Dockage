#!/bin/bash

NOW=$(date +'%Y-%m-%d_%H-%M-%S')

# NOTE: on symlink, the 'dirname' must be replaced with full name
source $(dirname "$0")/.env

CFG_BACKUP_DIR="${VOL_BASE_DIR}"/gitlab/CONFIG_BACKUP
CONTAINER_ID=$(docker ps -q -f ancestor=gitlab/gitlab-ce:"${GITLAB_VER}")

if [ "${CONTAINER_ID}" ]; then
  docker exec -t "${CONTAINER_ID}" gitlab-backup create > "${VOL_BASE_DIR}/gitlab/backup.log"
fi

mkdir -p "${CFG_BACKUP_DIR}"
tar cvfz "${CFG_BACKUP_DIR}/config_${NOW}.tgz" -C "${VOL_BASE_DIR}/gitlab" config
find "${CFG_BACKUP_DIR}" -type f -mtime +4 -exec rm {} \;