resource "google_sql_database" "database" {
  name     = "db"
  instance = google_sql_database_instance.gae_sql.name
  depends_on              = [google_sql_database_instance.gae_sql, google_sql_user.user]
}

resource "google_sql_database_instance" "gae_sql" {
  name             = "gae-sql-instance"
  region           = var.region
  database_version = "MYSQL_5_7"
  settings {
        tier = "db-f1-micro"
        ip_configuration {
                ipv4_enabled = true
                # require_ssl = true
                
                authorized_networks {
                    name = "The Network"
                    value = "0.0.0.0/0"
                }
                # authorized_networks  {
                #     name = "${google_compute_network.name}"
                #     value = "${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip}/24"
                # }
        }   
    }
  
  deletion_protection  = "false"
}

resource "google_sql_user" "user" {
    name = "user"
    instance = google_sql_database_instance.gae_sql.name
    host = "%"
    password = "${data.google_secret_manager_secret_version.gibberish.secret_data}"
    depends_on              = [google_sql_database_instance.gae_sql]
}

# resource "google_sql_user" "root" {
#     name = "Root"
#     instance = google_sql_database_instance.issuedb.name
#     host = "%"
#     password = "${data.google_secret_manager_secret_version.db_pass.secret_data}"
# }

output "gcp_mysql_ip" {
  value = "${google_sql_database_instance.gae_sql.first_ip_address}"
}
