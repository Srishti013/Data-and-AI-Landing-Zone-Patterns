
data "azurerm_subscription" "this" {}

resource "azurerm_resource_group" "this" {
  location = "westus3"
  name     = "rg-westus3-vault-005"
}
resource "azurerm_resource_group" "primary_wus1" {
  location = "westus"
  name     = "rg-vm-westus-primary-005"
}
resource "azurerm_resource_group" "primary_wus2" {
  location = "westus2"
  name     = "rg-vm-westus2-primary-005"
}
resource "azurerm_resource_group" "primary_wus3" {
  location = "westus3"
  name     = "rg-vm-westus3-primary-005"
}
resource "azurerm_resource_group" "secondary_eus" {
  location = "eastus"
  name     = "rg-vm-secondary_eus-005"
}
resource "azurerm_resource_group" "secondary_eus2" {
  location = "eastus2"
  name     = "rg-vm-secondary_eus2-005"
}
resource "azurerm_resource_group" "secondary_cus" {
  location = "centralus"
  name     = "rg-vm-secondary_cus-005"
}

locals {
  vault_name = "rsv-wus3-005"
}

# must be located in the same region as the VM to be backed up
resource "azurerm_storage_account" "primary_wus1" {
  #checkov:skip=CKV_AZURE_59:Example code - public access setting not in scope
  #checkov:skip=CKV_AZURE_33:Example code - queue logging not in scope
  #checkov:skip=CKV_AZURE_44:Example code - TLS version not in scope
  #checkov:skip=CKV_AZURE_190:Example code - blob public access not in scope
  #checkov:skip=CKV2_AZURE_40:Example code - shared key auth not in scope
  #checkov:skip=CKV2_AZURE_41:Example code - SAS expiration policy not in scope
  #checkov:skip=CKV2_AZURE_47:Example code - blob anonymous access not in scope
  #checkov:skip=CKV2_AZURE_38:Example code - soft-delete not in scope
  #checkov:skip=CKV2_AZURE_33:Example code - private endpoint not in scope
  #checkov:skip=CKV2_AZURE_1:Example code - CMK encryption not in scope
  account_replication_type = "GRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.primary_wus1.location
  name                     = "srv${azurerm_resource_group.primary_wus1.location}005"
  resource_group_name      = azurerm_resource_group.primary_wus1.name
}

resource "azurerm_storage_account" "primary_wus2" {
  #checkov:skip=CKV_AZURE_59:Example code - public access setting not in scope
  #checkov:skip=CKV_AZURE_33:Example code - queue logging not in scope
  #checkov:skip=CKV_AZURE_44:Example code - TLS version not in scope
  #checkov:skip=CKV_AZURE_206:Example code - replication not in scope
  #checkov:skip=CKV_AZURE_190:Example code - blob public access not in scope
  #checkov:skip=CKV2_AZURE_40:Example code - shared key auth not in scope
  #checkov:skip=CKV2_AZURE_41:Example code - SAS expiration policy not in scope
  #checkov:skip=CKV2_AZURE_47:Example code - blob anonymous access not in scope
  #checkov:skip=CKV2_AZURE_38:Example code - soft-delete not in scope
  #checkov:skip=CKV2_AZURE_33:Example code - private endpoint not in scope
  #checkov:skip=CKV2_AZURE_1:Example code - CMK encryption not in scope
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.primary_wus2.location
  name                     = "srv${azurerm_resource_group.primary_wus2.location}555"
  resource_group_name      = azurerm_resource_group.primary_wus2.name
}
resource "azurerm_storage_account" "primary_wus3" {
  #checkov:skip=CKV_AZURE_59:Example code - public access setting not in scope
  #checkov:skip=CKV_AZURE_33:Example code - queue logging not in scope
  #checkov:skip=CKV_AZURE_44:Example code - TLS version not in scope
  #checkov:skip=CKV_AZURE_206:Example code - replication not in scope
  #checkov:skip=CKV_AZURE_190:Example code - blob public access not in scope
  #checkov:skip=CKV2_AZURE_40:Example code - shared key auth not in scope
  #checkov:skip=CKV2_AZURE_41:Example code - SAS expiration policy not in scope
  #checkov:skip=CKV2_AZURE_47:Example code - blob anonymous access not in scope
  #checkov:skip=CKV2_AZURE_38:Example code - soft-delete not in scope
  #checkov:skip=CKV2_AZURE_33:Example code - private endpoint not in scope
  #checkov:skip=CKV2_AZURE_1:Example code - CMK encryption not in scope
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.primary_wus3.location
  name                     = "srv${azurerm_resource_group.primary_wus3.location}555"
  resource_group_name      = azurerm_resource_group.primary_wus3.name
}
resource "azurerm_storage_account" "sa" {
  #checkov:skip=CKV_AZURE_59:Example code - public access setting not in scope
  #checkov:skip=CKV_AZURE_33:Example code - queue logging not in scope
  #checkov:skip=CKV_AZURE_44:Example code - TLS version not in scope
  #checkov:skip=CKV_AZURE_190:Example code - blob public access not in scope
  #checkov:skip=CKV2_AZURE_40:Example code - shared key auth not in scope
  #checkov:skip=CKV2_AZURE_41:Example code - SAS expiration policy not in scope
  #checkov:skip=CKV2_AZURE_47:Example code - blob anonymous access not in scope
  #checkov:skip=CKV2_AZURE_38:Example code - soft-delete not in scope
  #checkov:skip=CKV2_AZURE_33:Example code - private endpoint not in scope
  #checkov:skip=CKV2_AZURE_1:Example code - CMK encryption not in scope
  account_replication_type = "GRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.primary_wus3.location
  name                     = "fsbk${azurerm_resource_group.primary_wus3.location}555"
  resource_group_name      = azurerm_resource_group.primary_wus3.name
}

resource "azurerm_storage_share" "this" {
  name               = "share1"
  quota              = 50
  storage_account_id = azurerm_storage_account.sa.id
}
resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "uami-${azurerm_resource_group.this.location}-005"
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
  backup_protected_file_share = {
    protect-share-s1 = {
      source_storage_account_id = "${data.azurerm_subscription.this.id}/resourceGroups/${azurerm_resource_group.primary_wus3.name}/providers/Microsoft.Storage/storageAccounts/fsbk${azurerm_resource_group.primary_wus3.location}005"
      #"${data.azurerm_subscription.this.id}/resourceGroups/${azurerm_resource_group.primary_wus3.name}/providers/Microsoft.Storage/storageAccounts/fsbk${azurerm_resource_group.primary_wus3.location}005"
      source_file_share_name        = azurerm_storage_share.this.name
      backup_file_share_policy_name = "pol-rsv-fileshare-vault-005"
      sleep_timer                   = "30s"
    }
  }
  backup_protected_vm = {
    vm-03 = {
      vm_backup_policy_name = "EnhancedPolicy"
      source_vm_id          = "${data.azurerm_subscription.this.id}/resourceGroups/${azurerm_resource_group.primary_wus3.name}/providers/Microsoft.Compute/virtualMachines/vm-${azurerm_resource_group.primary_wus3.location}-005"
      # azurerm_windows_virtual_machine.vm_wus3.id # nes/vm"
    }

  }
  classic_vmware_replication_enabled = false
  cross_region_restore_enabled       = false
  file_share_backup_policy = {
    fs_obj_key_pol_001 = {
      name     = "pol-rsv-fileshare-vault-005"
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
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id, ]
  }
  public_network_access_enabled = true
  storage_mode_type             = "GeoRedundant"


  depends_on = [azurerm_storage_account.sa, azurerm_windows_virtual_machine.vm_wus3]
}