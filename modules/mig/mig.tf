resource "google_compute_region_autoscaler" "autoscaler" {
  name   = "my-region-autoscaler"
  target = google_compute_region_instance_group_manager.wp-mig.id

  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.9
    }
  }
}

resource "google_compute_instance_template" "default" {
  name = "wpserver-template"
  tags = ["wp"]

  machine_type   = var.machine_type
  can_ip_forward = false

  disk {
    source_image = var.image
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.vpc-id
    subnetwork = var.priv-subnet
  }

  service_account {
    email  = var.sa
    scopes = ["cloud-platform", "storage-full"]
  }

  metadata_startup_script = <<SCRIPT
    #!/bin/bash
    sudo -u pashkadez gcsfuse --implicit-dirs -o allow_other terraform-wordpress-bucket-123456789 /mnt/wordpress/
    sudo ln -s /mnt/wordpress /var/www/
    sudo systemctl reload apache2
    SCRIPT
}


resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 10
  timeout_sec         = 9
  healthy_threshold   = 2
  unhealthy_threshold = 10

  http_health_check {
    request_path = "/index.html"
    port         = "80"
  }
}

resource "google_compute_region_instance_group_manager" "wp-mig" {
  name = "wp-mig"

  base_instance_name        = "wp"
  distribution_policy_zones = [var.zone1, var.zone2]

  version {
    instance_template = google_compute_instance_template.default.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }

  named_port {
    name = "http"
    port = 80
  }
}

