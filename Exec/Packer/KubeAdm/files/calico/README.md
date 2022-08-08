
## Images

- `tigera-operator.yaml`
  - `quay.io/tigera/operator:v1.27.12`
  - After applying `tigera-custom-resources.yaml`
    - pod `calico-kube-controllers`
      - `calico/kube-controllers:v3.23.3`
    - pod `calico-node`
      - `calico/pod2daemon-flexvol:v3.23.3`
      - `calico/cni:v3.23.3`
      - `calico/node:v3.23.3`
    - pod `calico-typha`
      - `calico/typha:v3.23.3`