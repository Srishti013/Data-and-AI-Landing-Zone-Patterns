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

resource "azurerm_route_table" "this" {
  location            = azurerm_resource_group.this.location
  name                = "MyRouteTable"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_route" "this" {
  address_prefix      = local.address_space
  name                = "acceptanceTestRoute1"
  next_hop_type       = "VnetLocal"
  resource_group_name = azurerm_resource_group.this.name
  route_table_name    = azurerm_route_table.this.name
}

locals {
  address_space = "10.0.0.0/16"
  subnets = {
    for i in range(3) :
    "subnet${i}" => {
      name             = "example-resource${i}"
      address_prefixes = [cidrsubnet(local.address_space, 8, i)]
      route_table = {
        id = azurerm_route_table.this.id
      }
    }
  }
}

module "vnet" {
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

  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name
  subnets             = local.subnets
}
