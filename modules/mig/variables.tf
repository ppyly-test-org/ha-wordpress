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

variable "name-base" {
  type = string
}

variable "tags" {
  type = list(string)
}


variable "scopes" {
  type = list(string)
}

variable "health-check-path" {
  type    = string
  default = "/"
}

variable "health-check-port" {
  type    = string
  default = "80"
}

variable "script" {
}

variable "named-port-name" {
  type    = string
  default = "http"
}

variable "named-port-number" {
  type    = number
  default = 80
}

variable "target_size" {
  type    = number
  default = null
}

variable "check_interval_sec" {
  type    = number
  default = 10
}

variable "timeout_sec" {
  type    = number
  default = 9
}

variable "healthy_threshold" {
  type    = number
  default = 2
}

variable "unhealthy_threshold" {
  type    = number
  default = 10
}

variable "initial_delay_sec" {
  type    = number
  default = 300
}

