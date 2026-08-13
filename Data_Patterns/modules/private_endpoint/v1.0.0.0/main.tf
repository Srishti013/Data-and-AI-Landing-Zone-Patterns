#################################
####Naming Conventions
#################################
module "module_pe" {
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


resource "azurerm_private_endpoint" "this" {
  location                      = module.module_pe.location
  name                          = module.module_pe.name
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_resource_id
  custom_network_interface_name = var.network_interface_name
  tags                          = merge(local.mandatory_tags, module.module_pe.tags)

  private_service_connection {
    is_manual_connection           = false
    name                           = var.private_service_connection_name != null ? var.private_service_connection_name : "pse-${module.module_pe.name}"
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = var.subresource_names
  }
  dynamic "ip_configuration" {
    for_each = var.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name
      subresource_name   = ip_configuration.value.subresource_name
    }
  }
  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_resource_ids) > 0 ? ["this"] : []

    content {
      name                 = var.private_dns_zone_group_name
      private_dns_zone_ids = var.private_dns_zone_resource_ids
    }
  }
}

resource "azurerm_private_endpoint_application_security_group_association" "this" {
  for_each = var.application_security_group_association_ids

  application_security_group_id = each.value
  private_endpoint_id           = azurerm_private_endpoint.this.id
}

resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_private_endpoint.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_private_endpoint.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
