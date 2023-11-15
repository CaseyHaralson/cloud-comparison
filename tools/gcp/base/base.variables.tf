variable "project_id" {
  description = "The GCP project id"
  type        = string
}

variable "terraform_state_bucket" {
  description = "The bucket that holds the terraform state for the project"
  type        = string
}

variable "project_resource_naming_suffix" {
  description = "A suffix to add to names created for this project"
  type        = string
  default     = ""

  validation {
    condition     = length(regexall("_", var.project_resource_naming_suffix)) == 0
    error_message = "The project resource naming suffix can't contain underscores"
  }
}
