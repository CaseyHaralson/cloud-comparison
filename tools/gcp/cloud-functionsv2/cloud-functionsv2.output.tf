output "functionv2_uri" {
  value = google_cloudfunctions2_function.functionv2.service_config[0].uri
}
