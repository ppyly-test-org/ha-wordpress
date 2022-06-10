resource "google_compute_global_address" "static-ip" {
  name = "static-ip"
  lifecycle {
  }
}

resource "google_compute_managed_ssl_certificate" "sslCertificate" {
  name = "google-cert"

  managed {
    domains = ["${var.domain}.", "www.${var.domain}."]
  }
  lifecycle {
  }
}

resource "google_dns_managed_zone" "dns-zone" {
  name     = "dns-zone"
  dns_name = "${var.domain}."
  lifecycle {
  }
}

resource "google_dns_record_set" "dns-records" {
  managed_zone = google_dns_managed_zone.dns-zone.name
  name         = "${var.domain}."
  type         = "A"
  rrdatas      = [google_compute_global_address.static-ip.address]
  ttl          = 300
  lifecycle {
  }
  depends_on = [google_compute_global_address.static-ip]
}

resource "google_dns_record_set" "cname" {
  name         = "www.${var.domain}."
  managed_zone = google_dns_managed_zone.dns-zone.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["${var.domain}."]
}