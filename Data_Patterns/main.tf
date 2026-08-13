# =============================================================================
# MBB Data Landing Zone - consolidated single-stack pattern.
#
# This mirrors data&AI_Patterns (the AI landing zone) but for the DATA landing
# zone. It consolidates the five standalone reference roots
# (data_shared / data_storage / data_ingestion / data_analytics / data_rbac,
# see the git-ignored ex-data/ reference) into ONE Terraform stack, deployed via
# a single GitHub issue-template workflow (.github/workflows/data-pattern.yml).
#
# Cross-folder references that the reference roots resolve with data sources are
# resolved here directly from module outputs, so the whole landing zone builds
# in a single apply.
#
# Naming/tag/CIDR tokens ({env}/{region_code}) in variables.tfvars are rewritten
# by the workflow from the deploy-issue selections before plan/apply.
# =============================================================================

# -----------------------------------------------------------------------------
# Resource Groups
# -----------------------------------------------------------------------------
module "data_resource_groups" {
  for_each = var.data_resource_groups
  source   = "./modules/resource_group/v1.0.0.1"

  # Naming and tag variables
  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code
  max_length         = each.value.max_length
  no_dashes          = each.value.no_dashes
  add_random         = each.value.add_random
  rnd_length         = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  product_name        = each.value.product_name
  product_version     = each.value.product_version
  app_support         = each.value.app_support

  # Optional Tags
  region               = lookup(each.value, "region", null)
  description          = lookup(each.value, "description", null)
  notification_emails  = lookup(each.value, "notification_emails", null)
  automation_policy    = lookup(each.value, "automation_policy", null)
  review_required      = lookup(each.value, "review_required", null)
  backup_policy        = lookup(each.value, "backup_policy", null)
  disaster_recovery    = lookup(each.value, "disaster_recovery", null)
  cost_alert_threshold = lookup(each.value, "cost_alert_threshold", null)
  budget_limit         = lookup(each.value, "budget_limit", null)

  lock             = lookup(each.value, "lock", null)
  role_assignments = lookup(each.value, "role_assignments", null)
  additional_tags  = lookup(each.value, "additional_tags", null)
}

# -----------------------------------------------------------------------------
# Network Security Groups
# -----------------------------------------------------------------------------
module "network_security_groups" {
  source   = "./modules/network_security_group/v1.0.0.1"
  for_each = var.network_security_groups

  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org             = each.value.org
  region_code     = each.value.region_code
  base_name       = each.value.base_name
  additional_name = each.value.additional_name
  iterator        = each.value.iterator

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  auto_delete         = lookup(each.value, "auto_delete", null)
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)

  security_rules = try(each.value.security_rules, {})

  depends_on = [module.data_resource_groups]
}

# -----------------------------------------------------------------------------
# Virtual Network + subnets (NSG resolved per subnet by nsg_key)
# -----------------------------------------------------------------------------
module "virtual_network" {
  for_each = var.virtual_networks
  source   = "./modules/virtual_network/v1.0.0.1"

  # Naming and tag variables
  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code
  max_length         = each.value.max_length
  no_dashes          = each.value.no_dashes
  add_random         = each.value.add_random
  rnd_length         = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  auto_delete         = lookup(each.value, "auto_delete", null)
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)

  # Network specific
  address_space       = each.value.address_space
  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name
  subscription_id     = var.subscription_id

  # Subnets with dynamic NSG resolution (by nsg_key) + optional delegation.
  subnets = {
    for subnet_key, subnet_config in each.value.subnets : subnet_key => merge(
      subnet_config,
      try(subnet_config.network_security_group, null) != null ? {
        network_security_group = {
          id = module.network_security_groups[subnet_config.network_security_group.nsg_key].resource_id
        }
      } : {},
      try(subnet_config.delegation, null) != null ? {
        delegation = subnet_config.delegation
      } : {}
    )
  }

  dns_servers = lookup(each.value, "dns_servers", null)

  # VNet peerings to the platform hub network (cross-subscription). Empty until
  # `peerings` is supplied in tfvars. The remote hub VNet resource id is resolved
  # from the hub VNet data source (network-subscription provider) via each
  # peering's `hub_key`, so tfvars never carries the raw cross-subscription
  # resource id. A reverse peering is created in-code when
  # `create_reverse_peering = true`.
  peerings = {
    for peer_key, peer in lookup(each.value, "peerings", {}) : peer_key => merge(
      { for k, v in peer : k => v if k != "hub_key" },
      { remote_virtual_network_resource_id = data.azurerm_virtual_network.hub[peer.hub_key].id }
    )
  }

  lock             = lookup(each.value, "lock", null)
  role_assignments = lookup(each.value, "role_assignments", null)
  additional_tags  = lookup(each.value, "additional_tags", null)

  depends_on = [module.data_resource_groups, module.network_security_groups]
}

# -----------------------------------------------------------------------------
# Route Tables (UDR routing default traffic to the platform firewall)
# -----------------------------------------------------------------------------
module "route_tables" {
  source   = "./modules/route_tables/v1.0.0.1"
  for_each = var.route_tables

  depends_on = [module.data_resource_groups, module.virtual_network]

  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org             = each.value.org
  region_code     = each.value.region_code
  base_name       = each.value.base_name
  additional_name = each.value.additional_name
  iterator        = each.value.iterator

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  auto_delete         = lookup(each.value, "auto_delete", null)
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)

  bgp_route_propagation_enabled = lookup(each.value, "bgp_route_propagation_enabled", true)
  routes                        = lookup(each.value, "routes", {})

  subnet_resource_ids = {
    for assoc_key, assoc_config in lookup(each.value, "subnet_associations", {}) : assoc_key =>
    module.virtual_network[assoc_config.vnet_key].subnets[assoc_config.subnet_key].resource_id
  }

  enable_telemetry = try(each.value.enable_telemetry, true)
  tags             = try(each.value.tags, {})
}

