resource "google_sql_database_instance" "wordpress-db" {
  name                = "${var.name-base}-master"
  database_version    = var.sql-version
  depends_on          = [google_service_networking_connection.master-private-vpc-db-connection]
  deletion_protection = "false"
  settings {
    location_preference {
      zone = var.zone1
    }
    tier = var.db-tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc-id
    }
    backup_configuration {
      binary_log_enabled = true
      enabled            = true
    }
  }
}

resource "google_sql_database_instance" "wordpress-db-replica" {
  name                 = "${var.name-base}-slave"
  database_version     = var.sql-version
  depends_on           = [google_service_networking_connection.replica-private-vpc-db-connection]
  deletion_protection  = "false"
  master_instance_name = google_sql_database_instance.wordpress-db.name
  settings {
    location_preference {
      zone = var.zone2
    }
    tier = var.db-tier
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc-id
    }
  }
  replica_configuration {
    failover_target = true
  }
}

resource "google_sql_user" "users" {
  name     = var.username
  instance = google_sql_database_instance.wordpress-db.name
  host     = "%"
  password   = var.password
  depends_on = [google_sql_database_instance.wordpress-db]
}

resource "google_sql_database" "wordpress-database" {
  name     = var.db-name
  instance = google_sql_database_instance.wordpress-db.name
}

resource "google_compute_global_address" "private-ip" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = var.vpc-id
}

resource "google_service_networking_connection" "master-private-vpc-db-connection" {
  network                 = var.vpc-id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private-ip.name]
}
resource "google_service_networking_connection" "replica-private-vpc-db-connection" {
  network                 = var.vpc-id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private-ip.name]
}
