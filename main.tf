resource "google_folder" "eu_i12e" {
  display_name = "eu-i12e"
  parent       = data.google_organization.lgr_enterprises.name
}