# -----------------------------------------------------------------------------
# User Managed Identities (SQL TDE, ADLS CMK, Event Grid delivery, ADF, ...)
# Created before Key Vault so KV role_assignments can resolve UMI principal ids.
# -----------------------------------------------------------------------------
module "user_managed_identities" {
  source   = "./modules/user_managed_identity/v1.0.0.0"
  for_each = var.user_managed_identities

  # Naming and tag variables
  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code
  max_length         = each.value.max_length
  no_dashes          = each.value.no_dashes
  add_random         = each.value.add_random
  rnd_length         = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  auto_delete         = lookup(each.value, "auto_delete", null)
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)

  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name
  enable_telemetry    = try(each.value.enable_telemetry, true)

  depends_on = [module.data_resource_groups]
}

# SQL Server admin password (kept in Key Vault, never in tfvars).
resource "random_password" "sql_admin_password" {
  length           = 20
  special          = true
  override_special = "!@#%^*()-_=+[]{}"
}

# -----------------------------------------------------------------------------
# Key Vault (Standard) with CMK keys (ADLS + SQL TDE) and a private endpoint.
# -----------------------------------------------------------------------------
module "key_vault" {
  source   = "./modules/key_vault/v1.0.0.1"
  for_each = var.key_vaults

  # Naming and tag variables
  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  owner              = each.value.owner
  app_code           = each.value.app_code
  bu                 = each.value.bu
  resource_type_code = each.value.resource_type_code
  max_length         = each.value.max_length
  no_dashes          = each.value.no_dashes
  add_random         = each.value.add_random
  rnd_length         = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  auto_delete         = lookup(each.value, "auto_delete", null)
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)

  resource_group_name           = module.data_resource_groups[each.value.resource_group_key].name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = each.value.sku_name
  public_network_access_enabled = each.value.public_network_access_enabled

  # RBAC - resolve UMI principal ids by key, or use a literal principal_id.
  role_assignments = merge(
    {
      for ra_key, ra_config in try(each.value.role_assignments, {}) : ra_key => {
        role_definition_id_or_name = ra_config.role_definition_id_or_name
        principal_id               = ra_config.principal_id
      }
      if try(ra_config.principal_id, null) != null
    },
    {
      for ra_key, ra_config in try(each.value.role_assignments, {}) : ra_key => {
        role_definition_id_or_name = ra_config.role_definition_id_or_name
        principal_id               = module.user_managed_identities[ra_config.umi_key].principal_id
      }
      if try(ra_config.principal_id, null) == null && try(ra_config.umi_key, null) != null
    }
  )

  # Wait for the runner's KV RBAC AND the private-endpoint DNS A-record to
  # propagate to the runner's resolver before key operations. On a first-time
  # fresh spoke the freshly-registered privatelink.vaultcore A-record can take
  # longer than 60s to be resolvable by the runner (otherwise the vault FQDN
  # resolves to the public IP -> 403 ForbiddenByConnection). 300s gives cold DNS
  # headroom; reduce once the region is warm.
  wait_for_rbac_before_key_operations = {
    create = "300s"
  }

  keys = {
    for key_name, key_config in try(each.value.keys, {}) : key_name => key_config
  }

  network_acls = try(each.value.network_acls, null) != null ? {
    bypass                     = each.value.network_acls.bypass
    default_action             = each.value.network_acls.default_action
    ip_rules                   = try(each.value.network_acls.ip_rules, [])
    virtual_network_subnet_ids = try(each.value.network_acls.virtual_network_subnet_ids, [])
  } : null

  private_endpoints = try(each.value.private_endpoints, null) != null ? {
    for pe_key, pe_config in each.value.private_endpoints : pe_key => {
      name                          = pe_config.name
      subnet_resource_id            = module.virtual_network[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
      private_dns_zone_resource_ids = try(pe_config.dns_zone_key, null) != null ? [data.azurerm_private_dns_zone.existing_private_dns_zones[pe_config.dns_zone_key].id] : []
    }
  } : {}

  additional_tags = lookup(each.value, "additional_tags", null)

  depends_on = [module.data_resource_groups, module.user_managed_identities, module.virtual_network]
}

# Key Vault RBAC. Consolidates the data_shared KV-Admin grant (runner identity,
# principal defaults to the current client) and the data_storage ADLS-CMK grant
# (a User Managed Identity resolved by umi_key). Each entry scopes to a Key Vault
# created in this stack.
module "role_assignments" {
  source   = "./modules/role_assignments/v1.0.0.0"
  for_each = var.role_assignments_config

  role_assignments_azure_resource_manager = {
    rbac = {
      principal_id = try(each.value.umi_key, null) != null ? (
        module.user_managed_identities[each.value.umi_key].principal_id
        ) : (
        try(each.value.principal_id, null) == null ? data.azurerm_client_config.current.object_id : each.value.principal_id
      )
      scope                = module.key_vault[each.value.key_vault_key].resource_id
      role_definition_name = each.value.role_definition_name
    }
  }

  depends_on = [module.data_resource_groups, module.key_vault, module.user_managed_identities]
}

# Wait for the KV crypto RBAC to propagate before the CMK-enabled ADLS storage
# account is created.
resource "time_sleep" "storage_rbac_wait" {
  count           = length(var.role_assignments_config) > 0 ? 1 : 0
  create_duration = "60s"
  depends_on      = [module.role_assignments]
}

