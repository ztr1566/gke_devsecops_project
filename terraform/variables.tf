variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The GCP Region for Networking (e.g., europe-west3)"
  type        = string
  default     = "europe-west3"
}

variable "zone" {
  description = "The GCP Zone for Compute/Cluster (e.g., europe-west3-b)"
  type        = string
  default     = "europe-west3-b"
}

variable "cluster_name" {
  description = "Name of the GKE Cluster"
  default     = "gke-devops-cluster"
}