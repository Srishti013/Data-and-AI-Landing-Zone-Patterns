module "module_WAF" {
  source = "../../naming_module/v1.0.0.1"

  # Basic naming parameters
  env                = var.env
  org                = var.org
  region_code        = var.region_code
  base_name          = var.base_name
  additional_name    = var.additional_name
  iterator           = var.iterator
  au                 = var.au
  app_code           = var.app_code
  bu                 = var.bu
  owner              = var.owner
  resource_type_code = var.resource_type_code
  max_length         = var.max_length
  no_dashes          = var.no_dashes
  add_random         = var.add_random
  rnd_length         = var.rnd_length

  # Use v1.0.0.1 naming module interface
  product_version = "1.0.0.1"

  # Pass mandatory tags to naming module (8 mandatory tags)
  environment         = var.environment
  business_owner      = var.business_owner
  business_unit       = var.business_unit
  criticality         = var.criticality
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance

  # Pass optional tags to naming module (3 optional tags)
  region              = var.region
  description         = var.description
  notification_emails = var.notification_emails

  # Additional custom tags with ProductName and ProductVersion
  additional_tags = merge(
    var.additional_tags != null ? var.additional_tags : {},
    {
      # Mandatory tags passed as additional_tags
      Owner          = var.owner
      AppName        = var.app_name
      BudgetID       = var.budget_id
      Status         = var.status
      ProductName    = "key_vault"
      ProductVersion = "1.0.0.1"
      Service        = var.service

      # Legacy tags maintained for compatibility
      Type               = var.type
      CostAllocationUnit = var.cost_allocation_unit
      BudgetLimit        = var.budget_limit
      CostAlertThreshold = var.cost_alert_threshold
      ComplianceRequired = var.compliance_required
    },
    var.delete_after != "" ? { DeleteAfter = var.delete_after } : {},
    var.tier != "" ? { Tier = var.tier } : {},
    var.app_id != "" ? { AppId = var.app_id } : {},
    var.auto_delete != "" ? { AutoDelete = var.auto_delete } : {},
    var.auto_shutdown != "" ? { AutoShutdown = var.auto_shutdown } : {},
    var.backup_policy != "" ? { BackupPolicy = var.backup_policy } : {},
    var.disaster_recovery != "" ? { DisasterRecovery = var.disaster_recovery } : {},
    var.integration_id != null && var.integration_id != "" ? { IntegrationID = var.integration_id } : {},
    var.experiment_phase != null && var.experiment_phase != "" ? { ExperimentPhase = var.experiment_phase } : {},
    var.os != null && var.os != "" ? { OS = var.os } : {},
    var.last_vm_accessed != null && var.last_vm_accessed != "" ? { LastVMAccessed = var.last_vm_accessed } : {},
    var.maintenance_window != null && var.maintenance_window != "" ? { MaintenanceWindow = var.maintenance_window } : {},
    var.patch_policy != null && var.patch_policy != "" ? { PatchPolicy = var.patch_policy } : {},
    var.retention != null && var.retention != "" ? { Retention = var.retention } : {},
    var.sandbox_type != null && var.sandbox_type != "" ? { SandboxType = var.sandbox_type } : {}
  )
}


resource "azurerm_web_application_firewall_policy" "this" {
  #checkov:skip=CKV_AZURE_122:WAF mode is configurable via variables
  #checkov:skip=CKV_AZURE_135:Log4j rule is configurable via managed_rules variable
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "managed_rules" {
    for_each = [var.managed_rules]

    content {
      dynamic "managed_rule_set" {
        for_each = managed_rules.value.managed_rule_set

        content {
          version = managed_rule_set.value.version
          type    = managed_rule_set.value.type

          dynamic "rule_group_override" {
            for_each = managed_rule_set.value.rule_group_override == null ? {} : managed_rule_set.value.rule_group_override

            content {
              rule_group_name = rule_group_override.value.rule_group_name

              dynamic "rule" {
                for_each = rule_group_override.value.rule == null ? [] : rule_group_override.value.rule

                content {
                  id      = rule.value.id
                  action  = rule.value.action
                  enabled = rule.value.enabled
                }
              }
            }
          }
        }
      }
      dynamic "exclusion" {
        for_each = managed_rules.value.exclusion == null ? {} : managed_rules.value.exclusion

        content {
          match_variable          = exclusion.value.match_variable
          selector                = exclusion.value.selector
          selector_match_operator = exclusion.value.selector_match_operator

          dynamic "excluded_rule_set" {
            for_each = exclusion.value.excluded_rule_set == null ? [] : [exclusion.value.excluded_rule_set]

            content {
              type    = excluded_rule_set.value.type
              version = excluded_rule_set.value.version

              dynamic "rule_group" {
                for_each = excluded_rule_set.value.rule_group == null ? [] : excluded_rule_set.value.rule_group

                content {
                  rule_group_name = rule_group.value.rule_group_name
                  excluded_rules  = rule_group.value.excluded_rules
                }
              }
            }
          }
        }
      }
    }
  }
  dynamic "custom_rules" {
    for_each = var.custom_rules == null ? {} : var.custom_rules

    content {
      action               = custom_rules.value.action
      priority             = custom_rules.value.priority
      rule_type            = custom_rules.value.rule_type
      enabled              = custom_rules.value.enabled
      group_rate_limit_by  = custom_rules.value.group_rate_limit_by
      name                 = custom_rules.value.name
      rate_limit_duration  = custom_rules.value.rate_limit_duration
      rate_limit_threshold = custom_rules.value.rate_limit_threshold

      dynamic "match_conditions" {
        for_each = custom_rules.value.match_conditions

        content {
          operator           = match_conditions.value.operator
          match_values       = match_conditions.value.match_values
          negation_condition = match_conditions.value.negation_condition
          transforms         = match_conditions.value.transforms

          dynamic "match_variables" {
            for_each = match_conditions.value.match_variables

            content {
              variable_name = match_variables.value.variable_name
              selector      = match_variables.value.selector
            }
          }
        }
      }
    }
  }
  dynamic "policy_settings" {
    for_each = var.policy_settings == null ? [] : [var.policy_settings]

    content {
      enabled                                   = policy_settings.value.enabled
      file_upload_limit_in_mb                   = policy_settings.value.file_upload_limit_in_mb
      js_challenge_cookie_expiration_in_minutes = policy_settings.value.js_challenge_cookie_expiration_in_minutes
      max_request_body_size_in_kb               = policy_settings.value.max_request_body_size_in_kb
      mode                                      = policy_settings.value.mode
      request_body_check                        = policy_settings.value.request_body_check
      request_body_enforcement                  = policy_settings.value.request_body_enforcement
      request_body_inspect_limit_in_kb          = policy_settings.value.request_body_inspect_limit_in_kb

      dynamic "log_scrubbing" {
        for_each = policy_settings.value.log_scrubbing == null ? [] : [policy_settings.value.log_scrubbing]

        content {
          enabled = log_scrubbing.value.enabled

          dynamic "rule" {
            for_each = log_scrubbing.value.rule == null ? [] : log_scrubbing.value.rule

            content {
              match_variable          = rule.value.match_variable
              enabled                 = rule.value.enabled
              selector                = rule.value.selector
              selector_match_operator = rule.value.selector_match_operator
            }
          }
        }
      }
    }
  }
  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_web_application_firewall_policy.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_web_application_firewall_policy.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
