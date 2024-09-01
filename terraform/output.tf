output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "service_ip" {
  value = kubernetes_service.time_service.status[0].load_balancer[0].ingress[0].ip
}
