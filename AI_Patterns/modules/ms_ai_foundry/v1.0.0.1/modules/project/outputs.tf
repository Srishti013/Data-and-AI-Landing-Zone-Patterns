output "project_ids" {
  description = "Map of project_key => project ARM id."
  value       = { for k, v in azapi_resource.ai_foundry_project : k => v.id }
}

output "project_internal_ids" {
  description = "Map of project_key => project internalId (for ABAC conditions)."
  value       = { for k, v in azapi_resource.ai_foundry_project : k => try(v.output.properties.internalId, "") }
}

output "diagnostic_setting_ids" {
  description = "Map of \"<project_key>.<diag_key>\" => diagnostic setting id."
  value       = { for k, v in azurerm_monitor_diagnostic_setting.ai_foundry_project : k => v.id }
}
