locals {
  vpc_network_subnets = flatten([[
    for subnet in var.vpc_network_subnets: {
      subnet_name           = "${subnet.name}${var.project_resource_naming_suffix}"
      subnet_ip             = subnet.cidr_group
      subnet_region         = subnet.region
      subnet_private_access = subnet.private
    }],
    [
      for sc in var.vpc_serverless_connectors_and_subnets: {
        subnet_name           = "${sc.name}${var.project_resource_naming_suffix}"
        subnet_ip             = "${sc.starting_ip}/28"
        subnet_region         = sc.region
        subnet_private_access = true
      }
    ]
  ])

  vpc_serverless_connectors = flatten([
    for sc in var.vpc_serverless_connectors_and_subnets: {
      name          = "${sc.name}${var.project_resource_naming_suffix}"
      region        = sc.region
      subnet_name   = "${sc.name}${var.project_resource_naming_suffix}"
      machine_type  = sc.machine_type
      min_instances = sc.min_instances
      max_instances = sc.max_instances
    }
  ])

  create_vpc_private_service_access = var.vpc_private_service_access_addresses != null ? true : false
}

module "vpc_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 5.0"

  project_id   = data.google_project.current.project_id
  network_name = "${var.vpc_network_name}${var.project_resource_naming_suffix}"
  subnets      = local.vpc_network_subnets

  depends_on = [ google_project_service.services ]
}

module "vpc_serverless_connector" {
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  version    = "~> 7.0"

  project_id     = data.google_project.current.project_id
  vpc_connectors = local.vpc_serverless_connectors
  
  depends_on = [ 
    google_project_service.services,
    module.vpc_network 
  ]
}

# =====================================================
#             private service access

# private VPC peering subnet that will be peered with 
resource "google_compute_global_address" "google-managed-services-range" {
  for_each = local.create_vpc_private_service_access == false ? {} : {
    for i, v in var.vpc_private_service_access_addresses : i => v
  }

  provider      = google-beta
  name          = "google-managed-services-${module.vpc_network.network_name}-${each.key}"
  purpose       = "VPC_PEERING"
  address       = each.value.starting_ip
  prefix_length = each.value.cidr_length
  address_type  = "INTERNAL"
  network       = module.vpc_network.network_self_link
}

# Creates the peering with the producer network.
resource "google_service_networking_connection" "private_service_access" {
  provider                = google-beta
  network                 = module.vpc_network.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    for a in google_compute_global_address.google-managed-services-range : a.name
  ]
}

# =====================================================