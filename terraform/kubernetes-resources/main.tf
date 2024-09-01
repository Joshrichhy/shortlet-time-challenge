provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"  # Path to your kubeconfig file
}

# resource "google_compute_network" "vpc_network" {
#   name = "my-vpc-network"
# }
#
# # Create subnets
# resource "google_compute_subnetwork" "subnet" {
#   name          = "gke-subnet"
#   ip_cidr_range = "10.0.0.0/24"
#   network       = google_compute_network.vpc_network.id
#   region        = var.region
# }
#
# # Create a NAT Gateway
# resource "google_compute_router" "nat_router" {
#   name    = "nat-router"
#   network = google_compute_network.vpc_network.id
#   region  = var.region
# }
#
# resource "google_compute_router_nat" "nat_gw" {
#   name                               = "nat-gateway"
#   router                             = google_compute_router.nat_router.name
#   region                             = var.region
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
# }
#
# # Create Service Account for GKE
# resource "google_service_account" "gke_service_account" {
#   account_id   = "gke-service-account"
#   display_name = "GKE Service Account"
# }
#
# # Assign roles to the service account
# resource "google_project_iam_binding" "gke_sa_role" {
#   project = var.project_id
#   role    = "roles/container.clusterAdmin"
#   members = ["serviceAccount:${google_service_account.gke_service_account.email}"]
# }

# # Create GKE Cluster
# resource "google_container_cluster" "primary" {
#   name     = "gke-cluster"
#   location = var.region
#
#   networking_mode = "VPC_NATIVE"
#   network         = google_compute_network.vpc_network.id
#   subnetwork      = google_compute_subnetwork.subnet.id
#
#   remove_default_node_pool = true
#   initial_node_count       = 1
#   deletion_protection = false
#
#   ip_allocation_policy {}
#
#   # Assign service account
#   node_config {
#     service_account = google_service_account.gke_service_account.email
#   }
# }

resource "google_container_node_pool" "primary_nodes" {
  name       = "node-pool"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  node_count = 1
}

# Define Kubernetes resources within Terraform (Deployment and Service)
resource "kubernetes_namespace" "time_namespace" {
  metadata {
    name = "time-namespace"
  }
}

resource "kubernetes_deployment" "time_deployment" {
  metadata {
    name      = "time-api"
    namespace = kubernetes_namespace.time_namespace.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "time-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "time-api"
        }
      }

      spec {
        container {
          name  = "time-api"
          image = "gcr.io/${var.project_id}/time-api:latest"
          port {
            container_port = 8678
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "time_service" {
  metadata {
    name      = "time-service"
    namespace = kubernetes_namespace.time_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "time-api"
    }

    port {
      port        = 80
      target_port = 8678
    }

    type = "LoadBalancer"
  }
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  direction = "INGRESS"

  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any IP address
}

resource "google_compute_firewall" "deny_all_ingress" {
  name    = "deny-all-ingress"
  network = google_compute_network.vpc_network.id

  deny {
    protocol = "all"
  }

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["0.0.0.0/0"]  # Allow traffic from any IP address
}

