# ===================================
#             network
vpc_serverless_connectors_and_subnets = [
  {
    name = "serverless-central-1"
    region = "us-central1"
    starting_ip = "172.16.8.0"
  }
]

vpc_private_service_access_addresses = {
  starting_ip = "172.16.0.0"
  cidr_length = 24
}
# ===================================

# ===================================
#             cloud-sql
cloudsql_server_zone = "us-central1-a"
cloudsql_server_deletion_protection =  false
# ===================================
