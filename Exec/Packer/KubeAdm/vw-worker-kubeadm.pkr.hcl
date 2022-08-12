variable k8s_master_ip {
  type = string
}

variable k8s_token {
  type = string
}

variable k8s_token_ca_cert_hash {
  type = string
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

variable ssh_password {
  type = string
}

variable ssh_username {
  type = string
}

variable vm_name {
  type = string
}

source "null" "init" {
  ssh_host     = "${var.net_ip}"
  ssh_username = "${var.ssh_username}"
  ssh_password = "${var.ssh_password}"
}

build {
  sources = ["null.init"]

  /*provisioner "shell" {
    execute_command  = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    script           = "scripts/init.sh"
    environment_vars = [
      "P_IP=${var.net_ip}",
      "P_GW=${var.net_gateway}",
      "P_HOST=${var.vm_name}",
      "P_DNS=${var.net_dns}"
    ]
  }*/

  provisioner "file" {
    source      = "files/"
    destination = "/tmp"
  }

  provisioner "shell" {
    execute_command  = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    script           = "scripts/install-common.sh"
  }

  provisioner "shell" {
    execute_command  = "echo '${var.ssh_password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    script           = "scripts/install-worker.sh"
    environment_vars = [
      "P_IP=${var.net_ip}",
      "P_K8S_MASTER_IP=${var.k8s_master_ip}",
      "P_K8S_TOKEN=${var.k8s_token}",
      "P_K8S_TOKEN_CA_CERT_HASH=${var.k8s_token_ca_cert_hash}"
    ]
  }

}