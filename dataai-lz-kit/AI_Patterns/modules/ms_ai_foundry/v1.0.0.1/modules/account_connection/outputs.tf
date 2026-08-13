output "account_connection_ids" {
  description = "Map of connection_key => account connection ARM id."
  value       = { for k, v in azapi_resource.account_connection : k => v.id }
}
