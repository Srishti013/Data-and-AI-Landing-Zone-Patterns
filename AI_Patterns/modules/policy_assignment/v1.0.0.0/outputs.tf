# # #############################################################################
# # # OUTPUTS Policy Assignment
# # #############################################################################

output "id" {
  value       = length(local.policy_assignment) > 0 ? local.policy_assignment[0].id : null
  description = "The ID of the Azure Policy Assignment."
}

output "principal_id" {
  value       = var.assign_identity && length(local.policy_assignment) > 0 ? local.policy_assignment[0].identity[0].principal_id : null
  description = "The Principal ID of the System Assigned Identity (if enabled)."
}

output "scope_type" {
  value = (
    local.scope_is_management_group ? "management_group" :
    local.scope_is_subscription ? "subscription" :
    local.scope_is_resource_group ? "resource_group" :
    local.scope_is_resource ? "resource" :
    "unknown"
  )
  description = "The detected scope type for this policy assignment."
}

output "role_assignment_ids" {
  value       = azurerm_role_assignment.remediation[*].id
  description = "The Role Assignment(s) created for policy remediation."
}
