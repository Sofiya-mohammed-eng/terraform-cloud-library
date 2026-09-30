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

variable "storage_account_id" {
  description = "Resource ID of the storage account to grant read access to — wire this to the storage category's output"
  type        = string
  default     = "REPLACE_WITH_STORAGE_ACCOUNT_ID"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

resource "azurerm_user_assigned_identity" "blob_reader" {
  name                = "terraform-cloud-library-blob-reader"
  resource_group_name = "rg-terraform-cloud-library"
  location            = var.location
}

resource "azurerm_role_definition" "blob_read" {
  name        = "terraform-cloud-library-blob-read"
  scope       = var.storage_account_id
  description = "Minimal permissions to list and read blobs in one storage account"

  permissions {
    actions     = []
    not_actions = []
    data_actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
    ]
    not_data_actions = []
  }

  assignable_scopes = [
    var.storage_account_id,
  ]
}

resource "azurerm_role_assignment" "this" {
  scope              = var.storage_account_id
  role_definition_id = azurerm_role_definition.blob_read.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.blob_reader.principal_id
}

output "identity_principal_id" {
  value = azurerm_user_assigned_identity.blob_reader.principal_id
}

output "role_definition_id" {
  value = azurerm_role_definition.blob_read.role_definition_resource_id
}
