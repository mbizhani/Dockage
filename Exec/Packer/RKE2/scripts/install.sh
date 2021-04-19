#!/bin/bash

## Install Registry CERT Files
mv ${P_FILE_BASE}/*.crt /usr/local/share/ca-certificates
update-ca-certificates

## Install RKE2 Files
if [ ! -f "${P_FILE_BASE}/rke2.linux-amd64.tar.gz" ]; then
  echo "File Not Found: ${P_FILE_BASE}/rke2.linux-amd64.tar.gz"
  exit 1
fi
tar xvfz ${P_FILE_BASE}/rke2.linux-amd64.tar.gz -C /usr/local

## CIS Hardening
cp -f /usr/local/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
systemctl restart systemd-sysctl


## Rancher Base Config Directory
mkdir -p /etc/rancher/rke2

## Config Files
printf "${P_REGISTRY}" > /etc/rancher/rke2/registries.yaml
printf "${P_CONFIG}"   > /etc/rancher/rke2/config.yaml

## CIS Hardening
if [ "${P_IS_SERVER}" == "true" ]; then
  echo "Creating etcd user"
  useradd -r -c "etcd user" -s /sbin/nologin -M etcd
fi

## Installed Files
RKE2_HOME="/var/lib/rancher/rke2"
ln -s ${RKE2_HOME}/bin/kubectl /usr/local/bin/kubectl
ln -s ${RKE2_HOME}/bin/ctr     /usr/local/bin/ctr

RKE2_CMD=$(cat << 'EOF'

# Added by Packer
alias ctr='ctr -a /run/k3s/containerd/containerd.sock --namespace k8s.io'
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
if [ -f "/usr/local/bin/kubectl" ]; then
  source <(kubectl completion bash)
fi
EOF
)
echo "${RKE2_CMD}" >> /root/.bashrc
[ -f "/home/packer/.bashrc" ] && echo "${RKE2_CMD}" >> /home/packer/.bashrc

cat > /root/install-rke2.sh << 'EOF'
systemctl enable rke2-server.service
systemctl start  rke2-server.service
journalctl -u rke2-server -f
EOF
chmod 700 /root/install-rke2.sh
