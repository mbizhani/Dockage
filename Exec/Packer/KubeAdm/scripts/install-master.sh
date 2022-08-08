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

# Hint: kubeadm config print init-defaults > $HOME/kubeadm-config.yml

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

## kubectl get pod -A -o wide
# NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE     IP              NODE         NOMINATED NODE   READINESS GATES
# kube-system   coredns-55568ff8d7-bplvb             0/1     Pending   0          3m46s   <none>          <none>       <none>           <none>
# kube-system   coredns-55568ff8d7-k42ng             0/1     Pending   0          3m46s   <none>          <none>       <none>           <none>
# kube-system   etcd-k8s-master                      1/1     Running   0          4m      192.168.15.10   k8s-master   <none>           <none>
# kube-system   kube-apiserver-k8s-master            1/1     Running   0          4m      192.168.15.10   k8s-master   <none>           <none>
# kube-system   kube-controller-manager-k8s-master   1/1     Running   0          4m      192.168.15.10   k8s-master   <none>           <none>
# kube-system   kube-proxy-9rxzd                     1/1     Running   0          3m47s   192.168.15.10   k8s-master   <none>           <none>
# kube-system   kube-scheduler-k8s-master            1/1     Running   0          4m2s    192.168.15.10   k8s-master   <none>           <none>

## kubectl get svc -A -o wide
# NAMESPACE     NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE     SELECTOR
# default       kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP                  4m51s   <none>
# kube-system   kube-dns     ClusterIP   10.43.0.10   <none>        53/UDP,53/TCP,9153/TCP   4m49s   k8s-app=kube-dns

## kubectl get nodes -o wide
# NAME         STATUS     ROLES           AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION    CONTAINER-RUNTIME
# k8s-master   NotReady   control-plane   3m24s   v1.24.3   192.168.15.10   <none>        Debian GNU/Linux 11 (bullseye)   5.10.0-16-amd64   containerd://1.6.6


#######################
## Install CNI (Calico)
## REF: https://kubernetes.io/docs/concepts/cluster-administration/addons/
kubectl apply -f /tmp/calico/tigera-operator.yaml
sleep 5
kubectl apply -f /tmp/calico/tigera-custom-resources.yaml

sleep 5

kubectl get pod -A -o wide

kubectl get nodes -o wide
