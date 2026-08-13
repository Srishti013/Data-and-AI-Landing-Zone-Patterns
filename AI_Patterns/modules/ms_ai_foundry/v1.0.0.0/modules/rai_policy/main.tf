
########################################
##RAI Policy
#######################################
# Managed via azapi (not azurerm) so that advanced content filters which have
# no severity threshold (Jailbreak, Indirect Attack, Protected Material Code/Text,
# Profanity, Spotlighting) can be expressed. azurerm_cognitive_account_rai_policy
# requires severity_threshold on every filter and therefore cannot model them.
resource "azapi_resource" "project_rai_policy" {
  for_each = var.ai_foundry_rai_policy != null ? var.ai_foundry_rai_policy : {}

  type                      = "Microsoft.CognitiveServices/accounts/raiPolicies@${try(each.value.api_version, "2024-10-01")}"
  name                      = var.name
  parent_id                 = each.value.account_key != null ? var.account_ids[each.value.account_key] : each.value.cognitive_account_id
  schema_validation_enabled = false

  body = {
    properties = {
      basePolicyName = each.value.base_policy_name
      mode           = try(each.value.mode, "Default")
      contentFilters = [
        for cf in try(each.value.content_filters, []) : merge(
          {
            name     = cf.name
            source   = cf.source
            enabled  = try(cf.filter_enabled, true)
            blocking = try(cf.block_enabled, true)
          },
          # severityThreshold is only valid for the four harm categories
          # (Hate/Sexual/Selfharm/Violence). Advanced filters must omit it.
          try(cf.severity_threshold, null) != null ? {
            severityThreshold = cf.severity_threshold
          } : {}
        )
      ]
    }
  }

  # Cognitive Services serializes child-resource writes; retry on the account
  # busy conflict so the policy applies in the same run as the deployments.
  retry = {
    error_message_regex  = ["RequestConflict", "Another operation is being performed", "Conflict"]
    interval_seconds     = 15
    max_interval_seconds = 120
  }
}
