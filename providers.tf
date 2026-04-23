terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.11.0"
    }
  }
}

provider "google" {
  project               = local.default_project_id
  region                = local.default_region
  user_project_override = true
  billing_project       = local.default_project_id
}
