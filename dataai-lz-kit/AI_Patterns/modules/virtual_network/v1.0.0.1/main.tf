module "module_vnet" {
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
      ProductName    = "virtual_network"
      ProductVersion = "1.0.0.1"
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
    var.maintenance_window != "" ? { MaintenanceWindow = var.maintenance_window } : {},
    var.patch_policy != "" ? { PatchPolicy = var.patch_policy } : {},
    var.retention != "" ? { Retention = var.retention } : {},
    var.sandbox_type != "" ? { SandboxType = var.sandbox_type } : {}
  )
}