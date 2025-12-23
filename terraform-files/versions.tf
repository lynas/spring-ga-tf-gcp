terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.12"
    }
    # Used for the local docker build/push
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
  backend "gcs" {
    bucket = "terraform-state-bucket-${var.project_id}"
    prefix = "terraform/state"
  }
}

# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}