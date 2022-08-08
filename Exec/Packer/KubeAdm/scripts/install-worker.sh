#!/bin/bash

###################
###################
## Install kubelet
## REF: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
if [ -f /tmp/debs/kubelet*.deb ]; then
  apt-get update
  apt-get upgrade -y
  apt-get install -y -f /tmp/debs/kubelet*.deb
else
  curl -fsSLo \
    /usr/share/keyrings/kubernetes-archive-keyring.gpg \
    https://packages.cloud.google.com/apt/doc/apt-key.gpg

  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" \
    > /etc/apt/sources.list.d/kubernetes.list

  apt-get update
  apt-get upgrade -y
  apt-get install -y kubelet
fi
apt-mark hold kubelet


