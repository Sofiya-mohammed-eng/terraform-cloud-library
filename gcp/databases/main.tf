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

variable "private_network" {
  description = "Self-link of the VPC network for private IP — wire this to the networking category's network_id output"
  type        = string
  default     = "REPLACE_WITH_NETWORK_SELF_LINK"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "taskboard"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "taskboard"
}

variable "db_password" {
  description = "Database user password — supply via TF_VAR_db_password, never commit a real value"
  type        = string
  sensitive   = true
}

variable "tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-f1-micro"
}

resource "google_sql_database_instance" "this" {
  name             = "terraform-cloud-library"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.private_network
    }

    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "this" {
  name     = var.db_name
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "this" {
  name     = var.db_user
  instance = google_sql_database_instance.this.name
  password = var.db_password
}

output "instance_connection_name" {
  value = google_sql_database_instance.this.connection_name
}

output "private_ip_address" {
  value = google_sql_database_instance.this.private_ip_address
}
