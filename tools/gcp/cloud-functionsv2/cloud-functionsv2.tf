# ===================================================
#          source bucket and artifact repo

resource "random_id" "functionv2_bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "functionv2_source_bucket" {
  name                        = "${random_id.functionv2_bucket_prefix.hex}-gcf2-source${var.project_resource_naming_suffix}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "functionv2_source" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.functionv2_source_bucket.name
  source = "function-source.zip"

  depends_on = [ google_storage_bucket.functionv2_source_bucket ]
}
# ===================================================

# ===================================================
#                   function v2

resource "google_cloudfunctions2_function" "functionv2" {
  name        = "${var.functionv2_name}${var.project_resource_naming_suffix}"
  location    = var.functionv2_region
  description = var.functionv2_description

  build_config {
    runtime     = var.functionv2_runtime
    entry_point = var.functionv2_entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.functionv2_source_bucket.name
        object = google_storage_bucket_object.functionv2_source.name
      }
    }
  }

  service_config {
    max_instance_count = var.functionv2_max_instance_count
    min_instance_count = var.functionv2_min_instance_count
    available_memory   = var.functionv2_available_memory
    available_cpu      = var.functionv2_available_cpu 
    timeout_seconds    = var.functionv2_timeout_seconds
    max_instance_request_concurrency = var.functionv2_max_concurrency
  }

  lifecycle {
    replace_triggered_by = [ google_storage_bucket_object.functionv2_source ]
  }

  depends_on = [ google_project_service.services ]
}

resource "google_cloud_run_service_iam_binding" "functionv2_allusers_binding" {
  project        = google_cloudfunctions2_function.functionv2.project
  location       = google_cloudfunctions2_function.functionv2.location
  service        = google_cloudfunctions2_function.functionv2.name

  # function v2 uses cloud run
  role    = "roles/run.invoker"
  members = [
    "allUsers",
  ]

  depends_on = [ google_cloudfunctions2_function.functionv2 ]
}
# ===================================================
