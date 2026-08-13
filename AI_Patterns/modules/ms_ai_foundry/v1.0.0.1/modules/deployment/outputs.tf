output "deployment_ids" {
  description = "Map of deployment_key => deployment ARM id."
  value       = { for k, v in azapi_resource.aifoundry_deployments : k => v.id }
}
