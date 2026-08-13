
module "module_rg" {
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
  resource_type_code = var.resource_type_code
  product_version    = "1.0.0.1"
  owner              = var.owner
  max_length         = var.max_length
  no_dashes          = var.no_dashes
  add_random         = var.add_random
  rnd_length         = var.rnd_length

  # 8 Mandatory Tags for v1.0.0.1 naming module
  environment         = var.environment
  business_owner      = var.business_owner
  business_unit       = var.business_unit
  criticality         = var.criticality
  cost_center         = var.cost_center
  data_classification = var.data_classification
  compliance          = var.compliance

  # 3 Optional Tags for v1.0.0.1 naming module
  region              = var.region
  description         = var.description
  notification_emails = var.notification_emails

  # Pass additional tags from resource group module including the requested tags
  additional_tags = merge(
    {
      # Additional mandatory tags passed from resource group
      AppName        = var.app_name
      BudgetID       = var.budget_id
      Status         = var.status
      AppSupport     = var.app_support
      ProductName    = var.product_name
      ProductVersion = var.product_version
    },
    # Optional tags (only include if provided)
    var.automation_policy != null && var.automation_policy != "" ? { AutomationPolicy = var.automation_policy } : {},
    var.review_required != null && var.review_required != "" ? { ReviewRequired = var.review_required } : {},
    var.backup_policy != null && var.backup_policy != "" ? { BackupPolicy = var.backup_policy } : {},
    var.disaster_recovery != null && var.disaster_recovery != "" ? { DisasterRecovery = var.disaster_recovery } : {},
    var.cost_alert_threshold != null && var.cost_alert_threshold != "" ? { CostAlertThreshold = var.cost_alert_threshold } : {},
    var.budget_limit != null && var.budget_limit != "" ? { BudgetLimit = var.budget_limit } : {},
    # Include any additional custom tags
    var.additional_tags != null ? var.additional_tags : {}
  )
}

resource "azurerm_resource_group" "this" {
  location = module.module_rg.location
  name     = module.module_rg.name
  tags     = merge(module.module_rg.tags, var.tags != null ? var.tags : {})
}

# resource "azurerm_resource_group" "this" {
#   location = var.location
#   name     = var.name
#   tags     = merge(local.mandatory_tags, var.tags)
# }

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_resource_group.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_resource_group.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? "/subscriptions/${data.azurerm_subscription.current.subscription_id}${each.value.role_definition_id_or_name}" : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
