output "db-ip" {
  value = google_sql_database_instance.wordpress-db.private_ip_address
}