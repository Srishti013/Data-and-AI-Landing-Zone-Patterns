###########################################
###Open AI Deployment Model
##########################################
resource "azapi_resource" "aifoundry_deployments" {
  for_each = var.ai_foundry_deployments != null ? var.ai_foundry_deployments : {}

  type                      = "Microsoft.CognitiveServices/accounts/deployments@2026-05-01"
  name                      = var.name
  parent_id                 = each.value.account_key != null ? var.account_ids[each.value.account_key] : each.value.parent_id
  schema_validation_enabled = false

  # Cognitive Services accounts serialize child-resource writes (deployments /
  # raiPolicies). When several deployments are created/updated in one apply the
  # account returns 409 RequestConflict ("Another operation is being performed
  # on the parent resource"). Retry with backoff so all deployments succeed in a
  # single apply instead of failing after the first one.
  retry = {
    error_message_regex  = ["RequestConflict", "Another operation is being performed", "Conflict"]
    interval_seconds     = 15
    max_interval_seconds = 120
  }

  body = {
    sku = {
      name     = each.value.sku_name
      capacity = each.value.capacity
    }

    properties = merge(
      {
        model = {
          format  = each.value.model_format
          name    = each.value.model_name
          version = each.value.model_version
        }
      },
      each.value.rai_policy_name != null ? {
        raiPolicyName = each.value.rai_policy_name
      } : {}
    )
  }
}
