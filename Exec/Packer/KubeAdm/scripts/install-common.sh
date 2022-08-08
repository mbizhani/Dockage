#!/bin/bash

##################
## Initialization
## REF: https://kubernetes.io/docs/setup/production-environment/container-runtimes/
cat > /etc/modules-load.d/k8s.conf << EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

######################
######################
## Install ContainerD
## REF: https://github.com/containerd/containerd/blob/main/docs/getting-started.md
tar xvfz /tmp/containerd/containerd.tar.gz -C /usr/local/
tar xvfz /tmp/containerd/crictl.tar.gz -C /usr/local/bin/

mkdir -p /usr/local/lib/systemd/system
cp /tmp/containerd.service /usr/local/lib/systemd/system

mkdir /etc/containerd/
if [ -f "/tmp/containerd-config.txt" ]; then
  cp /tmp/containerd-config.txt /etc/containerd/config.toml
else
  containerd config default > /etc/containerd/config.toml
  sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
  ENABLE_C_GROUP=$?
  echo "Enable Systemd CGroup: ${ENABLE_C_GROUP}"
  if [ "${ENABLE_C_GROUP}" != "0"]; then
    echo "--- ERROR ---"
    exit 1
  fi
fi

systemctl daemon-reload
systemctl enable --now containerd

echo 'source <(crictl completion)' >> $HOME/.bashrc
echo 'alias crictl="crictl -r unix:///run/containerd/containerd.sock"' >> $HOME/.bashrc

## Install Runc
install -m 755 /tmp/containerd/runc.amd64 /usr/local/sbin/runc


## Install CNI Plugins
mkdir -p /opt/cni/bin
tar xvzf /tmp/containerd/cni-plugins.tgz -C /opt/cni/bin/
