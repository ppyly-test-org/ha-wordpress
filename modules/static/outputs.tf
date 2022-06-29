output "static-ip" {
  value = google_compute_global_address.static-ip.address
}

output "static-ip1" {
  value = google_compute_address.static-ip1.address
}

output "ssl-cert" {
  value = google_compute_managed_ssl_certificate.sslCertificate.id
}