variable "functionv2_name" {
  description = "The name of the function"
  type        = string
  default     = "hello-world-v2-function"
}

variable "functionv2_description" {
  description = "The description of the function"
  type        = string
  default     = ""
}

variable "functionv2_region" {
  description = "The region where the function should be deployed"
  type        = string
  default     = "us-central1"
}

variable "functionv2_runtime" {
  description = "The runtime for the function"
  type        = string
  default     = "nodejs18"
}

variable "functionv2_entry_point" {
  description = "The entry point for the function"
  type        = string
  default     = "helloWorld"
}

variable "functionv2_max_instance_count" {
  description = "The function max instance count during scaling"
  type        = number
  default     = 1
}

variable "functionv2_min_instance_count" {
  description = "The function min instance count during scaling"
  type        = number
  default     = 0
}

variable "functionv2_available_memory" {
  description = "The available memory to the function"
  type        = string
  default     = "256M"
}

variable "functionv2_available_cpu" {
  description = "The available cpu to the function"
  type        = string
  default     = ".167"
}

variable "functionv2_timeout_seconds" {
  description = "The amount of time before the function times out"
  type        = number
  default     = 60
}

variable "functionv2_max_concurrency" {
  description = "The max number of concurrent requests each function instance can handle"
  type        = number
  default     = 1
}