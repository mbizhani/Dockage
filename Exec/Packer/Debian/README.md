## Install Debian on VMware Workstation via Packer

I created this project with
- VMware Workstation 16.2
- Debian 11 (`debian-11.4.0-amd64-DVD-1.iso`)
- Packer v1.8.3 [[REF](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli#installing-packer)]
  - `packer -autocomplete-install` - bash Completion - [[REF](https://www.packer.io/docs/commands#autocompletion)]

### Prerequisites
- `/etc/vmware/netmap.conf` required
  - The file may not be generated for VMware Workstation 16! [[REF](https://bleepcoder.com/packer/710568243/vmware-workstation-16-does-not-generate-netmap-conf-during)] 
  - `sudo vmware-netcfg` and press `Save` button
- Download Debian stable first DVD [[ISO-DVD](https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/)] 

### Install Debian
- The main REF is [[packer-Debian10](https://github.com/eaksel/packer-Debian10)]
  - Another REF - [[How to use Packer to Build a Debian 10 Template for VMware vSphere](https://gmusumeci.medium.com/how-to-use-packer-to-build-a-debian-10-template-for-vmware-vsphere-28da6338c87e)]
  - ESX REF - [[Automated VMWare Templates with HashiCorp Packer](https://www.infralovers.com/en/articles/2019/10/15/automated-vmware-templates-with-hashicorp-packer/)]
- Use a local file for `iso_url`
  - `sha1sum FILE` - generate checksum value for `iso_checksum` variable
- [VMware ISO Builder](https://www.packer.io/docs/builders/vmware/iso)
- Other Refs
  - [Packer - Unattended Installation for Debian](https://www.packer.io/guides/automatic-operating-system-installs/preseed_ubuntu)
  - [DebianInstaller - Preseed](https://wiki.debian.org/DebianInstaller/Preseed)  
  - [Appendix B. Automating the installation using preseeding](https://www.debian.org/releases/bullseye/amd64/apb.en.html)
  - [partman-auto-recipe.txt](https://salsa.debian.org/installer-team/debian-installer/-/raw/master/doc/devel/partman-auto-recipe.txt)
  - [LVM Problem](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=687160)
  - [multi line late_command sample](https://unix.stackexchange.com/questions/556413/how-do-i-set-mirrors-in-etc-apt-sources-list-with-a-debian-preseed-file)
  - [VMware Virtual Hardware Version](https://kb.vmware.com/s/article/1003746)
- Preseeding Special Config Items
  - `d-i partman-basicfilesystems/no_swap boolean false` - [[REF](https://lists.debian.org/debian-user/2012/08/msg01558.html)
  - `d-i partman-auto-lvm/no_boot boolean true` - found in `/var/log/installer/cdebconf/questions.dat` 
  - `d-i partman-auto-lvm/new_vg_name string vg-main` and in recipe `vg_name{ vg-main }` which is the main ref value
- **`/var/log/installer/cdebconf/questions.dat`** in VM
  - it contains answered questions during installation (the solution to find questions for addition to `preseed.cfg`)
  - The [[questions.dat](questions.dat)] for this installation
  - Search `Value:` for answered questions
- **RUN**
  - **VMware Workstation**
    - `vw-vars.pkrvars.hcl` - variables for installation
    - `packer build -var-file vw-vars.pkrvars.hcl vw-debian.pkr.hcl`
  - **ESXi**
    - Enable SSH
    - Set password in var file as `esx_ssh_password` or via env variable `PKR_VAR_esx_ssh_password`
    - `esxcli system settings advanced set -o /Net/GuestIPHack -i 1` in ESXi shell
      - This allows Packer to infer the guest IP from ESXi, without the VM needing to report it itself.
    - Open VNC Ports on the Firewall
      - `chmod 644 /etc/vmware/firewall/service.xml`
      - `chmod +t /etc/vmware/firewall/service.xml`
      - Append following
        ```xml
          <service id="1000">
            <id>packer-vnc</id>
            <rule id="0000">
              <direction>inbound</direction>
              <protocol>tcp</protocol>
              <porttype>dst</porttype>
              <port>
                <begin>5900</begin>
                <end>6000</end>
              </port>
            </rule>
            <enabled>true</enabled>
            <required>true</required>
          </service>
        ```
      - `chmod 444 /etc/vmware/firewall/service.xml`
      - `esxcli network firewall refresh`
    - `packer build -var-file esx-vars.pkrvars.hcl esx-debian.pkr.hcl`
      - Note: at first, it uploads ISO to `esx_cache_datastore:/esx_cache_directory`
    - For security, disable the previous accesses!
- Users
  - `packer` is defined in `preseed.cfg` file with `packer` password
  - `root` has `packer` password due to `preseed.cfg` file

Note: Call `packer hcl2_upgrade debian.json` to convert `json` to `hcl2` [[REF](https://www.packer.io/guides/hcl/from-json-v1)] 


### Other Configuration for Preseeding

- `/boot` partition in recipe
```
128 512 256 ext3                    \
  $defaultignore{ }                 \
  $primary{ }                       \
  $bootable{ }                      \
  method{ format }                  \
  format{ }                         \
  use_filesystem{ }                 \
  filesystem{ ext3 }                \
  mountpoint{ /boot } .             \
```

- `efi` & `GPT` - [[UEFI PXE Preseeded](https://sven.stormbind.net/blog/posts/deb_uefi_pxe_install_hpe_dl120/)]
```
# Keep that one set to true so we end up with a UEFI enabled
# system. If set to false, /var/lib/partman/uefi_ignore will be touched
d-i partman-efi/non_efi_system boolean true

# enforce usage of GPT - a must have to use EFI!
d-i partman-basicfilesystems/choose_label string gpt
d-i partman-basicfilesystems/default_label string gpt
d-i partman-partitioning/choose_label string gpt
d-i partman-partitioning/default_label string gpt
d-i partman/choose_label string gpt
d-i partman/default_label string gpt
```
