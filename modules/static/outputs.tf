output "static-ip" {
  value = google_compute_global_address.static-ip.address
}

output "ssl-cert" {
  value = google_compute_managed_ssl_certificate.sslCertificate.id
}