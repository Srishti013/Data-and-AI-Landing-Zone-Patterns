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

# Create a Resource Group
resource "azurerm_resource_group" "example" {
  location = "eastus"
  name     = "rg-blob-backup-tst"
}

# Create a Storage Account for Blob Storage
resource "azurerm_storage_account" "example" {
  #checkov:skip=CKV_AZURE_59: "Public access restriction not required for backup test example"
  #checkov:skip=CKV_AZURE_33: "Queue service logging not required for backup test example"
  #checkov:skip=CKV_AZURE_44: "TLS version configurable for backup test example"
  #checkov:skip=CKV_AZURE_206: "Replication type ZRS used for backup test example"
  #checkov:skip=CKV2_AZURE_40: "Shared key authorization acceptable for backup test example"
  #checkov:skip=CKV2_AZURE_41: "SAS expiration policy not required for backup test example"
  #checkov:skip=CKV2_AZURE_38: "Soft-delete not required for backup test example"
  #checkov:skip=CKV2_AZURE_33: "Private endpoint not required for backup test example"
  #checkov:skip=CKV2_AZURE_1: "CMK encryption not required for backup test example"
  account_replication_type        = "ZRS"
  account_tier                    = "Standard"
  location                        = azurerm_resource_group.example.location
  name                            = "stblobbackuptst"
  resource_group_name             = azurerm_resource_group.example.name
  allow_nested_items_to_be_public = false
}

# Create a Storage Container
# NOTE: Azure Data Protection automatically applies a scope lock on the storage account
# that prevents deletion of storage resources. This lock persists even after the backup
# vault is destroyed. Manual cleanup may be required in the Azure portal.
resource "azurerm_storage_container" "example" {
  #checkov:skip=CKV2_AZURE_21: "Blob service logging not required for backup test example"
  name                  = "example-container"
  container_access_type = "private"
  storage_account_id    = azurerm_storage_account.example.id

  lifecycle {
    create_before_destroy = false
  }
}

# Module Call for Backup Vault
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

  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
  resource_group_name = azurerm_resource_group.example.name
  # Define backup instance
  backup_instances = {
    "blob-instance" = {
      type                            = "blob"
      name                            = "bvault-blob-backup-blob-instance"
      backup_policy_key               = "blob-backup"
      storage_account_id              = azurerm_storage_account.example.id
      storage_account_container_names = [azurerm_storage_container.example.name]
    }
  }
  # Define backup policy
  backup_policies = {
    "blob-backup" = {
      type                                   = "blob"
      name                                   = "bvault-blob-backup-policy"
      backup_repeating_time_intervals        = ["R/2024-09-17T06:33:16+00:00/PT4H"]
      operational_default_retention_duration = "P30D"
      vault_default_retention_duration       = "P90D"
      time_zone                              = "Central Standard Time"
      retention_rules = [
        {
          name     = "Daily"
          duration = "P7D"
          priority = 25
          criteria = [{
            absolute_criteria = "FirstOfDay"
          }]
          life_cycle = [{
            data_store_type = "VaultStore"
            duration        = "P30D"
          }]
        },
        {
          name     = "Weekly"
          duration = "P7D"
          priority = 20
          criteria = [{
            absolute_criteria = "FirstOfWeek"
          }]
          life_cycle = [{
            data_store_type = "VaultStore"
            duration        = "P30D"
          }]
        }
      ]
    }
  }
  enable_telemetry = true
  lock             = null # Disable management lock to prevent destroy conflicts
  # Configure managed identity
  managed_identities = {
    system_assigned = true
  }
  soft_delete = "Off"
}

# Create role assignment outside the module to avoid circular dependencies
resource "azurerm_role_assignment" "storage_account_backup_contributor" {
  principal_id         = module.backup_vault.identity_principal_id
  scope                = azurerm_resource_group.example.id
  description          = "Backup Contributor for Blob Storage"
  role_definition_name = "Storage Account Backup Contributor"
}
