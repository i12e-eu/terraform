module "project" {
  source = "git@github.com:lukeribchester/terraform.modules.git//modules/project?ref=v1.0.0"

  name       = "eu-i12e-staging"
  project_id = "eu-i12e-staging"

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
