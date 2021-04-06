#!/bin/bash

function waitForPod() {
  LABEL=$1
  while [ "$(kubectl -n rook-ceph get pod -l "${LABEL}" | wc -l )" == "0" ] ||
        [ "$(kubectl -n rook-ceph get pod -l "${LABEL}" -o jsonpath="{.items[0].status.phase}")" != "Running" ]; do
    echo "Waiting for ${LABEL} ..."
    sleep 3
  done
}

kubectl create namespace rook-ceph

helm install rook-ceph Helm/rook-ceph/ --namespace rook-ceph -f Helm/values.yml
waitForPod "app=rook-ceph-operator"

kubectl apply -f Cluster/cluster-dev.yml
waitForPod "app=rook-ceph-mgr"

#kubectl apply -f Cluster/dashboard-ingress.yml

kubectl apply -f Cluster/toolbox.yml
waitForPod "app=rook-ceph-tools"
kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- bash
