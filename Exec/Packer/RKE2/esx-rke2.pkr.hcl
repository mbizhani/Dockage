variable cpus {
  type    = number
  default = 4
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

variable extra_disk_GB {
  type    = number
  default = 0
}

variable extra_disk_for_partition {
  type    = string
}

variable memory_GB {
  type    = number
  default = 4
}

variable net_ip {
  type = string
}

variable net_gateway {
  type = string
}

variable net_dns {
  type = string
}

variable rke2_cis_enabled {
  type    = bool
  default = false
}

variable rke2_is_server {
  type    = bool
  default = true
}

variable rke2_registry {
  type = string
}

variable rke2_sans {
  type = list(string)
}

variable rke2_server_host {
  type    = string
  default = ""
}

variable rke2_token {
  type    = string
  default = ""
}

variable source_vmx {
  type = string
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
  registry = <<-EOF
    mirrors:
      registry:
        endpoint:
          - '${var.rke2_registry}'
    EOF

  config = <<-EOF
    write-kubeconfig-mode: '0644'
    advertise-address: '${var.net_ip}'
    protect-kernel-defaults: true
    system-default-registry: '${split("//", var.rke2_registry)[1]}'

    ${length(var.rke2_sans) > 0 ? "tls-san:\n${join("\n", formatlist("  - '%s'", var.rke2_sans))}" : ""}
    ${var.rke2_token != "" ? "token: '${var.rke2_token}'" : ""}
    ${var.rke2_server_host != "" ? "server: 'https://${var.rke2_server_host}:9345'" : ""}
    ${var.rke2_cis_enabled ? "profile: 'cis-1.5'" : ""}
    EOF

  file_base = "/home/${var.ssh_username}/"

  common_vmx_data = {
    "mem.hotadd"  = "TRUE",
    "memsize"     = "${var.memory_GB * 1024}",
    "numvcpus"    = "${var.cpus}",
    "vcpu.hotadd" = "TRUE"
  }
}

// esxcli system settings advanced set -o /Net/GuestIPHack -i 1

source "vmware-vmx" "rke2-node" {
  disable_vnc          = true
  disk_additional_size = var.extra_disk_GB > 0 ? [var.extra_disk_GB * 1024] : []
  disk_type_id         = "thin" // DEFAULT: zeroedthick
  display_name         = "${var.vm_name}"
  headless             = true
  keep_registered      = true // DEFAULT is false
  remote_datastore     = "${var.esx_datastore}"
  remote_host          = "${var.esx_host}"
  remote_password      = "${var.esx_ssh_password}"
  remote_port          = 22
  remote_type          = "esx5"
  remote_username      = "${var.esx_ssh_username}"
  shutdown_command     = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"
  skip_export          = true                // DEFAULT is false, so exporting to ovf as default 'format'
  source_path          = "${var.source_vmx}" // REQUIRED
  ssh_password         = "${var.ssh_password}"
  ssh_port             = 22
  ssh_timeout          = "30m"
  ssh_username         = "${var.ssh_username}"
  vm_name              = "${var.vm_name}"
  vmdk_name            = "extra01"
  vmx_data = var.extra_disk_GB == 0 ? local.common_vmx_data : merge(local.common_vmx_data, {
    "scsi0:1.fileName" = "extra01-1.vmdk",
    "scsi0:1.present"  = "TRUE"
  })
}

build {
  sources = ["vmware-vmx.rke2-node"]

  provisioner "file" {
    source      = "files/"
    destination = "${local.file_base}"
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    script          = "scripts/init.sh"
    environment_vars = [
      "P_IP=${var.net_ip}",
      "P_GW=${var.net_gateway}",
      "P_HOST=${var.vm_name}",
      "P_DNS=${var.net_dns}",
      "P_EXTEND=${var.extra_disk_GB > 0 && var.extra_disk_for_partition != null ? var.extra_disk_for_partition : ""}"
    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    script          = "scripts/install.sh"
    environment_vars = [
      "P_REGISTRY=${trimspace(local.registry)}",
      "P_CONFIG=${trimspace(local.config)}",
      "P_IS_SERVER=${var.rke2_is_server}",
      "P_FILE_BASE=${local.file_base}"
    ]
  }
}
