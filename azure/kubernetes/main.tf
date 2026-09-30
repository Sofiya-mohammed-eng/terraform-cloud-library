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

variable "subnet_id" {
  description = "Subnet for the node pool — wire to the networking category's subnet_id output"
  type        = string
  default     = "REPLACE_WITH_SUBNET_ID"
}

variable "node_vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_B2s"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-terraform-cloud-library-aks"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = "terraform-cloud-library"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "tfcloudlibrary"

  private_cluster_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = var.node_vm_size
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    project     = "terraform-cloud-library"
    category    = "kubernetes"
    environment = "development"
  }
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.this.id
}
