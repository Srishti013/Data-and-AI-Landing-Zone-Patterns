output "custom_policy_definition_ids" {
  description = "IDs of the custom policy definitions created."
  value       = { for k, d in azurerm_policy_definition.custom : k => d.id }
}

output "assignment_names" {
  description = "Names of the subscription policy assignments created."
  value       = sort(keys(azurerm_subscription_policy_assignment.this))
}

output "assignment_count" {
  description = "Total number of policy assignments created."
  value       = length(azurerm_subscription_policy_assignment.this)
}
