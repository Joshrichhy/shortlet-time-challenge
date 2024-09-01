provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc_network" {
  name = "my-vpc-network"
}

# Create subnets
resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.id
  region        = var.region
}

# Create a NAT Gateway
resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  network = google_compute_network.vpc_network.id
  region  = var.region
}

resource "google_compute_router_nat" "nat_gw" {
  name                               = "nat-gateway"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Create Service Account for GKE
resource "google_service_account" "gke_service_account" {
  account_id   = "gke-service-account"
  display_name = "GKE Service Account"
}

# Assign roles to the service account
resource "google_project_iam_binding" "gke_sa_role" {
  project = var.project_id
  role    = "roles/container.clusterAdmin"
  members = ["serviceAccount:${google_service_account.gke_service_account.email}"]
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


