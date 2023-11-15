output "cloudrun_source_bucket_url" {
  value = google_storage_bucket.cloudrun_source_bucket.url
}

output "cloudrun_source_name" {
  value = google_storage_bucket_object.cloudrun_source.name
}

output "cloudrun_artifact_repository_id" {
  value = google_artifact_registry_repository.cloudrun_artifact_repo.repository_id
}

output "cloudrun_service_uris" {
  value = values(google_cloud_run_v2_service.cloudrun_service)[*].uri
}

output "cloudrun_service_name" {
  value = values(google_cloud_run_v2_service.cloudrun_service)[0].name
}

output "cloudrun_service_locations" {
  value = values(google_cloud_run_v2_service.cloudrun_service)[*].location
}

output "cloudrun_service_loadbalancer_url" {
  value = var.cloudrun_service_create_loadbalancer ? "http://${module.cloudrun_loadbalancer[0].external_ip}" : null
}
