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

variable "bucket_name" {
  description = "Globally unique Cloud Storage bucket name — replace before planning or applying"
  type        = string
  default     = "replace-with-your-unique-bucket-name"
}

resource "google_storage_bucket" "this" {
  name                        = var.bucket_name
  location                    = "US"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  labels = {
    project     = "terraform-cloud-library"
    category    = "storage"
    environment = "development"
  }
}

output "bucket_name" {
  value = google_storage_bucket.this.name
}

output "bucket_url" {
  value = google_storage_bucket.this.url
}
