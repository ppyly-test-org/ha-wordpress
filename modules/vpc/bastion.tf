resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = var.machine-type
  zone         = var.zone1

  tags = ["bastion"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network    = google_compute_network.network.id
    subnetwork = google_compute_subnetwork.subnet1.id
    access_config {
    }
  }
  metadata_startup_script = <<SCRIPT
sudo cat << EOF >> /etc/ssh/sshd_config
    PermitTTY no
    X11Forwarding no
    PermitTunnel no
    GatewayPorts no

    ForceCommand /usr/sbin/nologin
EOF
sudo systemctl restart sshd.service
SCRIPT
}