variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone1" {
  type = string
}

variable "zone2" {
  type = string
}

variable "bucket" {
  type = string
}

variable "sa" {
  type = string
}

variable "domain" {
  type = string
}

variable "wp-image" {
  type = string
}

variable "mig-min" {
  type = string
}

variable "mig-max" {
  type = string
}

variable "name-base" {
  type = string
}

variable "mig-tags" {
  type = list(string)
}

variable "source-image" {
  type = string
}

variable "ssh-private-key-path" {
  type = string
}

variable "ssh-username" {
  type = string
}

variable "packer-machine-type" {
  type = string
}

variable "wp-playbook" {
  type = string
}

variable "elk-image" {
  type = string
}

variable "elk-playbook" {
  type = string
}
