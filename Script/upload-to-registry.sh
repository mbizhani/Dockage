#!/bin/bash

PULL_SERVER=""
PUSH_SERVER="${PULL_SERVER}"
PUSH_SERVER_USER=
PUSH_SERVER_PASS=

if [ "$1" ]; then
  if [ "$PUSH_SERVER_USER" ]; then
    docker login -u "$PUSH_SERVER_USER" -p "$PUSH_SERVER_PASS" "$PUSH_SERVER"
  fi

  SEARCH=$1

  docker images | grep -E "^$SEARCH" | awk '{print "docker tag "$1":"$2" '$PUSH_SERVER'/"$1":"$2}' | bash

  docker images | grep -E "^$SEARCH" | awk '{print "docker push '$PUSH_SERVER'/"$1":"$2}' | bash

  if [ "$?" == "0" ]; then

    PULL_IMAGES=$(docker images | grep -E "^$SEARCH" | awk '{print "docker pull '$PULL_SERVER'/"$1":"$2}')

    docker images | grep -E "^$SEARCH" | awk '{print "docker rmi '$PUSH_SERVER'/"$1":"$2}' | bash

    docker images | grep -E "^$SEARCH" | awk '{print "docker rmi "$1":"$2}' | bash

    read -p "Pull tagged images (y)? "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "$PULL_IMAGES" | bash
    else
      echo "$PULL_IMAGES"
    fi
  else
    echo "Can't Push!!!"
    exit 1
  fi
fi