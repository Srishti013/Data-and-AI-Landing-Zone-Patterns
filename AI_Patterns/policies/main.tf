# =============================================================================
# AI Landing Zone - Azure Policy guardrail engine (subscription scope).
#
# Data-driven: every custom policy is a JSON document under ./definitions/*.json;
# every assignment (built-in OR custom) is a row in local.policy_catalog (catalog.tf).
# Incremental-safe: a custom row only assigns once its definition JSON exists.
# =============================================================================

locals {
  # Load every custom policy definition document from ./definitions/*.json
  _def_files  = fileset("${path.module}/definitions", "*.json")
  custom_defs = { for f in local._def_files : trimsuffix(f, ".json") => jsondecode(file("${path.module}/definitions/${f}")) }

  # Effects whose assignment needs a managed identity + role for remediation.
  remediation_effects = ["Modify", "DeployIfNotExists"]

  # Only assign rows whose definition is resolvable now:
  #  - built-in rows are always resolvable
  #  - custom rows resolve only once their definition JSON has been authored
  assignments = {
    for a in local.policy_catalog : a.name => a
    if a.builtin_id != null || contains(keys(local.custom_defs), coalesce(a.custom_key, "__none__"))
  }
}

resource "azurerm_policy_definition" "custom" {
  for_each = local.custom_defs

  name         = each.key
  policy_type  = "Custom"
  mode         = try(each.value.mode, "All")
  display_name = each.value.displayName
  description  = try(each.value.description, null)
  policy_rule  = jsonencode(each.value.policyRule)
  parameters   = try(each.value.parameters, null) != null ? jsonencode(each.value.parameters) : null
}

resource "azurerm_subscription_policy_assignment" "this" {
  for_each = local.assignments

  name                 = each.value.name
  display_name         = each.value.display_name
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = each.value.builtin_id != null ? "/providers/Microsoft.Authorization/policyDefinitions/${each.value.builtin_id}" : azurerm_policy_definition.custom[each.value.custom_key].id
  parameters           = each.value.parameters_json
  location             = contains(local.remediation_effects, each.value.effect) ? var.location : null

  dynamic "identity" {
    for_each = contains(local.remediation_effects, each.value.effect) ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}

# Modify / DeployIfNotExists assignments patch or deploy resources, so their
# managed identity needs rights. Contributor at subscription scope is broad but
# functional; can be tightened to per-policy roleDefinitionIds later.
resource "azurerm_role_assignment" "remediation" {
  for_each = { for k, a in local.assignments : k => a if contains(local.remediation_effects, a.effect) }

  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_subscription_policy_assignment.this[each.key].identity[0].principal_id
}
