#!/bin/bash

echo '*******************************'
echo '******** Start OpenVPN ********'
echo '*******************************'

if [[ ! "${OVPN_CFG}" || ! "${OVPN_RLM}" ]]; then
  echo -e "\nErr: Define both 'OVPN_CFG' and 'OVPN_RLM' env variables!"
  exit 1
fi

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
  mknod /dev/net/tun c 10 200
fi

/usr/sbin/openvpn \
  --daemon openvpn \
  --log /var/log/openvpn.log \
  --config ${OVPN_CFG_DIR}/${OVPN_CFG} \
  --auth-user-pass ${OVPN_CFG_DIR}/${OVPN_RLM}

echo "'openvpn' started"

i=5
while [[ ! "${TUN0_ADDR}" && $i -gt 0 ]]
do
  echo "Waiting for connection ('tun0' device) ($i) ..."
  sleep 2
  TUN0_ADDR=$(ip a show tun0 | grep "inet " | awk '{ print $2 }' | awk -F '/' '{print $1}')
  i=$(( $i - 1 ))
done

if [ "${TUN0_ADDR}" ]; then
  echo "TUN0 = ${TUN0_ADDR}"
else
  echo -e "\n********** Error - OpenVPN Output Log **********\n"
  cat /var/log/openvpn.log
  exit 1
fi