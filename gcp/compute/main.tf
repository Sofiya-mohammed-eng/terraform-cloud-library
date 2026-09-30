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

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "subnetwork" {
  description = "Subnetwork self-link to launch the instance into — wire this to an output from the networking category"
  type        = string
  default     = "REPLACE_WITH_SUBNETWORK_SELF_LINK"
}

variable "machine_type" {
  description = "Compute Engine machine type"
  type        = string
  default     = "e2-micro"
}

resource "google_service_account" "instance" {
  account_id   = "tf-cloud-library-compute"
  display_name = "terraform-cloud-library compute instance"
}

resource "google_compute_instance" "this" {
  name         = "terraform-cloud-library"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["terraform-cloud-library"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    # No access_config block — leaving this out means no external IP.
  }

  service_account {
    email  = google_service_account.instance.email
    scopes = ["cloud-platform"]
  }

  labels = {
    project     = "terraform-cloud-library"
    category    = "compute"
    environment = "development"
  }
}

output "instance_id" {
  value = google_compute_instance.this.id
}

output "internal_ip" {
  value = google_compute_instance.this.network_interface[0].network_ip
}
