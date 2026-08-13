#########################
####Naming Conventions
#########################
module "module_container_registry" {
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
  product_version = "1.0.0.0"

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
      ProductName    = "azure_container_registry"
      ProductVersion = "1.0.0.0"
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

############################
## Azure Container Registry
############################
resource "azurerm_container_registry" "this" {
  location                      = module.module_container_registry.location
  name                          = module.module_container_registry.name
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  anonymous_pull_enabled        = var.anonymous_pull_enabled
  data_endpoint_enabled         = var.data_endpoint_enabled
  export_policy_enabled         = var.export_policy_enabled
  network_rule_bypass_option    = var.network_rule_bypass_option
  public_network_access_enabled = var.public_network_access_enabled
  quarantine_policy_enabled     = var.quarantine_policy_enabled
  retention_policy_in_days      = var.sku == "Premium" ? var.retention_policy_in_days : null
  tags                          = module.module_container_registry.tags
  trust_policy_enabled          = var.enable_trust_policy
  zone_redundancy_enabled       = var.sku == "Premium" ? var.zone_redundancy_enabled : false

  dynamic "encryption" {
    for_each = var.customer_managed_key != null ? { this = var.customer_managed_key } : {}

    content {
      identity_client_id = data.azurerm_user_assigned_identity.this[0].client_id
      key_vault_key_id   = data.azurerm_key_vault_key.this[0].id
    }
  }
  dynamic "georeplications" {
    for_each = local.ordered_geo_replications

    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      tags                      = georeplications.value.tags
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
    }
  }
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  # Only one network_rule_set block is allowed.
  # Create it if the variable is not null.
  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? { this = var.network_rule_set } : {}

    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rule

        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.zone_redundancy_enabled && var.sku == "Premium" || !var.zone_redundancy_enabled
      error_message = "The Premium SKU is required if zone redundancy is enabled."
    }
    precondition {
      condition     = var.network_rule_set != null && var.sku == "Premium" || var.network_rule_set == null
      error_message = "The Premium SKU is required if a network rule set is defined."
    }
    precondition {
      condition     = var.customer_managed_key != null && var.sku == "Premium" || var.customer_managed_key == null
      error_message = "The Premium SKU is required if a customer managed key is defined."
    }
    precondition {
      condition     = var.customer_managed_key != null && contains(var.managed_identities.user_assigned_resource_ids, try(var.customer_managed_key.user_assigned_identity.resource_id, "null")) || var.customer_managed_key == null
      error_message = "The user assigned managed identity for the customer managed key encryption must be assigned to the container registry."
    }
  }
}

resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${module.module_container_registry.name}")
  scope      = azurerm_container_registry.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_container_registry.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${module.module_container_registry.name}"
  target_resource_id             = azurerm_container_registry.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type == "Dedicated" ? null : each.value.log_analytics_destination_type
  log_analytics_workspace_id     = each.value.workspace_resource_id
  partner_solution_id            = each.value.marketplace_partner_resource_id
  storage_account_id             = each.value.storage_account_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
    }
  }
}
