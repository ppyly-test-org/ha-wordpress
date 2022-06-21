
resource "google_compute_firewall" "allow_access" {
  name    = "allow-bastion-ssh"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["bastion"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = ["bastion"]
  target_tags = ["packer", "wp", "elastic", "logstash", "kibana"]
}

resource "google_compute_firewall" "allow_http_access" {
  name    = "allow-http-access"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags   = var.mig-tags
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-sql" {
  name    = "network-allow-mysql"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  source_tags = var.mig-tags
}

resource "google_compute_firewall" "allow_elasticsearch_connection" {
  name    = "allow-elasticsearch-connection"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["9200-9210", "9300-9310"]
  }
  source_tags = ["elastic", "logstash", "kibana"]
  target_tags = ["elastic"]
}

resource "google_compute_firewall" "allow_kibana_connection" {
  name    = "allow-kibana-connection"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["5601"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["kibana"]
}