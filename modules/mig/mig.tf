resource "google_compute_instance_template" "default" {
  name = "${var.name-base}-template"
  tags = var.tags

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
    scopes = var.scopes
  }

  metadata_startup_script = var.script
}


resource "google_compute_health_check" "autohealing" {
  name                = "${var.name-base}-health-check"
  check_interval_sec  = var.check_interval_sec
  timeout_sec         = var.timeout_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  http_health_check {
    request_path = var.health-check-path
    port         = var.health-check-port
  }
}

resource "google_compute_region_instance_group_manager" "mig" {
  name = "${var.name-base}-mig"

  base_instance_name        = var.name-base
  distribution_policy_zones = [var.zone1, var.zone2]

  version {
    instance_template = google_compute_instance_template.default.id
  }

  target_size = var.target_size

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = var.initial_delay_sec
  }

  named_port {
    name = var.named-port-name
    port = var.named-port-number
  }
}

