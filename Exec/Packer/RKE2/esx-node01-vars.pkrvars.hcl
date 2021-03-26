esx_datastore    = ""
esx_host         = ""
esx_ssh_password = ""
esx_ssh_username = ""

net_ip           = ""
net_gateway      = ""
net_dns          = ""

rke2_cis_enabled = false
rke2_registry    = "http://"
rke2_sans        = ["rke2-01", "rke2-02", "rke2-03"]
rke2_server_host = "" // Empty for First Node
rke2_token       = ""

source_vmx       = ""
ssh_password     = "packer"
ssh_username     = "packer"
vm_name          = "rke2-01"