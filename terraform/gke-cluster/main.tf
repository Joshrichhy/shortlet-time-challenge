provider "google" {
  project = var.project_id
  region  = var.region
}


# Create GKE Cluster
resource "google_container_cluster" "gke_cluster" {
  name     = "time-api-gke-cluster"
  location = var.region

  networking_mode = "VPC_NATIVE"
  network         = google_compute_network.vpc_network.id
  subnetwork      = google_compute_subnetwork.subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = false

  ip_allocation_policy {}

  # Assign service account
  node_config {
    service_account = google_service_account.gke_service_account.email
  }
}


output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "cluster_zone" {
  value = google_container_cluster.gke_cluster.location
}
