#!/bin/bash

if [[ ! "${SOCKS_PROXY_PORT}" && ! "${HTTP_PROXY_PORT}" ]]; then
  echo "Err: Define 'SOCKS_PROXY_PORT' or 'HTTP_PROXY_PORT' env variable(s)!"
  exit 1
fi

. "./scripts/run-openvpn.sh"

if [ "${SOCKS_PROXY_PORT}" ]; then
  . "./scripts/run-dante.sh"
  DANETE_LOG_FILE='/var/log/danted.log'
fi

if [ "${HTTP_PROXY_PORT}" ]; then
  . "./scripts/run-squid.sh"
  SQUID_LOG_FILE='/var/log/squid/access.log'
fi

sleep 2

if [ "${DEBUG}" == 'Y' ]; then
  multitail /var/log/openvpn.log ${DANETE_LOG_FILE} ${SQUID_LOG_FILE}
else
  echo -e "\n... Press 'ctrl+c' to exit ..."
  sleep infinity
fi
