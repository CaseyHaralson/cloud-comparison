locals {
  cloudsql_server_replicas = {
    for i, r in var.cloudsql_server_replicas : i => r
  }
}

resource "google_sql_database_instance" "replicas" {
  for_each = local.cloudsql_server_replicas

  database_version     = var.cloudsql_database_version
  name                 = "${var.cloudsql_server_name}${var.project_resource_naming_suffix}-rep${each.key}"
  project              = data.google_project.current.project_id
  region               = join("-", slice(split("-", each.value.zone), 0, 2))
  master_instance_name = module.cloudsql_server.instance_name
  deletion_protection  = var.cloudsql_server_deletion_protection

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = "db-f1-micro"
    activation_policy = "ALWAYS"

    ip_configuration {
      ipv4_enabled       = false
      private_network    = local.remote_network_state.vpc_network_id
      require_ssl        = true
      allocated_ip_range = null
    }

    location_preference {
      zone = each.value.zone
    }
  }

  depends_on = [ module.cloudsql_server ]
}

# =====================================================
#         database server and client certs

# server ca cert
data "google_sql_ca_certs" "cloudsql_server_replicas_ca_certs" {
  for_each = local.cloudsql_server_replicas

  instance = google_sql_database_instance.replicas[each.key].name

  depends_on = [ google_sql_database_instance.replicas ]
}
locals {
  cloudsql_server_replicas_ca_cert_furthest_expiration_time = {
    for i, r in google_sql_database_instance.replicas : i => 
    reverse(sort([for k, v in data.google_sql_ca_certs.cloudsql_server_replicas_ca_certs[i].certs : v.expiration_time]))[0]
  }

  cloudsql_server_replicas_latest_ca_cert = {
    for i, r in google_sql_database_instance.replicas : i => [
      for cert in data.google_sql_ca_certs.cloudsql_server_replicas_ca_certs[i].certs : cert
      if cert.expiration_time == [
        for k, v in local.cloudsql_server_replicas_ca_cert_furthest_expiration_time : v
        if k == i
      ][0]
    ][0]
  }
}
module "secret_manager_cloudsql_server_replicas_ca_cert" {
  for_each = local.cloudsql_server_replicas

  source = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.1"

  project_id = data.google_project.current.project_id
  secrets = [
    {
      name                  = "${var.cloudsql_server_ca_cert_secret_name}${var.project_resource_naming_suffix}-rep${each.key}"
      automatic_replication = true
      secret_data           = [
        for k, v in local.cloudsql_server_replicas_latest_ca_cert : v.cert
        if k == each.key
      ][0]
    }
  ]
}

# client key and cert
resource "google_sql_ssl_cert" "cloudsql_replicas_client_cert" {
  for_each = local.cloudsql_server_replicas

  common_name = "cloudsql_client_cert${var.project_resource_naming_suffix}-rep${each.key}"
  instance = google_sql_database_instance.replicas[each.key].name

  depends_on = [ google_sql_database_instance.replicas ]
}
module "secret_manager_cloudsql_replicas_client_cert_key" {
  for_each = local.cloudsql_server_replicas

  source = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.1"

  project_id = data.google_project.current.project_id
  secrets = [
    {
      name                  = "${var.cloudsql_client_cert_key_secret_name}${var.project_resource_naming_suffix}-rep${each.key}"
      automatic_replication = true
      secret_data           = [
        for k, v in google_sql_ssl_cert.cloudsql_replicas_client_cert : v.private_key
        if k == each.key
      ][0]
    }
  ]
}
module "secret-manager-cloudsql-replicas-client-cert" {
  for_each = local.cloudsql_server_replicas

  source = "GoogleCloudPlatform/secret-manager/google"
  version = "~> 0.1"

  project_id = data.google_project.current.project_id
  secrets = [
    {
      name                  = "${var.cloudsql_client_cert_secret_name}${var.project_resource_naming_suffix}-rep${each.key}"
      automatic_replication = true
      secret_data           = [
        for k, v in google_sql_ssl_cert.cloudsql_replicas_client_cert : v.cert
        if k == each.key
      ][0]
    }
  ]
}
# =====================================================