# SQL admin password secret in Key Vault.
#
# The expiration is computed dynamically from apply time (not a static far-future
# date) so it always satisfies the platform Key Vault guardrail policy on the
# target subscription/MG ("Secrets should have the specified maximum validity
# period"). time_offset captures its base timestamp at create and stores it in
# state, so the expiration is stable across subsequent applies (no drift/diff).
# CONFIRMED: the initiative Application-Enforce-Guardrails-KeyVault (MG
# a1074ffe-b122-4cec-946a-1becee305a4c) sets secretsValidityInDays = 90 with a
# Deny effect, so the secret validity MUST be < 90 days. 89 leaves headroom.
# To re-check: az policy set-definition show --name Application-Enforce-Guardrails-KeyVault \
#   --management-group a1074ffe-b122-4cec-946a-1becee305a4c \
#   --query "{days:parameters.secretsValidityInDays.defaultValue, effect:parameters.secretsValidPeriod.defaultValue}"
locals {
  sql_secret_validity_days = 89
}

resource "time_offset" "sql_secret_expiry" {
  for_each    = var.sql_server_secrets
  offset_days = local.sql_secret_validity_days
}

module "sql_secret" {
  source   = "./modules/key_vault/v1.0.0.1/modules/secret"
  for_each = var.sql_server_secrets

  name                  = each.value.secret_name
  value                 = random_password.sql_admin_password.result
  key_vault_resource_id = module.key_vault[each.value.key_vault_key].resource_id

  content_type    = each.value.content_type
  expiration_date = time_offset.sql_secret_expiry[each.key].rfc3339

  role_assignments = try(each.value.role_assignments, null) != null ? {
    for rbac_key, rbac_config in each.value.role_assignments : rbac_key => {
      role_definition_id_or_name = rbac_config.role_definition_id_or_name
      principal_id               = data.azurerm_client_config.current.object_id
    }
  } : {}

  depends_on = [module.data_resource_groups, module.key_vault, module.role_assignments]
}

# -----------------------------------------------------------------------------
# Application Insights (workspace-based, wired to the central LAW).
# -----------------------------------------------------------------------------
module "application_insights" {
  source = "./modules/app_insights/v1.0.0.0"
  # TEMP-DISABLED (demo 2026-07-21): App Insights requires a workspace_id, but the
  # central LAW is unreachable (SPN lacks mgmt-sub access). Re-enable by restoring
  # `for_each = var.application_insights` and the workspace_id line below.
  for_each = {}

  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org             = each.value.org
  region_code     = each.value.region_code
  base_name       = each.value.base_name
  additional_name = each.value.additional_name
  iterator        = each.value.iterator

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  auto_delete         = lookup(each.value, "auto_delete", null)
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)

  workspace_id                          = "" # TEMP-DISABLED (demo): was data.azurerm_log_analytics_workspace.workspace[0].id
  application_type                      = lookup(each.value, "application_type", "web")
  daily_data_cap_in_gb                  = lookup(each.value, "daily_data_cap_in_gb", 100)
  daily_data_cap_notifications_disabled = lookup(each.value, "daily_data_cap_notifications_disabled", false)
  internet_ingestion_enabled            = lookup(each.value, "internet_ingestion_enabled", false)
  internet_query_enabled                = lookup(each.value, "internet_query_enabled", false)
  local_authentication_disabled         = lookup(each.value, "local_authentication_disabled", false)
  retention_in_days                     = lookup(each.value, "retention_in_days", 90)
  sampling_percentage                   = lookup(each.value, "sampling_percentage", 100)
  tags                                  = try(each.value.tags, {})
}

# -----------------------------------------------------------------------------
# SQL Server + database (TDE with the CMK key created on the Key Vault).
# -----------------------------------------------------------------------------
module "data_sql_server" {
  source   = "./modules/sql_server/v1.0.0.0"
  for_each = var.sql_servers

  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  owner              = each.value.owner
  app_code           = each.value.app_code
  bu                 = each.value.bu
  resource_type_code = each.value.resource_type_code
  max_length         = each.value.max_length
  no_dashes          = each.value.no_dashes
  add_random         = each.value.add_random
  rnd_length         = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  additional_tags     = lookup(each.value, "additional_tags", null)

  resource_group_name                      = module.data_resource_groups[each.value.resource_group_key].name
  server_version                           = each.value.server_version
  administrator_login                      = each.value.administrator_login
  administrator_login_password             = random_password.sql_admin_password.result
  enable_telemetry                         = lookup(each.value, "enable_telemetry", true)
  express_vulnerability_assessment_enabled = try(each.value.express_vulnerability_assessment_enabled, true)
  databases                                = each.value.databases
  primary_user_assigned_identity_id        = try(module.user_managed_identities[each.value.umi_key].resource_id, null)

  # TDE with the CMK key created on the Key Vault (versioned id + auto-rotation).
  transparent_data_encryption_enabled                        = try(each.value.tde_key_name, null) != null && try(each.value.key_vault_key, null) != null
  transparent_data_encryption_key_vault_key_id               = try(each.value.tde_key_name, null) != null && try(each.value.key_vault_key, null) != null ? module.key_vault[each.value.key_vault_key].keys[each.value.tde_key_name].id : null
  transparent_data_encryption_key_automatic_rotation_enabled = try(each.value.transparent_data_encryption_key_automatic_rotation_enabled, false)

  managed_identities = {
    system_assigned = try(each.value.managed_identities.system_assigned, null)
    user_assigned_resource_ids = [
      for k, v in module.user_managed_identities : v.resource_id
      if contains(
        distinct(concat(try(each.value.managed_identities.umi_key, []), [each.value.umi_key])),
        k
      )
    ]
  }

