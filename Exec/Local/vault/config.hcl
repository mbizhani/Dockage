storage "file" {
  path = "/vault/file"
}

listener "tcp" {
  address     = "0.0.0.0:8200",
  tls_disable = true
}

ui = true

disable_mlock = true