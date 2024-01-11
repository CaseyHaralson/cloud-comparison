output "cloudsql_server_replicas_data" {
  value = {
    for i, r in google_sql_database_instance.replicas : r.region => {
      "ip" = r.private_ip_address,
      "ca_cert_secret_name" = "${var.cloudsql_server_ca_cert_secret_name}${var.project_resource_naming_suffix}-rep${i}",
      "client_cert_key_secret_name" = "${var.cloudsql_client_cert_key_secret_name}${var.project_resource_naming_suffix}-rep${i}",
      "client_cert_secret_name" = "${var.cloudsql_client_cert_secret_name}${var.project_resource_naming_suffix}-rep${i}"
    }
  }
}