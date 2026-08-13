output "private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azurerm_private_endpoint resource."
  value       = azurerm_private_endpoint.this
}

output "resource" {
  description = "This is the full output for the resource."
  value       = azurerm_search_service.this
}

output "resource_id" {
  description = "The ID of the machine learning workspace."
  value       = azurerm_search_service.this.id
}
