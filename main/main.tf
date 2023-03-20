data "vault_generic_secret" "gcp_auth" {
  path = "gcp/token/token-role-set"
}

provider "google" {
  project      = var.project_id
  access_token = data.vault_generic_secret.gcp_auth.data["token"]
  region       = var.region
}

provider "vault" {
  address = "http://vault.local_address"
}

terraform {
  backend "gcs" {
    bucket      = "terraform-state-bucket"
    prefix      = "statefiles"
    credentials = "credentials.json"
  }
}