module "module_asp" {
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
      ProductName    = "app_service_plan"
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
    var.integration_id != "" ? { IntegrationID = var.integration_id } : {},
    var.experiment_phase != "" ? { ExperimentPhase = var.experiment_phase } : {},
    var.os != "" ? { OS = var.os } : {},
    var.last_vm_accessed != "" ? { LastVMAccessed = var.last_vm_accessed } : {},
    var.patch_policy != "" ? { PatchPolicy = var.patch_policy } : {},
    var.retention != "" ? { Retention = var.retention } : {},
    var.sandbox_type != "" ? { SandboxType = var.sandbox_type } : {}
  )
}

data "azurerm_location" "region" {
  location = module.module_asp.location
}

resource "azurerm_service_plan" "this" {
  location                        = module.module_asp.location
  name                            = module.module_asp.name
  os_type                         = var.os_type
  resource_group_name             = var.resource_group_name
  sku_name                        = var.sku_name
  app_service_environment_id      = var.app_service_environment_id
  maximum_elastic_worker_count    = local.maximum_elastic_worker_count
  per_site_scaling_enabled        = var.per_site_scaling_enabled
  premium_plan_auto_scale_enabled = startswith(var.sku_name, "P") ? var.premium_plan_auto_scale_enabled : false
  tags                            = merge(module.module_asp.tags, var.tags != null ? var.tags : {})
  worker_count                    = local.worker_count
  zone_balancing_enabled          = var.zone_balancing_enabled
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${module.module_asp.name}")
  scope      = azurerm_service_plan.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}


resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_service_plan.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
