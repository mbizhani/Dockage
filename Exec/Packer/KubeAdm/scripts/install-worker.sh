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


####################
## Run kubeadm join
if [ "${P_K8S_TOKEN_CA_CERT_HASH}" ]; then
  kubeadm join ${P_K8S_MASTER_IP}:6443 \
    --token ${P_K8S_TOKEN} \
    --discovery-token-ca-cert-hash ${P_K8S_TOKEN_CA_CERT_HASH}
else
  kubeadm join ${P_K8S_MASTER_IP}:6443 \
    --token ${P_K8S_TOKEN} \
    --discovery-token-unsafe-skip-ca-verification
fi


##
# Trying to set the worker node role to worker. However, due to `kubelet` documentation for --node-labels:
#   --node-labels mapStringString
#          <Warning: Alpha feature> Labels to add when registering the node in the cluster.
#          Labels must be key=value pairs separated by ','. Labels in the 'kubernetes.io' namespace
#          must begin with an allowed prefix (kubelet.kubernetes.io, node.kubernetes.io) or be in
#          the specifically allowed set (beta.kubernetes.io/arch, beta.kubernetes.io/instance-type,
#          beta.kubernetes.io/os, failure-domain.beta.kubernetes.io/region, failure-domain.beta.kubernetes.io/zone,
#          kubernetes.io/arch, kubernetes.io/hostname, kubernetes.io/os, node.kubernetes.io/instance-type,
#          topology.kubernetes.io/region, topology.kubernetes.io/zone)
# ISSUE: https://github.com/kubernetes/kubernetes/issues/85073
#cat > /tmp/kubeadm.yml << EOF
#kind: JoinConfiguration
#apiVersion: kubeadm.k8s.io/v1beta3
#discovery:
#  bootstrapToken:
#    apiServerEndpoint: "${P_K8S_MASTER_IP}:6443"
#    token: "${P_K8S_TOKEN}"
#    unsafeSkipCAVerification: true
#  timeout: 5m0s
#nodeRegistration:
#  name: "$(hostname)"
#  taints: []
#  kubeletExtraArgs:
#    node-labels: "node-role.kubernetes.io/worker=worker"
#EOF
#
#kubeadm join --config /tmp/kubeadm.yml