  private_endpoints = try(each.value.private_endpoints, null) != null ? {
    for pe_key, pe_config in each.value.private_endpoints : pe_key => {
      name                          = pe_config.name
      subnet_resource_id            = module.virtual_network[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
      subresource_name              = pe_config.subresource_name
      private_dns_zone_resource_ids = try(pe_config.dns_zone_key, null) != null ? [data.azurerm_private_dns_zone.existing_private_dns_zones[pe_config.dns_zone_key].id] : []
      network_interface_name        = try(pe_config.network_interface_name, null)
    }
  } : {}

  # TEMP-DISABLED (demo 2026-07-21): auditing-to-central-LAW needs mgmt-sub access.
  # Was: merge(each.value..., { log_analytics_workspace_id = coalesce(try(...),
  #      data.azurerm_log_analytics_workspace.workspace[0].id) }).
  server_extended_auditing_policy = null

  # TEMP-DISABLED (demo 2026-07-21): SQL diag-to-central-LAW needs mgmt-sub access.
  # Was: inject workspace_resource_id = data.azurerm_log_analytics_workspace.workspace[0].id
  diagnostic_settings = {}

  azuread_administrator = {
    login_username              = var.user_principal_name
    object_id                   = var.object_id
    azuread_authentication_only = true
  }

  depends_on = [module.user_managed_identities, module.data_resource_groups, module.key_vault]
}

# -----------------------------------------------------------------------------
# Storage Accounts (ADLS Gen2, ZRS, HNS, CMK). CMK key vault + key resolved from
# the Key Vault module; the private-endpoint subnets from the VNet module.
# -----------------------------------------------------------------------------
module "storage_accounts" {
  source   = "./modules/storage_account/v1.0.0.2"
  for_each = var.storage_accounts

  depends_on = [
    module.data_resource_groups,
    module.user_managed_identities,
    module.key_vault,
    module.virtual_network,
    time_sleep.storage_rbac_wait,
  ]

  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org             = each.value.org
  region_code     = each.value.region_code
  base_name       = each.value.base_name
  additional_name = each.value.additional_name
  iterator        = each.value.iterator
  max_length      = each.value.max_length
  no_dashes       = each.value.no_dashes
  add_random      = each.value.add_random
  rnd_length      = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  auto_delete         = lookup(each.value, "auto_delete", null)
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)
  backup_policy       = lookup(each.value, "backup_policy", null)

  # Storage Account specific configuration
  account_kind                      = each.value.account_kind
  account_tier                      = each.value.account_tier
  account_replication_type          = each.value.account_replication_type
  access_tier                       = each.value.access_tier
  min_tls_version                   = each.value.min_tls_version
  allowed_copy_scope                = lookup(each.value, "allowed_copy_scope", null)
  https_traffic_only_enabled        = each.value.https_traffic_only_enabled
  public_network_access_enabled     = each.value.public_network_access_enabled
  allow_nested_items_to_be_public   = each.value.allow_nested_items_to_be_public
  shared_access_key_enabled         = each.value.shared_access_key_enabled
  default_to_oauth_authentication   = each.value.default_to_oauth_authentication
  infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled
  is_hns_enabled                    = lookup(each.value, "is_hns_enabled", false)

  managed_identities = {
    system_assigned            = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = try(each.value.managed_identities.umi_key, null) != null ? toset([module.user_managed_identities[each.value.managed_identities.umi_key].resource_id]) : toset([])
  }

  # Network rules. When enable_defender_datascanner_access = true (set on the
  # HNS ADLS account), add the Microsoft Defender for Storage data-scanner
  # private-link exception (Defender adds this out-of-band when malware scanning
  # is enabled; declaring it prevents Terraform from removing it on each apply).
  # The datascanner id is resolved from the DEPLOY subscription (region/env-
  # agnostic). NOTE: requires Defender for Storage to be enabled on the target
  # subscription - set the flag to false for a subscription without Defender.
  network_rules = merge(
    each.value.network_rules,
    try(each.value.enable_defender_datascanner_access, false) ? {
      private_link_access = concat(
        try(each.value.network_rules.private_link_access, []),
        [{
          endpoint_resource_id = "/subscriptions/${var.subscription_id}/providers/Microsoft.Security/datascanners/StorageDataScanner"
        }]
      )
    } : {}
  )

  queues     = try(each.value.queues, {})
  containers = try(each.value.containers, {})

  private_endpoints = {
    for pe_key, pe_config in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name                          = pe_config.name
      subnet_resource_id            = module.virtual_network[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
      subresource_name              = pe_config.subresource_name
      network_interface_name        = try(pe_config.network_interface_name, null)
      private_dns_zone_resource_ids = try(pe_config.dns_zone_key, null) != null ? [data.azurerm_private_dns_zone.existing_private_dns_zones[pe_config.dns_zone_key].id] : []
    }
  }

  # Customer-Managed Key. key_vault_resource_id + key resolved from the Key
  # Vault module; the wrapping identity from the UMI module.
  customer_managed_key = try(each.value.customer_managed_key, null) != null ? {
    key_vault_resource_id = module.key_vault[each.value.customer_managed_key.key_vault_key].resource_id
    key_name              = each.value.customer_managed_key.key_name
    key_version           = try(each.value.customer_managed_key.key_version, null)
    user_assigned_identity = try(each.value.customer_managed_key.user_assigned_identity_ref, null) != null ? {
      resource_id = module.user_managed_identities[each.value.customer_managed_key.user_assigned_identity_ref].resource_id
    } : null
  } : null

  sas_policy = try(each.value.sas_policy, null)

  # Lifecycle management policy (data retention / tiering by medallion zone).
  storage_management_policy_rule = try(each.value.storage_management_policy_rule, {})

