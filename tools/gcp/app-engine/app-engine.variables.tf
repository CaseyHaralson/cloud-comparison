variable "app_service_name" {
  description = "The name of the app service"
  type        = string
  default     = "app"
}

variable "app_runtime" {
  description = "The runtime of the app service"
  type        = string
  default     = "nodejs18"
}

variable "app_version" {
  description = "The version of the app"
  type        = string
  default     = "_NEXT_VERSION_"
}

variable "app_instance_class" {
  description = "The instance class of the app"
  type        = string
  default     = "F1"
}

variable "app_entrypiont_shellcommand" {
  description = "The app entrypoint command"
  type        = string
  default     = "node ."
}

variable "app_max_concurrent_requests" {
  description = "The max number of concurrent requests before spawning a new app instance"
  type        = number
  default     = 10
}

variable "app_min_instances" {
  description = "The min number of app instances during scaling"
  type        = number
  default     = 0
}

variable "app_max_instances" {
  description = "The max number of app instances during scaling"
  type        = number
  default     = 1
}