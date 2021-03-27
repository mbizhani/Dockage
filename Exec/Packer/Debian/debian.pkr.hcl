
variable "base_output_dir" {
  type = string
}

variable "boot_wait" {
  type    = string
  default = "5s"
}

variable "cpus" {
  type    = number
  default = 2
}

variable "cpus_cores" {
  type    = number
  default = 2
}

variable "disk_size_GB" {
  type    = number
  default = 15
}

variable "iso_checksum" {
  type = string
}

variable "iso_url" {
  type = string
}

variable "memory_GB" {
  type    = number
  default = 2
}

variable "mirror" {
  type    = bool
  default = true
}

variable "single_partition" {
  type    = bool
  default = false
}

variable "ssh_password" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "vm_name" {
  type = string
}

locals {
  preseed_file = "${var.single_partition ? "preseed-sp.cfg" : "preseed.cfg"}"
}

source "vmware-iso" "vmware" {
  boot_command = [
    "<esc><wait>",
    "auto ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${local.preseed_file} <wait>",
    "apt-setup/use_mirror=${var.mirror} <wait>",
  "<enter>"]
  boot_wait         = "${var.boot_wait}"
  cores             = "${var.cpus_cores}"
  cpus              = "${var.cpus * var.cpus_cores}"
  disk_adapter_type = "scsi"
  disk_size         = "${var.disk_size_GB * 1024}"
  disk_type_id      = "1"
  guest_os_type     = "debian10-64"
  headless          = false
  http_directory    = "http"
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url}"
  memory            = "${var.memory_GB * 1024}"
  output_directory  = "${var.base_output_dir}/${var.vm_name}"
  shutdown_command  = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"
  ssh_password      = "${var.ssh_password}"
  ssh_port          = 22
  ssh_timeout       = "30m"
  ssh_username      = "${var.ssh_username}"
  version           = 15
  vm_name           = "${var.vm_name}"
  vmdk_name         = "${var.vm_name}"
}

/*
source "virtualbox-iso" "vbox" {
  boot_command     = ["<esc><wait>", "auto ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>", "<enter>"]
  boot_wait        = "${var.boot_wait}"
  disk_size        = "${var.disk_size}"
  guest_os_type    = "Debian_64"
  headless         = false
  http_directory   = "http"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  shutdown_command = "echo 'packer' | sudo -S /sbin/shutdown -hP now"
  ssh_password     = "${var.ssh_password}"
  ssh_port         = 22
  ssh_timeout      = "30m"
  ssh_username     = "${var.ssh_username}"
  vboxmanage       = [["modifyvm", "{{ .Name }}", "--memory", "${var.memory}"], ["modifyvm", "{{ .Name }}", "--cpus", "${var.cpus}"]]
  vm_name          = "${var.vm_name}"
}*/

build {
  sources = ["source.vmware-iso.vmware"]

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    script          = "scripts/init.sh"
  }
}
