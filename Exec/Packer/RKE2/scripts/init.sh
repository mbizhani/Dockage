#!/bin/bash

ip -c a
echo "Hostname: $(hostname)"

if [[ "${P_IP}" && "${P_GW}" ]]; then
  sed -i "s|dhcp|static\n  address ${P_IP}/24\n  gateway ${P_GW}|g" /etc/network/interfaces

#  NIC="$(ip a | awk '/inet.*brd/{print $NF; exit}')"
#  cat > /etc/network/interfaces.d/packer << EOF
#iface ${NIC} inet static
#  address ${P_IP}/24
#  gateway ${P_GW}
#EOF
fi

if [ "${P_HOST}" ]; then
  hostnamectl --static set-hostname "${P_HOST}"

  if [ "${P_IP}" ]; then
    printf "127.0.0.1\tlocalhost\n\n${P_IP}\t${P_HOST}\n" > /etc/hosts
  fi
fi

if [ "${P_DNS}" ]; then
  printf "nameserver ${P_DNS}\n" > /etc/resolv.conf
#  printf "nameserver ${P_DNS}\n" > /root/resolv.conf
fi

#reboot
