resource "google_compute_instance" "wp-bootstrap" {
  name         = "wp-bootstrap"
  machine_type = "f1-micro"
  zone         = var.zone1
  tags         = ["wp"]
  boot_disk {
    initialize_params {
      image = var.wp-image
    }
  }
  network_interface {
    network    = module.vpc.vpc-id
    subnetwork = module.vpc.priv-subnet
    access_config {
    }
  }
  service_account {
    email  = var.sa
    scopes = ["cloud-platform", "storage-full"]
  }
  depends_on              = [module.wp-packer, google_compute_region_autoscaler.autoscaler]
  metadata_startup_script = file("scripts/wp-mig.sh")
}

resource "google_compute_instance" "kibana" {
  name         = "kibana"
  machine_type = "e2-medium"
  zone         = var.zone1

  tags = ["wp", "kibana", "elastic"]

  boot_disk {
    initialize_params {
      image = var.elk-image
    }
  }

  network_interface {
    network    = module.vpc.vpc-id
    subnetwork = module.vpc.priv-subnet
    access_config {
      nat_ip = module.static.static-ip1
    }
  }
 
  service_account {
    email  = var.sa
    scopes = ["cloud-platform"]
  }

  depends_on = [null_resource.elastic-mig-delay]

  metadata_startup_script = file("scripts/kibana.sh")
}


resource "google_compute_instance" "elk-bootstrap" {
  name         = "elk-bootstrap"
  machine_type = "e2-medium"
  zone         = var.zone1

  tags = ["elastic"]

  boot_disk {
    initialize_params {
      image = var.elk-image
    }
  }

  network_interface {
    network    = module.vpc.vpc-id
    subnetwork = module.vpc.priv-subnet
    # access_config {
    # }
  }

  service_account {
    email  = var.sa
    scopes = ["cloud-platform"]
  }

  depends_on = [module.elk-packer]

  metadata_startup_script = file("scripts/elk-bootstrap.sh")
  provisioner "local-exec" {
    command = <<EOF
sleep 90
EOF
  }
}
