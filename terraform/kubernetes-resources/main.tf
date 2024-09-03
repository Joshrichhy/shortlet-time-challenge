provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "terraform_remote_state" "gke" {
  backend = "local"
  config = {
    path = "../gke-cluster/terraform.tfstate"
  }
}


resource "google_container_node_pool" "primary_nodes" {
  name       = "node-pool"
  cluster    = data.terraform_remote_state.gke.outputs.cluster_name
  location   = data.terraform_remote_state.gke.outputs.cluster_zone

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  node_count = 1
}


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

resource "google_compute_firewall" "allow_only_http_https" {
  name   = "allow-only-http-https"
 network = data.terraform_remote_state.gke.outputs.vpc_network_id
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8678" ]
  }

  direction = "INGRESS"
  priority  = 800

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "deny_all_other_ingress" {
  name   = "deny-all-other-ingress"
 network = data.terraform_remote_state.gke.outputs.vpc_network_id
  deny {
    protocol = "all"
  }

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["0.0.0.0/0"]
}

