output "connection_ids" {
  description = "Map of connection_key => project connection ARM id."
  value       = { for k, v in azapi_resource.ai_foundry_project_connection : k => v.id }
}