  # SA-scoped data-plane role for the Terraform SPN (HNS ADLS account only) so it
  # can set POSIX ACLs. The module gates the ADLS Gen2 paths behind this
  # assignment, so it is effective before ACLs are applied. principal_id is the
  # deploying identity (region/env-agnostic) rather than a hard-coded SPN id.
  role_assignments = lookup(each.value, "is_hns_enabled", false) ? {
    tf_spn_adls_data_owner = {
      role_definition_id_or_name       = "Storage Blob Data Owner"
      principal_id                     = data.azurerm_client_config.current.object_id
      principal_type                   = "ServicePrincipal"
      skip_service_principal_aad_check = true
    }
  } : {}

  # Root-level ADLS filesystem(s) with POSIX ACLs on "/" (e.g. raw1: --x
  # execute-only traversal so CFS group members can pass THROUGH root to reach
  # teradata/cfs without listing root contents). Replaces the deep-path
  # adls_acl_paths approach; the module gates the filesystem behind the
  # tf_spn_adls_data_owner role above so the runner can set the root ACL.
  storage_data_lake_gen2_filesystems = try(each.value.storage_data_lake_gen2_filesystems, {})

  enable_telemetry = try(each.value.enable_telemetry, true)
  tags             = try(each.value.tags, {})
}

# -----------------------------------------------------------------------------
# Event Grid System Topic (BARE - no event subscriptions).
#
# Uses event_system_topic v1.0.0.1, which sets `source_arm_resource_id` on
# the underlying azurerm resource (the argument valid on azurerm < 4.37). This
# stack is pinned to azurerm < 4.37 by the fabric_capacity module (azurerm
# 4.37 network_api_version bug), so the earlier v1.0.0.0 module - which used the
# renamed `source_resource_id` (only present on azurerm >= 4.37) - could not be
# used here. The module input variable name is unchanged between versions.
# App teams add delivery subscriptions later via event_subscriptions.
# -----------------------------------------------------------------------------
module "eventgrid_system_topic" {
  source   = "./modules/event_system_topic/v1.0.0.1"
  for_each = var.eventgrid_system_topics

  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  owner              = each.value.owner
  app_code           = each.value.app_code
  bu                 = each.value.bu
  resource_type_code = each.value.resource_type_code
  max_length         = each.value.max_length
  no_dashes          = each.value.no_dashes
  add_random         = each.value.add_random
  rnd_length         = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = try(each.value.region, "")
  description         = try(each.value.description, "")
  notification_emails = try(each.value.notification_emails, [])

  eventgrid_system_topic_resource_group_name = module.data_resource_groups[each.value.resource_group_key].name
  eventgrid_system_topic_type                = each.value.eventgrid_system_topic_type
  eventgrid_system_topic_source_resource_id  = module.storage_accounts[each.value.storage_account_key].resource_id

  eventgrid_system_topic_identity = {
    type         = each.value.eventgrid_system_topic_identity.type
    identity_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  # Bare topic: no subscriptions.
  eventgrid_system_topic_event_subscriptions = {}

  depends_on = [module.data_resource_groups, module.storage_accounts, module.user_managed_identities]
}

# -----------------------------------------------------------------------------
# Azure Data Factory (managed VNet, system + user identities, Purview link,
# Azure + self-hosted IRs, managed private endpoints to SQL/ADLS created here).
# -----------------------------------------------------------------------------
module "data_factories" {
  source   = "./modules/data_factory/v1.0.0.0"
  for_each = var.data_factories

  location            = local.location_by_region_code[each.value.region_code]
  name                = each.value.name
  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name

  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code
  max_length         = each.value.max_length
  no_dashes          = each.value.no_dashes
  add_random         = each.value.add_random
  rnd_length         = each.value.rnd_length

  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  region              = try(each.value.region, "")
  description         = try(each.value.description, "")
  notification_emails = try(each.value.notification_emails, [])
  app_id              = try(each.value.app_id, "")
  auto_delete         = try(each.value.auto_delete, "")
  delete_after        = try(each.value.delete_after, "")
  integration_id      = try(each.value.integration_id, "")
  retention           = try(each.value.retention, "")
  experiment_phase    = try(each.value.experiment_phase, "")
  sandbox_type        = try(each.value.sandbox_type, "")
  os                  = try(each.value.os, "")
  patch_policy        = try(each.value.patch_policy, "")
  maintenance_window  = try(each.value.maintenance_window, "")
  last_vm_accessed    = try(each.value.last_vm_accessed, "")
  additional_tags     = lookup(each.value, "additional_tags", null)

  managed_identities = {
    system_assigned = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = distinct(concat(
      try(each.value.managed_identities.user_assigned_resource_ids, []),
      [for key in try(each.value.umi_keys, []) : module.user_managed_identities[key].resource_id]
    ))
  }

  public_network_enabled           = try(each.value.public_network_enabled, false)
  managed_virtual_network_enabled  = try(each.value.managed_virtual_network_enabled, false)
  customer_managed_key_id          = try(each.value.customer_managed_key_id, null)
  customer_managed_key_identity_id = try(each.value.customer_managed_key_identity_id, null)
  purview_id                       = try(each.value.purview_id, null)

  github_configuration = try(each.value.github_configuration, null)
  vsts_configuration   = try(each.value.vsts_configuration, null)
  global_parameters    = try(each.value.global_parameters, [])
  diagnostic_settings  = try(each.value.diagnostic_settings, {})
  role_assignments     = try(each.value.role_assignments, {})
  lock                 = try(each.value.lock, null)

