output "mig" {
  value = google_compute_region_instance_group_manager.mig.instance_group
}
output "heath" {
  value = google_compute_health_check.autohealing.id
}
output "mig-id" {
  value = google_compute_region_instance_group_manager.mig.id
}