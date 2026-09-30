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
}

variable "project_id" {
  description = "GCP project ID — replace before planning or applying"
  type        = string
  default     = "REPLACE_WITH_YOUR_GCP_PROJECT_ID"
}

variable "bucket_name" {
  description = "Name of the bucket to grant read access to — wire this to the storage category's bucket_name output"
  type        = string
  default     = "REPLACE_WITH_BUCKET_NAME"
}

resource "google_service_account" "bucket_reader" {
  account_id   = "tf-cloud-library-reader"
  display_name = "terraform-cloud-library bucket reader"
}

resource "google_project_iam_custom_role" "bucket_read" {
  role_id     = "terraformCloudLibraryBucketRead"
  title       = "terraform-cloud-library bucket read"
  description = "Minimal permissions to list and read objects in one bucket"

  permissions = [
    "storage.objects.list",
    "storage.objects.get",
  ]
}

resource "google_storage_bucket_iam_member" "this" {
  bucket = var.bucket_name
  role   = google_project_iam_custom_role.bucket_read.id
  member = "serviceAccount:${google_service_account.bucket_reader.email}"
}

output "service_account_email" {
  value = google_service_account.bucket_reader.email
}

output "custom_role_id" {
  value = google_project_iam_custom_role.bucket_read.id
}
