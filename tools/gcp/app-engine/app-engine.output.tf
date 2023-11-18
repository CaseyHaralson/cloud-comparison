output "app_engine_app_name" {
  value = google_app_engine_standard_app_version.app.service
}

# this url can't be figured out from the resource
# so have to manually compute it
# note: the "uc" portion of the url is the region...so its hardcoded for now
output "app_engine_app_uri" {
  value = "https://${google_app_engine_standard_app_version.app.service}-dot-${data.google_project.current.project_id}.uc.r.appspot.com/"
}
