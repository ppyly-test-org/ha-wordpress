output "wp-mig" {
  value = google_compute_region_instance_group_manager.wp-mig.instance_group
}
output "wp-heath" {
  value = google_compute_health_check.autohealing.id
}