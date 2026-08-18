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

  ######################################## Role definition Id parsing logic ########################################

  # Extracting policy definition name
  policy_set_def_name = basename(var.policy_definition_id)

  # Enhanced approach: process role assignments for both individual policies and policy sets
  policy_definition = contains(split("/", var.policy_definition_id), "policySetDefinitions") ? {} : {
    (var.policy_definition_id) = {
      policy_key    = var.policy_definition_id
      policy_def_id = basename(var.policy_definition_id)
    }
  }

  # For policy set definitions, extract individual policy definitions and their role requirements  
  policy_set_definitions = contains(split("/", var.policy_definition_id), "policySetDefinitions") ? try(merge(
    try({ for psd in data.azurerm_policy_set_definition.builtin : psd.id => psd }, {}),
    try({ for psd in data.azurerm_policy_set_definition.custom : psd.id => psd }, {}),
    try({ for psd in data.azurerm_policy_set_definition.this : psd.id => psd }, {})
  ), {}) : {}

  # Extract all policy definition references from policy set definitions as a list (allow duplicates)
  policy_set_policy_definitions_list = length(local.policy_set_definitions) > 0 ? flatten([
    for psd in values(local.policy_set_definitions) : [
      for pd in psd.policy_definition_reference : {
        policy_key    = pd.policy_definition_id
        policy_def_id = basename(pd.policy_definition_id)
        is_builtin    = !strcontains(pd.policy_definition_id, "/managementGroups/")
        is_custom     = strcontains(pd.policy_definition_id, "/managementGroups/")
        mg_name       = strcontains(pd.policy_definition_id, "/managementGroups/") ? try(regex("/managementGroups/([^/]+)/", pd.policy_definition_id)[0], null) : null
      }
    ]
  ]) : []

  # # Extracting policy rules from policy definitions
  # Combine data from built-in and custom policy definitions (individual policies only)
  all_policy_data = try(merge(
    data.azurerm_policy_definition.builtin,
    data.azurerm_policy_definition.custom,
    data.azurerm_policy_definition.this # For backward compatibility
  ), {})

  # Extract policy rules from individual policies
  policy_rule_json = try([
    for policy in local.policy_definition : {
      policy_rule_map = jsondecode(
        try(
          lookup(local.all_policy_data, policy.policy_key)["policy_rule"],
          lookup(data.azurerm_policy_definition.this, policy.policy_key, {})["policy_rule"]
        )
      )
    }
    if try(lookup(local.all_policy_data, policy.policy_key)["policy_rule"], null) != null ||
    try(lookup(data.azurerm_policy_definition.this, policy.policy_key, {})["policy_rule"], null) != null
  ], [])

  # Note: Policy set rule extraction is disabled due to Terraform for_each limitations
  # Only individual policies support automatic role assignment extraction
  combined_policy_rules = try(local.policy_rule_json, [])

  # Fetching Role assignments from individual policies only
  map_role_definition_id = try(flatten([
    for policy in try(local.combined_policy_rules, []) : [
      for role_def in try(policy.policy_rule_map.then.details.roleDefinitionIds, []) : {
        role_def_key = basename(role_def)
        role_def_id  = "/providers/Microsoft.Authorization/roleDefinitions/${basename(role_def)}"
      }
    ]
  ]), [])

  # Add manual role definitions if provided
  manual_role_definition_id = try([
    for role_def in var.manual_role_definition_ids : {
      role_def_key = basename(role_def)
      role_def_id  = role_def
    }
  ], [])

  # Combine automatic and manual role definitions
  all_role_definition_ids = concat(
    try(local.map_role_definition_id, []),
    try(local.manual_role_definition_id, [])
  )

  role_assignments = try({
    for k in try(local.all_role_definition_ids, []) : k.role_def_id => k...
    if length(try(local.all_role_definition_ids, [])) > 0 && var.assign_identity == true
  }, {})

  ######## For Output variable and role assignments ########
  policy_assignment = concat(
    azurerm_management_group_policy_assignment.this,
    azurerm_subscription_policy_assignment.this,
    azurerm_resource_group_policy_assignment.this,
    azurerm_resource_policy_assignment.this,
  )
}

#
# - Dependencies data resources
#
# Data source for built-in policy definitions (only for individual policies)
data "azurerm_policy_definition" "builtin" {
  for_each = {
    for k, v in local.policy_definition : k => v
    if !strcontains(k, "/managementGroups/")
  }

  name = each.value.policy_def_id
}

# Data source for custom policy definitions in management groups (only for individual policies)
data "azurerm_policy_definition" "custom" {
  for_each = {
    for k, v in local.policy_definition : k => v
    if strcontains(k, "/managementGroups/") && var.auto_detect_management_group
  }

  name = each.value.policy_def_id
  management_group_name = (
    var.management_group_policy_definition != null ? var.management_group_policy_definition :
    try(regex("/managementGroups/([^/]+)/", each.key)[0], null)
  )
}

# Legacy data source for backward compatibility (only for individual policies)
data "azurerm_policy_definition" "this" {
  for_each = {
    for k, v in local.policy_definition : k => v
    if !var.auto_detect_management_group || var.management_group_policy_definition != null
  }

  name                  = each.value.policy_def_id
  management_group_name = var.management_group_policy_definition
}

# Data source for built-in policy set definitions
data "azurerm_policy_set_definition" "builtin" {
  count = (
    contains(split("/", var.policy_definition_id), "policySetDefinitions") &&
    !strcontains(var.policy_definition_id, "/managementGroups/")
  ) ? 1 : 0

  name = local.policy_set_def_name
}

# Data source for custom policy set definitions in management groups
data "azurerm_policy_set_definition" "custom" {
  count = (
    contains(split("/", var.policy_definition_id), "policySetDefinitions") &&
    strcontains(var.policy_definition_id, "/managementGroups/") &&
    var.auto_detect_management_group
  ) ? 1 : 0

  name = local.policy_set_def_name
  management_group_name = (
    var.management_group_set_definition != null ? var.management_group_set_definition :
    try(regex("/managementGroups/([^/]+)/", var.policy_definition_id)[0], null)
  )
}

# Legacy data source for backward compatibility
data "azurerm_policy_set_definition" "this" {
  count = (
    contains(split("/", var.policy_definition_id), "policySetDefinitions") &&
    (!var.auto_detect_management_group || var.management_group_set_definition != null)
  ) ? 1 : 0

  name                  = local.policy_set_def_name
  management_group_name = var.management_group_set_definition
}

# Note: Due to Terraform limitations with for_each on computed values, 
# automatic role assignment extraction for policy sets is not supported.
# For policy sets with DeployIfNotExists/Modify policies:
# 1. Set assign_identity = true to create the managed identity
# 2. Create role assignments separately outside this module
# 3. Or use individual policy assignments for automatic role assignment

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
  for_each = var.assign_identity == true ? local.role_assignments : {}

  principal_id       = local.policy_assignment[0].identity[0].principal_id
  role_definition_id = each.key
  scope              = var.scope

  depends_on = [
    azurerm_resource_group_policy_assignment.this,
    azurerm_subscription_policy_assignment.this,
    azurerm_resource_policy_assignment.this,
    azurerm_management_group_policy_assignment.this
  ]
}
