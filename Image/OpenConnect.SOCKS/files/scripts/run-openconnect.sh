#!/bin/bash

echo '***********************************'
echo '******** Start OpenConnect ********'
echo '***********************************'

if [ "${VPN_CERT}" ]; then
  echo "${VPN_PASS}" | openconnect -b \
    -u "${VPN_USER}" \
    --servercert "${VPN_CERT}" \
    --passwd-on-stdin \
    --protocol=${VPN_PROTO} \
    --pid-file=${OC_PID_FILE} \
    --non-inter \
    "${VPN_HOST}"
else
  openconnect --non-inter "${VPN_HOST}" 2> test.txt
  SRV_CERT="$(cat test.txt | grep '\-\-servercert')"
  echo ">>> Found Server Cert = ${SRV_CERT}"
  rm -f test.txt

  if [ "${SRV_CERT}" ]; then
    echo "${VPN_PASS}" | openconnect -b \
      -u "${VPN_USER}" \
      ${SRV_CERT} \
      --passwd-on-stdin \
      --protocol=${VPN_PROTO} \
      --pid-file=${OC_PID_FILE} \
      --non-inter \
      "${VPN_HOST}"
  else
    echo "${VPN_PASS}" | openconnect -b \
      -u "${VPN_USER}" \
      ${SRV_CERT} \
      --passwd-on-stdin \
      --protocol=${VPN_PROTO} \
      --pid-file=${OC_PID_FILE} \
      --non-inter \
      "${VPN_HOST}"
  fi
fi

echo "OpenConnect PID = $(cat ${OC_PID_FILE})"
