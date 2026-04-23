terraform {
  backend "gcs" {
    bucket = "lgr-terraform"
    prefix = "eu-i12e"
  }
}
