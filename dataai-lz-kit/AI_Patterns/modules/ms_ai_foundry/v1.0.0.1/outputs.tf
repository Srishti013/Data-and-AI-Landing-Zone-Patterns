output "ai_foundry_deployment_ids" {
  description = "Map of AI Foundry deployment IDs"
  value = {
    for k, v in module.deployment.deployment_ids : k => v
  }
}

output "ai_foundry_account_ids" {
  value = {
    for k, v in azapi_resource.ai_foundry : k => v.id
  }
}

output "ai_foundry_project_ids" {
  value = {
    for k, v in module.project.project_ids : k => v
  }
}

output "rai_policy_name" {
  value = {
    for k, v in module.rai_policy.rai_policy_name : k => v
  }
  description = "RAI policy name for model deployments"
}

output "rai_policy_id" {
  value = {
    for k, v in module.rai_policy.rai_policy_id : k => v
  }
  description = "RAI policy resource ID for audit logging"
}

output "ai_foundry_project_connection_ids" {
  description = "Map of AI Foundry project connection IDs"
  value = {
    for k, v in module.project_connection.connection_ids : k => v
  }
}

output "account_connection_ids" {
  description = "Map of account-level connection IDs"
  value = {
    for k, v in module.account_connection.account_connection_ids : k => v
  }
}

output "project_internal_ids" {
  description = "Map of project internalIds (for ABAC conditions)"
  value = {
    for k, v in module.project.project_internal_ids : k => v
  }
}

output "ai_foundry_project_diagnostic_setting_ids" {
  description = "Map of AI Foundry project diagnostic setting IDs, keyed by \"<project_key>.<diag_key>\""
  value = {
    for k, v in module.project.diagnostic_setting_ids : k => v
  }
}