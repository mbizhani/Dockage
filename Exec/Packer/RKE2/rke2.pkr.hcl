
variable "base_output_dir" {
  type = string
}

variable "extra_disk_GB" {
  type    = number
  default = 0
}

variable "net_ip" {
  type = string
}

variable "net_gateway" {
  type = string
}

variable "net_dns" {
  type = string
}

variable "rke2_cis_enabled" {
  type    = bool
  default = false
}

variable "rke2_is_server" {
  type    = bool
  default = true
}

variable "rke2_registry" {
  type = string
}

variable "rke2_sans" {
  type = list(string)
}

variable "rke2_server_host" {
  type    = string
  default = ""
}

variable "rke2_token" {
  type    = string
  default = ""
}

variable "source_vmx" {
  type = string
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
}

source "vmware-vmx" "rke2-node" {
  disk_additional_size = var.extra_disk_GB > 0 ? [var.extra_disk_GB * 1024] : []
  disk_adapter_type    = "scsi"
  disk_type_id         = "1"
  display_name         = "${var.vm_name}"
  headless             = false
  linked               = false // 'full' clone of the source VM
  output_directory     = "${var.base_output_dir}/${var.vm_name}"
  shutdown_command     = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"
  source_path          = "${var.source_vmx}" // REQUIRED
  ssh_password         = "${var.ssh_password}"
  ssh_port             = 22
  ssh_timeout          = "30m"
  ssh_username         = "${var.ssh_username}"
  vm_name              = "${var.vm_name}"
  vmdk_name            = "extra01"
  vmx_data = var.extra_disk_GB == 0 ? {} : {
    "scsi0:1.fileName" = "extra01-1.vmdk",
    "scsi0:1.present"  = "TRUE"
  }
}

build {
  sources = ["vmware-vmx.rke2-node"]

  provisioner "file" {
    source      = "files/"
    destination = "${local.file_base}"
  }

  provisioner "shell" {
    execute_command   = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    script            = "scripts/init.sh"
    //expect_disconnect = true
    //skip_clean        = true
    environment_vars = [
      "P_IP=${var.net_ip}",
      "P_GW=${var.net_gateway}",
      "P_HOST=${var.vm_name}",
      "P_DNS=${var.net_dns}"
    ]
  }

  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    script          = "scripts/install.sh"
    //pause_before    = "20s"
    environment_vars = [
      "P_REGISTRY=${trimspace(local.registry)}",
      "P_CONFIG=${trimspace(local.config)}",
      "P_IS_SERVER=${var.rke2_is_server}",
      "P_FILE_BASE=${local.file_base}"
    ]
  }
}
