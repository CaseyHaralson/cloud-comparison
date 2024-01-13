# ===================================
#             network
vpc_serverless_connectors_and_subnets = [
  {
    name = "serverless-central1"
    region = "us-central1"
    starting_ip = "172.16.8.0"
    machine_type = "f1-micro"
  }
]

vpc_private_service_access_addresses = [
  {
    starting_ip = "172.17.0.0"
    cidr_length = 24
  }
]
# ===================================
