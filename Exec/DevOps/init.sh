#! /bin/bash

source .env

NEXUS_VOL_DIR="${VOL_BASE_DIR}/nexus"
mkdir -p "${NEXUS_VOL_DIR}"
chown 200:200 "${NEXUS_VOL_DIR}"

docker network create ${EXT_NET} || true
