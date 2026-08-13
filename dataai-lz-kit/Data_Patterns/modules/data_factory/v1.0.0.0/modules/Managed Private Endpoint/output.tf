output "id" {
  description = "Managed Private Endpoint resource ID"
  value       = azurerm_data_factory_managed_private_endpoint.this.id
}

output "name" {
  description = "Managed Private Endpoint name"
  value       = azurerm_data_factory_managed_private_endpoint.this.name
}

output "target_resource_id" {
  description = "Target resource ID"
  value       = azurerm_data_factory_managed_private_endpoint.this.target_resource_id
}

output "subresource_name" {
  description = "Subresource name"
  value       = azurerm_data_factory_managed_private_endpoint.this.subresource_name
}

output "resource" {
  description = "Complete Managed Private Endpoint resource object"
  value       = azurerm_data_factory_managed_private_endpoint.this
}