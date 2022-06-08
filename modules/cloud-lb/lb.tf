
resource "google_compute_backend_service" "wordpress-backend" {
  backend {
    group           = var.mig
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    max_utilization = 1
  }
  name          = "wordpress-backend"
  health_checks = [var.healthcheck]
}

resource "google_compute_url_map" "url-map" {
  name            = "url-map"
  default_service = google_compute_backend_service.wordpress-backend.id
}

resource "google_compute_target_https_proxy" "httpsProxy" {
  name             = "proxy"
  url_map          = google_compute_url_map.url-map.id
  ssl_certificates = [var.ssl-cert]
}

resource "google_compute_global_forwarding_rule" "load-balancer-rule" {
  name       = "https-forwarding-rule"
  ip_address = var.static-ip
  port_range = "443"
  target     = google_compute_target_https_proxy.httpsProxy.id
}

resource "google_compute_global_forwarding_rule" "http-redirect" {
  name       = "http-forwarding-rule"
  target     = google_compute_target_http_proxy.http-redirect.self_link
  ip_address = var.static-ip
  port_range = "80"
}

resource "google_compute_url_map" "http-redirect" {
  name = "http-redirect"
  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

resource "google_compute_target_http_proxy" "http-redirect" {
  name    = "http-redirect"
  url_map = google_compute_url_map.http-redirect.self_link
}

