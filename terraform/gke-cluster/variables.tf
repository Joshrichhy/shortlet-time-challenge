variable "project_id" {
  description = "The ID of the project in which to create resources."
  type        = string
}

variable "region" {
  description = "The region in which to create resources."
  default     = "us-central1"
  type        = string
}

variable "gke_service_account" {
  description = "The email of the service account to use for GKE."
  type        = string
}
