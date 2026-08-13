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

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "backup_mua_operator" {
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = module.backup_vault.resource_guard_id
  role_definition_name = "Backup MUA Operator"
}


# Create a Resource Group
resource "azurerm_resource_group" "example" {
  location = "eastus2"
  name     = "rg-resource-guard-tst"
  tags = {
    Environment = "Demo"
    Purpose     = "Resource Guard Example"
  }
}

# Create a Backup Vault with Resource Guard protection
module "backup_vault" {
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

  # Required parameters
  datastore_type      = "VaultStore"
  redundancy          = "GeoRedundant"
  resource_group_name = azurerm_resource_group.example.name
  # Enable system-assigned managed identity
  managed_identities = {
    system_assigned = true
  }
}


