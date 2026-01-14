terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Backend Configuration (Remote State)
  backend "gcs" {
    bucket  = "tf-state-gke-devops-project"
    prefix  = "terraform/state-v2"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}