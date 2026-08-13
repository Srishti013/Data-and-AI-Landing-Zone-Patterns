terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a Resource Group in the randomly selected region
resource "azurerm_resource_group" "example" {
  location = local.test_regions.primary_region
  name     = "rg-redundancy-backup-tst"
}

# Geo-redundant with cross-region restore enabled
module "backup_vault_geo_redundant_with_cross_restore" {
  source = "../../"

  # Required naming and tag variables
  env            = "tst"
  au             = "0000001"
  owner          = "ITOpsTeam"
  app_code       = "bkp"
  bu             = "IT"
  app_name       = "backup-test"
  business_unit  = "IT"
  business_owner = "admin@example.com"
  service        = "backup"
  budget_id      = "BUD001"
  criticality    = "Low"
  environment    = "Testing"

  datastore_type               = "VaultStore"
  redundancy                   = "GeoRedundant"
  resource_group_name          = azurerm_resource_group.example.name
  cross_region_restore_enabled = true # Only works with GeoRedundant
  enable_telemetry             = true
  retention_duration_in_days   = 30
  soft_delete                  = "On"
}

# Geo-redundant without cross-region restore
module "backup_vault_geo_redundant_no_cross_restore" {
  source = "../../"

  # Required naming and tag variables
  env            = "tst"
  au             = "0000001"
  owner          = "ITOpsTeam"
  app_code       = "bkp"
  bu             = "IT"
  app_name       = "backup-test"
  business_unit  = "IT"
  business_owner = "admin@example.com"
  service        = "backup"
  budget_id      = "BUD001"
  criticality    = "Low"
  environment    = "Testing"

  datastore_type               = "VaultStore"
  redundancy                   = "GeoRedundant"
  resource_group_name          = azurerm_resource_group.example.name
  cross_region_restore_enabled = false
  enable_telemetry             = true
  retention_duration_in_days   = 30
  soft_delete                  = "On"
}

# Locally redundant
module "backup_vault_locally_redundant" {
  source = "../../"

  # Required naming and tag variables
  env            = "tst"
  au             = "0000001"
  owner          = "ITOpsTeam"
  app_code       = "bkp"
  bu             = "IT"
  app_name       = "backup-test"
  business_unit  = "IT"
  business_owner = "admin@example.com"
  service        = "backup"
  budget_id      = "BUD001"
  criticality    = "Low"
  environment    = "Testing"

  datastore_type             = "VaultStore"
  redundancy                 = "LocallyRedundant"
  resource_group_name        = azurerm_resource_group.example.name
  enable_telemetry           = true
  retention_duration_in_days = 45
  soft_delete                = "On"
}

# Zone redundant (if available in the region)
module "backup_vault_zone_redundant" {
  source = "../../"

  # Required naming and tag variables
  env            = "tst"
  au             = "0000001"
  owner          = "ITOpsTeam"
  app_code       = "bkp"
  bu             = "IT"
  app_name       = "backup-test"
  business_unit  = "IT"
  business_owner = "admin@example.com"
  service        = "backup"
  budget_id      = "BUD001"
  criticality    = "Low"
  environment    = "Testing"

  datastore_type             = "VaultStore"
  redundancy                 = "ZoneRedundant"
  resource_group_name        = azurerm_resource_group.example.name
  enable_telemetry           = true
  retention_duration_in_days = 60
  soft_delete                = "On"
}

# Define regions for redundancy options
locals {
  test_regions = {
    primary_region  = "eastus"  # Primary region with all redundancy options
    paired_region   = "westus"  # Paired region for geo-redundant testing
    fallback_region = "eastus2" # Fallback if primary isn't available
  }
}
