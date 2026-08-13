# =============================================================================
# Outputs - resource ids / names for the consolidated Data landing zone.
# =============================================================================
output "resource_group_ids" {
  description = "Map of data resource group key -> resource id."
  value       = { for k, v in module.data_resource_groups : k => v.resource_id }
}

output "virtual_network_ids" {
  description = "Map of VNet key -> resource id."
  value       = { for k, v in module.virtual_network : k => v.resource_id }
}

output "key_vault_ids" {
  description = "Map of Key Vault key -> resource id."
  value       = { for k, v in module.key_vault : k => v.resource_id }
}

output "storage_account_ids" {
  description = "Map of storage account key -> resource id."
  value       = { for k, v in module.storage_accounts : k => v.resource_id }
}

output "sql_server_ids" {
  description = "Map of SQL Server key -> resource id."
  value       = { for k, v in module.data_sql_server : k => v.resource_id }
}

output "data_factory_ids" {
  description = "Map of Data Factory key -> resource id."
  value       = { for k, v in module.data_factories : k => v.resource_id }
}

output "user_managed_identity_principal_ids" {
  description = "Map of UMI key -> principal id."
  value       = { for k, v in module.user_managed_identities : k => v.principal_id }
}
