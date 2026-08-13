output "ai_foundry_deployment_ids" {
  description = "Map of AI Foundry deployment IDs"
  value = {
    for k, v in azapi_resource.aifoundry_deployments : k => v.id
  }
}

output "ai_foundry_account_ids" {
  value = {
    for k, v in azapi_resource.ai_foundry : k => v.id
  }
}

output "ai_foundry_project_ids" {
  value = {
    for k, v in azapi_resource.ai_foundry_project : k => v.id
  }
}

output "rai_policy_name" {
  value = {
    for k, v in azapi_resource.project_rai_policy : k => v.name
  }
  description = "RAI policy name for model deployments"
}

output "rai_policy_id" {
  value = {
    for k, v in azapi_resource.project_rai_policy : k => v.id
  }
  description = "RAI policy resource ID for audit logging"
}

output "ai_foundry_project_connection_ids" {
  description = "Map of AI Foundry project connection IDs"
  value = {
    for k, v in azapi_resource.ai_foundry_project_connection : k => v.id
  }
}

output "account_connection_ids" {
  description = "Map of account-level connection IDs"
  value = {
    for k, v in azapi_resource.account_connection : k => v.id
  }
}

output "project_internal_ids" {
  description = "Map of project internalIds (for ABAC conditions)"
  value = {
    for k, v in azapi_resource.ai_foundry_project : k => try(v.output.properties.internalId, "")
  }
}

output "ai_foundry_project_diagnostic_setting_ids" {
  description = "Map of AI Foundry project diagnostic setting IDs, keyed by \"<project_key>.<diag_key>\""
  value = {
    for k, v in azurerm_monitor_diagnostic_setting.ai_foundry_project : k => v.id
  }
}