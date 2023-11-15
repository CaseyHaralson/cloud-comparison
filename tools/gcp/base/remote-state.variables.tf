variable "network_remotestate_prefix" {
  description = "The remote state prefix for the terraform network (blank for none)"
  type        = string
  default     = ""
}

variable "cloudsql_remotestate_prefix" {
  description = "The remote state prefix for the terraform cloudsql (blank for none)"
  type        = string
  default     = ""
}

variable "memorystore_remotestate_prefix" {
  description = "The remote state prefix for the terraform memorystore (blank for none)"
  type        = string
  default     = ""
}