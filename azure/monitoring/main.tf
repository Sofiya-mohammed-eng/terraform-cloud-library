terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

variable "subscription_id" {
  description = "Azure subscription ID — replace before planning or applying"
  type        = string
  default     = "REPLACE_WITH_YOUR_AZURE_SUBSCRIPTION_ID"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "vm_id" {
  description = "VM resource ID to monitor — wire to the compute category's vm_id output"
  type        = string
  default     = "REPLACE_WITH_VM_ID"
}

variable "alert_email" {
  description = "Email address to notify on alarm"
  type        = string
  default     = "REPLACE_WITH_YOUR_EMAIL"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-terraform-cloud-library-monitoring"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "terraform-cloud-library-logs"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_action_group" "this" {
  name                = "terraform-cloud-library-alerts"
  resource_group_name = azurerm_resource_group.this.name
  short_name          = "tfcloudlib"

  email_receiver {
    name          = "primary"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_metric_alert" "high_cpu" {
  name                = "terraform-cloud-library-high-cpu"
  resource_group_name = azurerm_resource_group.this.name
  scopes              = [var.vm_id]
  description         = "CPU above 80% for 10 minutes"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}

output "action_group_id" {
  value = azurerm_monitor_action_group.this.id
}
