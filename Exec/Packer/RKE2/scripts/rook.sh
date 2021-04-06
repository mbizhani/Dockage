#!/bin/bash

if [ -b /dev/sdb ]; then
  echo "Found Block Device: /dev/sdb"

#  mkdir /dev/ceph
#  ln -s /dev/sdb /dev/ceph/ceph01
fi
