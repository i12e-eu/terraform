resource "google_folder" "eu_i12e" {
  display_name = "eu-i12e"
  parent       = data.google_organization.lgr_enterprises.name
}

module "production" {
  source = "./environments/production"

  folder_id       = google_folder.eu_i12e.name
  billing_account = data.google_billing_account.lgr_enterprises.id
}

module "staging" {
  source = "./environments/staging"

  folder_id       = google_folder.eu_i12e.name
  billing_account = data.google_billing_account.lgr_enterprises.id
}
