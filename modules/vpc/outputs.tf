output "subnet" {
  value = google_compute_subnetwork.subnet1.id
}

output "priv-subnet" {
  value = google_compute_subnetwork.subnet.id
}

output "vpc-id" {
  value = google_compute_network.network.id
}

output "bastion-ip" {
  value = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
}
