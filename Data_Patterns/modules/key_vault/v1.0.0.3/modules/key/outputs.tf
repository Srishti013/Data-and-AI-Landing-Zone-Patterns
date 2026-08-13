output "id" {
  description = "The Key Vault Key ID"
  value       = azurerm_key_vault_key.this.id
}

output "resource_id" {
  description = "The Azure resource id of the secret."
  value       = azurerm_key_vault_key.this.resource_id
}

output "resource_versionless_id" {
  description = "The versionless Azure resource id of the secret."
  value       = azurerm_key_vault_key.this.resource_versionless_id
}

output "versionless_id" {
  description = "The Base ID of the Key Vault Key"
  value       = azurerm_key_vault_key.this.versionless_id
}

output "version" {
  description = "The current version of the key vault key."
  value       = azurerm_key_vault_key.this.version
}

output "name" {
  description = "The Key Vault Key Name"
  value       = azurerm_key_vault_key.this.name
}