#!/bin/bash

ip -c a
echo "Hostname: $(hostname)"

if [ "${P_HOST}" ]; then
  hostnamectl --static set-hostname "${P_HOST}"

  if [ "${P_IP}" ]; then
    printf "127.0.0.1\tlocalhost\n\n${P_IP}\t${P_HOST}\n" > /etc/hosts
  fi
fi

## Debian
if [ -f /etc/network/interfaces ]; then
  if [[ "${P_IP}" && "${P_GW}" ]]; then
    sed -i "s|dhcp|static\n  address ${P_IP}/24\n  gateway ${P_GW}|g" /etc/network/interfaces
  fi

  if [ "${P_DNS}" ]; then
    printf "\ndns-nameservers ${P_DNS}\n" >> /etc/network/interfaces

    if [[ "${P_IP}" && -f /etc/resolv.conf && ! -L /etc/resolv.conf ]]; then
      printf "nameserver ${P_DNS}\n" > /etc/resolv.conf
    fi
  fi
fi

if [ "${P_EXTEND}" ]; then
  echo "Extending Partition: ${P_EXTEND}"
  MAP="$(df --output=source ${P_EXTEND}  | sed 1d)"
  VG="$(lvs -o vg_name,lv_path,lv_dmpath --noheadings | grep "${MAP}" | awk '{print $1}')"
  LV="$(lvs -o vg_name,lv_path,lv_dmpath --noheadings | grep "${MAP}" | awk '{print $2}')"
  echo "VG = ${VG}, LV = ${LV}, MAP = ${MAP}"
  B_DEV="$(pvs -a --noheadings | grep -v ${VG} | awk '{print $1}')"
  echo "BLOCK_DEV = ${B_DEV}"
  if [ "${B_DEV}" ]; then
    vgextend ${VG} ${B_DEV}
    lvextend -r -l +100%FREE ${LV}
  fi
fi

