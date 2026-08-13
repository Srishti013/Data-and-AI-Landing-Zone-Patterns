#################################
##MS Foundry Project
#################################
resource "azapi_resource" "ai_foundry_project" {
  for_each = var.ai_foundry_projects != null ? var.ai_foundry_projects : {}

  type                      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name                      = each.value.name != null ? each.value.name : each.key
  parent_id                 = each.value.account_key != null ? var.account_ids[each.value.account_key] : each.value.parent_id
  location                  = var.location
  schema_validation_enabled = false

  body = {
    sku = {
      name = each.value.sku_name
    }


    properties = {
      displayName = each.value.displayName
      description = each.value.description

    }

    identity = merge(
      {
        type = each.value.identity_type
      },
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], each.value.identity_type) ? {
        userAssignedIdentities = {
          (each.value.identity_id) = {}
        }
      } : {}
    )
  }

  response_export_values = [
    "identity.principalId",
    "properties.internalId"
  ]
}

#################################
##MS Foundry Project - Diagnostic Settings
#################################
locals {
  # Flatten projects x their diagnostic settings into a single map keyed by
  # "<project_key>.<diag_key>" so each setting becomes a discrete resource.
  ai_foundry_project_diagnostic_settings = merge([
    for proj_key, proj in(var.ai_foundry_projects != null ? var.ai_foundry_projects : {}) : {
      for diag_key, diag in proj.diagnostic_settings :
      "${proj_key}.${diag_key}" => {
        project_key = proj_key
        setting     = diag
      }
    }
  ]...)
}

resource "azurerm_monitor_diagnostic_setting" "ai_foundry_project" {
  for_each = local.ai_foundry_project_diagnostic_settings

  name                           = each.value.setting.name != null ? each.value.setting.name : "diag-${each.value.project_key}"
  target_resource_id             = azapi_resource.ai_foundry_project[each.value.project_key].id
  log_analytics_workspace_id     = each.value.setting.workspace_resource_id
  log_analytics_destination_type = each.value.setting.workspace_resource_id != null ? each.value.setting.log_analytics_destination_type : null
  storage_account_id             = each.value.setting.storage_account_resource_id
  eventhub_authorization_rule_id = each.value.setting.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.setting.event_hub_name
  partner_solution_id            = each.value.setting.marketplace_partner_resource_id

  # Log category groups (e.g. "allLogs", "audit")
  dynamic "enabled_log" {
    for_each = each.value.setting.log_groups

    content {
      category_group = enabled_log.value
    }
  }

  # Individual log categories (used when explicit categories are preferred)
  dynamic "enabled_log" {
    for_each = each.value.setting.log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.setting.metric_categories

    content {
      category = metric.value
    }
  }
}