  linked_service_key_vault              = try(each.value.linked_service_key_vault, {})
  linked_service_azure_blob_storage     = try(each.value.linked_service_azure_blob_storage, {})
  linked_service_azure_file_storage     = try(each.value.linked_service_azure_file_storage, {})
  linked_service_azure_sql_database     = try(each.value.linked_service_azure_sql_database, {})
  linked_service_data_lake_storage_gen2 = try(each.value.linked_service_data_lake_storage_gen2, {})
  linked_service_databricks             = try(each.value.linked_service_databricks, {})
  linked_service_cosmosdb_mongoapi      = try(each.value.linked_service_cosmosdb_mongoapi, {})
  dataset_cosmosdb_mongoapi             = try(each.value.dataset_cosmosdb_mongoapi, {})

  # Integration Runtimes. A tfvars location of "auto" is resolved to the Azure
  # location of the selected region (region_code -> local.location_by_region_code),
  # so SEA deploys pin the IRs to southeastasia and MYW to malaysiawest without
  # editing tfvars. Any explicit location in tfvars is passed through unchanged.
  integration_runtime_self_hosted = {
    for ir_key, ir in try(each.value.integration_runtime_self_hosted, {}) : ir_key => merge(ir, {
      location = try(ir.location, "auto") == "auto" ? try(local.location_by_region_code[each.value.region_code], "auto") : ir.location
    })
  }
  azure_integration_runtime_azure = {
    for ir_key, ir in try(each.value.azure_integration_runtime_azure, {}) : ir_key => merge(ir, {
      location = try(ir.location, "auto") == "auto" ? try(local.location_by_region_code[each.value.region_code], "auto") : ir.location
    })
  }
  credential_service_principal            = try(each.value.credential_service_principal, {})
  credential_user_managed_identity        = try(each.value.credential_user_managed_identity, {})
  private_endpoints_manage_dns_zone_group = try(each.value.private_endpoints_manage_dns_zone_group, true)

  # Managed private endpoints to the SQL Server / ADLS storage created in this
  # stack (resolved from module outputs).
  managed_private_endpoints = {
    for mpe_key, mpe in try(each.value.managed_private_endpoints, {}) : mpe_key => {
      name = "${each.key}-mpe-${mpe_key}"
      target_resource_id = try(
        module.data_sql_server[mpe.sql_server_key].resource_id,
        module.storage_accounts[mpe.adls_sa_key].resource_id,
        mpe.target_resource_id
      )
      subresource_name = mpe.subresource_name
    }
  }

  private_endpoints = {
    for pe_key, pe in try(each.value.private_endpoints, {}) : pe_key => {
      name                                    = try(pe.name, null)
      subnet_resource_id                      = module.virtual_network[pe.vnet_key].subnets[pe.subnet_key].resource_id
      private_dns_zone_group_name             = try(pe.private_dns_zone_group_name, "default")
      private_dns_zone_resource_ids           = [for zone_key in try(pe.dns_zone_keys, []) : data.azurerm_private_dns_zone.existing_private_dns_zones[zone_key].id]
      application_security_group_associations = try(pe.application_security_group_associations, {})
      private_service_connection_name         = try(pe.private_service_connection_name, null)
      network_interface_name                  = try(pe.network_interface_name, null)
      location                                = try(pe.location, null)
      resource_group_name                     = try(pe.resource_group_name, null)
      ip_configurations                       = try(pe.ip_configurations, {})
      tags                                    = try(pe.tags, null)
    }
  }

  enable_telemetry = try(each.value.enable_telemetry, true)

  depends_on = [
    module.data_resource_groups,
    module.user_managed_identities,
    module.data_sql_server,
    module.storage_accounts,
  ]
}

# -----------------------------------------------------------------------------
# Standalone Private Endpoints (Azure Data Factory: dataFactory + portal).
# The connection target resolves from the Data Factory module (adf:<key>).
# -----------------------------------------------------------------------------
module "private_endpoint" {
  source   = "./modules/private_endpoint/v1.0.0.0"
  for_each = var.private_endpoints

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org             = each.value.org
  region_code     = each.value.region_code
  base_name       = each.value.base_name
  additional_name = each.value.additional_name
  iterator        = each.value.iterator
  no_dashes       = each.value.no_dashes

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  auto_delete         = lookup(each.value, "auto_delete", null)
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)

  location               = local.location_by_region_code[each.value.region_code]
  resource_group_name    = module.data_resource_groups[each.value.resource_group_key].name
  network_interface_name = each.value.network_interface_name
  subnet_resource_id     = module.virtual_network[each.value.vnet_key].subnets[each.value.subnet_key].resource_id

  private_connection_resource_id = (
    can(regex("^adf:", each.value.private_connection_resource_ref)) ?
    module.data_factories[split(":", each.value.private_connection_resource_ref)[1]].resource_id :
    each.value.private_connection_resource_ref
  )

  subresource_names           = each.value.subresource_names
  private_dns_zone_group_name = "default"
  private_dns_zone_resource_ids = [
    for key in each.value.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[key].id
  ]

  depends_on = [module.data_resource_groups, module.data_factories]
}

# -----------------------------------------------------------------------------
# Microsoft Fabric Capacity (analytics).
# -----------------------------------------------------------------------------
module "fabric_capacity" {
  source   = "./modules/fabric_capacity/v1.0.0.0"
  for_each = var.fabric_capacities

  resource_group_name    = module.data_resource_groups[each.value.resource_group_key].name
  sku_name               = each.value.sku_name
  administration_members = each.value.administration_members

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org             = lookup(each.value, "org", null)
  region_code     = lookup(each.value, "region_code", null)
  base_name       = lookup(each.value, "base_name", null)
  additional_name = lookup(each.value, "additional_name", null)
  iterator        = lookup(each.value, "iterator", null)
  max_length      = lookup(each.value, "max_length", null)
  no_dashes       = lookup(each.value, "no_dashes", null)
  add_random      = lookup(each.value, "add_random", null)
  rnd_length      = lookup(each.value, "rnd_length", null)

