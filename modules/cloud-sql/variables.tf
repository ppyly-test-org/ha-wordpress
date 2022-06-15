variable "vpc-id" {
  type = string
}

variable "zone1" {
  type = string
}

variable "zone2" {
  type = string
}

variable "password" {
  type = string
}

variable "db-tier" {
  type    = string
  default = "db-f1-micro"
}

variable "sql-version" {
  type    = string
  default = "MYSQL_5_7"
}

variable "name-base" {
  type = string
}

variable "username" {
  type = string
  default = "wordpress"
}

variable "db-name" {
  type = string
  default = "wordpress"
}