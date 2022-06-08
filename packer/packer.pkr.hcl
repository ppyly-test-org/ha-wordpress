packer {
  required_plugins {
    googlecompute = {
      version = " >= 0.0.1 "
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "db-ip" {
  type = string
}

variable "priv-subnet" {
  type = string
}

variable "bucket" {
  type = string
}

variable "project" {
  type = string
}

variable "zone" {
  type = string
}

variable "password" {
  type = string
}

# variable "salt_result" {
#   type = string
# }

source "googlecompute" "wp-conf" {
  project_id                   = var.project
  source_image                 = "ubuntu-2004-focal-v20220419"
  machine_type                 = "e2-medium"
  ssh_username                 = "pashkadez"
  ssh_private_key_file         = "~/.ssh/id_rsa"
  ssh_bastion_username         = "pashkadez"
  ssh_bastion_host             = "34.116.153.6"
  ssh_bastion_private_key_file = "~/.ssh/id_rsa"
  zone                         = var.zone
  tags                         = ["packer"]
  use_internal_ip              = true
  subnetwork                   = var.priv-subnet
  image_name                   = "configured-ubuntu-image"
}

build {
  sources = ["sources.googlecompute.wp-conf"]

  provisioner "ansible" {
    playbook_file = "packer/playbook.yml"
    extra_arguments = [
      "--extra-vars",
      "bucket=${var.bucket} db_ip=${var.db-ip} password=${var.password}"
    ]

  }
}