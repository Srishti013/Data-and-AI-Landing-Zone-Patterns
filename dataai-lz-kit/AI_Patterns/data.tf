data "azurerm_subscriptions" "available" {}

data "azurerm_client_config" "current" {}

# Existing central Log Analytics Workspace (management subscription). Used as
# the destination for Application Insights and for Key Vault (and other
# resources') diagnostic settings. Read whenever the central workspace name is
# provided.
data "azurerm_log_analytics_workspace" "central" {
  count = var.log_analytics_workspace_name != "" ? 1 : 0

  provider            = azurerm.law
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_rg_name
}

# Hub virtual networks in the platform network subscription. Read so the VNet
# module can peer to them without tfvars carrying raw cross-subscription
# resource ids. Only populated when var.hub_virtual_networks is set.
data "azurerm_virtual_network" "hub" {
  for_each = var.hub_virtual_networks

  provider            = azurerm.network
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

# Existing shared private DNS zones in the platform network subscription. The
# private endpoints register A-records into these via their dns_zone_keys. Only
# populated when var.existing_private_dns_zones is set.
data "azurerm_private_dns_zone" "existing_private_dns_zones" {
  for_each = var.existing_private_dns_zones

  provider            = azurerm.network
  name                = each.value.name
  resource_group_name = var.existing_private_dns_zones_rg_name
}

# Customer-Managed Key (CMK) sources. The Key Vault and its key are created by
# module.key_vault in this same apply; the depends_on defers these reads until
# after the key exists so the per-resource CMK blocks (AI Search, Redis, SQL
# TDE, Document Intelligence, Cosmos) can consume the key uri/version/id. Only
# populated when var.key_vault_keys is set (otherwise no CMK, no reads).
data "azurerm_key_vault" "cmk" {
  for_each = var.key_vault_keys

  name                = each.value.key_vault_name
  resource_group_name = each.value.resource_group_name

  depends_on = [module.key_vault]
}

data "azurerm_key_vault_key" "cmk" {
  for_each = var.key_vault_keys

  name         = each.value.name
  key_vault_id = data.azurerm_key_vault.cmk[each.key].id

  depends_on = [module.key_vault]
}
