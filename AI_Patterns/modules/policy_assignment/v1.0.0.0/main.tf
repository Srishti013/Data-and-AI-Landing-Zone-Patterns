# Overview:
#   This module:
#   - Creates policy-assignment and assign the remediation required role to the policy assignment identity

# 
# - Generate the locals for filtering the scope against the below resource blocks and creates a map of Role Definition Ids 
#   when found in the policy definition.
# 
locals {
  # The following regex is designed to consistently split a resource_id into the following capture
  # groups, regardless of resource type:
  # [0] Resource scope, type substring (e.g. "/providers/Microsoft.Management/managementGroups/")
  # [1] Resource scope, name substring (e.g. "group1")
  # [2] Resource, type substring (e.g. "/providers/Microsoft.Authorization/policyAssignments/")
  # [3] Resource, name substring (e.g. "assignment1")
  regex_scope_is_management_group = "(?i)(/providers/Microsoft.Management/managementGroups/)([^/]+)$"
  regex_scope_is_subscription     = "(?i)(/subscriptions/)([^/]+)$"
  regex_scope_is_resource_group   = "(?i)(/subscriptions/[^/]+/resourceGroups/)([^/]+)$"
  regex_scope_is_resource         = "(?i)(/subscriptions/[^/]+/resourceGroups(?:/[^/]+){4}/)([^/]+)$"

  scope_is_management_group = length(regexall(local.regex_scope_is_management_group, var.scope)) > 0 ? true : false
  scope_is_subscription     = local.scope_is_management_group == false ? length(regexall(local.regex_scope_is_subscription, var.scope)) > 0 ? true : false : false
  scope_is_resource_group   = local.scope_is_management_group == false ? length(regexall(local.regex_scope_is_resource_group, var.scope)) > 0 ? true : false : false
  scope_is_resource         = local.scope_is_management_group == false ? length(regexall(local.regex_scope_is_resource, var.scope)) > 0 ? true : false : false

  ######## For Output variable and role assignments ########
  policy_assignment = concat(
    azurerm_management_group_policy_assignment.this,
    azurerm_subscription_policy_assignment.this,
    azurerm_resource_group_policy_assignment.this,
    azurerm_resource_policy_assignment.this,
  )
}

#
# - If scope is Management Group, create a Management Group policy assignment
#
resource "azurerm_management_group_policy_assignment" "this" {
  count = local.scope_is_management_group == true ? 1 : 0

  # Mandatory resource attributes
  name                 = var.name
  management_group_id  = var.scope
  policy_definition_id = var.policy_definition_id

  # Optional resource attributes
  location     = var.location
  description  = var.description
  display_name = var.display_name
  metadata     = try(length(var.metadata) > 0, false) ? jsonencode(var.metadata) : null
  parameters   = try(length(var.parameters) > 0, false) ? jsonencode(var.parameters) : null
  not_scopes   = var.not_scopes
  enforce      = var.enforcement_mode == null ? true : var.enforcement_mode == "Default"

  # Dynamic configuration blocks
  # The identity block only supports a single value for type = "SystemAssigned" 
  # so the following logic ensures the block is only created when this values specified in the source template
  dynamic "identity" {
    for_each = var.assign_identity == false ? [] : tolist([var.assign_identity])
    content {
      type = "SystemAssigned"
    }
  }
}

#
# - If scope is Subscription, create a Subscription policy assignment
#
resource "azurerm_subscription_policy_assignment" "this" {
  count = local.scope_is_subscription == true ? 1 : 0

  # Mandatory resource attributes
  name                 = var.name
  subscription_id      = var.scope
  policy_definition_id = var.policy_definition_id

  # Optional resource attributes
  location     = var.location
  description  = var.description
  display_name = var.display_name
  metadata     = try(length(var.metadata) > 0, false) ? jsonencode(var.metadata) : null
  parameters   = try(length(var.parameters) > 0, false) ? jsonencode(var.parameters) : null
  not_scopes   = var.not_scopes
  enforce      = var.enforcement_mode == null ? true : var.enforcement_mode == "Default"

  # Dynamic configuration blocks
  # The identity block only supports a single value for type = "SystemAssigned" 
  # so the following logic ensures the block is only created when this value is specified in the source template
  dynamic "identity" {
    for_each = var.assign_identity == false ? [] : tolist([var.assign_identity])
    content {
      type = "SystemAssigned"
    }
  }
}

#
# - If scope is Resource Group, create a Resource Group policy assignment
#
resource "azurerm_resource_group_policy_assignment" "this" {
  count = local.scope_is_resource_group == true ? 1 : 0

  # Mandatory resource attributes
  name                 = var.name
  resource_group_id    = var.scope
  policy_definition_id = var.policy_definition_id

  # Optional resource attributes
  location     = var.location
  description  = var.description
  display_name = var.display_name
  metadata     = try(length(var.metadata) > 0, false) ? jsonencode(var.metadata) : null
  parameters   = try(length(var.parameters) > 0, false) ? jsonencode(var.parameters) : null
  not_scopes   = var.not_scopes
  enforce      = var.enforcement_mode == null ? true : var.enforcement_mode == "Default"

  # Dynamic configuration blocks
  # The identity block only supports a single value for type = "SystemAssigned" 
  # so the following logic ensures the block is only created when this valueis specified in the source template
  dynamic "identity" {
    for_each = var.assign_identity == false ? [] : tolist([var.assign_identity])
    content {
      type = "SystemAssigned"
    }
  }
}

#
# - If scope is Resource, create a Resource policy assignment
#
resource "azurerm_resource_policy_assignment" "this" {
  count = local.scope_is_resource == true ? 1 : 0

  # Mandatory resource attributes
  name                 = var.name
  resource_id          = var.scope
  policy_definition_id = var.policy_definition_id

  # Optional resource attributes
  location     = var.location
  description  = var.description
  display_name = var.display_name
  metadata     = try(length(var.metadata) > 0, false) ? jsonencode(var.metadata) : null
  parameters   = try(length(var.parameters) > 0, false) ? jsonencode(var.parameters) : null
  not_scopes   = var.not_scopes
  enforce      = var.enforcement_mode == null ? true : var.enforcement_mode == "Default"


  # Dynamic configuration blocks
  # The identity block only supports a single value for type = "SystemAssigned" 
  # so the following logic ensures the block is only created when this value is specified in the source template
  dynamic "identity" {
    for_each = var.assign_identity == false ? [] : tolist([var.assign_identity])
    content {
      type = "SystemAssigned"
    }
  }
}

#
# - If roleAssignments found AND assign_identity == true => Assign the Role(s) required to the Policy assignment Identity
#
resource "azurerm_role_assignment" "remediation" {
  count = var.assign_identity == true ? 1 : 0

  principal_id         = local.policy_assignment[0].identity[0].principal_id
  role_definition_name = var.remediation_role_name
  scope                = var.scope

  depends_on = [
    azurerm_resource_group_policy_assignment.this,
    azurerm_subscription_policy_assignment.this,
    azurerm_resource_policy_assignment.this,
    azurerm_management_group_policy_assignment.this
  ]
}
