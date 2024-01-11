# ===================================
#             cloud-run
cloudrun_service_name = "postgres-test-service"

cloudrun_service_resource_limits = {
  cpu = 1,
  memory = "2Gi"
}

cloudrun_service_max_concurrency = 3
cloudrun_service_max_instance_count = 1

cloudrun_service_startup_probe = {
  type = "http_get"
  http_get_path = "/ready"

  period_seconds = 1
  failure_threshold = 20
}

cloudrun_service_vpc_access = {
  connector_from_remote_state = true
}

cloudrun_service_connect_to_cloudsql=true

cloudrun_service_env_variables = [
  {
    name = "ENABLE_INSTRUMENTATION"
    value = "true"
  }
]
# ===================================