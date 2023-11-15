locals {
  create_cloudrun_service_http_startup_probe = var.cloudrun_service_startup_probe.type == "http_get" && length(regexall("google-samples", var.cloudrun_service_container_image)) == 0 ? true : false

  # create an object of {region: connector_id}
  cloudrun_vpc_access = var.cloudrun_service_vpc_access == null ? null : {
    for r in var.cloudrun_service_regions : r => [
      for c in local.remote_network_state.vpc_serverless_connector_ids : c
      if length(regexall("${r}", c)) > 0
    ][0]
  }

  # cloud sql environment variables
  cloudrun_cloudsql_env_variables = var.cloudrun_service_connect_to_cloudsql == false ? [] : [
    {
      name  = "PGHOST"
      value = local.remote_cloudsql_state.cloudsql_server_ip
    },
  ]
  cloudrun_secret_cloudsql_env_variables = var.cloudrun_service_connect_to_cloudsql == false ? [] : [
    {
      env_name = "PGUSER"
      secret   = local.remote_cloudsql_state.cloudsql_user_secret_name
    },
    {
      env_name = "PGPASSWORD"
      secret   = local.remote_cloudsql_state.cloudsql_password_secret_name
    },
    {
      env_name = "PGHOST_CA_CERT"
      secret   = local.remote_cloudsql_state.cloudsql_server_ca_cert_secret_name
    },
    {
      env_name = "PGCLIENT_KEY"
      secret   = local.remote_cloudsql_state.cloudsql_client_cert_key_secret_name
    },
    {
      env_name = "PGCLIENT_CERT"
      secret   = local.remote_cloudsql_state.cloudsql_client_cert_secret_name
    }
  ]
  cloudrun_cloudsql_replica_env_variables = var.cloudrun_service_connect_to_cloudsql == false ? [] : flatten([
    for k, v in local.remote_cloudsql_state.cloudsql_server_replicas_data : [
      {
        name  = "PGREPLICA_${replace(k, "-", "_")}_HOST"
        value = v.ip
      }
    ]
  ])
  cloudrun_secret_cloudsql_replica_env_variables = var.cloudrun_service_connect_to_cloudsql == false ? [] : flatten([
    for k, v in local.remote_cloudsql_state.cloudsql_server_replicas_data : [
      {
        env_name = "PGREPLICA_${replace(k, "-", "_")}_HOST_CA_CERT"
        secret   = v.ca_cert_secret_name
      },
      {
        env_name = "PGREPLICA_${replace(k, "-", "_")}_CLIENT_KEY"
        secret   = v.client_cert_key_secret_name
      },
      {
        env_name = "PGREPLICA_${replace(k, "-", "_")}_CLIENT_CERT"
        secret   = v.client_cert_secret_name
      }
    ]
  ])
  cloudrun_cloudsql_location_specific_env_variables = {
    for r in var.cloudrun_service_regions : r => var.cloudrun_service_connect_to_cloudsql == false ? [] : flatten([
      for k, v in local.remote_cloudsql_state.cloudsql_server_replicas_data : {
        name = "PGREPLICA_KEY"
        value = replace(k, "-", "_")
      }
      if k == r
    ])
  }

  # memorystore environment variables
  cloudrun_memorystore_env_variables = {
    for r in var.cloudrun_service_regions : r => var.cloudrun_service_connect_to_memorystore == false ? [] : [
      {
        name  = "REDIS_HOST"
        value = [
          for k, v in local.remote_memorystore_state.memorystore_data : v.ip
          if k == r
        ][0]
      },
      {
        name  = "REDIS_PORT"
        value = [
          for k, v in local.remote_memorystore_state.memorystore_data : v.port
          if k == r
        ][0]
      }
    ]
  }
  cloudrun_secret_memorystore_env_variables = {
    for r in var.cloudrun_service_regions : r => var.cloudrun_service_connect_to_memorystore == false ? [] : flatten([
      local.remote_memorystore_state.memorystore_auth_enabled == false ? [] : [
        {
          env_name = "REDIS_AUTH_PASS"
          secret   = [
            for k, v in local.remote_memorystore_state.memorystore_data : v.auth_string_secret_name
            if k == r
          ][0]
        }
      ],
      local.remote_memorystore_state.memorystore_tls_enabled == false ? [] : [
        {
          env_name = "REDIS_HOST_CERT"
          secret   = [
            for k, v in local.remote_memorystore_state.memorystore_data : v.host_ca_cert_secret_name
            if k == r
          ][0]
        }
      ]
    ])
  }

  # auth0 environment variables
  cloudrun_secret_auth0_env_variables = var.cloudrun_service_auth0_secret_env_variables == null ? [] : [
    {
      env_name = "AUTH0_BASE_URL"
      secret   = var.cloudrun_service_auth0_secret_env_variables.base_url_env_name
    },
    {
      env_name = "AUTH0_ISSUER_BASE_URL"
      secret   = var.cloudrun_service_auth0_secret_env_variables.issuer_base_url_env_name
    },
    {
      env_name = "AUTH0_CLIENT_ID"
      secret   = var.cloudrun_service_auth0_secret_env_variables.client_id_env_name
    },
    {
      env_name = "AUTH0_CLIENT_SECRET"
      secret   = var.cloudrun_service_auth0_secret_env_variables.client_secret_env_name
    }
  ]

  # combine the environment variables
  cloudrun_env_variables = {
    for r in var.cloudrun_service_regions : r => flatten([
      var.cloudrun_service_env_variables,
      local.cloudrun_cloudsql_env_variables,
      local.cloudrun_cloudsql_replica_env_variables,
      [for k, v in local.cloudrun_cloudsql_location_specific_env_variables : v if k == r],
      [for k, v in local.cloudrun_memorystore_env_variables : v if k == r]
    ])
  }
  cloudrun_secret_env_variables = {
    for r in var.cloudrun_service_regions : r => flatten([
      local.cloudrun_secret_cloudsql_env_variables,
      local.cloudrun_secret_cloudsql_replica_env_variables,
      [for k, v in local.cloudrun_secret_memorystore_env_variables : v if k == r],
      local.cloudrun_secret_auth0_env_variables
    ])
  }
}

