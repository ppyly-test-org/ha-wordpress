variable "machine_type" {
  type    = string
  default = "f1-micro"
}

variable "zone1" {
  type = string
}

variable "zone2" {
  type = string
}

variable "sa" {
  type = string
}

variable "priv-subnet" {
  type = string
}

variable "vpc-id" {
  type = string
}

variable "image" {
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

variable "tags" {
  type = list (string)
}