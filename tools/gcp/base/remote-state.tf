# ===================================
#         remote network state
locals {
  use_remote_network_state = length(var.network_remotestate_prefix) > 0 ? true : false
  remote_network_state = local.use_remote_network_state ? data.terraform_remote_state.remote_network_state[0].outputs : null
}

data "terraform_remote_state" "remote_network_state" {
  count = local.use_remote_network_state ? 1 : 0

  backend = "gcs"
  config = {
    bucket = var.terraform_state_bucket
    prefix = var.network_remotestate_prefix
  }
}
# ===================================

# ===================================
#       remote cloudsql state
locals {
  use_remote_cloudsql_state = length(var.cloudsql_remotestate_prefix) > 0 ? true : false
  remote_cloudsql_state = local.use_remote_cloudsql_state ? data.terraform_remote_state.remote_cloudsql_state[0].outputs : null
}

data "terraform_remote_state" "remote_cloudsql_state" {
  count = local.use_remote_cloudsql_state ? 1 : 0

  backend = "gcs"
  config = {
    bucket = var.terraform_state_bucket
    prefix = var.cloudsql_remotestate_prefix
  }
}
# ===================================

# ===================================
#       remote memorystore state
locals {
  use_remote_memorystore_state = length(var.memorystore_remotestate_prefix) > 0 ? true : false
  remote_memorystore_state = local.use_remote_memorystore_state ? data.terraform_remote_state.remote_memorystore_state[0].outputs : null
}

data "terraform_remote_state" "remote_memorystore_state" {
  count = local.use_remote_memorystore_state ? 1 : 0

  backend = "gcs"
  config = {
    bucket = var.terraform_state_bucket
    prefix = var.memorystore_remotestate_prefix
  }
}
# ===================================