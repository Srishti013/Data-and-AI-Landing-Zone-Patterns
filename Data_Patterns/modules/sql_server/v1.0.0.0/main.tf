#########################
####Naming Conventions
#########################
module "module_sql_server" {
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
      ProductName    = "sql_server"
      ProductVersion = "1.0.0.0"
      Service        = var.service

      # Legacy tags maintained for compatibility
      AppSupport         = var.app_support
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

########################################
### Azure SQL Server
########################################
resource "azurerm_mssql_server" "this" {
  location                                 = module.module_sql_server.location
  name                                     = module.module_sql_server.name # calling code must supply the name
  resource_group_name                      = var.resource_group_name
  version                                  = var.server_version
  administrator_login                      = var.administrator_login
  administrator_login_password             = var.administrator_login_password
  connection_policy                        = var.connection_policy
  express_vulnerability_assessment_enabled = var.express_vulnerability_assessment_enabled
  minimum_tls_version                      = "1.2"
  outbound_network_restriction_enabled     = var.outbound_network_restriction_enabled
  primary_user_assigned_identity_id        = var.primary_user_assigned_identity_id
  public_network_access_enabled            = var.public_network_access_enabled
  tags                                     = module.module_sql_server.tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? { this = var.azuread_administrator } : {}

    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      azuread_authentication_only = azuread_administrator.value.azuread_authentication_only
      tenant_id                   = azuread_administrator.value.tenant_id
    }
  }
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  # Transparent Data Encryption is managed by the azurerm_mssql_server_transparent_data_encryption
  # resource below (which supports auto-rotation and versionless keys). Ignore changes to the
  # inline attribute so the two do not conflict when Azure reflects the CMK back on read.
  lifecycle {
    ignore_changes = [transparent_data_encryption_key_vault_key_id]
  }
}

# Manages the server Transparent Data Encryption (TDE) protector. Using the dedicated resource
# (instead of the inline azurerm_mssql_server attribute) allows enabling automatic key rotation.
# The key_vault_key_id is a versioned Key Vault Key ID used to bootstrap the protector.
resource "azurerm_mssql_server_transparent_data_encryption" "this" {
  # Gate on a plan-time-known flag rather than the key id itself. When the CMK is created or
  # updated in the same run, its id is "known after apply" (unknown); deriving count from it would
  # raise "Invalid count argument". transparent_data_encryption_enabled is a static input, so count
  # is always resolvable at plan time.
  count = var.transparent_data_encryption_enabled ? 1 : 0

  server_id             = azurerm_mssql_server.this.id
  key_vault_key_id      = var.transparent_data_encryption_key_vault_key_id
  auto_rotation_enabled = var.transparent_data_encryption_key_automatic_rotation_enabled

  # When auto-rotation is enabled, Azure automatically advances the TDE protector to the newest
  # Key Vault key version. The versioned key_vault_key_id only bootstraps the protector; ignoring
  # subsequent changes prevents Terraform from perpetually reverting to the stale version that the
  # Terraform-managed key resource still references after Azure rotates the key.
  lifecycle {
    ignore_changes = [key_vault_key_id]
  }
}


# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${module.module_sql_server.name}")
  scope      = azurerm_mssql_server.this.id
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_mssql_server.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${module.module_sql_server.name}"
  target_resource_id             = azurerm_mssql_server.this.id
  eventhub_authorization_rule_id = each.value.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.event_hub_name
  log_analytics_destination_type = each.value.log_analytics_destination_type
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

########################################
### Azure SQL Auditing (server-level)
########################################
resource "azurerm_mssql_server_extended_auditing_policy" "this" {
  count = try(var.server_extended_auditing_policy.enabled, false) ? 1 : 0

  server_id                               = azurerm_mssql_server.this.id
  log_monitoring_enabled                  = var.server_extended_auditing_policy.log_monitoring_enabled
  retention_in_days                       = var.server_extended_auditing_policy.retention_in_days
  storage_endpoint                        = var.server_extended_auditing_policy.storage_endpoint
  storage_account_access_key              = var.server_extended_auditing_policy.storage_account_access_key
  storage_account_access_key_is_secondary = var.server_extended_auditing_policy.storage_account_access_key_is_secondary
  storage_account_subscription_id         = var.server_extended_auditing_policy.storage_account_subscription_id
}

# Route Azure SQL audit events to Log Analytics. Audit events are surfaced by the server's
# "master" database under the SQLSecurityAuditEvents category, so the diagnostic setting must
# target <server>/databases/master (NOT the server resource). This diagnostic setting is what
# makes the "Log Analytics" destination appear enabled in the SQL Auditing portal blade.
resource "azurerm_monitor_diagnostic_setting" "master_audit" {
  count = try(var.server_extended_auditing_policy.enabled, false) && try(var.server_extended_auditing_policy.log_monitoring_enabled, false) && try(var.server_extended_auditing_policy.log_analytics_workspace_id, null) != null && try(var.server_extended_auditing_policy.create_master_audit_diagnostic_setting, true) ? 1 : 0

  name                           = coalesce(var.server_extended_auditing_policy.diagnostic_setting_name, "sqlaudit-to-law-${module.module_sql_server.name}")
  target_resource_id             = "${azurerm_mssql_server.this.id}/databases/master"
  log_analytics_workspace_id     = var.server_extended_auditing_policy.log_analytics_workspace_id
  log_analytics_destination_type = var.server_extended_auditing_policy.log_analytics_destination_type

  dynamic "enabled_log" {
    for_each = toset(var.server_extended_auditing_policy.audit_log_categories)

    content {
      category = enabled_log.value
    }
  }

  depends_on = [azurerm_mssql_server_extended_auditing_policy.this]
}