# ===================================================
#          source bucket and artifact repo

resource "random_id" "cloudrun_source_bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "cloudrun_source_bucket" {
  name                        = "${random_id.cloudrun_source_bucket_prefix.hex}-gcr-source${var.project_resource_naming_suffix}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "cloudrun_source" {
  name   = "container-source.zip"
  bucket = google_storage_bucket.cloudrun_source_bucket.name
  source = "container-source.zip"

  depends_on = [ google_storage_bucket.cloudrun_source_bucket ]
}

resource "google_artifact_registry_repository" "cloudrun_artifact_repo" {
  location      = var.cloudrun_artifact_repository_region
  repository_id = "${var.cloudrun_artifact_repository_name}${var.project_resource_naming_suffix}"
  format        = "DOCKER"
}
# ===================================================

# ===================================================
#               cloud run service

resource "google_cloud_run_v2_service" "cloudrun_service" {
  for_each = toset(var.cloudrun_service_regions)

  name     = "${var.cloudrun_service_name}${var.project_resource_naming_suffix}"
  location = each.value
  ingress  = var.cloudrun_service_ingress

  template {
    timeout                          = var.cloudrun_service_timeout_seconds
    max_instance_request_concurrency = var.cloudrun_service_max_concurrency

    scaling {
      max_instance_count = var.cloudrun_service_max_instance_count
      min_instance_count = var.cloudrun_service_min_instance_count
    }

    containers {
      image = var.cloudrun_service_container_image
      resources {
        limits            = var.cloudrun_service_resource_limits
        cpu_idle          = var.cloudrun_service_cpu_idle
        startup_cpu_boost = var.cloudrun_service_startup_cpu_boost
      }

      startup_probe {
        period_seconds    = var.cloudrun_service_startup_probe.period_seconds
        failure_threshold = var.cloudrun_service_startup_probe.failure_threshold
        timeout_seconds   = var.cloudrun_service_startup_probe.timeout_seconds
        
        # conditionally create http startup probe or fallback to original tcp startup probe
        dynamic "http_get" {
          for_each = local.create_cloudrun_service_http_startup_probe ? [1] : []
          content {
            path = var.cloudrun_service_startup_probe.http_get_path
          }
        }
        dynamic "tcp_socket" {
          for_each = local.create_cloudrun_service_http_startup_probe ? [] : [1]
          content {}
        }
      }

      env {
        name  = "GCP_PROJECT_ID"
        value = data.google_project.current.project_id
      }
      env {
        name  = "GCP_REGION"
        value = each.value
      }

      # add any configured environment variables
      dynamic "env" {
        for_each = [for k, v in local.cloudrun_env_variables : v if k == each.value][0]

        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      # add any configured secret environment variables
      dynamic "env" {
        for_each = [for k, v in local.cloudrun_secret_env_variables : v if k == each.value][0]

        content {
          name = env.value.env_name
          value_source {
            secret_key_ref {
              secret  = env.value.secret
              version = "latest"
            }
          }
        }
      }
    }

    dynamic "vpc_access" {
      for_each = local.cloudrun_vpc_access == null ? [] : [1]

      content {
        connector = [
          for k, v in local.cloudrun_vpc_access : v
          if k == each.value
        ][0]
        egress    = var.cloudrun_service_vpc_access.egress
      }
    }

    labels = {
      service : "${var.cloudrun_service_name}${var.project_resource_naming_suffix}"
      type    : "cloudrun_service"
    }
  }

  # since we change images outside of terraform
  # don't let terraform update the resource based on image changes
  # or based on the fact that we made changes manually
  # lifecycle {
  #   ignore_changes = [ 
  #     template[0].containers[0].image,
  #     client,
  #     client_version,
  #     template[0].revision
  #   ]
  # }

  depends_on = [ google_project_service.services ]
}

resource "google_cloud_run_v2_service_iam_binding" "binding" {
  for_each = toset(var.cloudrun_service_regions)

  project  = google_cloud_run_v2_service.cloudrun_service[each.key].project
  location = google_cloud_run_v2_service.cloudrun_service[each.key].location
  name     = google_cloud_run_v2_service.cloudrun_service[each.key].name

  role = "roles/run.invoker"
  members = [
    "allUsers",
  ]

  depends_on = [ google_cloud_run_v2_service.cloudrun_service ]
}

# allow cloudrun service to access configured secret values
resource "google_secret_manager_secret_iam_member" "cloudrun_secret_access" {
  for_each = toset(flatten([
    for k, v in local.cloudrun_secret_env_variables : [
      for k2, v2 in v : v2.secret
    ]
  ]))

  secret_id = each.value
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
}
# ===================================================

# ===================================================
#               load balancer

resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  for_each = toset(var.cloudrun_service_regions)

  name                  = "${var.cloudrun_service_name}-neg${var.project_resource_naming_suffix}"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_v2_service.cloudrun_service[each.key].location
  
  cloud_run {
    service = google_cloud_run_v2_service.cloudrun_service[each.key].name
  }

  depends_on = [ google_cloud_run_v2_service.cloudrun_service ]
}

