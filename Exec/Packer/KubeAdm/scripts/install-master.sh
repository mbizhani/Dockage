#!/bin/bash

###################
###################
## Install KubeADM
## REF: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
if [ -f /tmp/debs/kubeadm*.deb ]; then
  apt-get update
  apt-get upgrade -y
  apt-get install -y -f /tmp/debs/*.deb
else
  curl -fsSLo \
    /usr/share/keyrings/kubernetes-archive-keyring.gpg \
    https://packages.cloud.google.com/apt/doc/apt-key.gpg

  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" \
    > /etc/apt/sources.list.d/kubernetes.list

  apt-get update
  apt-get upgrade -y
  apt-get install -y kubelet kubeadm kubectl
fi
apt-mark hold kubelet kubeadm kubectl
echo 'source <(kubectl completion bash)' >> $HOME/.bashrc
# RESULT:
# The following NEW packages will be installed:
#   conntrack cri-tools ebtables iptables kubeadm kubectl kubelet kubernetes-cni libip6tc2 libnetfilter-conntrack3 libnfnetlink0 socat

# NOTE:
# The kubelet is now restarting every few seconds, as it waits in a crashloop for kubeadm to tell it what to do.

## Download Images
## => exec: kubeadm config images list
## => Get stable version by "https://dl.k8s.io/release/stable-1.txt"
## => List is
# k8s.gcr.io/kube-apiserver:v1.24.3
# k8s.gcr.io/kube-controller-manager:v1.24.3
# k8s.gcr.io/kube-scheduler:v1.24.3
# k8s.gcr.io/kube-proxy:v1.24.3
# k8s.gcr.io/pause:3.7
# k8s.gcr.io/etcd:3.5.3-0
# k8s.gcr.io/coredns/coredns:v1.8.6

## Run kubeadm init
## REF: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

# TIP: kubeadm config print init-defaults > $HOME/kubeadm-config.yml

kubeadm init \
  --apiserver-advertise-address "${P_IP}" \
  --control-plane-endpoint "${P_IP}" \
  --image-repository "${P_K8S_REGISTRY}" \
  --kubernetes-version "${P_K8S_VER}" \
  --token "${P_K8S_TOKEN}" \
  --pod-network-cidr "${P_K8S_CIDR_POD}" \
  --service-cidr "${P_K8S_CIDR_SERVICE}"

echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> $HOME/.bashrc
export KUBECONFIG=/etc/kubernetes/admin.conf


#######################
## Install CNI (Calico)
## REF: https://kubernetes.io/docs/concepts/cluster-administration/addons/
kubectl apply -f /tmp/calico/tigera-operator.yaml
sleep 5
kubectl apply -f /tmp/calico/tigera-custom-resources.yaml

# TODO: wait for node to be ready!