output "capacity_id" {
  description = "The resource ID of the Azure Fabric capacity created by this module."
  value       = azurerm_fabric_capacity.fabric_capacity.id
}