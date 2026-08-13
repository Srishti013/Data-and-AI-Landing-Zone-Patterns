output "rai_policy_name" {
  description = "Map of rai_key => RAI policy name."
  value       = { for k, v in azapi_resource.project_rai_policy : k => v.name }
}

output "rai_policy_id" {
  description = "Map of rai_key => RAI policy ARM id."
  value       = { for k, v in azapi_resource.project_rai_policy : k => v.id }
}
