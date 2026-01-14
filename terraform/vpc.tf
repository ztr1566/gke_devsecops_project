# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  region        = var.region 
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/24"

  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "gke-services-range"
    ip_cidr_range = "10.2.0.0/20"
  }
}