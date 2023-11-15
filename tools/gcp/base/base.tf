terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.34.0"
    }
  }
  backend "gcs" {
    bucket = "_TERRAFORM_BUCKET_"
    prefix = "_TERRAFORM_STATE_PREFIX_"
  }
}

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

data "google_project" "current" {
}
