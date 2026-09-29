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

variable "storage_account_name" {
  description = "Globally unique storage account name: lowercase letters and numbers only, 3-24 chars — replace before planning or applying"
  type        = string
  default     = "replaceuniquestorageacct"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-terraform-cloud-library"
  location = var.location
}

resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
  }

  tags = {
    project     = "terraform-cloud-library"
    category    = "storage"
    environment = "development"
  }
}

resource "azurerm_storage_container" "this" {
  name                  = "portfolio-files"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "container_name" {
  value = azurerm_storage_container.this.name
}
