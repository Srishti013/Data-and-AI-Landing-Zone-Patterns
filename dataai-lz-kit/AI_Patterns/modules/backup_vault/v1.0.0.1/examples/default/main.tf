terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}


provider "azurerm" {
  features {}
}

provider "azapi" {}

# Create a Resource Group in the randomly selected region
resource "azurerm_resource_group" "example" {
  location = "eastus"
  name     = "rg-backup-default-tst"
}

# Call the Backup Vault Module
module "backup_vault" {
  source = "../../" # Replace with correct module path

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

  # Minimum required variables
  datastore_type      = "VaultStore"
  redundancy          = "GeoRedundant"
  resource_group_name = azurerm_resource_group.example.name
  diagnostic_settings = {}
  enable_telemetry    = true # Enable telemetry (optional)
}
