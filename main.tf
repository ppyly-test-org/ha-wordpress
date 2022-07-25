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
  mig-tags = var.wp-mig-tags
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
  depends_on           = [module.vpc]
}

module "elastic-mig" {
  source            = "./modules/mig/"
  name-base         = "elastic"
  tags              = ["wp", "elastic"]
  zone1             = var.zone1
  zone2             = var.zone2
  sa                = var.sa
  vpc-id            = module.vpc.vpc-id
  machine_type      = "e2-medium"
  priv-subnet       = module.vpc.priv-subnet
  image             = var.elk-image
  scopes            = var.wp-mig-scopes
  script            = file("scripts/elk-mig.sh")
  health-check-port = "9200"
  target_size       = 3
  depends_on        = [module.elk-packer, google_compute_instance.elk-bootstrap]
  initial_delay_sec = 300
}

resource "null_resource" "elastic-mig-delay" {
  provisioner "local-exec" {
    command = <<EOF
sleep 30
EOF
  }
  depends_on        = [module.elastic-mig]
}

module "logstash-mig" {
  source            = "./modules/mig/"
  name-base         = "logstash"
  tags              = ["logstash"]
  zone1             = var.zone1
  zone2             = var.zone2
  sa                = var.sa
  vpc-id            = module.vpc.vpc-id
  machine_type      = "e2-medium"
  priv-subnet       = module.vpc.priv-subnet
  image             = var.elk-image
  scopes            = var.wp-mig-scopes
  script            = file("scripts/logstash.sh")
  health-check-port = "5044"
  target_size       = 2
  depends_on        = [module.elk-packer, null_resource.elastic-mig-delay]
  initial_delay_sec = 300
}

module "cloud-sql" {
  source     = "./modules/cloud-sql/"
  vpc-id     = module.vpc.vpc-id
  name-base  = var.wp-name-base
  zone1      = var.zone1
  zone2      = var.zone2
  password   = data.google_secret_manager_secret_version.gibberish.secret_data
  depends_on = [module.vpc.priv-subnet]
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

module "wp-mig" {
  source            = "./modules/mig/"
  name-base         = var.wp-name-base
  tags              = var.wp-mig-tags
  zone1             = var.zone1
  zone2             = var.zone2
  sa                = var.sa
  vpc-id            = module.vpc.vpc-id
  priv-subnet       = module.vpc.priv-subnet
  image             = var.wp-image
  scopes            = var.wp-mig-scopes
  # health-check-path = "/index.html"
  script            = file("scripts/wp-mig.sh")
  depends_on        = [module.wp-packer, module.logstash-mig, google_compute_instance.kibana ]
}

resource "google_compute_region_autoscaler" "autoscaler" {
  name   = "${var.wp-name-base}-region-autoscaler"
  target = module.wp-mig.mig-id

  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 1
    }
  }
  depends_on = [module.wp-mig]
}

module "cloud-lb" {
  source      = "./modules/cloud-lb/"
  mig         = module.wp-mig.mig
  healthcheck = module.wp-mig.heath
  ssl-cert    = module.static.ssl-cert
  static-ip   = module.static.static-ip
  depends_on  = [module.wp-mig]
}


#  echo $(gcloud compute instances list --filter='name ~ wp*' --format 'csv[no-heading](INTERNAL_IP)') | sed -e 's/ /, /g'