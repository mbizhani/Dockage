# Install Rook

## Images for Air-gaped Installation

```
-- Rook Helm Chart
rook/ceph:v1.5.9
quay.io/cephcsi/cephcsi:v3.2.0
k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.0.1
k8s.gcr.io/sig-storage/csi-resizer:v1.0.0
k8s.gcr.io/sig-storage/csi-provisioner:v2.0.0
k8s.gcr.io/sig-storage/csi-snapshotter:v3.0.0
k8s.gcr.io/sig-storage/csi-attacher:v3.0.0

--- cluster.yml
ceph/ceph:v15.2.10
```

## Steps
- On VM
  - `mkdir /dev/ceph`
  - `ln -s /dev/sdb /dev/ceph/ceph01`

- `helm repo add rook-release https://charts.rook.io/release`
- `helm pull rook-release/rook-ceph --untar`

- `kubectl create namespace rook-ceph`
- `helm install rook-ceph Helm/rook-ceph/ --namespace rook-ceph -f Helm/values.yml`
- `kubectl apply -f Cluster/cluster-dev.yml`
- `kubectl apply -f Cluster/toolbox.yml`
  - `kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- bash`
  - `ceph status`
  - `ceph df`
  - `ceph osd status`

## Notes
- It seems Ceph does not work on LVs [[issue](https://github.com/rook/rook/issues/2047)]
  - [One Solution](https://github.com/rook/rook/issues/2047#issuecomment-509484812)
  - [Another Solution - Cluster on PVC](https://bleepcoder.com/rook/650083003/cannot-use-with-lvm-lv)