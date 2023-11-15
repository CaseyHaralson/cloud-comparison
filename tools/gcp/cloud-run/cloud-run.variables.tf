variable "cloudrun_artifact_repository_region" {
  description = "The region where the cloud run artifact repository should be deployed"
  type        = string
  default     = "us-central1"
}

variable "cloudrun_artifact_repository_name" {
  description = "The id/name for the cloud run artifact repository"
  type        = string
  default     = "cloudrun-artifact-repo"
}

variable "cloudrun_service_name" {
  description = "The name of the cloud run service"
  type        = string
  default     = "hello-world-service"
}

variable "cloudrun_service_regions" {
  description = "The regions where the cloud run service should be deployed"
  type        = list(string)
  default     = ["us-central1"]
}

variable "cloudrun_service_ingress" {
  description = "The type of ingress that should be allowed to the cloud run service"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
}

variable "cloudrun_service_container_image" {
  description = "The container image that should be used in the cloud run service"
  type        = string
  default     = "_CONTAINER_IMAGE_"
}

variable "cloudrun_service_max_instance_count" {
  description = "The cloud run service max instance count during scaling"
  type        = number
  default     = 1
}

variable "cloudrun_service_min_instance_count" {
  description = "The cloud run service min instance count during scaling"
  type        = number
  default     = 0
}

variable "cloudrun_service_timeout_seconds" {
  description = "The amount of time before the cloud run service times out"
  type        = string
  default     = "300s"
}

variable "cloudrun_service_max_concurrency" {
  description = "The max number of concurrent requests each cloud run service instance can handle"
  type        = number
  default     = 80
}

variable "cloudrun_service_resource_limits" {
  description = "The resource limits for each cloud run service instance"
  type        = map(string)
  default     = {
    cpu    = "1"
    memory = "512Mi"
  }
}

variable "cloudrun_service_cpu_idle" {
  description = "Whether the cloud run service should idle the cpu between requests or keep the cpu active"
  type        = bool
  default     = false
}

variable "cloudrun_service_startup_cpu_boost" {
  description = "Whether the cloud run service should boost the cpu during startup"
  type        = bool
  default     = false
}

variable "cloudrun_service_startup_probe" {
  description = "The startup probe configuration for the cloud run service"
  type = object({
    type            = optional(string, "tcp_socket")
    http_get_path   = optional(string, "/")

    period_seconds    = optional(number, 10)
    failure_threshold = optional(number, 3)
    timeout_seconds   = optional(number, 1)
  })
  default = {
    period_seconds    = 240
    failure_threshold = 1
    timeout_seconds   = 240
  }
}

variable "cloudrun_infra_remote_state_prefix" {
  description = "The remote state prefix for the terraform infrastructure to be used by cloud run (blank for none)"
  type        = string
  default     = ""
}

variable "cloudrun_service_vpc_access" {
  description = "VPC access connector for the cloud run service"
  type = object({
    egress = optional(string, "PRIVATE_RANGES_ONLY")
  })
  default = null
}

variable "cloudrun_service_connect_to_cloudsql" {
  description = "Should the cloud run service connect to cloud sql?"
  type        = bool
  default     = false
}

variable "cloudrun_service_env_variables" {
  description = "Environment variables for the cloud run service"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "cloudrun_service_connect_to_memorystore" {
  description = "Should the cloud run service connect to memorystore?"
  type        = bool
  default     = false
}

variable "cloudrun_service_create_loadbalancer" {
  description = "Should a load balancer be created to stand in front of the cloud run service?"
  type        = bool
  default     = false
}

variable "cloudrun_service_directory_entry" {
  description = "Should a service directory endpoint be created for the cloud run service?"
  type        = bool
  default     = false
}

variable "cloudrun_service_auth0_secret_env_variables" {
  description = "Cloud run service env secrets to allow connection to Auth0 (null if shouldn't connect)"
  type        = object({
    base_url_env_name        = string
    issuer_base_url_env_name = string
    client_id_env_name       = string
    client_secret_env_name   = string
  })
  default     = null
}
