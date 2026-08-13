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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "azapi" {}

# Resource Group
resource "azurerm_resource_group" "example" {
  location = "centralus"
  name     = "rg-disk-backup-tst"
  tags = {
    Environment = "Demo"
    Deployment  = "Terraform"
    Service     = "Data Protection"
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "law-disk-backup-tst"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

# Managed Disk
resource "azurerm_managed_disk" "example" {
  #checkov:skip=CKV_AZURE_93: "CMK disk encryption not required for backup test example"
  create_option        = "Empty"
  resource_group_name  = azurerm_resource_group.example.name
  location             = azurerm_resource_group.example.location
  name                 = "disk-flex-backup-primary"
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 64
  tags = {
    Environment = "Demo"
    Purpose     = "Disk Backup"
  }
}

# Snapshot Resource Group
resource "azurerm_resource_group" "snapshots" {
  location = azurerm_resource_group.example.location
  name     = "rg-disk-backup-snaps-tst"
  tags = {
    Environment = "Demo"
    Purpose     = "Disk Snapshots"
  }
}

# Backup Vault Module
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
  # Define backup instance that references policy
  backup_instances = {
    "disk-instance" = {
      type                         = "disk"
      name                         = "bvault-disk-backup-instance"
      backup_policy_key            = "disk-daily"
      disk_id                      = azurerm_managed_disk.example.id
      snapshot_resource_group_name = azurerm_resource_group.snapshots.name
    }
  }
  # Define backup policy
  backup_policies = {
    "disk-daily" = {
      type                            = "disk"
      name                            = "bvault-disk-backup-policy"
      backup_repeating_time_intervals = ["R/2025-01-01T00:00:00+00:00/P1D"]
      default_retention_duration      = "P30D"
      time_zone                       = "UTC"
      retention_rules = [
        {
          name     = "Daily"
          priority = 25
          duration = "P7D"
          criteria = [{
            absolute_criteria = "FirstOfDay"
          }]
        },
        {
          name     = "Weekly"
          priority = 20
          duration = "P30D"
          criteria = [{
            absolute_criteria = "FirstOfWeek"
          }]
        }
      ]
    }
  }
  # Configure diagnostic settings
  diagnostic_settings = {
    diag_to_law = {
      name                  = "diag-law"
      log_categories        = []
      log_groups            = ["allLogs"]
      metric_categories     = ["Health"]
      workspace_resource_id = azurerm_log_analytics_workspace.example.id
    }
  }
  enable_telemetry = true
  immutability     = "Disabled"
  lock             = null
  # Configure managed identity
  managed_identities = {
    system_assigned = true
  }
  soft_delete = "Off"
}

# Create role assignments outside the module to avoid circular dependencies
resource "azurerm_role_assignment" "disk_backup_reader" {
  principal_id         = module.backup_vault.identity_principal_id
  scope                = azurerm_managed_disk.example.id
  role_definition_name = "Disk Backup Reader"
}

resource "azurerm_role_assignment" "disk_snapshot_contributor" {
  principal_id         = module.backup_vault.identity_principal_id
  scope                = azurerm_resource_group.snapshots.id
  role_definition_name = "Disk Snapshot Contributor"
}
