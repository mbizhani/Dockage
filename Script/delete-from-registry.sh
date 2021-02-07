#!/bin/bash

# HELP
# https://github.com/docker/distribution/issues/1579 (***)
# https://github.com/byrnedo/docker-reg-tool/blob/master/docker_reg_tool

REG_URL="http://localhost"
REG_IMAGE="registry:2.7.1"

function gcReg() {
  REG_CONTAINER=$(docker ps -q --filter ancestor=${REG_IMAGE})
  docker exec ${REG_CONTAINER} registry garbage-collect /etc/docker/registry/config.yml
}

if [[ "$1" && "$2" ]]; then
  IMAGE="$1"
  TAG="$2"

  DIGEST=$(
    curl -s -i -H "Accept: application/vnd.docker.distribution.manifest.v2+json" "${REG_URL}/v2/${IMAGE}/manifests/${TAG}" \
    | grep "Docker-Content-Digest:" \
    | awk '{print $2}')

  DIGEST=${DIGEST//[$'\t\r\n']}

  if [ "$DIGEST" ]; then
    echo "DIGEST = ${DIGEST}"

    curl -X DELETE "${REG_URL}/v2/${IMAGE}/manifests/${DIGEST}"

    gcReg
  else
    gcReg

    echo "ERROR: Image Not Found"
  fi
else
  gcReg

  echo "ERROR: $0 IMAGE TAG"
fi


