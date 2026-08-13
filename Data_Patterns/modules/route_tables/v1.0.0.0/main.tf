module "module_rt" {
  source = "../../naming_module/v1.0.0.0"

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

  # Mandatory Business Tags
  app_name       = var.app_name
  app_support    = var.app_support
  business_unit  = var.business_unit
  country        = var.country
  business_owner = var.business_owner
  type           = var.type

  # Mandatory DevOps Tags
  product_name    = var.product_name
  product_version = var.product_version

  # Mandatory Finance Tags
  cost_center          = var.cost_center
  cost_allocation_unit = var.cost_allocation_unit
  budget_id            = var.budget_id
  budget_limit         = var.budget_limit
  cost_alert_threshold = var.cost_alert_threshold

  # Mandatory Governance Tags
  data_classification = var.data_classification
  compliance_required = var.compliance_required
  compliance          = var.compliance

  # Mandatory Operation Tags
  criticality = var.criticality
  environment = var.environment
  status      = var.status

  # Optional Tags
  delete_after        = var.delete_after
  tier                = var.tier
  app_id              = var.app_id
  auto_delete         = var.auto_delete
  auto_shutdown       = var.auto_shutdown
  description         = var.description
  backup_policy       = var.backup_policy
  disaster_recovery   = var.disaster_recovery
  notification_emails = var.notification_emails
  region              = var.region
  automation_policy   = var.automation_policy
  maintenance_window  = var.maintenance_window
  patch_policy        = var.patch_policy
  review_required     = var.review_required
  retention           = var.retention
  sandbox_type        = var.sandbox_type
  service             = var.service

  # Additional custom tags
  additional_tags = var.additional_tags
}

# Create Route Table
resource "azurerm_route_table" "this" {
  location                      = module.module_rt.location
  name                          = module.module_rt.name
  resource_group_name           = var.resource_group_name
  bgp_route_propagation_enabled = var.bgp_route_propagation_enabled
  tags                          = merge(module.module_rt.tags, var.tags != null ? var.tags : {})
}

# Create routes associated to the Route Table
resource "azurerm_route" "this" {
  for_each = var.routes

  address_prefix         = each.value.address_prefix
  name                   = each.value.name
  next_hop_type          = each.value.next_hop_type
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this.name
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

# Associate route table with VNets
resource "azurerm_subnet_route_table_association" "this" {
  for_each = var.subnet_resource_ids

  route_table_id = azurerm_route_table.this.id
  subnet_id      = each.value
}

# Applying Management Lock to the Route Table if specified.
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_route_table.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [azurerm_route.this]
}

# Apply resource level IaM.
resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azurerm_route_table.this.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
