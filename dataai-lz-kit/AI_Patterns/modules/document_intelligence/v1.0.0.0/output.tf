output "cognitive_account" {
  description = "Full Cognitive Account resource object"
  value       = azurerm_cognitive_account.this
  sensitive   = true
}

output "id" {
  description = "The ID of the Cognitive Account."
  value       = azurerm_cognitive_account.this.id
}

output "name" {
  description = "The name of the Cognitive Account."
  value       = azurerm_cognitive_account.this.name
}

output "endpoint" {
  description = "The endpoint of the Cognitive Account."
  value       = azurerm_cognitive_account.this.endpoint
}

output "primary_access_key" {
  description = "The primary access key of the Cognitive Account."
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
}


output "custom_subdomain_name" {
  description = "The custom subdomain name of the Cognitive Account."
  value       = azurerm_cognitive_account.this.custom_subdomain_name
}