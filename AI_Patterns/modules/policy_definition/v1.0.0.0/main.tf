# Overview:
#   This module creates a Custom policy_definition from already-decoded values
#   (the caller reads the JSON document and passes displayName/policyRule/etc.).

resource "azurerm_policy_definition" "this" {
  name                = var.name
  policy_type         = "Custom"
  mode                = var.mode
  display_name        = var.display_name
  management_group_id = var.management_group_id

  description = var.description
  policy_rule = jsonencode(var.policy_rule)
  parameters  = var.parameters != null ? jsonencode(var.parameters) : null
}
