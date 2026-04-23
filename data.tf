data "google_organization" "lgr_enterprises" {
  organization = "501551464420"
}

data "google_billing_account" "lgr_enterprises" {
  billing_account = "01D9AE-D3F96C-EF9910"
  open            = true
}
