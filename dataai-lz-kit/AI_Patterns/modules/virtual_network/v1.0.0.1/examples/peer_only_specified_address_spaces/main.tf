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

#Defining the first virtual network (vnet-1) with its subnets and settings.
module "vnet1" {
  source = "../../"

  env             = "dev"
  au              = "0233985"
  owner           = "Infrastructure Team"
  app_code        = "infra"
  bu              = "IT"
  product_version = "1.0"
  app_name        = "Test Application"
  app_support     = "support@example.com"
  business_unit   = "Information Technology"
  business_owner  = "John Doe"
  budget_id       = "BUD-001"
  criticality     = "High"
  environment     = "Development"
  service         = "vnet"

  address_space       = ["10.4.0.0/16", "10.5.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name
  name                = "example-resource-1"
  subnets = {
    subnet1 = {
      name             = "example-resource-1-1"
      address_prefixes = ["10.4.1.0/24", "10.4.2.0/24"]
    }
    subnet2 = {
      name             = "example-resource-1-2"
      address_prefixes = ["10.4.3.0/24", "10.4.4.0/24"]
    }
    subnet3 = {
      name             = "example-resource-1-3"
      address_prefixes = ["10.5.5.0/24", "10.5.6.0/24"]
    }
  }
}

module "vnet2" {
  source = "../../"

  env             = "dev"
  au              = "0233985"
  owner           = "Infrastructure Team"
  app_code        = "infra"
  bu              = "IT"
  product_version = "1.0"
  app_name        = "Test Application"
  app_support     = "support@example.com"
  business_unit   = "Information Technology"
  business_owner  = "John Doe"
  budget_id       = "BUD-001"
  criticality     = "High"
  environment     = "Development"
  service         = "vnet"

  address_space       = ["10.6.0.0/16", "10.7.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name
  name                = "example-resource-2"
  peerings = {
    peertovnet1 = {
      name                               = "example-resource-vnet2-to-vnet1"
      remote_virtual_network_resource_id = module.vnet1.resource_id
      allow_forwarded_traffic            = true
      allow_gateway_transit              = true
      allow_virtual_network_access       = true
      peer_complete_vnets                = false
      local_peered_address_spaces = [
        {
          address_prefix = "10.6.1.0/24"
        },
        {
          address_prefix = "10.6.2.0/24"
        }
      ]
      remote_peered_address_spaces = [
        {
          address_prefix = "10.4.1.0/24"
        },
        {
          address_prefix = "10.4.2.0/24"
        }
      ]

      create_reverse_peering               = true
      reverse_name                         = "example-resource-vnet1-to-vnet2"
      reverse_allow_forwarded_traffic      = false
      reverse_allow_gateway_transit        = false
      reverse_allow_virtual_network_access = true
      reverse_peer_complete_vnets          = false
      reverse_local_peered_address_spaces = [
        {
          address_prefix = "10.4.1.0/24"
        },
        {
          address_prefix = "10.4.2.0/24"
        }
      ]
      reverse_remote_peered_address_spaces = [
        {
          address_prefix = "10.6.1.0/24"
        },
        {
          address_prefix = "10.6.2.0/24"
        }
      ]
    }
  }
  subnets = {
    subnet1 = {
      name             = "example-resource-2-1"
      address_prefixes = ["10.6.1.0/24", "10.6.2.0/24"]
    }
    subnet2 = {
      name             = "example-resource-2-2"
      address_prefixes = ["10.6.3.0/24", "10.6.4.0/24"]
    }
    subnet3 = {
      name             = "example-resource-2-3"
      address_prefixes = ["10.7.5.0/24", "10.7.6.0/24"]
    }
  }
}