provider "google" {
  project = var.project
  region  = var.region
}

data "google_secret_manager_secret_version" "gibberish" {
  secret = "gibberish"
}

module "static" {
  source = "./modules/static/"
  domain = var.domain
}

module "storage" {
  source = "./modules/storage/"
  region = var.region
  sa     = var.sa
}

module "vpc" {
  source   = "./modules/vpc/"
  zone1    = var.zone1
  mig-tags = var.mig-tags
}

module "cloud-sql" {
  source     = "./modules/cloud-sql/"
  vpc-id     = module.vpc.vpc-id
  name-base  = var.name-base
  zone1      = var.zone1
  zone2      = var.zone2
  password   = data.google_secret_manager_secret_version.gibberish.secret_data
  depends_on = [module.vpc.priv-subnet]
}

module "elk-packer" {
  source               = "./modules/packer/"
  subnet               = module.vpc.priv-subnet
  project              = var.project
  zone                 = var.zone1
  image-name           = var.elk-image
  source-image         = var.source-image
  bastion-ip           = module.vpc.bastion-ip
  ssh-private-key-path = var.ssh-private-key-path
  ssh-username         = var.ssh-username
  packer-machine-type  = var.packer-machine-type
  playbook             = var.elk-playbook
  ansible-extra-vars   = ""
  depends_on           = [module.cloud-sql.db-ip, module.vpc.priv-subnet, module.storage.bucket, module.static]
}

module "wp-packer" {
  source               = "./modules/packer/"
  subnet               = module.vpc.priv-subnet
  project              = var.project
  zone                 = var.zone1
  image-name           = var.wp-image
  source-image         = var.source-image
  bastion-ip           = module.vpc.bastion-ip
  ssh-private-key-path = var.ssh-private-key-path
  ssh-username         = var.ssh-username
  packer-machine-type  = var.packer-machine-type
  playbook             = var.wp-playbook
  ansible-extra-vars   = "bucket=${module.storage.bucket} db_ip=${module.cloud-sql.db-ip} password=${data.google_secret_manager_secret_version.gibberish.secret_data}"
  depends_on           = [module.cloud-sql.db-ip, module.vpc.priv-subnet, module.storage.bucket, module.static]
}

module "mig" {
  source      = "./modules/mig/"
  mig-min     = var.mig-min
  mig-max     = var.mig-max
  name-base   = var.name-base
  tags        = var.mig-tags
  zone1       = var.zone1
  zone2       = var.zone2
  sa          = var.sa
  vpc-id      = module.vpc.vpc-id
  priv-subnet = module.vpc.priv-subnet
  image       = var.wp-image
  depends_on  = [module.wp-packer]
}

module "cloud-lb" {
  source      = "./modules/cloud-lb/"
  mig         = module.mig.wp-mig
  healthcheck = module.mig.wp-heath
  ssl-cert    = module.static.ssl-cert
  static-ip   = module.static.static-ip
  depends_on  = [module.mig]
}