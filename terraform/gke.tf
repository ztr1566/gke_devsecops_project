# GKE Cluster (Zonal)
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  
  location = var.zone 
  
  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
  deletion_protection = false

  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    disk_size_gb = 25
    disk_type    = "pd-standard" 
    machine_type = "e2-medium"
    image_type   = "COS_CONTAINERD"
  }
}

# Custom Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.zone 
  cluster    = google_container_cluster.primary.name
  node_count = 2 

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
    disk_type    = "pd-standard"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    labels = {
      env = "dev"
    }
  }
}