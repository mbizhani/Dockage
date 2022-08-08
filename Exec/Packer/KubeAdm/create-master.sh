#!/bin/bash

packer build -var-file vm-master-vars.pkrvars.hcl vw-master-kubeadm.pkr.hcl