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

resource "null_resource" "packer" {
  provisioner "local-exec" {
    command = <<EOF
packer build -var 'priv-subnet=${module.vpc.priv-subnet}' -var 'db-ip=${module.cloud-sql.db-ip}' -var 'bucket=${module.storage.bucket}' -var 'project=${var.project}' -var 'zone=${var.zone1}' -var 'password=${data.google_secret_manager_secret_version.gibberish.secret_data}' packer/packer.pkr.hcl
sleep 25
EOF
  }
  depends_on = [module.cloud-sql.db-ip, module.vpc.priv-subnet, module.storage.bucket, module.static]
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
  image       = var.image
  depends_on  = [null_resource.packer]
}

module "cloud-lb" {
  source      = "./modules/cloud-lb/"
  mig         = module.mig.wp-mig
  healthcheck = module.mig.wp-heath
  ssl-cert    = module.static.ssl-cert
  static-ip   = module.static.static-ip
  depends_on  = [module.mig]
}