# ===================================
#             cloud-run
cloudrun_service_name = "hello-world-service"
cloudrun_artifact_repository_name = "cloudrun-artifact-repo"

cloudrun_service_regions = ["us-central1"]

cloudrun_service_resource_limits = {
  cpu = 1,
  memory = "2Gi"
}

cloudrun_service_cpu_idle = true
cloudrun_service_max_concurrency = 1
cloudrun_service_max_instance_count = 1
# ===================================