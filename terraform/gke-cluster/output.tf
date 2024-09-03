output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

output "cluster_zone" {
  value = google_container_cluster.gke_cluster.location
}


output "gke_cluster_location" {
  value = google_container_cluster.gke_cluster.location
}

output "vpc_network_id" {
  value = google_compute_network.vpc_network.id
}