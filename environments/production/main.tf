module "project" {
  source = "git@github.com:lukeribchester/terraform.modules.git//modules/project?ref=v1.0.0"

  name       = "eu-i12e-production"
  project_id = "eu-i12e-production"

  org_id          = null
  folder_id       = var.folder_id
  billing_account = var.billing_account

  services = [
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

module "iam_workload_identity_pool" {
  source = "git@github.com:lukeribchester/terraform.modules.git//modules/iam_workload_identity_pool?ref=v1.0.0"

  project = module.project.project_id

  workload_identity_pool_id          = "github"
  workload_identity_pool_provider_id = "github"
  disabled                           = false

  attribute_condition = <<-COND
    assertion.repository_owner_id == "278406427" &&
    (
      attribute.repository == "i12e-eu/qwik" ||
      attribute.repository == "i12e-eu/rust"
    ) &&
    (
      assertion.ref == "refs/heads/main" ||
      assertion.ref == "refs/heads/development"
    ) &&
    assertion.ref_type == "branch"
COND
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  issuer_uri = "https://token.actions.githubusercontent.com"
}

module "artifact_registry_repository" {
  source = "git@github.com:lukeribchester/terraform.modules.git//modules/artifact_registry_repository?ref=v1.0.0"

  project = module.project.project_id

  repository_id = "qwik"
  location      = "europe-west4"
  format        = "DOCKER"

  readers = ["serviceAccount:${module.cloud_run.service_account_email}"]
  writers = [module.iam_workload_identity_pool.principal_set]
}

module "cloud_run" {
  source = "git@github.com:lukeribchester/terraform.modules.git//modules/cloud_run_service?ref=v1.0.0"

  project = module.project.project_id

  service_account_id = "qwik-run"

  name                = "qwik"
  location            = "europe-west4"
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  min_instance_count               = 1
  max_instance_count               = 10
  max_instance_request_concurrency = 80
  image                            = "europe-west4-docker.pkg.dev/eu-i12e-production/qwik/qwik:latest"

  domains = [
    "i12e.eu",
    "i12e.nl",
    "i12r.nl",
  ]

  developers            = [module.iam_workload_identity_pool.principal_set]
  service_account_users = [module.iam_workload_identity_pool.principal_set]
}
