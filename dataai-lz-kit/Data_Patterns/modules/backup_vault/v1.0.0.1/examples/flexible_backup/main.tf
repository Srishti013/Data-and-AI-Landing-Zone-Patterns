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
  name     = "rg-flex-backup-tst"
  tags = {
    Environment = "Demo"
    Deployment  = "Terraform"
    Service     = "Data Protection"
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  location            = azurerm_resource_group.example.location
  name                = "law-flex-backup-tst"
  resource_group_name = azurerm_resource_group.example.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

# Snapshot Resource Group
resource "azurerm_resource_group" "snapshots" {
  location = azurerm_resource_group.example.location
  name     = "rg-flex-backup-snaps-tst"
  tags = {
    Environment = "Demo"
    Purpose     = "Disk Snapshots"
  }
}

# First Managed Disk (Primary/Production)
resource "azurerm_managed_disk" "example" {
  #checkov:skip=CKV_AZURE_93: "CMK disk encryption not required for backup test example"
  create_option        = "Empty"
  location             = azurerm_resource_group.example.location
  name                 = "disk-flex-backup-primary"
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 64
  tags = {
    Environment = "Demo"
    Purpose     = "Production Disk"
  }
}

# Second Managed Disk (Secondary/Development)
resource "azurerm_managed_disk" "database" {
  #checkov:skip=CKV_AZURE_93: "CMK disk encryption not required for backup test example"
  create_option        = "Empty"
  location             = azurerm_resource_group.example.location
  name                 = "disk-flex-backup-secondary"
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 32
  tags = {
    Environment = "Demo"
    Purpose     = "Development Disk"
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
  # Define multiple backup instances that reference policies
  backup_instances = {
    # Production disk instance
    "production-disk" = {
      type                         = "disk"
      name                         = "bvault-flex-backup-prod-instance"
      backup_policy_key            = "production-daily"
      disk_id                      = azurerm_managed_disk.example.id
      snapshot_resource_group_name = azurerm_resource_group.snapshots.name
    },

    # Development disk instance
    "development-disk" = {
      type                         = "disk"
      name                         = "bvault-flex-backup-dev-instance"
      backup_policy_key            = "development-weekly"
      disk_id                      = azurerm_managed_disk.database.id
      snapshot_resource_group_name = azurerm_resource_group.snapshots.name
    }
  }
  # Define multiple backup policies independently
  backup_policies = {
    # Production disk policy - daily backups with long retention
    "production-daily" = {
      type                                   = "disk"
      name                                   = "bvault-flex-backup-prod-policy"
      backup_repeating_time_intervals        = ["R/2025-01-01T00:00:00+00:00/P1D"]
      default_retention_duration             = "P7D"
      operational_default_retention_duration = "P30D"
      time_zone                              = "UTC"
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
    },

    # Development disk policy - weekly backups
    "development-weekly" = {
      type                                   = "disk"
      name                                   = "bvault-flex-backup-dev-policy"
      backup_repeating_time_intervals        = ["R/2025-01-01T00:00:00+00:00/P1W"]
      default_retention_duration             = "P30D"
      operational_default_retention_duration = "P14D"
      time_zone                              = "UTC"
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
  managed_identities = {
    system_assigned = true
  }
  soft_delete = "Off"
}

# Create role assignments outside the module to avoid circular dependencies
resource "azurerm_role_assignment" "disk_backup_reader_primary" {
  principal_id         = module.backup_vault.identity_principal_id
  scope                = azurerm_managed_disk.example.id
  role_definition_name = "Disk Backup Reader"
}

resource "azurerm_role_assignment" "disk_backup_reader_secondary" {
  principal_id         = module.backup_vault.identity_principal_id
  scope                = azurerm_managed_disk.database.id
  role_definition_name = "Disk Backup Reader"
}

resource "azurerm_role_assignment" "disk_snapshot_contributor" {
  principal_id         = module.backup_vault.identity_principal_id
  scope                = azurerm_resource_group.snapshots.id
  role_definition_name = "Disk Snapshot Contributor"
}
