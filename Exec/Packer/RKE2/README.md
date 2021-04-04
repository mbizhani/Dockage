## Install 3-Node Air-Gaped RKE2 Cluster by Packer

I created this project with
- VMware Workstation 16.0
- Cloning a Debian 10 VM created in [[Install Debian on VMware Workstation via Packer](/Exec/Packer/Debian)] 
- Packer v1.7.0 [[REF](https://learn.hashicorp.com/tutorials/packer/getting-started-install)]
- Docker Registry `registry:2.7.1` - [[REF](https://docs.docker.com/registry/deploying/)]
- RKE2 version [[v1.19.7+rke2r1](https://github.com/rancher/rke2/releases/tag/v1.19.7%2Brke2r1)]

### Prerequisites
- A base Linux VM for cloning
- Download `rke2.linux-amd64.tar.gz` from [[RKE2 Releases](https://github.com/rancher/rke2/releases)] to `files` directory
- Docker image registry with HTTPS enabled
  - Save the registry's CERT file in `files` directory (only if it is an invalid CERT file)
  - Upload RKE2 images to the registry (`rke2-images.linux-amd64.txt` file in [RKE2 Releases](https://github.com/rancher/rke2/releases)) 

### Install RKE2 Cluster
- Set variables in `node0X-vars.pkrvars.hcl`, where `X=1,2,3`
  - Set `rke2_token` only for three-node cluster (`openssl rand -hex 24` rand generator)
  - For second and third nodes, variable `rke2_server_host` should have IP address of first node
- RUN - `packer build -var-file node0X-vars.pkrvars.hcl rke2.pkr.hcl`, where `X=1,2,3`
- For first node
  - Power on the VM
  - Install RKE2
```
systemctl enable rke2-server.service
systemctl start rke2-server.service
journalctl -u rke2-server -f
```
  - `kubectl get po -A` & `kubectl cluster-info` - check K8S
- After completion, run previous steps for second and third nodes
- `kubectl get no -o wide` - at the enb, check all nodes
- `scp packer@rke2-01:/etc/rancher/rke2/rke2.yaml kube_config_cluster.yml`
  - `chmod 600 kube_config_cluster.yml`
  - `sed -i 's/127.0.0.1/rke2-01/' kube_config_cluster.yml`