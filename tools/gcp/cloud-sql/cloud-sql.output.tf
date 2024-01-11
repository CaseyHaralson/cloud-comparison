output "cloudsql_server_ip" {
  value = module.cloudsql_server.private_ip_address
}

output "cloudsql_user_secret_name" {
  value = "${var.cloudsql_user_secret_name}${var.project_resource_naming_suffix}"
}

output "cloudsql_password_secret_name" {
  value = "${var.cloudsql_password_secret_name}${var.project_resource_naming_suffix}"
}

output "cloudsql_server_ca_cert_secret_name" {
  value = "${var.cloudsql_server_ca_cert_secret_name}${var.project_resource_naming_suffix}"
}

output "cloudsql_client_cert_key_secret_name" {
  value = "${var.cloudsql_client_cert_key_secret_name}${var.project_resource_naming_suffix}"
}

output "cloudsql_client_cert_secret_name" {
  value = "${var.cloudsql_client_cert_secret_name}${var.project_resource_naming_suffix}"
}
