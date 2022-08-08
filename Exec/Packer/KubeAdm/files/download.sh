#!/bin/bash

mkdir containerd

wget https://github.com/containerd/containerd/releases/download/v1.6.6/containerd-1.6.6-linux-amd64.tar.gz \
  -O containerd/containerd.tar.gz

wget https://github.com/opencontainers/runc/releases/download/v1.1.3/runc.amd64 \
  -O containerd/runc.amd64

wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz \
  -O containerd/cni-plugins.tgz

wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.24.2/crictl-v1.24.2-linux-amd64.tar.gz \
  -O containerd/crictl.tar.gz