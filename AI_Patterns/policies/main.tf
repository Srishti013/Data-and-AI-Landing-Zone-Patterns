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

# Each custom policy is a JSON document under ./definitions; the caller decodes it
# and the policy_definition module creates the Custom definition resource.
module "definition" {
  source   = "../modules/policy_definition/v1.0.0.0"
  for_each = local.custom_defs

  name         = each.key
  display_name = each.value.displayName
  mode         = try(each.value.mode, "All")
  description  = try(each.value.description, null)
  policy_rule  = each.value.policyRule
  parameters   = try(each.value.parameters, null)
}

# Every assignment (built-in or custom) is created through the shared
# policy_assignment module. The module detects the subscription scope, attaches a
# SystemAssigned identity when assign_identity is true, and — for Modify /
# DeployIfNotExists policies — extracts the policy's own roleDefinitionIds and
# creates the remediation role assignments automatically.
module "assignment" {
  source   = "../modules/policy_assignment/v1.0.0.0"
  for_each = local.assignments

  name                 = each.value.name
  display_name         = each.value.display_name
  scope                = "/subscriptions/${var.subscription_id}"
  policy_definition_id = each.value.builtin_id != null ? "/providers/Microsoft.Authorization/policyDefinitions/${each.value.builtin_id}" : module.definition[each.value.custom_key].id
  parameters           = each.value.parameters_json != null ? jsondecode(each.value.parameters_json) : null
  assign_identity      = contains(local.remediation_effects, each.value.effect)
  location             = contains(local.remediation_effects, each.value.effect) ? var.location : null
}
