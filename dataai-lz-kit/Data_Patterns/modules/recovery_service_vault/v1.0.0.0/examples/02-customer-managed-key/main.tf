

resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "rg-rsv-cmk-example"
}

locals {
  vault_name = "rsv-eus-app1-002"
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
  customer_managed_key = {
    key_vault_resource_id = azurerm_key_vault.this.id
    key_name              = azurerm_key_vault_key.this.id
    user_assigned_identity_resource_id = {
      resource_id = azurerm_user_assigned_identity.this_identity.id
    }
  }
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this_identity.id]
  }
  public_network_access_enabled = true
  storage_mode_type             = "GeoRedundant"

  depends_on = [azurerm_key_vault_key.this, azurerm_key_vault.this]
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "this_identity" {
  location            = azurerm_resource_group.this.location
  name                = "uai-rsv-cmk-example"
  resource_group_name = azurerm_resource_group.this.name
}

#Create a Customer Managed Key for a Recovery Services Vault.
resource "azurerm_key_vault_key" "this" {
  #checkov:skip=CKV_AZURE_112:Example code - HSM backed key not in scope
  #checkov:skip=CKV_AZURE_40:Example code - key expiration not in scope
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
  key_type     = "RSA"
  key_vault_id = azurerm_key_vault.this.id
  name         = "kvkey-rsv-cmk-example"
  key_size     = 2048

  depends_on = [azurerm_key_vault.this]
}

#create a keyvault for storing the credential with RBAC for the deployment user
resource "azurerm_key_vault" "this" {
  #checkov:skip=CKV_AZURE_189:Example code - public network access not in scope
  #checkov:skip=CKV_AZURE_109:Example code - firewall rules not in scope
  #checkov:skip=CKV_AZURE_110:Example code - purge protection not in scope
  #checkov:skip=CKV_AZURE_42:Example code - key vault recoverability not in scope
  #checkov:skip=CKV2_AZURE_32:Example code - private endpoint not in scope
  location                   = azurerm_resource_group.this.location
  name                       = "kv-rsv-cmk-example"
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Create", "Delete", "Get", "List", "Purge", "Recover",
      "SetRotationPolicy", "GetRotationPolicy",
      "UnwrapKey", "WrapKey", "Verify", "Sign",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.this_identity.principal_id
    key_permissions = [
      "Get", "UnwrapKey", "WrapKey",
    ]
  }

  tags = {
    Dep = "IT"
  }
}

