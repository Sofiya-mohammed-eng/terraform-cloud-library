terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "GCP project ID — replace before planning or applying"
  type        = string
  default     = "REPLACE_WITH_YOUR_GCP_PROJECT_ID"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "network" {
  description = "VPC network self-link — wire to the networking category's network_id output"
  type        = string
  default     = "REPLACE_WITH_NETWORK_SELF_LINK"
}

variable "subnetwork" {
  description = "Subnetwork self-link — wire to the networking category's subnet_id output"
  type        = string
  default     = "REPLACE_WITH_SUBNETWORK_SELF_LINK"
}

variable "machine_type" {
  description = "Machine type for the node pool"
  type        = string
  default     = "e2-medium"
}

resource "google_container_cluster" "this" {
  name     = "terraform-cloud-library"
  location = var.region

  network    = var.network
  subnetwork = var.subnetwork

  remove_default_node_pool = true
  initial_node_count       = 1

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

resource "google_service_account" "node" {
  account_id   = "tf-cloud-library-gke-node"
  display_name = "terraform-cloud-library GKE node"
}

resource "google_container_node_pool" "primary" {
  name       = "terraform-cloud-library-nodes"
  cluster    = google_container_cluster.this.name
  location   = var.region
  node_count = 1

  node_config {
    machine_type    = var.machine_type
    service_account = google_service_account.node.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = {
      project  = "terraform-cloud-library"
      category = "kubernetes"
    }
  }
}

output "cluster_name" {
  value = google_container_cluster.this.name
}

output "cluster_endpoint" {
  value     = google_container_cluster.this.endpoint
  sensitive = true
}
