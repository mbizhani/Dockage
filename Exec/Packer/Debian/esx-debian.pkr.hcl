
variable boot_wait {
  type    = string
  default = "5s"
}

variable cpus {
  type    = number
  default = 2
}

variable cpus_cores {
  type    = number
  default = 2
}

variable disk_size_GB {
  type    = number
  default = 20
}

variable esx_cache_datastore {
  type = string
}

variable esx_cache_directory {
  type = string
}

variable esx_datastore {
  type = string
}

variable esx_host {
  type = string
}

variable esx_ssh_username {
  type = string
}

variable esx_ssh_password {
  type = string
}

variable iso_checksum {
  type = string
}

variable iso_url {
  type = string
}

variable memory_GB {
  type    = number
  default = 2
}

variable mirror {
  type    = bool
  default = true
}

variable net_mac_address {
  type    = string
  default = ""
}

variable partition {
  type    = string
  default = "main"
}

variable ssh_password {
  type = string
}

variable ssh_username {
  type = string
}

variable vm_name {
  type = string
}

locals {
  preseed_file = "preseed-${var.partition}.cfg"

  common_vmx_data = {}
}

source "vmware-iso" "vmware" {
  boot_command = [
    "<esc><wait>",
    "auto ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${local.preseed_file} <wait>",
    "apt-setup/use_mirror=${var.mirror} <wait>",
    "${var.mirror ? "" : "apt-setup/security_host=\"\""} <wait>",
  "<enter>"]
  boot_wait              = "${var.boot_wait}"
  cores                  = "${var.cpus_cores}"
  cpus                   = "${var.cpus * var.cpus_cores}"
  disk_size              = "${var.disk_size_GB * 1024}"
  disk_type_id           = "thin"  // DEFAULT: zeroedthick
  display_name           = "${var.vm_name}"
  guest_os_type          = "debian10-64"
  headless               = true
  http_directory         = "http"
  iso_checksum           = "${var.iso_checksum}"
  iso_url                = "${var.iso_url}"
  keep_registered        = true // DEFAULT is false
  memory                 = "${var.memory_GB * 1024}"
  network_name           = "VM Network" // Necessary for default DHCP configuration
  remote_cache_datastore = "${var.esx_cache_datastore}"
  remote_cache_directory = "${var.esx_cache_directory}"
  remote_datastore       = "${var.esx_datastore}"
  remote_host            = "${var.esx_host}"
  remote_password        = "${var.esx_ssh_password}"
  remote_port            = 22
  remote_type            = "esx5"
  remote_username        = "${var.esx_ssh_username}"
  shutdown_command       = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"
  skip_export            = true // DEFAULT is false, so exporting to ovf as default 'format'
  ssh_password           = "${var.ssh_password}"
  ssh_port               = 22
  ssh_timeout            = "30m"
  ssh_username           = "${var.ssh_username}"
  version                = 15
  vm_name                = "${var.vm_name}"
  vmdk_name              = "${var.vm_name}"
  vnc_disable_password   = true
  vmx_data          = merge(
    local.common_vmx_data,
    var.net_mac_address != "" ? { "ethernet0.addressType" = "static", "ethernet0.address" = var.net_mac_address} : {}
  )
}

build {
  sources = ["source.vmware-iso.vmware"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    script          = "scripts/init.sh"
  }
}
