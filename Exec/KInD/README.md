# KInD + Ingress + Local Registry

## Steps
1. Download `kind-linux-amd64` from [release page](https://github.com/kubernetes-sigs/kind/releases) (e.g. `v0.14.0`)
  - Rename file to `kind`
  - Put it in PATH (e.g. `/usr/local/bin`)
  - Make it executable, i.e. `chmod +x PATH/kind`
  - Add `source <(kind completion bash)` to `$HOME/.bashrc`
2. Download the latest image `kindest/node` from [Docker Hub](https://hub.docker.com/r/kindest/node/tags) (`docker pull kindest/node:v1.24.1`)
3. Create a docker registry from [Local](../Local) example
4. Create a single-node cluster using following script
```shell
cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."app-registry:5000"]
    endpoint = ["http://app-registry:5000"]

nodes:
- role: control-plane
  image: kindest/node:v1.24.1 
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
```
5. `docker network connect "kind" "app-registry"`
6. Store following images to local registry
  - `k8s.gcr.io/ingress-nginx/controller:v1.2.1` as `app-registry:5000/ingress-nginx/controller:v1.2.1`
  - `k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1` as `app-registry:5000/ingress-nginx/kube-webhook-certgen:v1.1.1` 
7. `kubectl apply -f ingress-nginx.yml`
8. Test ingress `kubectl apply -f sample-nginx.yml`