output "custom_policy_definition_ids" {
  description = "IDs of the custom policy definitions created."
  value       = { for k, m in module.definition : k => m.id }
}

output "assignment_names" {
  description = "Names of the subscription policy assignments created."
  value       = sort(keys(module.assignment))
}

output "assignment_count" {
  description = "Total number of policy assignments created."
  value       = length(module.assignment)
}
