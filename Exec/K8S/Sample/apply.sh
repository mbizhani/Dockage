#!/bin/bash

if [ -f "$1" ]; then
  source .env
  declare -A REPLACEMENT=( ["busybox:1.32"]="${BUSYBOX_IMG}" ["nginx:1.18.0"]="${NGINX_IMG}" )

  FILE="$(cat "$1")"
  for KEY in "${!REPLACEMENT[@]}"; do
    FILE="${FILE//${KEY}/${REPLACEMENT[${KEY}]}}"
  done

  echo "$FILE" | kubectl apply -f -
fi