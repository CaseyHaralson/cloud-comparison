# ===================================================
#          source bucket and artifact repo

resource "random_id" "function_bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "function_source_bucket" {
  name                        = "${random_id.function_bucket_prefix.hex}-gcf-source${var.project_resource_naming_suffix}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "function_source" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.function_source_bucket.name
  source = "function-source.zip"

  depends_on = [ google_storage_bucket.function_source_bucket ]
}
# ===================================================

# ===================================================
#                   function

resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  region      = var.function_region
  description = var.function_description

  runtime             = var.function_runtime
  entry_point         = var.function_entry_point
  available_memory_mb = var.function_available_memory_mb
  timeout             = var.function_timeout
  max_instances       = var.function_max_instances
  min_instances       = var.function_min_instances
  trigger_http        = true

  source_archive_bucket = google_storage_bucket.function_source_bucket.name
  source_archive_object = google_storage_bucket_object.function_source.name

  lifecycle {
    replace_triggered_by = [ google_storage_bucket_object.function_source ]
  }

  depends_on = [ google_project_service.services ]
}

resource "google_cloudfunctions_function_iam_member" "function_allusers_binding" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"

  depends_on = [ google_cloudfunctions_function.function ]
}
# ===================================================
