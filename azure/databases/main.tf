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

variable "db_admin_username" {
  description = "Administrator username"
  type        = string
  default     = "taskboardadmin"
}

variable "db_admin_password" {
  description = "Administrator password — supply via TF_VAR_db_admin_password, never commit a real value"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "Flexible Server SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-terraform-cloud-library-db"
  location = var.location
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "terraform-cloud-library-db"
  resource_group_name    = azurerm_resource_group.this.name
  location               = azurerm_resource_group.this.location
  version                = "16"
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  sku_name               = var.sku_name
  storage_mb             = 32768
  backup_retention_days  = 7

  public_network_access_enabled = false

  # Connecting privately additionally requires a delegated subnet and a
  # private DNS zone linked to the VNet from the networking category —
  # omitted here to keep this example focused on the server resource itself.

  tags = {
    project     = "terraform-cloud-library"
    category    = "databases"
    environment = "development"
  }
}

output "server_fqdn" {
  value = azurerm_postgresql_flexible_server.this.fqdn
}
