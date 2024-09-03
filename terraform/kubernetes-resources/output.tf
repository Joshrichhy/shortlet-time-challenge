output "service_ip" {
  value = kubernetes_service.time_service.status[0].load_balancer[0].ingress[0].ip
}
