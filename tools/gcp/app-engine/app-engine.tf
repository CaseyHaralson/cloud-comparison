# ===================================================
#          source bucket and artifact repo

resource "random_id" "app_bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "app_source_bucket" {
  name                        = "${random_id.app_bucket_prefix.hex}-gca-source${var.project_resource_naming_suffix}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "app_source" {
  name   = "app-source.zip"
  bucket = google_storage_bucket.app_source_bucket.name
  source = "app-source.zip"

  depends_on = [ google_storage_bucket.app_source_bucket ]
}
# ===================================================

# ===================================================
#                   app engine

resource "google_app_engine_standard_app_version" "app" {
  service        = "${var.app_service_name}${var.project_resource_naming_suffix}"
  runtime        = var.app_runtime
  version_id     = var.app_version
  instance_class = var.app_instance_class

  entrypoint {
    shell = var.app_entrypiont_shellcommand
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_storage_bucket.app_source_bucket.name}/${google_storage_bucket_object.app_source.name}"
    }
  }

  automatic_scaling {
    max_concurrent_requests = var.app_max_concurrent_requests
    standard_scheduler_settings {
      min_instances = var.app_min_instances
      max_instances = var.app_max_instances
    }
  }

  delete_service_on_destroy = true

  depends_on = [ google_project_service.services ]
}
# ===================================================
