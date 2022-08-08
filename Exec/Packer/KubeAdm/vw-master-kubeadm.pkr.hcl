variable k8s_cidr_pod {
  type = string
}

variable k8s_cidr_service {
  type = string
}

variable k8s_registry {
  type = string
}

variable k8s_token {
  type = string
}

variable k8s_ver {
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
    script           = "scripts/install-master.sh"
    environment_vars = [
      "P_IP=${var.net_ip}",
      "P_K8S_CIDR_POD=${var.k8s_cidr_pod}",
      "P_K8S_CIDR_SERVICE=${var.k8s_cidr_service}",
      "P_K8S_REGISTRY=${var.k8s_registry}",
      "P_K8S_VER=${var.k8s_ver}",
      "P_K8S_TOKEN=${var.k8s_token}"
    ]
  }

}