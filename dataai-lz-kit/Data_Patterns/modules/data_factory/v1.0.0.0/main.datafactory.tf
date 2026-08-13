############################
####Naming Conventions
############################
module "module_data_factory" {
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
      ProductName    = "data_factory"
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

#######################
##Data Factory
#######################
resource "azurerm_data_factory" "this" {
  location                         = module.module_data_factory.location
  name                             = module.module_data_factory.name
  resource_group_name              = var.resource_group_name
  customer_managed_key_id          = var.customer_managed_key_id
  customer_managed_key_identity_id = var.customer_managed_key_identity_id
  managed_virtual_network_enabled  = var.managed_virtual_network_enabled
  public_network_enabled           = var.public_network_enabled
  purview_id                       = var.purview_id
  tags                             = module.module_data_factory.tags

  dynamic "github_configuration" {
    for_each = var.github_configuration != null ? [var.github_configuration] : []

    content {
      account_name       = github_configuration.value.account_name
      branch_name        = github_configuration.value.branch_name
      repository_name    = github_configuration.value.repository_name
      root_folder        = github_configuration.value.root_folder
      git_url            = github_configuration.value.git_url
      publishing_enabled = github_configuration.value.publishing_enabled
    }
  }
  dynamic "global_parameter" {
    for_each = var.global_parameters

    content {
      name  = global_parameter.value.name
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }
  dynamic "identity" {
    for_each = local.managed_identities.system_assigned_user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  dynamic "vsts_configuration" {
    for_each = var.vsts_configuration != null ? [var.vsts_configuration] : []

    content {
      account_name       = vsts_configuration.value.account_name
      branch_name        = vsts_configuration.value.branch_name
      project_name       = vsts_configuration.value.project_name
      repository_name    = vsts_configuration.value.repository_name
      root_folder        = vsts_configuration.value.root_folder
      tenant_id          = vsts_configuration.value.tenant_id
      publishing_enabled = vsts_configuration.value.publishing_enabled
    }
  }

  lifecycle {
    ignore_changes = [
      # global_parameter,
      # public_network_enabled,
      # vsts_configuration,
      github_configuration
    ]
  }
}

resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_data_factory.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [
    azurerm_data_factory.this
  ]
}

resource "azurerm_data_factory_credential_service_principal" "this" {
  for_each = var.credential_service_principal

  data_factory_id      = azurerm_data_factory.this.id
  name                 = each.value.name
  service_principal_id = each.value.service_principal_id
  tenant_id            = each.value.tenant_id
  annotations          = each.value.annotations
  description          = each.value.description

  dynamic "service_principal_key" {
    for_each = each.value.service_principal_key != null ? [each.value.service_principal_key] : []

    content {
      linked_service_name = service_principal_key.value.linked_service_name
      secret_name         = service_principal_key.value.secret_name
      secret_version      = service_principal_key.value.secret_version
    }
  }
}

resource "azurerm_data_factory_credential_user_managed_identity" "this" {
  for_each = var.credential_user_managed_identity

  data_factory_id = azurerm_data_factory.this.id
  identity_id     = each.value.identity_id
  name            = each.value.name
  annotations     = each.value.annotations
  description     = each.value.description
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? each.value.name : "diag-${var.name}"
  target_resource_id             = azurerm_data_factory.this.id
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

resource "azapi_resource" "cosmosdb_mongoapi_dataset" {
  for_each = var.dataset_cosmosdb_mongoapi

  name      = each.value.name
  parent_id = azurerm_data_factory.this.id
  type      = "Microsoft.DataFactory/factories/datasets@2018-06-01"
  body = {
    properties = {
      type = "CosmosDbMongoDbApiCollection"
      typeProperties = {
        collection = each.value.collection_name
      }
      linkedServiceName = {
        type          = "LinkedServiceReference"
        referenceName = each.value.linked_service_name
      }
      annotations = each.value.annotations
      description = each.value.description
      folder = each.value.folder != null ? {
        name = each.value.folder
      } : null
      parameters = each.value.parameters != null ? {
        for k, v in each.value.parameters : k => {
          type         = "String"
          defaultValue = v
        }
      } : null
    }
  }
  create_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  delete_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  depends_on = [
    azurerm_data_factory_linked_service_cosmosdb_mongoapi.this,
  ]
}
