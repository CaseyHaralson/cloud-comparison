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

# ===================================
#          cloud-functions
function_name = "hello-world-function"
function_region = "us-central1"
function_runtime = "nodejs18"
function_entry_point = "helloWorld"
function_max_instances = 1
function_min_instances = 0
function_available_memory_mb = 2048
# ===================================

# ===================================
#         cloud-functions v2
functionv2_name = "hello-world-v2-function"
functionv2_region = "us-central1"
functionv2_runtime = "nodejs18"
functionv2_entry_point = "helloWorld"
functionv2_max_instance_count = 1
functionv2_min_instance_count = 0
functionv2_available_memory = "2G"
functionv2_available_cpu = 1
functionv2_max_concurrency = 1
# ===================================