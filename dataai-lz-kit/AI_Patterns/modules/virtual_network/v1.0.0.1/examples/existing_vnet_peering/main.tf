terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.

# This allows us to randomize the region for the resource group.
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "southeastasia"
  name     = "rg-example"
}

resource "azurerm_virtual_network" "local" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource-1"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "remote" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource-2"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.1.0.0/16"]
}

module "peering" {
  source = "../../modules/peering"

  name = "example-resource-local-to-remote"
  remote_virtual_network = {
    resource_id = azurerm_virtual_network.remote.id
  }
  virtual_network = {
    resource_id = azurerm_virtual_network.local.id
  }
  allow_forwarded_traffic              = true
  allow_gateway_transit                = true
  allow_virtual_network_access         = true
  create_reverse_peering               = true
  reverse_allow_forwarded_traffic      = false
  reverse_allow_gateway_transit        = false
  reverse_allow_virtual_network_access = true
  reverse_name                         = "example-resource-remote-to-local"
  reverse_use_remote_gateways          = false
  use_remote_gateways                  = false
}