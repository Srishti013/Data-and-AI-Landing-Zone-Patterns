

resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "rg-rsv-01default-example"
}

locals {
  vault_name = "rsv-eus-app1-001"
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
  public_network_access_enabled                  = true
  storage_mode_type                              = "GeoRedundant"
}
