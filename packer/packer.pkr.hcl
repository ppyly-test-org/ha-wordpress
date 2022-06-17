packer {
  required_plugins {
    googlecompute = {
      version = " >= 0.0.1 "
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "priv-subnet" {
  type = string
}

variable "project" {
  type = string
}

variable "zone" {
  type = string
}

variable "image-name" {
  type = string
}

variable "source-image" {
  type = string
}

variable "bastion-ip" {
  type = string
}

variable "playbook" {
  type = string
}

variable "ansible-extra-vars" {
  type = string
}

variable "ssh-private-key-path" {
  type = string
}

variable "username" {
  type = string
}

variable "machine-type" {
  type = string
}

source "googlecompute" "conf" {
  project_id                   = var.project
  source_image                 = var.source-image
  machine_type                 = var.machine-type
  ssh_username                 = var.username
  ssh_private_key_file         = var.ssh-private-key-path
  ssh_bastion_username         = var.username
  ssh_bastion_host             = var.bastion-ip
  ssh_bastion_private_key_file = var.ssh-private-key-path
  zone                         = var.zone
  tags                         = ["packer"]
  use_internal_ip              = true
  subnetwork                   = var.priv-subnet
  image_name                   = var.image-name
}

build {
  sources = ["sources.googlecompute.conf"]

  provisioner "ansible" {
    playbook_file = var.playbook
    extra_arguments = [
      # "-vvvv",
      "--extra-vars",
      "${var.ansible-extra-vars}"
    ]
  }
}