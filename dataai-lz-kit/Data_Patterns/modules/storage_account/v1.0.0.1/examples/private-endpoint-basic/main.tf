
terraform {
  required_version = ">= 1.11"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

resource "random_string" "this" {
  length  = 3
  numeric = false
  special = false
  upper   = false
}

locals {
  storage_account_name = "stoavmdevswe001${random_string.this.result}"
}

resource "azurerm_resource_group" "this" {
  location = var.location
  name     = "rg-storage-pe-example"
}

resource "azurerm_virtual_network" "this" {
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  name                = "vnet-storage-pe-example"
}

resource "azurerm_subnet" "private_endpoints" {
  #checkov:skip=CKV2_AZURE_31:Example code - NSG not in scope
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "subnet-private-endpoints"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "storage-account"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.this.id
}

module "storage_account" {
  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash
  source = "../.."

  env            = "dev"
  au             = "0233985"
  owner          = "Infrastructure Team"
  app_code       = "infra"
  bu             = "IT"
  app_name       = "Test Application"
  business_unit  = "Information Technology"
  business_owner = "John Doe"
  budget_id      = "BUD-001"
  criticality    = "High"
  environment    = "Development"
  service        = "Storage"

  resource_group_name = azurerm_resource_group.this.name
  containers = {
    demo = {
      name = "demo"
    }
  }
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.blob.id]
      subnet_resource_id            = azurerm_subnet.private_endpoints.id
      subresource_name              = "blob"
    }
  }
}
