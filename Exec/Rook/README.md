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
- `helm repo add rook-release https://charts.rook.io/release`
- `helm pull rook-release/rook-ceph --untar`
- `kubectl create namespace rook-ceph`
- `helm install rook-ceph rook-ceph/ --namespace rook-ceph -f values.yml` - in `Helm` dir
- `kubectl apply -f cluster-dev.yml`
- `kubectl apply -f toolbox.yml`
  - `kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- bash`
  - `ceph status`
  - `ceph df`
  - `ceph osd status`
