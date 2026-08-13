

resource "azurerm_resource_group" "this" {
  location = "eastus"
  name     = "rg-rsv-pe-example"
}

locals {
  vault_name          = "rsv-eus-app1-003"
  endpoints           = toset(["AzureBackup", "AzureSiteRecovery"])
  endpoints_dns_zones = toset(["AzureBackup", "AzureSiteRecovery", "blob", "queue"])
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
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this_identity.id]
  }
  #create a private endpoint for each endpoint type
  private_endpoints = {
    for endpoint in local.endpoints :
    endpoint => {

      # the name must be set to avoid conflicting resources.
      name                          = "pe-${endpoint}-${local.vault_name}"
      subnet_resource_id            = azurerm_subnet.private.id
      subresource_name              = endpoint
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this[endpoint].id]

      # these are optional but illustrate making well-aligned service connection & NIC names.
      private_service_connection_name = "psc-${endpoint}-${local.vault_name}"
      network_interface_name          = "nic-pe-${endpoint}-${local.vault_name}"
      inherit_tags                    = false
      inherit_lock                    = false

      tags = {
        env   = "Prod"
        owner = "ABREG0 "
        dept  = "IT"
      }

      role_assignments = {
        role_assignment_1 = {
          role_definition_id_or_name = data.azurerm_role_definition.this.id
          principal_id               = data.azurerm_client_config.current.object_id
        }
      }
    }


  }
  public_network_access_enabled = false
  storage_mode_type             = "GeoRedundant"
}

resource "azurerm_virtual_network" "vnet" {
  location            = azurerm_resource_group.this.location
  name                = "vnet-rsv-pe-example"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "private" {
  address_prefixes     = ["192.168.0.0/24"]
  name                 = "snet-rsv-pe-example"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.this.location
  name                = "nsg-rsv-pe-example"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "private" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  subnet_id                 = azurerm_subnet.private.id
}

resource "azurerm_network_security_rule" "no_internet" {
  access                      = "Deny"
  direction                   = "Outbound"
  name                        = "deny-internet-outbound"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 100
  protocol                    = "*"
  resource_group_name         = azurerm_resource_group.this.name
  destination_address_prefix  = "Internet"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.private.address_prefixes[0]
  source_port_range           = "*"
}

resource "azurerm_private_dns_zone" "this" {
  for_each = local.endpoints_dns_zones

  name                = each.value == "blob" || each.value == "queue" ? "privatelink.${each.value}.core.windows.net" : each.value == "AzureBackup" ? "privatelink.eus.backup.windowsazure.com" : "privatelink.siterecovery.windowsazure.com"
  resource_group_name = azurerm_resource_group.this.name
  tags = {
    env = "Dev"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_links" {
  for_each = azurerm_private_dns_zone.this

  name                  = "${each.key}_${azurerm_virtual_network.vnet.name}-link"
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  resource_group_name   = azurerm_resource_group.this.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "this_identity" {
  location            = azurerm_resource_group.this.location
  name                = "uai-rsv-pe-example"
  resource_group_name = azurerm_resource_group.this.name
}

data "azurerm_role_definition" "this" {
  name = "Contributor"
}
