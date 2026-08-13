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

locals {
  address_space = "10.0.0.0/16"
  subnets = {
    for i in range(2) :
    "subnet${i}" => {
      name             = "example-resource${i}"
      address_prefixes = [cidrsubnet(local.address_space, 8, i)]
    }
  }
}

resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

module "subnets" {
  source   = "../../modules/subnet"
  for_each = local.subnets

  name = each.value.name
  virtual_network = {
    resource_id = azurerm_virtual_network.this.id
  }
  address_prefixes = each.value.address_prefixes
}