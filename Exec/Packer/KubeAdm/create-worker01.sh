#!/bin/bash

packer build -var-file vm-worker01-vars.pkrvars.hcl vw-worker-kubeadm.pkr.hcl