module "cloudrun_loadbalancer" {
  source            = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version           = "~> 9.0"

  count = var.cloudrun_service_create_loadbalancer ? 1 : 0

  project = data.google_project.current.project_id
  name    = "${var.cloudrun_service_name}-lb${var.project_resource_naming_suffix}"

  ssl = false
  managed_ssl_certificate_domains = []
  https_redirect = false
  backends = {
    default = {
      description                     = null
      protocoldescription             = null
      protocol                        = "HTTP"
      # port_name                       = var.service_port_name
      enable_cdn                      = false
      custom_request_headers          = null
      custom_response_headers         = null
      security_policy                 = null
      compression_mode                = null

      log_config = {
        enable = true
        sample_rate = 1.0
      }

      groups = [
        for neg in google_compute_region_network_endpoint_group.cloudrun_neg:
        {
          group = neg.id
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }

  labels = {
    service : "${var.cloudrun_service_name}${var.project_resource_naming_suffix}"
    type    : "loadbalancer"
  }

  depends_on = [ google_compute_region_network_endpoint_group.cloudrun_neg ]
}
# ===================================================

# ===================================================
#               service directory

resource "google_service_directory_endpoint" "cloudrun_service_directory_endpoint" {
  for_each = var.cloudrun_service_directory_entry ? toset(var.cloudrun_service_regions) : []

  provider    = google-beta
  endpoint_id = "${each.value}-${var.cloudrun_service_name}${var.project_resource_naming_suffix}"
  service     = "projects/${data.google_project.current.project_id}/locations/us-central1/namespaces/service-directory/services/services"

  metadata = {
    service_name = google_cloud_run_v2_service.cloudrun_service[each.key].name
    region       = each.value
    uri          = google_cloud_run_v2_service.cloudrun_service[each.key].uri
  }

  depends_on = [ google_cloud_run_v2_service.cloudrun_service ]
}
# ===================================================
