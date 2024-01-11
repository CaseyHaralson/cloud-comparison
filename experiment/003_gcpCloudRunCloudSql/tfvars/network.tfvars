# ===================================
#             network
vpc_serverless_connectors_and_subnets = [
  {
    name = "serverless-central1"
    region = "us-central1"
    starting_ip = "172.16.8.0"
  }
]

vpc_private_service_access_addresses = [
  {
    starting_ip = "172.17.0.0"
    cidr_length = 24
  }
]
# ===================================
