data "google_secret_manager_secret_version_access" "cloudsql_user" {
  secret = "${var.cloudsql_user_secret_name}${var.project_resource_naming_suffix}"
}

data "google_secret_manager_secret_version_access" "cloudsql_password" {
  secret = "${var.cloudsql_password_secret_name}${var.project_resource_naming_suffix}"
}

module "cloudsql_server" {
  source = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "15.0.0"
  
  database_version    = var.cloudsql_database_version
  name                = "${var.cloudsql_server_name}${var.project_resource_naming_suffix}"
  project_id          = data.google_project.current.project_id
  zone                = var.cloudsql_server_zone
  deletion_protection = var.cloudsql_server_deletion_protection
  edition             = "ENTERPRISE"
  disk_type           = "PD_SSD"
  disk_size           = var.cloudsql_server_disk_size
  tier                = var.cloudsql_server_tier
  

  user_name     = data.google_secret_manager_secret_version_access.cloudsql_user.secret_data
  user_password = data.google_secret_manager_secret_version_access.cloudsql_password.secret_data

  ip_configuration = {
    allocated_ip_range  = null
    authorized_networks = []
    ipv4_enabled        = false
    private_network     = local.remote_network_state.vpc_network_id
    require_ssl         = true
  }

  depends_on = [ google_project_service.services ]
}

# =====================================================
#         database server and client certs

# server ca cert
data "google_sql_ca_certs" "cloudsql_server_ca_certs" {
  instance = module.cloudsql_server.instance_name

  depends_on = [ module.cloudsql_server ]
}
locals {
  cloudsql_server_ca_cert_furthest_expiration_time = reverse(sort([
    for k, v in data.google_sql_ca_certs.cloudsql_server_ca_certs.certs : v.expiration_time]))[0]

  cloudsql_server_latest_ca_cert = [
    for v in data.google_sql_ca_certs.cloudsql_server_ca_certs.certs : v 
      if v.expiration_time == local.cloudsql_server_ca_cert_furthest_expiration_time]
}
module "secret_manager_cloudsql_server_ca_cert" {
  source = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.1"

  project_id = data.google_project.current.project_id
  secrets = [
    {
      name                  = "${var.cloudsql_server_ca_cert_secret_name}${var.project_resource_naming_suffix}"
      automatic_replication = true
      secret_data           = local.cloudsql_server_latest_ca_cert[0].cert
    }
  ]
}

# client key and cert
resource "google_sql_ssl_cert" "cloudsql_client_cert" {
  common_name = "cloudsql_client_cert${var.project_resource_naming_suffix}"
  instance = module.cloudsql_server.instance_name

  depends_on = [ module.cloudsql_server ]
}
module "secret_manager_cloudsql_client_cert_key" {
  source = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.1"

  project_id = data.google_project.current.project_id
  secrets = [
    {
      name                  = "${var.cloudsql_client_cert_key_secret_name}${var.project_resource_naming_suffix}"
      automatic_replication = true
      secret_data           = google_sql_ssl_cert.cloudsql_client_cert.private_key
    }
  ]
}
module "secret-manager-client-cert" {
  source = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.1"

  project_id = data.google_project.current.project_id
  secrets = [
    {
      name                  = "${var.cloudsql_client_cert_secret_name}${var.project_resource_naming_suffix}"
      automatic_replication = true
      secret_data           = google_sql_ssl_cert.cloudsql_client_cert.cert
    }
  ]
}
# =====================================================
