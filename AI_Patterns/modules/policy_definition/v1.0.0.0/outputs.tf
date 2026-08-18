output "id" {
  value       = azurerm_policy_definition.this.id
  description = "The ID of the custom policy definition."
}

output "name" {
  value       = azurerm_policy_definition.this.name
  description = "The name of the custom policy definition."
}
