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

variable "instance_id" {
  description = "Compute Engine instance ID to monitor — wire to the compute category's instance_id output"
  type        = string
  default     = "REPLACE_WITH_INSTANCE_ID"
}

variable "alert_email" {
  description = "Email address to notify on alarm"
  type        = string
  default     = "REPLACE_WITH_YOUR_EMAIL"
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "terraform-cloud-library-email"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

resource "google_monitoring_alert_policy" "high_cpu" {
  display_name = "terraform-cloud-library-high-cpu"
  combiner     = "OR"

  conditions {
    display_name = "CPU utilization above 80%"

    condition_threshold {
      filter = join(" AND ", [
        "resource.type = \"gce_instance\"",
        "resource.label.instance_id = \"${var.instance_id}\"",
        "metric.type = \"compute.googleapis.com/instance/cpu/utilization\"",
      ])
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "600s"

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]
}

output "notification_channel_id" {
  value = google_monitoring_notification_channel.email.id
}

output "alert_policy_id" {
  value = google_monitoring_alert_policy.high_cpu.id
}
