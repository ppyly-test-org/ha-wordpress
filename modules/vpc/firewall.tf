
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

resource "google_compute_firewall" "allow_internal_ssh" {
  name    = "allow-internal-ssh"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = ["bastion"]
  target_tags = ["wp", "packer"]
}

resource "google_compute_firewall" "allow_http_access" {
  name    = "allow-http-access"
  network = google_compute_network.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags   = ["wp"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-sql" {
  name    = "network-allow-mysql"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
  source_tags = ["wp"]
}