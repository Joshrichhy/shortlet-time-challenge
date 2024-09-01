output "cluster_name" {
  value = google_container_cluster.gke_cluster.name
}

output "cluster_endpoint" {
  value = google_container_cluster.gke_cluster.endpoint
}

# output "service_ip" {
#   value = kubernetes_service.time_service.status[0].load_balancer[0].ingress[0].ip
# }


output "cluster_zone" {
  value = google_container_cluster.gke_cluster.location
}
