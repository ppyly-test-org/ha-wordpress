variable "vpc-id" {
  type = string
}

variable "zone1" {
  type = string
}

variable "zone2" {
  type = string
}

variable "wordpress" {
  type    = string
  default = "wordpress"
}

variable "password" {
  type = string
}

variable "tier" {
  type    = string
  default = "db-f1-micro"
}

variable "sql-version" {
  type    = string
  default = "MYSQL_5_7"
}