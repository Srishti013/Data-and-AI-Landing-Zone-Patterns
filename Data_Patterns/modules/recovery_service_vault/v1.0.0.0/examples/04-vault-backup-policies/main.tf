

resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "rg-rsv-backup-example"
}

resource "azurerm_resource_group" "primary" {
  location = "westus3"
  name     = "rg-rsv-backup-example-wus3"
}
resource "azurerm_resource_group" "secondary" {
  location = "Central US"
  name     = "rg-rsv-backup-example-cus"
}
locals {
  vault_name = "rsv-eus-app1-001"
}

resource "azurerm_user_assigned_identity" "this_identity" {
  location            = azurerm_resource_group.this.location
  name                = "uai-rsv-backup-example"
  resource_group_name = azurerm_resource_group.this.name
}


module "recovery_services_vault" {
  source = "../../"

  # MBB Naming Module Variables (Required)
  env      = "dev"
  au       = "0233985"
  owner    = "CloudOps"
  app_code = "myapp"
  bu       = "IT"

  # Mandatory Tags (Required)
  app_name       = "Recovery Services Vault"
  business_unit  = "IT Operations"
  business_owner = "John Doe"
  budget_id      = "BUD001"
  criticality    = "Medium"
  environment    = "Development"
  service        = "Backup"

  resource_group_name                            = azurerm_resource_group.this.name
  sku                                            = "RS0"
  alerts_for_all_job_failures_enabled            = true
  alerts_for_critical_operation_failures_enabled = true
  classic_vmware_replication_enabled             = false
  cross_region_restore_enabled                   = false
  file_share_backup_policy = {
    pol-rsv-fileshare-vault-001 = {
      name     = "pol-rsv-fileshare-vault-001"
      timezone = "Pacific Standard Time"

      frequency = "Daily" # (Required) Sets the backup frequency. Possible values are hourly, Daily

      backup = {
        time = "22:00"
        hourly = {
          interval        = 6
          start_time      = "13:00"
          window_duration = "6"
        }
      }
      retention_daily = 1 # 1-200
      retention_weekly = {
        count    = 7
        weekdays = ["Tuesday", "Saturday"]
      }
      retention_monthly = {
        count = 5
        # weekdays =  ["Tuesday","Saturday"]
        # weeks = ["First","Third"]
        days              = [3, 10, 20]
        include_last_days = false
      }
      retention_yearly = {
        count    = 5
        months   = ["January", "June"]
        weekdays = ["Tuesday", "Saturday"]
        weeks    = ["First", "Third"]
        # days = [3, 10, 20]
        # include_last_days = false
      }
    }
  }
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this_identity.id]
  }
  public_network_access_enabled = true
  storage_mode_type             = "GeoRedundant"
  vm_backup_policy = {
    pol-rsv-vm-vault-001 = {
      name                           = "pol-rsv-vm-vault-001"
      timezone                       = "Pacific Standard Time"
      instant_restore_retention_days = 5
      policy_type                    = "V2"
      frequency                      = "Weekly" # (Required) Sets the backup frequency. Possible values are Hourly, Daily and Weekly
      instant_restore_resource_group = {
        ps = { prefix = "prefix-"
          suffix = null

        }
      }
      backup = {
        time          = "22:00"
        hour_interval = 6
        hour_duration = 12
        weekdays      = ["Tuesday", "Saturday"]
      }
      retention_daily = 7 # 7-9999
      retention_weekly = {
        count    = 7
        weekdays = ["Tuesday", "Saturday"]
      }
      retention_monthly = {
        count             = 5
        weekdays          = ["Tuesday", "Saturday"]
        weeks             = ["First", "Third"]
        days              = [3, 10, 20]
        include_last_days = false
      }
      retention_yearly = {
        count             = 5
        months            = ["January", "June"]
        weekdays          = ["Tuesday", "Saturday"]
        weeks             = ["First", "Third"]
        days              = [3, 10, 20]
        include_last_days = false
      }
    }
  }
  workload_backup_policy = {
    "pol-rsv-SAPh-vault-002" = {
      name          = "pol-rsv-SAPh-vault-01"
      workload_type = "SAPHanaDatabase"
      settings = {
        time_zone           = "Pacific Standard Time"
        compression_enabled = false
      }
      backup_frequency = "Weekly" # Daily or Weekly
      protection_policy = {
        log = {
          policy_type           = "Log"
          retention_daily_count = 15
          backup = {
            frequency_in_minutes = 15
            time                 = "22:00"
            weekdays             = ["Saturday"]
          }
        }
        full = {
          policy_type = "Full"
          backup = {
            time     = "22:00"
            weekdays = ["Saturday"]
          }
          retention_daily_count = 15
          retention_weekly = {
            count    = 10
            weekdays = ["Saturday"]
          }
          retention_monthly = {
            count     = 10
            weekdays  = ["Saturday", ]
            weeks     = ["First", "Third"]
            monthdays = [3, 10, 20]
          }
          retention_yearly = {
            count     = 10
            months    = ["January", "June", "October", "March"]
            weekdays  = ["Saturday", ]
            weeks     = ["First", "Second", "Third"]
            monthdays = [3, 10, 20]
          }

        }
        differential = {
          policy_type           = "Differential"
          retention_daily_count = 15
          backup = {
            time     = "22:00"
            weekdays = ["Wednesday", "Friday"]
          }
        }

      }
    }
  }
}

