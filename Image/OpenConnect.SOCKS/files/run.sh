#!/bin/bash

OC_PID_FILE="/run/openconnect.pid"
export OC_PID_FILE

. "./scripts/run-openconnect.sh"

if [ -f "${OC_PID_FILE}" ]; then
  sleep ${SLEEP}

  . "./scripts/run-socks.sh"
fi
