variable "vpc_network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "private-network"
}

variable "vpc_network_subnets" {
  description = "Subnets for the network"
  type = list(object({
    name       = string
    cidr_group = string
    region     = string
    private    = optional(bool, true)
  }))
  default = []
}

variable "vpc_serverless_connectors_and_subnets" {
  description = "Serverless connectors and associated subnets in the network"
  type = list(object({
    name          = string
    region        = string
    starting_ip   = string
    machine_type  = optional(string, "e2-micro")
    min_instances = optional(number, 2)
    max_instances = optional(number, 3)
  }))
  default = []

  # TODO: add ability to plug in to shared vpc?
}

variable "vpc_private_service_access_addresses" {
  description = "Private service access addresses in the network"
  type = list(object({
    starting_ip = string
    cidr_length = number
  }))
  default = null
}