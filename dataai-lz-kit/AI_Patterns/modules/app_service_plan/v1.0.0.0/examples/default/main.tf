terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.19.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
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

resource "random_integer" "region_index" {
  max = length(local.test_regions) - 1
  min = 0
}

## End of section to provide a random Azure region for the resource group

# This is required for resource modules
# Hardcoding location due to quota constaints
resource "azurerm_resource_group" "this" {
  location = "australiaeast"
  name     = "rg-appserviceplan-example"
}

# This is the module call
module "test" {
  source = "../.."

  # Naming module variables
  env                = "test"
  au                 = "0233985"
  owner              = "example-team"
  resource_type_code = "asp"
  app_code           = "example"
  bu                 = "it"
  region_code        = "aue"

  # Required resource configuration
  os_type             = "Windows"
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry

  # Required business tags
  app_name       = "Example App Service Plan"
  business_owner = "john.doe@example.com"
  business_unit  = "IT"
  criticality    = "Medium"
  environment    = "test"
  service        = "web-hosting"
  budget_id      = "IT-001"
}
