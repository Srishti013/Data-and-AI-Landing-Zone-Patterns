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
  service         = "vnet"

  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = true
  subnets = {
    subnet1 = {
      name                            = "subnet1"
      address_prefix                  = "10.0.0.0/24"
      default_outbound_access_enabled = true
      delegations = [{
        name = "aca_delegation"
        service_delegation = {
          name = "Microsoft.App/environments"
        }
      }]
    }
  }
}

/* # NOTE: This resource take a long time to create and destroy, so we are removing from e2e tests.
resource "azurerm_container_app_environment" "aca" {
  name                       = "example-resource"
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name

  infrastructure_resource_group_name = "${"rg-example"}-aca"
  infrastructure_subnet_id           = module.vnet.subnets["subnet1"].resource_id
  internal_load_balancer_enabled = true

  workload_profile {
    name = "Consumption"
    workload_profile_type  = "Consumption"
    maximum_count = 1
    minimum_count = 0
  }
  zone_redundancy_enabled = false
}
*/