output "id" {
  description = "The ID of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.this.id
}

output "name" {
  description = "The name of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.this.name
}

output "endpoint" {
  description = "The endpoint of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "read_endpoints" {
  description = "The read endpoints of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.this.read_endpoints
}

output "write_endpoints" {
  description = "The write endpoints of the Cosmos DB account."
  value       = azurerm_cosmosdb_account.this.write_endpoints
}

output "identity_principal_id" {
  description = "The principal ID of the managed identity, if configured."
  value       = try(azurerm_cosmosdb_account.this.identity[0].principal_id, null)
}

output "private_endpoints" {
  description = "A map of private endpoints. The map key is the supplied input to var.private_endpoints. The map value is the entire azurerm_private_endpoint resource."
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}

output "sql_databases" {
  description = "A map of SQL databases created. The map key is the supplied input to var.sql_databases."
  value       = azurerm_cosmosdb_sql_database.this
}

output "sql_containers" {
  description = "A map of SQL containers created."
  value       = azurerm_cosmosdb_sql_container.this
}
