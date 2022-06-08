resource "google_compute_network" "network" {
  name                    = "test-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "test-subnet"
  ip_cidr_range            = "10.10.0.0/24"
  network                  = google_compute_network.network.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "subnet1" {
  name                     = "test-subnet1"
  ip_cidr_range            = "10.10.10.0/24"
  network                  = google_compute_network.network.self_link
  private_ip_google_access = true
}


resource "google_compute_router" "my-router" {
  name    = "my-router"
  network = google_compute_network.network.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.my-router.name
  region                             = google_compute_router.my-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}