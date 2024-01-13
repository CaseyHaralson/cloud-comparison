variable "cloudsql_user_secret_name" {
  description = "The secret name for the cloud sql user"
  type        = string
  default     = "PGUSER"
}

variable "cloudsql_password_secret_name" {
  description = "The secret name for the cloud sql password"
  type        = string
  default     = "PGPASSWORD"
}

variable "cloudsql_server_ca_cert_secret_name" {
  description = "The secret name where the cloud sql server ca cert will be stored"
  type        = string
  default     = "PGHOST_CA_CERT"
}

variable "cloudsql_client_cert_key_secret_name" {
  description = "The secret name where the cloud sql client cert key will be stored"
  type        = string
  default     = "PGCLIENT_KEY"
}

variable "cloudsql_client_cert_secret_name" {
  description = "The secret name where the cloud sql client cert will be stored"
  type        = string
  default     = "PGCLIENT_CERT"
}

variable "cloudsql_database_version" {
  description = "The cloud sql database version (like POSTGRES_14)"
  type        = string
  default     = "POSTGRES_14"
}

variable "cloudsql_server_name" {
  description = "The cloud sql server name"
  type        = string
  default     = "cloudsql-server"
}

variable "cloudsql_server_zone" {
  description = "The cloud sql server zone"
  type        = string
}

variable "cloudsql_server_deletion_protection" {
  description = "Should the cloud sql server be protected against deletion by Terraform?"
  type        = bool
  default     = true
}

variable "cloudsql_server_replicas" {
  description = "Cloud sql server replica information (blank for none)"
  type        = list(object({
    zone = string
  }))
  default     = []
}

variable "cloudsql_server_disk_size" {
  description = "The cloud sql server disk size in GB"
  type        = number
  default     = 10
}

variable "cloudsql_server_tier" {
  description = "The cloud sql server machine size"
  type        = string
  default     = "db-f1-micro" # db-f1-micro, db-g1-small, db-n1-standard-1, db-perf-optimized-N-2, etc...
}