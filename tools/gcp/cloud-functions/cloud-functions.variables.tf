variable "function_name" {
  description = "The name of the function"
  type        = string
  default     = "hello-world-function"
}

variable "function_description" {
  description = "The description of the function"
  type        = string
  default     = ""
}

variable "function_region" {
  description = "The region where the function should be deployed"
  type        = string
  default     = "us-central1"
}

variable "function_runtime" {
  description = "The runtime for the function"
  type        = string
  default     = "nodejs18"
}

variable "function_entry_point" {
  description = "The entry point for the function"
  type        = string
  default     = "helloWorld"
}

variable "function_max_instances" {
  description = "The function max instance count during scaling"
  type        = number
  default     = 1
}

variable "function_min_instances" {
  description = "The function min instance count during scaling"
  type        = number
  default     = 0
}

variable "function_available_memory_mb" {
  description = "The available memory to the function"
  type        = number
  default     = 256
}

variable "function_timeout" {
  description = "The amount of time before the function times out"
  type        = number
  default     = 60
}