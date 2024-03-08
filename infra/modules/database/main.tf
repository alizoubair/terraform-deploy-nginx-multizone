resource "google_sql_database_instance" "instance" {
    name             = "${var.region}-db-gce"
    database_version = var.db_settings.database_version
    region           = var.region
    settings {
        availability_type = var.availability_type
        backup_configuration {
            enabled            = true
            binary_log_enabled = true
        }
        tier = var.db_settings.database_tier
        ip_configuration {
            private_network = var.private_network_id
            ipv4_enabled    = true
        }
    }

    deletion_protection = false
    depends_on          = [google_service_networking_connection.private_vpc]
}

resource "google_sql_database" "db" {
    name      = var.db_settings.db_name
    charset   = "utf8"
    collation = "utf8_general_ci"
    instance  = google_sql_database_instance.instance.name
}

resource "google_sql_user" "db" {
    name     = var.db_settings.user_name
    instance = google_sql_database_instance.instance.name
    password = random_password.sql_password.result
}

resource "google_compute_global_address" "sql" {
    name          = "db-address-gce"
    purpose       = "VPC_PEERING"
    address_type  = "INTERNAL"
    prefix_length = 20
    network       = var.private_network_id
}

resource "google_service_networking_connection" "private_vpc" {
    network                 = var.private_network_id
    service                 = "servicenetworking.googleapis.com"
    reserved_peering_ranges = [
        google_compute_global_address.sql.name
    ]
}

resource "random_password" "sql_password" {
    length           = 20
    min_lower        = 4
    min_numeric      = 4
    min_special      = 4
    min_upper        = 4
    override_special = "!@#*()-_=+[]{}:?"
}

resource "google_secret_manager_secret" "sql_password" {
    secret_id = "db-password"
    project   = var.project_id

    replication {
      auto {}
    }
}

resource "google_secret_manager_secret_version" "sql_password" {
    secret      = google_secret_manager_secret.sql_password.id
    enabled     = true
    secret_data = random_password.sql_password.result
}

resource "google_secret_manager_secret_iam_member" "sql_password" {
    project   = google_secret_manager_secret.sql_password.project
    secret_id = google_secret_manager_secret.sql_password.secret_id
    role      = "roles/secretmanager.secretAccessor"
    member    = "serviceAccount:${var.service_account}"
}