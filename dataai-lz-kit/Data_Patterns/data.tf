# Available subscriptions (used by locals to resolve platform sub GUIDs from
# their display names for the aliased providers).
data "azurerm_subscriptions" "available" {}

# Current authenticated client (tenant_id for Key Vault, object_id for RBAC).
data "azurerm_client_config" "current" {}

# Resource group in the platform network subscription that holds the shared
# Private DNS Zones.
data "azurerm_resource_group" "pvt_dns_zones_rg" {
  provider = azurerm.pvt_dns_zones_sub
  name     = var.existing_private_dns_zones_rg_name
}

# Existing shared Private DNS Zones (vault/sql/blob/dfs/queue/adf/adf_portal).
# Private endpoints resolve their zone ids from here via each endpoint's
# dns_zone_key.
data "azurerm_private_dns_zone" "existing_private_dns_zones" {
  provider            = azurerm.pvt_dns_zones_sub
  for_each            = var.existing_private_dns_zones
  name                = each.value.name
  resource_group_name = data.azurerm_resource_group.pvt_dns_zones_rg.name
}

# Hub virtual network(s) in the platform network subscription. Read so the VNet
# module can peer to the hub without tfvars carrying raw cross-subscription
# resource ids. Only populated when var.hub_virtual_networks is set.
data "azurerm_virtual_network" "hub" {
  provider            = azurerm.pvt_dns_zones_sub
  for_each            = var.hub_virtual_networks
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

# Central Log Analytics Workspace (platform management subscription) consumed by
# Application Insights and SQL Server diagnostic settings.
# TEMP-DISABLED (demo 2026-07-21): reading it needs SPN access to the mgmt sub
# (not granted). Re-enable together with the azurerm.law_sub provider.
# data "azurerm_log_analytics_workspace" "workspace" {
#   count               = var.log_analytics_workspace_name != "" ? 1 : 0
#   provider            = azurerm.law_sub
#   name                = var.log_analytics_workspace_name
#   resource_group_name = var.log_analytics_workspace_rg_name
# }

# System-assigned identities of the Data Factories created in this stack.
# Read back so RBAC can grant the ADF managed identity access to KV / Storage.
# Depends on the module so the ADF exists before this is evaluated.
data "azurerm_data_factory" "adf_system" {
  for_each            = var.data_factories
  name                = each.value.name
  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name

  depends_on = [module.data_factories]
}
