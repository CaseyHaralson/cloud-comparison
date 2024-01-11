output "vpc_network_name" {
  value = module.vpc_network.network_name
}

output "vpc_network_id" {
  value = module.vpc_network.network_id
}

# output "vpc_network_subnets" {
#   value = module.vpc_network.subnets
# }

output "vpc_serverless_connector_ids" {
  value = module.vpc_serverless_connector.connector_ids
}
