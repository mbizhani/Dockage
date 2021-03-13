## Install Debian 10 on VMware Workstation via Packer

### Prerequisites
- `/etc/vmware/netmap.conf` required
  - VMware Workstation 16 has problem, file not found [[REF](https://bleepcoder.com/packer/710568243/vmware-workstation-16-does-not-generate-netmap-conf-during)] 
  - `sudo vmware-netcfg` and press `Save` button

### Install Packer
- [[REF](https://learn.hashicorp.com/tutorials/packer/getting-started-install)]
- `curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -`
- `sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"`
- `sudo apt-get update && sudo apt-get install packer`
- `packer` - verify installation

### Install
- [[packer-Debian10](https://github.com/eaksel/packer-Debian10)]
  - Another REF - [[How to use Packer to Build a Debian 10 Template for VMware vSphere](https://gmusumeci.medium.com/how-to-use-packer-to-build-a-debian-10-template-for-vmware-vsphere-28da6338c87e)]
- `packer hcl2_upgrade debian10.json` - convert `json` to `hcl2` [[REF](https://www.packer.io/guides/hcl/from-json-v1)] 
- Use a local file for `iso_url`
  - `sha1sum FILE` for `iso_checksum` variable
- [VMware ISO Builder](https://www.packer.io/docs/builders/vmware/iso)
- [Appendix B. Automating the installation using preseeding](https://www.debian.org/releases/buster/amd64/apb.en.html)
  - [partman-auto-recipe.txt](https://github.com/xobs/debian-installer/blob/master/doc/devel/partman-auto-recipe.txt)
  - `d-i partman-basicfilesystems/no_swap boolean false` [[REF](https://lists.debian.org/debian-user/2012/08/msg01558.html)]
  - [LVM Problem](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=687160)
- `packer build -only=vmware-iso debian10.json`