  # Mandatory Tags
  app_name            = each.value.app_name
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  budget_id           = each.value.budget_id
  compliance          = each.value.compliance
  cost_center         = each.value.cost_center
  criticality         = each.value.criticality
  data_classification = each.value.data_classification
  environment         = each.value.environment
  status              = each.value.status
  service             = each.value.service
  product_name        = "fabric_capacity"
  product_version     = "1.0.0.0"

  # Optional Tags
  description         = lookup(each.value, "description", null)
  region              = lookup(each.value, "region", null)
  notification_emails = lookup(each.value, "notification_emails", ["platform-alerts@example.com"])
  app_id              = lookup(each.value, "app_id", null)
  auto_delete         = lookup(each.value, "auto_delete", null)
  delete_after        = lookup(each.value, "delete_after", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  integration_id      = lookup(each.value, "integration_id", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  retention           = lookup(each.value, "retention", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)

  depends_on = [module.data_resource_groups]
}

# -----------------------------------------------------------------------------
# Consolidated cross-resource RBAC (replaces the standalone data_rbac root).
# Principal resolves from: a UMI created in this stack (umi_key), an ADF system
# identity (system_identity_key), or a literal principal_id (e.g. the Purview
# MSI). Scope resolves from local.resource_scope_map (KV / Storage / ADF / SQL).
# -----------------------------------------------------------------------------
module "data_rbac_role_assignment" {
  source   = "./modules/role_assignments/v1.0.0.0"
  for_each = var.data_rbac_role_assignments

  role_assignments_azure_resource_manager = {
    rbac = {
      principal_id = coalesce(
        try(module.user_managed_identities[each.value.umi_key].principal_id, null),
        try(local.system_assigned_principal_ids[each.value.system_identity_key], null),
        try(each.value.principal_id, null)
      )
      scope                = local.resource_scope_map[each.value.scope_key]
      role_definition_name = try(each.value.role_definition_name, null)
      role_definition_id   = try(each.value.role_definition_id, null)
    }
  }

  depends_on = [
    module.key_vault,
    module.storage_accounts,
    module.data_factories,
    module.data_sql_server,
    module.user_managed_identities,
  ]
}

# =============================================================================
# Backup platform (Recovery Services Vault + Backup Vault).
# Mirrors the Data Landing Zone dev reference (dev-data/data_shared). Both
# vaults are CMK-encrypted via a User Managed Identity + a Key Vault key, and
# the Recovery Services Vault private endpoint registers into the shared
# `backup_azure` private DNS zone. Driven off var.recovery_service_vaults /
# var.backup_vaults; empty by default so the stack is unchanged until tfvars
# populate them.
# =============================================================================
module "recovery_service_vaults" {
  source = "./modules/recovery_service_vault/v1.0.0.0"

  for_each = var.recovery_service_vaults

  depends_on = [module.data_resource_groups, module.key_vault, module.user_managed_identities]

  # Required variables
  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name
  sku                 = each.value.sku

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org             = each.value.org
  region_code     = each.value.region_code
  base_name       = each.value.base_name
  additional_name = each.value.additional_name
  iterator        = each.value.iterator
  max_length      = each.value.max_length
  no_dashes       = each.value.no_dashes
  add_random      = each.value.add_random
  rnd_length      = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = each.value.region
  description         = each.value.desc
  notification_emails = each.value.notification_emails
  app_id              = each.value.app_id
  auto_delete         = each.value.auto_delete
  delete_after        = each.value.delete_after
  integration_id      = each.value.integration_id
  retention           = each.value.retention
  experiment_phase    = each.value.experiment_phase
  sandbox_type        = each.value.sandbox_type
  os                  = each.value.os
  patch_policy        = each.value.patch_policy
  maintenance_window  = each.value.maintenance_window
  last_vm_accessed    = each.value.last_vm_accessed

  # Recovery Service Vault specific configuration
  public_network_access_enabled                  = each.value.public_network_access_enabled
  soft_delete_enabled                            = each.value.soft_delete_enabled
  storage_mode_type                              = each.value.storage_mode_type
  cross_region_restore_enabled                   = each.value.cross_region_restore_enabled
  classic_vmware_replication_enabled             = each.value.classic_vmware_replication_enabled
  immutability                                   = each.value.immutability
  alerts_for_all_job_failures_enabled            = each.value.alerts_for_all_job_failures_enabled
  alerts_for_critical_operation_failures_enabled = each.value.alerts_for_critical_operation_failures_enabled

  # Private endpoints - resolve from VNet and DNS zone modules
  private_endpoints = {
    for pe_key, pe_config in each.value.private_endpoints : pe_key => {
      name                   = pe_config.name
      subnet_resource_id     = module.virtual_network[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
      subresource_name       = pe_config.subresource_name
      network_interface_name = pe_config.network_interface_name
      private_dns_zone_resource_ids = length(pe_config.dns_zone_keys) > 0 ? [
        for dns_key in pe_config.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[dns_key].id
      ] : []
    }
  }

  # Managed Identity for CMK encryption
  managed_identities = try(each.value.managed_identities, null) != null ? {
    system_assigned = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = toset([
      for ref in try(each.value.managed_identities.user_assigned_identity_refs, []) :
      module.user_managed_identities[ref].resource_id
    ])
    } : {
    system_assigned            = false
    user_assigned_resource_ids = toset([])
  }

  # Customer Managed Key encryption
  customer_managed_key = try(each.value.customer_managed_key, null) != null ? {
    key_vault_resource_id = module.key_vault[each.value.customer_managed_key.key_vault_key].resource_id
    key_name              = module.key_vault[each.value.customer_managed_key.key_vault_key].keys[each.value.customer_managed_key.key_ref].id
    key_version           = try(each.value.customer_managed_key.key_version, null)
    user_assigned_identity = try(each.value.customer_managed_key.user_assigned_identity_ref, null) != null ? {
      resource_id = module.user_managed_identities[each.value.customer_managed_key.user_assigned_identity_ref].resource_id
    } : null
  } : null

  # Backup policies configuration
  vm_backup_policy         = try(each.value.vm_backup_policy, {})
  file_share_backup_policy = try(each.value.file_share_backup_policy, {})

  # Optional variables
  enable_telemetry = try(each.value.enable_telemetry, true)
}

# Backup Vaults
module "backup_vaults" {
  source   = "./modules/backup_vault/v1.0.0.0"
  for_each = var.backup_vaults

  # Naming and tag variables
  env                = each.value.env
  org                = each.value.org
  region_code        = each.value.region_code
  base_name          = each.value.base_name
  additional_name    = each.value.additional_name
  iterator           = each.value.iterator
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code
  max_length         = each.value.max_length
  no_dashes          = each.value.no_dashes
  add_random         = each.value.add_random
  rnd_length         = each.value.rnd_length

  # Mandatory Tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance
  app_name            = each.value.app_name
  budget_id           = each.value.budget_id
  status              = each.value.status
  service             = each.value.service

  # Optional Tags
  region              = each.value.region
  description         = each.value.desc
  notification_emails = each.value.notification_emails
  app_id              = each.value.app_id
  auto_delete         = each.value.auto_delete
  delete_after        = each.value.delete_after
  integration_id      = each.value.integration_id
  retention           = each.value.retention
  experiment_phase    = each.value.experiment_phase
  sandbox_type        = each.value.sandbox_type
  os                  = each.value.os
  patch_policy        = each.value.patch_policy
  maintenance_window  = each.value.maintenance_window
  last_vm_accessed    = each.value.last_vm_accessed

  # Backup Vault specific configuration
  resource_group_name = module.data_resource_groups[each.value.resource_group_key].name
  datastore_type      = each.value.datastore_type
  redundancy          = each.value.redundancy
  soft_delete         = each.value.soft_delete
  immutability        = each.value.immutability

  # Managed Identity configuration
  managed_identities = {
    system_assigned = try(each.value.managed_identities.system_assigned, true)

    user_assigned_resource_ids = try(each.value.managed_identities.umi_key, null) != null ? [
      module.user_managed_identities[each.value.managed_identities.umi_key].resource_id
    ] : []
  }

  customer_managed_key = null

  # Backup policies configuration
  backup_policies = try(each.value.backup_policies, {})

  # Optional variables
  enable_telemetry = try(each.value.enable_telemetry, true)

  depends_on = [module.data_resource_groups, module.key_vault, module.user_managed_identities]
}

# Backup Vault CMK is enabled out-of-band via azapi after the vault's managed
# identity has been granted the Key Vault crypto role (created inside
# module.key_vault's per-vault role_assignments). The wait must start only AFTER
# that grant exists, otherwise the timer can elapse before the role assignment
# is created/propagated and the CMK patch fails.
resource "time_sleep" "wait_for_backup_vault_cmk_rbac" {
  create_duration = "180s"
  depends_on = [
    module.backup_vaults,
    module.key_vault,
    module.user_managed_identities
  ]
}

resource "azapi_update_resource" "backup_vault_cmk" {
  for_each = {
    for k, v in var.backup_vaults : k => v
    if try(v.customer_managed_key, null) != null
  }

  type        = "Microsoft.DataProtection/backupVaults@2026-03-01"
  resource_id = module.backup_vaults[each.key].resource_id

  body = {
    # Set the user-assigned identity explicitly in the CMK PUT so the vault's
    # identity is applied atomically with the encryption settings. Relying on
    # the backup-vault module's identity attachment + azapi's GET-merge races
    # on a fresh deploy (the just-created UMI isn't reflected on the vault yet),
    # which surfaces as "UserErrorIdentityDetailsNotFound / Managed Identity has
    # not been set for the backup vault".
    identity = {
      type = "UserAssigned"
      userAssignedIdentities = {
        (module.user_managed_identities[each.value.customer_managed_key.user_assigned_identity_ref].resource_id) = {}
      }
    }
    properties = {
      securitySettings = {
        softDeleteSettings = {
          state                   = each.value.soft_delete
          retentionDurationInDays = 14
        }

        immutabilitySettings = {
          state = each.value.immutability
        }

        encryptionSettings = {
          state = "Enabled"

          kekIdentity = {
            identityType = "UserAssigned"
            identityId   = module.user_managed_identities[each.value.customer_managed_key.user_assigned_identity_ref].resource_id
          }

          keyVaultProperties = {
            keyUri = try(each.value.customer_managed_key.key_version, null) != null ? (
              "${module.key_vault[each.value.customer_managed_key.key_vault_key].uri}keys/${each.value.customer_managed_key.key_name}/${each.value.customer_managed_key.key_version}"
              ) : (
              "${module.key_vault[each.value.customer_managed_key.key_vault_key].uri}keys/${each.value.customer_managed_key.key_name}"
            )
          }
        }
      }
    }
  }

  depends_on = [
    module.key_vault,
    module.user_managed_identities,
    time_sleep.wait_for_backup_vault_cmk_rbac
  ]
}
