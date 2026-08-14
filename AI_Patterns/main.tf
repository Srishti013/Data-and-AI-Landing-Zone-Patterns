module "resource_group" {
  for_each = var.resource_groups

  source = "./modules/resource_group/v1.0.0.1"

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
  description          = lookup(each.value, "description", null)
  notification_emails  = lookup(each.value, "notification_emails", null)
  automation_policy    = lookup(each.value, "automation_policy", null)
  review_required      = lookup(each.value, "review_required", null)
  backup_policy        = lookup(each.value, "backup_policy", null)
  disaster_recovery    = lookup(each.value, "disaster_recovery", null)
  cost_alert_threshold = lookup(each.value, "cost_alert_threshold", null)
  budget_limit         = lookup(each.value, "budget_limit", null)

  # Optional configurations
  lock             = lookup(each.value, "lock", null)
  role_assignments = lookup(each.value, "role_assignments", null)
  additional_tags  = lookup(each.value, "additional_tags", null)
}

# Virtual Networks
module "identity_vnet" {
  for_each = var.virtual_networks

  source = "./modules/virtual_network/v1.0.0.1"


  depends_on = [module.resource_group, module.network_security_groups]

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
  resource_group_name = module.resource_group[each.value.resource_group_key].name
  subscription_id     = var.subscription_id

  # Custom DNS servers (optional). Left unset until hub peering is in place -
  # when ready, populate `dns_servers` in tfvars (e.g. the central DNS resolver
  # IP). Falls back to Azure-provided DNS when null.
  dns_servers = lookup(each.value, "dns_servers", null)


  # Subnets with dynamic NSG resolution
  subnets = {
    for subnet_key, subnet_config in each.value.subnets : subnet_key => merge(
      subnet_config,
      subnet_config.network_security_group != null ? {
        network_security_group = {
          id = module.network_security_groups[subnet_config.network_security_group.id].resource_id
        }
      } : {}
    )
  }

  # VNet peerings to the platform hub network (cross-subscription). Optional and
  # opt-in: empty until `peerings` is supplied in tfvars, so existing runs are
  # unaffected. The remote hub VNet resource id is resolved from the hub VNet
  # data source (network-subscription provider) via each peering's `hub_key`, so
  # tfvars never carries the raw cross-subscription resource id. A reverse
  # peering is created in-code when `create_reverse_peering = true`.
  peerings = {
    for peer_key, peer in lookup(each.value, "peerings", {}) : peer_key => merge(
      { for k, v in peer : k => v if k != "hub_key" },
      { remote_virtual_network_resource_id = data.azurerm_virtual_network.hub[peer.hub_key].id }
    )
  }

  # Optional configurations
  lock             = lookup(each.value, "lock", null)
  role_assignments = lookup(each.value, "role_assignments", null)
  additional_tags  = lookup(each.value, "additional_tags", null)
}

module "network_security_groups" {
  for_each = var.network_security_groups

  source = "./modules/network_security_group/v1.0.0.1"

  depends_on = [module.resource_group]

  # Required variables
  resource_group_name = module.resource_group[each.value.resource_group_key].name

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

  # Mandatory Tags (matching network RG pattern)
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

  # Security rules - default to an empty map when not defined in tfvars
  security_rules = try(each.value.security_rules, {})
}

module "key_vault" {
  for_each = var.key_vaults

  source = "./modules/key_vault/v1.0.0.3"

  depends_on = [module.resource_group, module.identity_vnet, module.user_managed_identities]

  # Required variables
  resource_group_name = module.resource_group[each.value.resource_group_key].name

  # tenant_id is picked up automatically from the authenticated Azure context
  # (the OIDC login in the workflow) and is intentionally NOT passed via tfvars.
  tenant_id = data.azurerm_client_config.current.tenant_id

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

  # Key Vault configuration - matched to the AI Landing Zone reference
  # (key_vault/v1.0.0.3). The module is RBAC-only and always enables purge
  # protection, so `enable_rbac_authorization` / `purge_protection_enabled` are
  # not module arguments.
  sku_name                      = each.value.sku_name
  public_network_access_enabled = lookup(each.value, "public_network_access_enabled", null)
  network_acls                  = lookup(each.value, "network_acls", null)

  # RBAC role assignments - same approach as the AI LZ reference. Each entry
  # either provides a literal `principal_id` or resolves a User Managed Identity
  # by its tfvars key (`umi_key`). Empty when no role_assignments are defined.
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

  # Customer-Managed Keys. Keys are created on the Key Vault when an entry
  # supplies a `keys` map in tfvars (empty by default => no keys). The module
  # waits 60s after its own RBAC role assignments before key operations so the
  # runner identity can create the key material. The per-resource CMK blocks
  # (Storage, ACR, AI Search, Redis, SQL TDE, Document Intelligence, Cosmos,
  # AI Foundry) consume these keys via var.key_vault_keys / the data sources.
  keys = {
    for key_name, key_config in lookup(each.value, "keys", {}) : key_name => key_config
  }

  wait_for_rbac_before_key_operations = {
    create = "60s"
  }

  # Private Endpoints - subnet resolved from the AI Shared / AI Foundry VNet
  # module output. Private DNS zone wiring is opt-in: when a private endpoint
  # supplies `dns_zone_keys` in tfvars, those keys resolve to shared private DNS
  # zone ids (network-subscription provider); otherwise the endpoint stays
  # NIC-only.
  private_endpoints = {
    for pe_key, pe in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name                          = pe.name
      subnet_resource_id            = module.identity_vnet[pe.vnet_key].subnets[pe.subnet_key].resource_id
      network_interface_name        = lookup(pe, "network_interface_name", null)
      private_dns_zone_resource_ids = length(lookup(pe, "dns_zone_keys", [])) > 0 ? [for k in pe.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id] : lookup(pe, "private_dns_zone_resource_ids", [])
    }
  }

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
  additional_tags     = lookup(each.value, "additional_tags", null)
}

# -----------------------------------------------------------------------------
# Customer-Managed Key (CMK) RBAC. Grants each User Managed Identity the Key
# Vault crypto role on its Key Vault (scope resolves to a module.key_vault
# entry) so the resource encryption services can wrap/unwrap with the key. The
# time_sleep gives the role assignment time to propagate before any CMK-enabled
# resource is created. Both are empty / skipped when
# var.role_assignments_config_cmk is unset (the default => no CMK, no wait).
# -----------------------------------------------------------------------------
module "role_assignments_cmk" {
  source   = "./modules/role_assignments/v1.0.0.0"
  for_each = var.role_assignments_config_cmk

  role_assignments_azure_resource_manager = {
    (each.key) = {
      principal_id         = module.user_managed_identities[each.value.umi_key].principal_id
      scope                = module.key_vault[each.value.scope_key].resource_id
      role_definition_name = each.value.role_definition_name
    }
  }

  depends_on = [module.user_managed_identities, module.key_vault]
}

resource "time_sleep" "rbac_wait_cmk" {
  count           = length(var.role_assignments_config_cmk) > 0 ? 1 : 0
  create_duration = "60s"
  depends_on      = [module.role_assignments_cmk]
}

# -----------------------------------------------------------------------------
# AI Foundry base RBAC. Grants the shared AI Foundry identity its control-plane
# roles on the aishared / aicommon resource groups (Cosmos DB Operator, Storage
# Blob Data Contributor/Owner, Search Service Contributor, ...). Each scope_key
# resolves to a module.resource_group entry. Empty / skipped when
# var.role_assignments_config_foundry is unset (the default).
# -----------------------------------------------------------------------------
module "role_assignments_foundry" {
  source   = "./modules/role_assignments/v1.0.0.0"
  for_each = var.role_assignments_config_foundry

  role_assignments_azure_resource_manager = {
    (each.key) = {
      principal_id         = module.user_managed_identities[each.value.umi_key].principal_id
      scope                = module.resource_group[each.value.scope_key].resource_id
      role_definition_name = each.value.role_definition_name
    }
  }

  depends_on = [module.user_managed_identities, module.resource_group]
}

module "route_tables" {
  for_each = var.route_tables

  source = "./modules/route_tables/v1.0.0.1"

  # Route tables must be created after the resource group and after the VNet
  # subnets exist, because the module associates the UDR to the subnets.
  depends_on = [module.resource_group, module.identity_vnet]

  # Required variables
  resource_group_name = module.resource_group[each.value.resource_group_key].name

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
  auto_delete         = lookup(each.value, "auto_delete", "")
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)

  # Route table specific configuration
  bgp_route_propagation_enabled = lookup(each.value, "bgp_route_propagation_enabled", true)
  routes                        = lookup(each.value, "routes", {})

  # Subnet associations - resolve each subnet's resource_id from the VNet module
  # output (the same way the Key Vault private endpoints are resolved).
  subnet_resource_ids = {
    for assoc_key, assoc_config in lookup(each.value, "subnet_associations", {}) : assoc_key =>
    module.identity_vnet[assoc_config.vnet_key].subnets[assoc_config.subnet_key].resource_id
  }

  # Optional module configuration (telemetry + raw tags passthrough)
  enable_telemetry = try(each.value.enable_telemetry, true)
  tags             = try(each.value.tags, {})
}

module "user_managed_identities" {
  for_each = var.user_managed_identities

  source = "./modules/user_managed_identity/v1.0.0.0"

  depends_on = [module.resource_group]

  # Required variables
  resource_group_name = module.resource_group[each.value.resource_group_key].name

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
  auto_delete         = lookup(each.value, "auto_delete", "")
  delete_after        = lookup(each.value, "delete_after", null)
  integration_id      = lookup(each.value, "integration_id", null)
  retention           = lookup(each.value, "retention", null)
  experiment_phase    = lookup(each.value, "experiment_phase", null)
  sandbox_type        = lookup(each.value, "sandbox_type", null)
  os                  = lookup(each.value, "os", null)
  patch_policy        = lookup(each.value, "patch_policy", null)
  maintenance_window  = lookup(each.value, "maintenance_window", null)
  last_vm_accessed    = lookup(each.value, "last_vm_accessed", null)

  # Optional module configuration
  enable_telemetry = try(each.value.enable_telemetry, true)
}

module "storage_accounts" {
  for_each = var.storage_accounts

  source = "./modules/storage_account/v1.0.0.1"

  # Storage accounts depend on the resource group, the VNet subnets (for the
  # private endpoints) and the managed identities they reference. When CMK is
  # enabled they also wait for the Key Vault and the CMK RBAC propagation.
  depends_on = [module.resource_group, module.identity_vnet, module.user_managed_identities, module.key_vault, time_sleep.rbac_wait_cmk]

  # Required variables
  resource_group_name = module.resource_group[each.value.resource_group_key].name

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
  https_traffic_only_enabled        = each.value.https_traffic_only_enabled
  public_network_access_enabled     = each.value.public_network_access_enabled
  allow_nested_items_to_be_public   = each.value.allow_nested_items_to_be_public
  shared_access_key_enabled         = each.value.shared_access_key_enabled
  default_to_oauth_authentication   = each.value.default_to_oauth_authentication
  infrastructure_encryption_enabled = each.value.infrastructure_encryption_enabled

  # Customer-Managed Key. Opt-in: only set when the entry supplies a
  # `customer_managed_key` block in tfvars (otherwise null => service-managed).
  customer_managed_key = try(each.value.customer_managed_key, null) != null ? {
    key_vault_resource_id = data.azurerm_key_vault.cmk[each.value.customer_managed_key.key_vault_key].id
    key_name              = each.value.customer_managed_key.key_name
    key_version           = try(each.value.customer_managed_key.key_version, null)
    user_assigned_identity = try(each.value.customer_managed_key.user_assigned_identity_ref, null) != null ? {
      resource_id = module.user_managed_identities[each.value.customer_managed_key.user_assigned_identity_ref].resource_id
    } : null
  } : null

  # Identity - user-assigned managed identity resolved from the UAMI module
  managed_identities = {
    system_assigned            = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = try(each.value.managed_identities.umi_key, null) != null ? toset([module.user_managed_identities[each.value.managed_identities.umi_key].resource_id]) : toset([])
  }

  # Network rules
  network_rules = each.value.network_rules

  # SAS expiration policy (compliance: SAS policies should be configured).
  # Optional - only applied when defined in tfvars.
  sas_policy = try(each.value.sas_policy, null)

  # Blob containers / queues / tables to pre-create (optional - empty when not
  # defined in tfvars). Queues back the Event Grid system topics and Function
  # App deployment containers back the Flex Consumption function apps.
  containers = try(each.value.containers, {})
  queues     = try(each.value.queues, {})
  tables     = try(each.value.tables, {})

  # Private endpoints - subnet resolved from the VNet module output (the same
  # way the Key Vault private endpoints are resolved). Private DNS wiring is
  # opt-in via each endpoint's `dns_zone_keys`; otherwise NIC-only.
  private_endpoints = {
    for pe_key, pe_config in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name                          = pe_config.name
      subnet_resource_id            = module.identity_vnet[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
      subresource_name              = pe_config.subresource_name
      network_interface_name        = lookup(pe_config, "network_interface_name", null)
      private_dns_zone_resource_ids = length(lookup(pe_config, "dns_zone_keys", [])) > 0 ? [for k in pe_config.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id] : lookup(pe_config, "private_dns_zone_resource_ids", [])
    }
  }

  # Optional module configuration (telemetry + raw tags passthrough)
  enable_telemetry = try(each.value.enable_telemetry, true)
  tags             = try(each.value.tags, {})
}

# -----------------------------------------------------------------------------
# Application Insights
# Workspace-based; connected to the existing central Log Analytics Workspace in
# the management subscription, resolved at plan time via the
# data.azurerm_log_analytics_workspace.central data source (azurerm.law
# provider). No Log Analytics Workspace is created by this pattern.
# -----------------------------------------------------------------------------
module "application_insights" {
  for_each = var.application_insights

  source = "./modules/app_insights/v1.0.0.0"

  depends_on = [module.resource_group]

  resource_group_name = module.resource_group[each.value.resource_group_key].name

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

  # Application Insights configuration
  # Connect to the existing central Log Analytics Workspace (management
  # subscription) resolved via the azurerm.law data source.
  workspace_id     = data.azurerm_log_analytics_workspace.central[0].id
  application_type = lookup(each.value, "application_type", "web")

  # Governance / security settings - matched to the AI LZ reference. All are
  # tfvars-driven and fall back to the module defaults. The public-access
  # controls (internet_ingestion_enabled / internet_query_enabled) are left at
  # their defaults because hardening them requires the Azure Monitor Private
  # Link Scope path, which depends on hub peering and is not in place yet.
  daily_data_cap_in_gb                  = lookup(each.value, "daily_data_cap_in_gb", 100)
  daily_data_cap_notifications_disabled = lookup(each.value, "daily_data_cap_notifications_disabled", false)
  internet_ingestion_enabled            = lookup(each.value, "internet_ingestion_enabled", true)
  internet_query_enabled                = lookup(each.value, "internet_query_enabled", true)
  local_authentication_disabled         = lookup(each.value, "local_authentication_disabled", false)
  retention_in_days                     = lookup(each.value, "retention_in_days", 90)
  sampling_percentage                   = lookup(each.value, "sampling_percentage", 100)
  tags                                  = try(each.value.tags, {})
}

##############################
## Internal API Management (Common AI resource)
##
## Uses internal VNet integration against our own APIM subnet (not peering
## dependent). The sheet marks the APIM private endpoint as "No", so no PE is
## wired. named_values are left empty: the AI LZ reference populates them from
## Function App host keys that do not exist in this stack.
##############################
module "internal_api_management" {
  source   = "./modules/internal_apim/v1.0.0.1"
  for_each = var.internal_api_management

  # Required APIM inputs
  global_policy_vars  = each.value.global_policy_vars
  resource_group_name = module.resource_group[each.value.resource_group_key].name
  location            = each.value.location
  name                = try(each.value.name, each.key)
  service             = try(each.value.service, try(each.value.resource_type_code, "apim"))

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
  add_random      = each.value.add_random
  rnd_length      = each.value.rnd_length
  max_length      = each.value.max_length

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

  # Required APIM SKU / publisher
  sku_name        = each.value.sku_name
  publisher_name  = each.value.publisher_name
  publisher_email = each.value.publisher_email
  additional_tags = {}

  # Internal VNet integration - resolves the APIM subnet from our VNet module
  virtual_network_subnet_id = module.identity_vnet[each.value.vnet_key].subnets[each.value.subnet_key].resource_id

  # API surface / named values / private endpoints not wired yet (see header)
  named_values     = try(each.value.named_values, {})
  backends         = try(each.value.backends, {})
  apis             = try(each.value.apis, {})
  products         = try(each.value.products, {})
  subscriptions    = try(each.value.subscriptions, {})
  api_version_sets = try(each.value.api_version_sets, {})

  # NOTE: route_tables is included here (extra vs ex/dev-ai) so the apim_internet
  # UDR (ApiManagement -> Internet) is associated to the APIM subnet BEFORE APIM
  # provisions. Without it, Terraform can create APIM in parallel with the route
  # table association; while the hub's BGP default route (0.0.0.0/0 -> firewall)
  # is still active it black-holes the :3443 management-endpoint return traffic
  # and APIM fails provisioning with "422 ManagementApiRequestFailed". Ordering
  # the UDR first makes fresh end-to-end deploys succeed without the portal
  # "Apply network configuration" remediation. APIM also depends on the pre-
  # created DNS record (azurerm_private_dns_a_record.apim_internal) so the record
  # exists before APIM's :3443 self-check runs during provisioning. If APIM still
  # caches a stale (public) resolution, azapi_resource_action.apim_apply_network_update
  # below forces a re-resolution AFTER provisioning to self-heal in the same run.
  depends_on = [module.resource_group, module.identity_vnet, module.network_security_groups, module.route_tables, azurerm_private_dns_a_record.apim_internal, azurerm_private_dns_zone_virtual_network_link.apim_spoke_azure_api]
}

# -----------------------------------------------------------------------------
# Internal APIM DNS PRE-registration into the shared hub `azure-api.net` zone.
#
# Internal-mode APIM has NO Private Endpoint, so nothing auto-registers its
# *.azure-api.net hostnames. CRITICAL ORDERING: APIM runs its own control-plane
# (:3443) self-check DURING provisioning, so the DNS record must ALREADY exist
# when APIM provisions - it CANNOT be created from the APIM's output afterwards
# (that deadlocks: APIM never finishes -> record never created -> 422).
#
# So the record is created BEFORE APIM (the APIM module depends_on it) using the
# PREDICTED ILB IP = the first usable address of the APIM subnet (Azure reserves
# the first 4 addresses; APIM stv2 takes base+4). Verified on uat-006: subnet
# 10.248.8.64/26 -> ILB 10.248.8.68. The record NAME comes from the map key (=
# the APIM name) and the IP from the subnet CIDR (var) - both STATIC, so there is
# NO dependency on the APIM module and NO hardcoded literal IP.
#
# The gateway (base) name + control-plane/portal subdomains all point at the ILB
# IP. `.management` is what the self-check needs. Trim local.apim_dns_hostnames
# to [""] for MYW-style base-name-only.
#
# PREREQS (one-time, hub side): (1) the `azure-api.net` zone pre-created in the
# hub (Singapore/network) BEFORE the AI deploy runs, (2) the deploy SPN granted
# "Private DNS Zone Contributor" on that zone in the connectivity subscription.
# -----------------------------------------------------------------------------
locals {
  apim_dns_hostnames = ["", ".management", ".portal", ".developer", ".scm"]

  apim_dns_records = {
    for rec in flatten([
      for apim_key, apim in var.internal_api_management : [
        for suffix in local.apim_dns_hostnames : {
          key  = "${apim_key}${suffix}"
          name = "${apim_key}${suffix}"
          # Predicted APIM ILB private IP = first usable addr of the APIM subnet.
          ip = cidrhost(var.virtual_networks[apim.vnet_key].subnets[apim.subnet_key].address_prefix, 4)
        }
      ]
    ]) : rec.key => rec
  }
}

resource "azurerm_private_dns_a_record" "apim_internal" {
  for_each = local.apim_dns_records

  provider = azurerm.network

  name                = each.value.name
  zone_name           = "azure-api.net"
  resource_group_name = var.existing_private_dns_zones_rg_name
  ttl                 = 3600
  records             = [each.value.ip]
}

# CRITICAL (confirmed live on sit-007): the SEA DNS Private Resolver only returns
# the private azure-api.net records to a spoke when that SPOKE VNet is ALSO
# linked to the zone - the hub (inbound-endpoint VNet) link alone is NOT enough.
# MYW does this for its aifoundry spokes. Without this link the internal APIM
# resolves its own .management hostname to the PUBLIC IP -> :3443 self-check
# ConnectFailure -> 422 ManagementApiRequestFailed. Created in the hub zone
# (network sub) via the azurerm.network provider (SPN has Private DNS Zone
# Contributor there). registration disabled (resolution-only).
resource "azurerm_private_dns_zone_virtual_network_link" "apim_spoke_azure_api" {
  for_each = var.internal_api_management

  provider = azurerm.network

  name                  = "link-to-${each.value.vnet_key}"
  resource_group_name   = var.existing_private_dns_zones_rg_name
  private_dns_zone_name = "azure-api.net"
  virtual_network_id    = module.identity_vnet[each.value.vnet_key].resource_id
  registration_enabled  = false
}

# ---------------------------------------------------------------------------
# Foundry spoke-to-zone private DNS VNet links (parity with ex/dev-ai-latest
# `vnet_link`). ex/dev-ai-latest links ONLY the dedicated AI Foundry VNet (which
# uses Azure-provided DNS) to each account privatelink zone, so the injected
# Standard-Agent managed environment + Foundry private endpoints resolve via the
# linked zones. The aishared VNet is intentionally EXCLUDED: it uses the custom
# hub resolver (10.247.130.196), which already serves those zones, so a VNet link
# on it would be inert (a custom-DNS VNet bypasses its own linked zones). Scoped
# here to the aifoundry VNet only (regexall "aifoundry"). vault_core is NOT linked
# (CMK Key Vault is reached via the account's trusted-services bypass).
# ---------------------------------------------------------------------------
locals {
  # Account privatelink zones the Foundry VNet links to (by tfvars key).
  foundry_spoke_dns_zone_keys = ["cognitive_services", "openai", "ai_services", "storage_blob", "cosmos_sql"]

  foundry_spoke_dns_links = {
    for pair in flatten([
      for vnet_key, vnet in var.virtual_networks : [
        for zk in local.foundry_spoke_dns_zone_keys : {
          key       = "${vnet_key}--${zk}"
          vnet_key  = vnet_key
          zone_name = var.existing_private_dns_zones[zk].name
        }
        if contains(keys(var.existing_private_dns_zones), zk)
      ]
      if length(regexall("aifoundry", vnet_key)) > 0
    ]) : pair.key => pair
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "foundry_spoke_zones" {
  for_each = local.foundry_spoke_dns_links

  provider = azurerm.network

  name                  = "link-to-${each.value.vnet_key}"
  resource_group_name   = var.existing_private_dns_zones_rg_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id    = module.identity_vnet[each.value.vnet_key].resource_id
  registration_enabled  = false
}

# Force APIM to re-read VNet DNS AFTER the pre-created azure-api.net records are
# in place. Internal APIM runs its control-plane (:3443) self-check early during
# provisioning and CACHES the resolution; if it cached a stale/public answer, it
# will not re-resolve until an "apply network configuration" is triggered. This
# action issues that operation programmatically (runs with the deploy SPN's
# rights - no Contributor/portal step needed) so the whole thing succeeds in ONE
# go. It is long-running (~15-45 min) and waits for completion. Replaces the
# earlier time_sleep propagation wait (which could not clear a cached failure).
resource "azapi_resource_action" "apim_apply_network_update" {
  for_each = var.internal_api_management

  type        = "Microsoft.ApiManagement/service@2023-05-01-preview"
  resource_id = module.internal_api_management[each.key].resource_id
  action      = "applynetworkconfigurationupdates"
  method      = "POST"

  depends_on = [
    module.internal_api_management,
    azurerm_private_dns_a_record.apim_internal,
  ]
}

##############################
## AI Foundry (MS Foundry) Account + Projects (Common AI resource)
##
## The account private endpoint, Standard-Agent account connections (Storage /
## Search / Cosmos) and capability hosts are intentionally omitted: the PE needs
## the hub-peered private DNS zones, and the connections reference cross-stack
## resources. CMK encryption is also omitted (Key Vault key + peering).
## Network injection uses our own delegated agent subnet (not peering).
##############################
module "ai_foundry_account" {
  count  = length(var.ai_foundry_accounts) > 0 ? 1 : 0
  source = "./modules/ms_ai_foundry/v1.0.0.1"

  # Naming + tagging are module-level scalars taken from the single account entry
  env                = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].env
  org                = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].org
  region_code        = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].region_code
  base_name          = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].base_name
  additional_name    = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].additional_name
  iterator           = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].iterator
  au                 = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].au
  app_code           = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].app_code
  bu                 = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].bu
  owner              = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].owner
  resource_type_code = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].resource_type_code
  max_length         = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].max_length
  no_dashes          = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].no_dashes
  add_random         = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].add_random
  rnd_length         = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].rnd_length

  environment         = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].environment
  business_owner      = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].business_owner
  business_unit       = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].business_unit
  criticality         = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].criticality
  cost_center         = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].cost_center
  data_classification = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].data_classification
  compliance          = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].compliance
  app_name            = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].app_name
  budget_id           = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].budget_id
  status              = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].status
  product_name        = try(var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].product_name, "ms_foundry")
  service             = "foundry-service"

  # AI Foundry Accounts - resolve RG / identity / storage from local modules
  ai_foundry_accounts = {
    for k, v in var.ai_foundry_accounts : k => {
      parent_id              = module.resource_group[v.resource_group_key].resource_id
      sku_name               = v.sku_name
      identity_type          = v.identity_type
      identity_id            = module.user_managed_identities[v.umi_key].resource_id
      disableLocalAuth       = v.disableLocalAuth
      allowProjectManagement = v.allowProjectManagement
      customSubDomainName    = v.customSubDomainName
      publicNetworkAccess    = v.publicNetworkAccess

      restrict_outbound_network_access = try(v.restrict_outbound_network_access, false)
      allowed_fqdn_list                = try(v.allowed_fqdn_list, [])

      # Customer-Managed Key encryption. Opt-in: only set when the account
      # supplies an `encryption` block in tfvars (otherwise null => MS-managed).
      encryption = try(v.encryption, null) != null ? {
        key_source         = "Microsoft.KeyVault"
        key_vault_uri      = data.azurerm_key_vault.cmk[v.encryption.key_vault_key].vault_uri
        key_name           = data.azurerm_key_vault_key.cmk[v.encryption.key_vault_key].name
        key_version        = data.azurerm_key_vault_key.cmk[v.encryption.key_vault_key].version
        identity_client_id = module.user_managed_identities[v.encryption.umi_key].client_id
      } : null

      network_injections = try(v.network_injections, null) == null ? [] : [
        for ni in v.network_injections : {
          scenario                      = try(ni.scenario, "agent")
          subnet_arm_id                 = module.identity_vnet[ni.vnet_key].subnets[ni.subnet_key].resource_id
          use_microsoft_managed_network = try(ni.use_microsoft_managed_network, false)
        }
      ]
      network_acls = try(v.network_acls, null)
      user_owned_storage = try(v.storage_key, null) != null ? [
        {
          resource_id        = module.storage_accounts[v.storage_key].resource_id
          identity_client_id = module.user_managed_identities[v.umi_key].client_id
        }
      ] : []
    }
  }

  # AI Foundry Projects - the reference's only projects are {org}-proj-aea /
  # {org}-proj-espi, which belong to the excluded AEA/ESPI app tier. Per the SEA
  # scope (base infra only - no app infra) any project whose key contains
  # "aea"/"espi" is filtered out, so the account is provisioned with zero
  # projects today. Mirrors the app-tier exclusion used for private_endpoints;
  # a future non-AEA/ESPI project added to var.ai_foundry_projects would deploy.
  ai_foundry_projects = {
    for k, v in var.ai_foundry_projects : k => {
      account_key   = v.foundry_key
      parent_id     = null
      sku_name      = v.sku_name
      identity_type = v.identity_type
      identity_id   = v.identity_type == "UserAssigned" ? module.user_managed_identities[v.umi_key].resource_id : null
      displayName   = v.displayName
      description   = try(v.description, "")
    }
    if length(regexall("aea|espi", k)) == 0
  }

  # Model deployments handled by a separate module call below (sequencing)
  ai_foundry_deployments         = {}
  ai_foundry_project_connections = {}

  # Standard Agent / cross-stack pieces omitted (peering dependent)
  account_connections              = {}
  role_assignments                 = {}
  cosmos_role_assignments          = {}
  project_role_assignments         = {}
  account_capability_hosts         = {}
  project_capability_hosts         = {}
  project_cosmos_role_assignments  = {}
  post_ch_storage_role_assignments = {}

  # Give the Cognitive Services account time to fully provision (its OpenAI
  # capability + RAI policy surface) before the model deployments validate their
  # RAI policy. ex/dev-ai (which deploys the SAME gpt-5.1 successfully) sets 120s
  # here; without it the gpt-5.1 deployment races a not-yet-ready account and
  # fails 400 "Failed to validate policies for model gpt-5.1/2025-11-13".
  wait_after_account_creation = "120s"

  # Account private endpoint. Private DNS wiring is opt-in via the endpoint's
  # `dns_zone_keys` (resolved against the shared private DNS zones); NIC-only
  # when omitted.
  private_endpoint_config = try(var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].private_endpoint, null) == null ? null : {
    name                = var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].private_endpoint.name
    location            = lookup(local.location_by_region_code, var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].region_code, "southeastasia")
    resource_group_name = module.resource_group[var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].resource_group_key].name
    subnet_id           = module.identity_vnet[var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].private_endpoint.vnet_key].subnets[var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].private_endpoint.subnet_key].resource_id
    account_key         = keys(var.ai_foundry_accounts)[0]
    subresource_names   = ["account"]
    dns_zone_ids        = length(lookup(var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].private_endpoint, "dns_zone_keys", [])) > 0 ? [for k in var.ai_foundry_accounts[keys(var.ai_foundry_accounts)[0]].private_endpoint.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id] : []
  }

  depends_on = [
    module.resource_group,
    module.user_managed_identities,
    module.identity_vnet,
    module.storage_accounts,
    module.key_vault,
    time_sleep.rbac_wait_cmk
  ]
}

# Wait for the Foundry account to settle before creating model deployments
resource "time_sleep" "wait_for_foundry_account" {
  count           = length(var.ai_foundry_accounts) > 0 ? 1 : 0
  depends_on      = [module.ai_foundry_account]
  create_duration = "60s"
}

##############################
## AI Foundry Model (OpenAI) Deployment (Common AI resource)
##############################
module "ai_foundry_deployment_01" {
  for_each = var.ai_foundry_deployments_01
  source   = "./modules/ms_ai_foundry/v1.0.0.1"

  env             = each.value.env
  org             = each.value.org
  region_code     = each.value.region_code
  base_name       = each.value.base_name
  additional_name = each.value.additional_name
  # Model deployment sub-number is a fixed model identifier (01/02/03),
  # independent of the form-driven stack iterator, so it is hardcoded here to
  # avoid all three deployments collapsing to the same Azure name.
  iterator           = "01"
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
  product_name        = try(each.value.product_name, "ms_foundry")
  service             = each.value.service

  ai_foundry_accounts = {}
  ai_foundry_projects = {}

  ai_foundry_deployments = {
    (each.key) = {
      parent_id       = module.ai_foundry_account[0].ai_foundry_account_ids[each.value.foundry_key]
      sku_name        = each.value.sku_name
      capacity        = each.value.capacity
      model_format    = each.value.model_format
      model_name      = each.value.model_name
      model_version   = each.value.model_version
      rai_policy_name = try(each.value.rai_policy_key, null) != null ? module.ai_foundry_rai_policy[each.value.rai_policy_key].rai_policy_name[each.value.rai_policy_key] : null
    }
  }
  ai_foundry_project_connections = {}

  depends_on = [time_sleep.wait_for_foundry_account]
}

##############################
## AI Foundry Model (OpenAI) Deployment 02 (Common AI resource)
## Model deployments to the same Cognitive account must be created
## sequentially (Azure returns 409 on concurrent creates), so 02 depends on 01.
##############################
module "ai_foundry_deployment_02" {
  for_each = var.ai_foundry_deployments_02
  source   = "./modules/ms_ai_foundry/v1.0.0.1"

  env             = each.value.env
  org             = each.value.org
  region_code     = each.value.region_code
  base_name       = each.value.base_name
  additional_name = each.value.additional_name
  # Fixed model identifier (see deployment_01 note).
  iterator           = "02"
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
  product_name        = try(each.value.product_name, "ms_foundry")
  service             = each.value.service

  ai_foundry_accounts = {}
  ai_foundry_projects = {}

  ai_foundry_deployments = {
    (each.key) = {
      parent_id       = module.ai_foundry_account[0].ai_foundry_account_ids[each.value.foundry_key]
      sku_name        = each.value.sku_name
      capacity        = each.value.capacity
      model_format    = each.value.model_format
      model_name      = each.value.model_name
      model_version   = each.value.model_version
      rai_policy_name = try(each.value.rai_policy_key, null) != null ? module.ai_foundry_rai_policy[each.value.rai_policy_key].rai_policy_name[each.value.rai_policy_key] : null
    }
  }
  ai_foundry_project_connections = {}

  depends_on = [module.ai_foundry_deployment_01]
}

##############################
## AI Foundry Model (OpenAI) Deployment 03 (Common AI resource)
## Chained after 02 to keep model creation on the account sequential.
##############################
module "ai_foundry_deployment_03" {
  for_each = var.ai_foundry_deployments_03
  source   = "./modules/ms_ai_foundry/v1.0.0.1"

  env             = each.value.env
  org             = each.value.org
  region_code     = each.value.region_code
  base_name       = each.value.base_name
  additional_name = each.value.additional_name
  # Fixed model identifier (see deployment_01 note).
  iterator           = "03"
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
  product_name        = try(each.value.product_name, "ms_foundry")
  service             = each.value.service

  ai_foundry_accounts = {}
  ai_foundry_projects = {}

  ai_foundry_deployments = {
    (each.key) = {
      parent_id       = module.ai_foundry_account[0].ai_foundry_account_ids[each.value.foundry_key]
      sku_name        = each.value.sku_name
      capacity        = each.value.capacity
      model_format    = each.value.model_format
      model_name      = each.value.model_name
      model_version   = each.value.model_version
      rai_policy_name = try(each.value.rai_policy_key, null) != null ? module.ai_foundry_rai_policy[each.value.rai_policy_key].rai_policy_name[each.value.rai_policy_key] : null
    }
  }
  ai_foundry_project_connections = {}

  depends_on = [module.ai_foundry_deployment_02]
}

##############################
## RAI Policy for AI Foundry (Common AI resource)
##############################
module "ai_foundry_rai_policy" {
  for_each = var.ai_foundry_rai_policy
  source   = "./modules/ms_ai_foundry/v1.0.0.1"

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
  product_name        = try(each.value.product_name, "ms_foundry")
  service             = each.value.service

  ai_foundry_rai_policy = {
    (each.key) = {
      cognitive_account_id = module.ai_foundry_account[0].ai_foundry_account_ids[each.value.foundry_key]
      base_policy_name     = each.value.base_policy_name
      content_filters      = local.rai_content_filters
    }
  }

  ai_foundry_accounts            = {}
  ai_foundry_deployments         = {}
  ai_foundry_project_connections = {}

  depends_on = [module.ai_foundry_account]
}

##############################
## Azure Container Registry (Common AI resource)
##
## Premium SKU (module default). The private endpoint (sheet:
## {org}-pe-cr-aishared-...) is created here as a NIC only - the private DNS zone
## group is left unmanaged because DNS wiring depends on hub peering and is
## deferred to the peering stage.
##############################
module "azure_container_registry" {
  source   = "./modules/azure_container_registry/v1.0.0.0"
  for_each = var.azure_container_registry

  # Naming module required variables
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

  resource_group_name = module.resource_group[each.value.resource_group_key].name

  # Container Registry configuration
  sku = lookup(each.value, "sku", "Premium")

  managed_identities = {
    system_assigned            = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  # Customer-Managed Key. Opt-in: only set when the entry supplies a
  # `customer_managed_key` block in tfvars (otherwise null => service-managed).
  customer_managed_key = try(each.value.customer_managed_key, null) != null ? {
    key_vault_resource_id = data.azurerm_key_vault.cmk[each.value.customer_managed_key.key_vault_key].id
    key_name              = each.value.customer_managed_key.key_name
    key_version           = try(each.value.customer_managed_key.key_version, null)
    user_assigned_identity = try(each.value.customer_managed_key.user_assigned_identity_ref, null) != null ? {
      resource_id = module.user_managed_identities[each.value.customer_managed_key.user_assigned_identity_ref].resource_id
    } : null
  } : null

  # Private endpoint. DNS zone groups are managed only when a private endpoint
  # supplies `dns_zone_keys` in tfvars (resolved against the shared private DNS
  # zones in the network subscription); otherwise the endpoint stays NIC-only.
  private_endpoints_manage_dns_zone_group = anytrue([for pe_key, pe in lookup(each.value, "private_endpoints", {}) : length(lookup(pe, "dns_zone_keys", [])) > 0])
  private_endpoints = {
    for pe_key, pe in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name                          = pe.name
      subnet_resource_id            = module.identity_vnet[pe.vnet_key].subnets[pe.subnet_key].resource_id
      network_interface_name        = lookup(pe, "network_interface_name", null)
      private_dns_zone_resource_ids = length(lookup(pe, "dns_zone_keys", [])) > 0 ? [for k in pe.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id] : lookup(pe, "private_dns_zone_resource_ids", [])
    }
  }

  depends_on = [module.resource_group, module.key_vault, module.user_managed_identities, module.identity_vnet, time_sleep.rbac_wait_cmk]
}

# =============================================================================
# Cosmos DB account (Common AI resource)
# =============================================================================
module "cosmosdb" {
  source   = "./modules/cosmosdb_account/v1.0.0.0"
  for_each = var.cosmosdb_accounts

  # Naming module required variables
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
  backup_policy        = lookup(each.value, "backup_policy", null)
  disaster_recovery    = lookup(each.value, "disaster_recovery", null)
  cost_alert_threshold = lookup(each.value, "cost_alert_threshold", null)
  budget_limit         = lookup(each.value, "budget_limit", null)
  additional_tags      = lookup(each.value, "additional_tags", null)

  # Resource configuration
  resource_group_name        = module.resource_group[each.value.resource_group_key].name
  analytical_storage_enabled = each.value.analytical_storage_enabled
  automatic_failover_enabled = each.value.automatic_failover_enabled
  capacity                   = each.value.capacity
  consistency_policy         = each.value.consistency_policy

  identity = {
    type         = each.value.identity.type
    identity_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  capabilities                          = each.value.capabilities
  ip_range_filter                       = each.value.ip_range_filter
  local_authentication_disabled         = each.value.local_authentication_disabled
  multiple_write_locations_enabled      = each.value.multiple_write_locations_enabled
  network_acl_bypass_for_azure_services = each.value.network_acl_bypass_for_azure_services
  partition_merge_enabled               = each.value.partition_merge_enabled
  public_network_access_enabled         = each.value.public_network_access_enabled

  sql_databases = lookup(each.value, "sql_databases", {})

  # Private endpoint. Private DNS wiring is opt-in via each endpoint's
  # `dns_zone_keys`; otherwise NIC-only.
  private_endpoints = {
    for pe_key, pe in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name                          = pe.name
      subnet_resource_id            = module.identity_vnet[pe.vnet_key].subnets[pe.subnet_key].resource_id
      subresource_name              = lookup(pe, "subresource_name", null)
      network_interface_name        = lookup(pe, "network_interface_name", null)
      private_dns_zone_resource_ids = length(lookup(pe, "dns_zone_keys", [])) > 0 ? [for k in pe.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id] : lookup(pe, "private_dns_zone_resource_ids", [])
    }
  }

  depends_on = [module.resource_group, module.user_managed_identities, module.identity_vnet]
}

# -----------------------------------------------------------------------------
# Cosmos DB Customer-Managed Key. The Cosmos module does not expose CMK, so it
# is enabled via a two-step ARM PATCH after the account exists and the CMK RBAC
# has propagated: first defaultIdentity (the UMI), then the versionless
# keyVaultKeyUri. local.cosmos_cmk_patch is empty unless a cosmos account
# declares a customer_managed_key block, so these are no-ops by default. The
# terraform_data trigger re-runs the PATCH only when the key uri or UMI changes.
# -----------------------------------------------------------------------------
resource "terraform_data" "cosmos_cmk_trigger" {
  for_each = local.cosmos_cmk_patch

  input = each.value
}

resource "azapi_resource_action" "cosmos_cmk_default_identity" {
  for_each = local.cosmos_cmk_patch

  type        = "Microsoft.DocumentDB/databaseAccounts@2024-05-15"
  resource_id = each.value.cosmos_id
  method      = "PATCH"

  body = {
    properties = {
      defaultIdentity = "UserAssignedIdentity=${each.value.umi_id}"
    }
  }

  depends_on = [time_sleep.rbac_wait_cmk]

  lifecycle {
    replace_triggered_by = [terraform_data.cosmos_cmk_trigger[each.key]]
  }
}

resource "azapi_resource_action" "cosmos_cmk" {
  for_each = local.cosmos_cmk_patch

  type        = "Microsoft.DocumentDB/databaseAccounts@2024-05-15"
  resource_id = each.value.cosmos_id
  method      = "PATCH"

  body = {
    properties = {
      keyVaultKeyUri = each.value.key_uri
    }
  }

  depends_on = [azapi_resource_action.cosmos_cmk_default_identity]

  lifecycle {
    replace_triggered_by = [terraform_data.cosmos_cmk_trigger[each.key]]
  }
}

# -----------------------------------------------------------------------------
# Cosmos DB data-plane RBAC. Grants each identity the Cosmos DB Built-in Data
# Contributor SQL role (fixed definition id 00000000-0000-0000-0000-000000000002)
# on the target Cosmos account so it can read/write data (control-plane RBAC
# alone does not grant data access). Empty / skipped when
# var.cosmosdb_sql_role_assignments is unset (the default).
# -----------------------------------------------------------------------------
resource "azurerm_cosmosdb_sql_role_assignment" "foundry_cosmos_data_plane" {
  for_each = var.cosmosdb_sql_role_assignments

  resource_group_name = module.resource_group[each.value.resource_group_key].name
  account_name        = module.cosmosdb[each.value.account_key].name
  role_definition_id  = "${module.cosmosdb[each.value.account_key].id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = module.user_managed_identities[each.value.umi_key].principal_id
  scope               = module.cosmosdb[each.value.account_key].id

  depends_on = [module.cosmosdb, module.user_managed_identities]
}
# enabled, so this password is never actually used to log in - it only satisfies
# the provider requirement. It is intentionally NOT written to Key Vault.
resource "random_password" "sql_admin_password" {
  length           = 20
  special          = true
  override_special = "!@#%^*()-_=+[]{}"
}

# =============================================================================
# SQL Server + database (Common AI resource)
# =============================================================================
module "sql_server" {
  source   = "./modules/sql_server/v1.0.0.0"
  for_each = var.sql_servers

  # Naming module required variables
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
  product_name        = each.value.product_name
  app_support         = each.value.app_support

  # Optional Tags
  region              = lookup(each.value, "region", null)
  description         = lookup(each.value, "description", null)
  notification_emails = lookup(each.value, "notification_emails", null)
  app_id              = lookup(each.value, "app_id", null)
  additional_tags     = lookup(each.value, "additional_tags", null)

  resource_group_name                      = module.resource_group[each.value.resource_group_key].name
  server_version                           = each.value.server_version
  administrator_login                      = each.value.administrator_login
  administrator_login_password             = random_password.sql_admin_password.result
  enable_telemetry                         = lookup(each.value, "enable_telemetry", true)
  express_vulnerability_assessment_enabled = lookup(each.value, "express_vulnerability_assessment_enabled", true)
  databases                                = each.value.databases
  primary_user_assigned_identity_id        = module.user_managed_identities[each.value.umi_key].resource_id

  # Transparent Data Encryption. Opt-in: uses the CMK key resolved from the
  # data source when the entry sets `tde_key_name` (a var.key_vault_keys key);
  # otherwise null => service-managed key.
  transparent_data_encryption_key_vault_key_id = try(data.azurerm_key_vault_key.cmk[each.value.tde_key_name].id, null)

  managed_identities = {
    system_assigned            = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  # Private endpoint. Private DNS wiring is opt-in via each endpoint's
  # `dns_zone_keys`; otherwise NIC-only.
  private_endpoints = {
    for pe_key, pe in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name                          = pe.name
      subnet_resource_id            = module.identity_vnet[pe.vnet_key].subnets[pe.subnet_key].resource_id
      subresource_name              = lookup(pe, "subresource_name", null)
      network_interface_name        = lookup(pe, "network_interface_name", null)
      private_dns_zone_resource_ids = length(lookup(pe, "dns_zone_keys", [])) > 0 ? [for k in pe.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id] : lookup(pe, "private_dns_zone_resource_ids", [])
    }
  }

  azuread_administrator = {
    login_username              = var.login_username
    object_id                   = var.sql_admin_object_id
    azuread_authentication_only = true
  }

  depends_on = [module.resource_group, module.user_managed_identities, module.identity_vnet, module.key_vault, time_sleep.rbac_wait_cmk]
}

# =============================================================================
# Managed Redis Cache (Common AI resource)
# =============================================================================
module "managed_redis" {
  source   = "./modules/managed_redis_cache/v1.0.0.1"
  for_each = var.managed_redis_instances

  # Naming module required variables
  env                = each.value.env
  au                 = each.value.au
  app_code           = each.value.app_code
  bu                 = each.value.bu
  owner              = each.value.owner
  resource_type_code = each.value.resource_type_code

  # Optional naming variables
  org             = lookup(each.value, "org", "")
  region_code     = lookup(each.value, "region_code", "sea")
  base_name       = lookup(each.value, "base_name", null)
  additional_name = lookup(each.value, "additional_name", null)
  iterator        = lookup(each.value, "iterator", null)
  max_length      = lookup(each.value, "max_length", 63)
  no_dashes       = lookup(each.value, "no_dashes", false)
  add_random      = lookup(each.value, "add_random", false)
  rnd_length      = lookup(each.value, "rnd_length", 2)

  # Mandatory Business Tags
  app_name       = each.value.app_name
  app_support    = each.value.app_support
  business_unit  = each.value.business_unit
  business_owner = each.value.business_owner
  type           = lookup(each.value, "type", "Infrastructure")

  # Mandatory DevOps Tags
  product_name    = lookup(each.value, "product_name", "managed_redis")
  product_version = lookup(each.value, "product_version", "1.0.0.0")

  # Mandatory Finance Tags
  cost_center          = each.value.cost_center
  cost_allocation_unit = each.value.cost_allocation_unit
  budget_id            = each.value.budget_id
  budget_limit         = lookup(each.value, "budget_limit", "")
  cost_alert_threshold = lookup(each.value, "cost_alert_threshold", "")

  # Mandatory Governance Tags
  data_classification = each.value.data_classification
  compliance_required = lookup(each.value, "compliance_required", "No")
  compliance          = lookup(each.value, "compliance", "None")

  # Mandatory Operation Tags
  criticality = each.value.criticality
  environment = each.value.environment
  status      = lookup(each.value, "status", "Live")

  # Optional Tags
  delete_after        = lookup(each.value, "delete_after", "")
  tier                = lookup(each.value, "tier", "")
  app_id              = lookup(each.value, "app_id", "")
  auto_delete         = lookup(each.value, "auto_delete", "")
  auto_shutdown       = lookup(each.value, "auto_shutdown", "")
  description         = lookup(each.value, "description", "")
  backup_policy       = lookup(each.value, "backup_policy", "")
  disaster_recovery   = lookup(each.value, "disaster_recovery", "")
  notification_emails = lookup(each.value, "notification_emails", [])
  region              = lookup(each.value, "region", "")
  tags                = lookup(each.value, "tags", null)
  additional_tags     = lookup(each.value, "additional_tags", null)

  # Resource configuration
  resource_group_name       = module.resource_group[each.value.resource_group_key].name
  sku_name                  = each.value.sku_name
  high_availability_enabled = lookup(each.value, "high_availability_enabled", true)
  public_network_access     = lookup(each.value, "public_network_access", "Disabled")

  default_database = each.value.default_database

  managed_redis_identity = {
    type         = each.value.managed_redis_identity.type
    identity_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  # Customer-Managed Key. Opt-in: only set when the entry supplies a
  # `customer_managed_key` block in tfvars (otherwise null => service-managed).
  customer_managed_key = try(each.value.customer_managed_key, null) != null ? {
    key_vault_resource_id = data.azurerm_key_vault.cmk[each.value.customer_managed_key.key_vault_key].id
    key_name              = each.value.customer_managed_key.key_name
    key_version           = data.azurerm_key_vault_key.cmk[each.value.customer_managed_key.key_vault_key].version
    user_assigned_identity = {
      resource_id = module.user_managed_identities[each.value.umi_key].resource_id
    }
  } : null

  timeouts         = lookup(each.value, "timeouts", null)
  enable_telemetry = lookup(each.value, "enable_telemetry", true)

  depends_on = [module.resource_group, module.user_managed_identities, module.key_vault, time_sleep.rbac_wait_cmk]
}

# -----------------------------------------------------------------------------
# Managed Redis audit diagnostics (parity with dev-ai-latest ai_common).
# Redis audit logs are emitted by the Redis "default" database sub-resource, so
# the auditing diagnostic setting must target ".../databases/default" and is
# wired to the same central Log Analytics Workspace as the rest of the stack.
# -----------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "managed_redis_audit" {
  for_each = var.managed_redis_instances

  name                           = replace(each.key, "-redis-", "-diag-audit-redis-")
  target_resource_id             = "${module.managed_redis[each.key].resource_id}/databases/default"
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.central[0].id
  log_analytics_destination_type = "Dedicated"

  enabled_log {
    category = "ConnectionEvents"
  }
}

# =============================================================================
# Bing resource (Grounding Custom Search) - always Global location
# =============================================================================
module "bing_resource" {
  source   = "./modules/bing_resource/v1.0.0.0"
  for_each = {} # aea app workload NOT deployed (base infra/subnets/NSGs kept); re-enable with var.bing_accounts

  # Naming module required variables
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
  # NOTE: the bing module guards these tags with `!= ""` only (not `!= null`),
  # so a null leaks through as a null Azure tag (InvalidNullTagValue). Default to "".
  app_id             = lookup(each.value, "app_id", "")
  auto_delete        = lookup(each.value, "auto_delete", "")
  delete_after       = lookup(each.value, "delete_after", "")
  integration_id     = lookup(each.value, "integration_id", null)
  retention          = lookup(each.value, "retention", null)
  experiment_phase   = lookup(each.value, "experiment_phase", null)
  sandbox_type       = lookup(each.value, "sandbox_type", null)
  os                 = lookup(each.value, "os", null)
  patch_policy       = lookup(each.value, "patch_policy", null)
  maintenance_window = lookup(each.value, "maintenance_window", null)
  last_vm_accessed   = lookup(each.value, "last_vm_accessed", null)

  parent_id = module.resource_group[each.value.resource_group_key].resource_id

  # Module expects a map of accounts
  bing_accounts = {
    (each.key) = {
      sku_name           = each.value.sku_name
      kind               = each.value.kind
      location           = each.value.location
      statistics_enabled = lookup(each.value, "statistics_enabled", false)
      tags               = lookup(each.value, "tags", null)
    }
  }

  depends_on = [module.resource_group]
}

# =============================================================================
# Document Intelligence (Form Recognizer)
# =============================================================================
module "document_intelligence" {
  source   = "./modules/document_intelligence/v1.0.0.0"
  for_each = {} # aea/espi app workload NOT deployed (base infra kept); re-enable with var.document_intelligence

  # Naming module required variables
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

  resource_group_name = module.resource_group[each.value.resource_group_key].name

  kind     = each.value.kind
  sku_name = each.value.sku_name

  custom_subdomain_name      = lookup(each.value, "custom_subdomain_name", null)
  dynamic_throttling_enabled = lookup(each.value, "dynamic_throttling_enabled", null)

  # Customer-Managed Key. Opt-in: only set when the entry supplies a
  # `customer_managed_key` block in tfvars (otherwise null => service-managed).
  customer_managed_key = try(each.value.customer_managed_key, null) != null ? {
    key_vault_key_id   = data.azurerm_key_vault_key.cmk[each.value.customer_managed_key.key_vault_key].id
    identity_client_id = module.user_managed_identities[each.value.umi_key].client_id
  } : null

  identity = {
    type         = each.value.identity.type
    identity_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  local_auth_enabled                 = lookup(each.value, "local_auth_enabled", null)
  outbound_network_access_restricted = lookup(each.value, "outbound_network_access_restricted", null)
  public_network_access_enabled      = lookup(each.value, "public_network_access_enabled", null)
  storage                            = lookup(each.value, "storage", null)
  tags                               = lookup(each.value, "tags", null)

  depends_on = [module.resource_group, module.user_managed_identities, module.key_vault, time_sleep.rbac_wait_cmk]
}

# =============================================================================
# AI Search service. CMK enforcement disabled and CMK deferred to peering.
# =============================================================================
module "search_services" {
  source   = "./modules/ai_search/v1.0.0.1"
  for_each = var.search_services

  # Naming module required variables
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

  # name and location are set explicitly per entry (not derived from region_code)
  # so BOTH regional search services (Malaysia West + Southeast Asia) can be
  # deployed in a single run. region_code is globally rewritten by the workflow
  # to the one selected region, so the region is pinned here via name/location
  # instead, keeping the two services distinct.
  name                = each.value.name
  location            = each.value.location
  resource_group_name = module.resource_group[each.value.resource_group_key].name

  sku                           = each.value.sku
  public_network_access_enabled = each.value.public_network_access_enabled
  local_authentication_enabled  = each.value.local_authentication_enabled
  enable_telemetry              = lookup(each.value, "enable_telemetry", true)
  allowed_ips                   = lookup(each.value, "allowed_ips", null)
  replica_count                 = lookup(each.value, "replica_count", null)

  # Customer-Managed Key. Opt-in: enforcement + key are only set when the entry
  # supplies a `customer_managed_key` block in tfvars (otherwise disabled/null
  # => service-managed encryption).
  customer_managed_key_enforcement_enabled = try(each.value.customer_managed_key, null) != null ? try(each.value.customer_managed_key_enforcement_enabled, true) : false
  customer_managed_key = try(each.value.customer_managed_key, null) != null ? {
    key_vault_uri      = data.azurerm_key_vault.cmk[each.value.customer_managed_key.key_vault_key].vault_uri
    key_name           = data.azurerm_key_vault_key.cmk[each.value.customer_managed_key.key_vault_key].name
    key_version        = data.azurerm_key_vault_key.cmk[each.value.customer_managed_key.key_vault_key].version
    identity_client_id = module.user_managed_identities[each.value.umi_key].client_id
  } : null

  managed_identities = {
    system_assigned = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = each.value.umi_key != null ? [
      module.user_managed_identities[each.value.umi_key].resource_id
    ] : null
  }

  # NIC-only by default; private DNS wiring is opt-in via each endpoint's
  # `dns_zone_keys`. AI Search exposes a single "searchService" subresource, so
  # no subresource_name is required on each entry.
  private_endpoints = {
    for pe_key, pe_config in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name                          = pe_config.name
      subnet_resource_id            = module.identity_vnet[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
      network_interface_name        = lookup(pe_config, "network_interface_name", null)
      private_dns_zone_resource_ids = length(lookup(pe_config, "dns_zone_keys", [])) > 0 ? [for k in pe_config.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id] : lookup(pe_config, "private_dns_zone_resource_ids", [])
    }
  }
  diagnostic_settings = {}

  tags       = lookup(each.value, "tags", null)
  depends_on = [module.resource_group, module.user_managed_identities, module.identity_vnet, module.key_vault, time_sleep.rbac_wait_cmk]
}

# =============================================================================
# App Service Plans
# Hosting plans for the AEA web app (Standard) and the Flex Consumption
# function apps (FC1). os_type Linux, zone balancing disabled.
# =============================================================================
module "app_service_plans" {
  source   = "./modules/app_service_plan/v1.0.0.0"
  for_each = {} # aea/espi app workload NOT deployed (base infra kept); re-enable with var.app_service_plans

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

  resource_group_name    = module.resource_group[each.value.resource_group_key].name
  os_type                = each.value.os_type
  sku_name               = each.value.sku_name
  zone_balancing_enabled = each.value.zone_balancing_enabled

  tags       = lookup(each.value, "tags", null)
  depends_on = [module.resource_group]
}

# =============================================================================
# App Services (web apps)
# Plain Linux web-app shells (no container image / no app code). VNet
# integration into the dedicated web subnet; user-assigned identity attached.
# =============================================================================
module "app_services" {
  source   = "./modules/app_service/v1.0.0.2"
  for_each = {} # aea app workload NOT deployed (base infra kept); re-enable with var.app_services

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

  resource_group_name       = module.resource_group[each.value.resource_group_key].name
  service_plan_resource_id  = module.app_service_plans[each.value.service_plan_key].resource_id
  virtual_network_subnet_id = each.value.subnet_key != null ? module.identity_vnet[each.value.vnet_key].subnets[each.value.subnet_key].resource_id : null

  kind                       = each.value.kind
  os_type                    = each.value.os_type
  enable_telemetry           = lookup(each.value, "enable_telemetry", true)
  app_settings               = lookup(each.value, "app_settings", {})
  client_affinity_enabled    = lookup(each.value, "client_affinity_enabled", false)
  client_certificate_enabled = lookup(each.value, "client_certificate_enabled", false)
  client_certificate_mode    = lookup(each.value, "client_certificate_mode", "Required")
  enabled                    = lookup(each.value, "enabled", true)

  # Web app shells - no storage account wiring.
  storage_account_name          = null
  storage_account_access_key    = null
  storage_uses_managed_identity = false
  vnet_image_pull_enabled       = false

  managed_identities = {
    system_assigned            = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = each.value.umi_key != null ? [module.user_managed_identities[each.value.umi_key].resource_id] : []
  }

  site_config = each.value.site_config

  private_endpoints = {
    for pe_key, pe_config in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name                          = pe_config.name
      subnet_resource_id            = module.identity_vnet[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
      subresource_name              = pe_config.subresource_name
      network_interface_name        = lookup(pe_config, "network_interface_name", null)
      private_dns_zone_resource_ids = length(lookup(pe_config, "dns_zone_keys", [])) > 0 ? [for k in pe_config.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id] : lookup(pe_config, "private_dns_zone_resource_ids", [])
    }
  }

  diagnostic_settings = {}

  enable_application_insights = lookup(each.value, "enable_application_insights", false)
  application_insights        = lookup(each.value, "application_insights", {})
  connection_strings          = lookup(each.value, "connection_strings", {})

  tags = lookup(each.value, "tags", null)

  depends_on = [module.resource_group, module.app_service_plans, module.user_managed_identities]
}

# =============================================================================
# Function Apps (Flex Consumption / FC1)
# Linux Python flex-consumption function shells. Deployment container backed by
# the per-function storage account using user-assigned identity auth. App code
# is deployed out-of-band; this provisions infrastructure only.
# =============================================================================
module "function_app_flex" {
  source   = "./modules/app_service/v1.0.0.2"
  for_each = {} # aea/espi app workload NOT deployed (base infra kept); re-enable with var.function_app_flex

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
  app_support         = each.value.app_support
  type                = each.value.type

  # Optional Tags
  region               = lookup(each.value, "region", null)
  description          = lookup(each.value, "description", null)
  notification_emails  = lookup(each.value, "notification_emails", null)
  app_id               = lookup(each.value, "app_id", null)
  cost_allocation_unit = lookup(each.value, "cost_allocation_unit", null)

  resource_group_name       = module.resource_group[each.value.resource_group_key].name
  service_plan_resource_id  = module.app_service_plans[each.value.service_plan_key].resource_id
  virtual_network_subnet_id = module.identity_vnet[each.value.vnet_key].subnets[each.value.subnet_key].resource_id

  enable_telemetry            = lookup(each.value, "enable_telemetry", true)
  fc1_runtime_name            = each.value.fc1_runtime_name
  fc1_runtime_version         = each.value.fc1_runtime_version
  function_app_uses_fc1       = each.value.function_app_uses_fc1
  instance_memory_in_mb       = each.value.instance_memory_in_mb
  kind                        = each.value.kind
  enable_application_insights = each.value.enable_application_insights

  managed_identities = {
    system_assigned            = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  maximum_instance_count = each.value.maximum_instance_count
  os_type                = each.value.os_type

  storage_authentication_type       = each.value.storage_authentication_type
  storage_container_endpoint        = "${module.storage_accounts[each.value.storage_key].resource.primary_blob_endpoint}${element(split("/", module.storage_accounts[each.value.storage_key].containers[each.value.container_key].id), length(split("/", module.storage_accounts[each.value.storage_key].containers[each.value.container_key].id)) - 1)}"
  storage_container_type            = each.value.storage_container_type
  storage_user_assigned_identity_id = each.value.storage_authentication_type == "UserAssignedIdentity" ? module.user_managed_identities[each.value.umi_key].resource_id : null

  site_config = merge(each.value.site_config, {
    application_insights_connection_string = module.application_insights[each.value.app_insights_key].connection_string
    application_insights_key               = module.application_insights[each.value.app_insights_key].instrumentation_key
  })

  private_endpoints = {
    for pe_key, pe_config in lookup(each.value, "private_endpoints", {}) : pe_key => {
      name                          = pe_config.name
      subnet_resource_id            = module.identity_vnet[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
      subresource_name              = pe_config.subresource_name
      network_interface_name        = lookup(pe_config, "network_interface_name", null)
      private_dns_zone_resource_ids = length(lookup(pe_config, "dns_zone_keys", [])) > 0 ? [for k in pe_config.dns_zone_keys : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id] : lookup(pe_config, "private_dns_zone_resource_ids", [])
    }
  }

  diagnostic_settings = {}

  tags = lookup(each.value, "tags", null)

  depends_on = [module.resource_group, module.app_service_plans, module.storage_accounts, module.application_insights, module.user_managed_identities]
}

# =============================================================================
# Event Grid System Topics
# Each topic watches its source storage account for BlobCreated events and
# routes them to a storage queue using a user-assigned identity. The identity
# is first granted "Storage Queue Data Message Sender" on the source account,
# then a short wait lets the RBAC assignment propagate before the topic is
# created.
# =============================================================================
# Event Grid System Topic (BARE - no event subscriptions / no app-storage link),
# mirroring the Data pattern. Uses event_system_topic v1.0.0.1, which sets
# `source_arm_resource_id` (valid on azurerm < 4.37). The app-specific ESPI
# delivery + its role_assignments_egst RBAC are intentionally omitted.
module "eventgrid_system_topics" {
  source   = "./modules/event_system_topic/v1.0.0.1"
  for_each = var.eventgrid_system_topics

  depends_on = [
    module.storage_accounts
  ]

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

  eventgrid_system_topic_resource_group_name = module.resource_group[each.value.resource_group_key].name
  eventgrid_system_topic_type                = each.value.eventgrid_system_topic_type
  eventgrid_system_topic_source_resource_id  = module.storage_accounts[each.value.storage_account_key].resource_id

  eventgrid_system_topic_identity = {
    type         = each.value.eventgrid_system_topic_identity.type
    identity_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  # Bare topic: no event subscriptions (app-specific ESPI delivery removed).
  eventgrid_system_topic_event_subscriptions = {}
}

# =============================================================================
# Web Application Firewall policies + Application Gateways (HTTP-only)
# WAF_v2 private Application Gateways with NO public IP. TLS termination / SSL
# certificates are DEFERRED to the peering stage (no Key Vault certificate
# available yet), so the gateways are provisioned with HTTP (port 80) listeners
# only. The KV certificate role assignment / RBAC wait present in the reference
# stack are intentionally omitted.
# =============================================================================
module "waf_policies" {
  source   = "./modules/web_application_firewall/v1.0.0.0"
  for_each = { for k, v in var.waf_policies : k => v if length(regexall("aea|espi", k)) == 0 }

  depends_on = [module.resource_group]

  # Naming variables
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

  # Mandatory tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance

  # v1.0.0.0 specific tags
  app_name             = each.value.app_name
  type                 = each.value.type
  budget_id            = each.value.budget_id
  status               = each.value.status
  service              = each.value.service
  cost_allocation_unit = each.value.cost_allocation_unit
  compliance_required  = each.value.compliance_required

  # WAF Policy specific parameters
  name                = each.value.name
  resource_group_name = module.resource_group[each.value.resource_group_key].name
  location            = local.location_by_region_code[each.value.region_code]
  managed_rules       = each.value.managed_rules
  policy_settings     = each.value.policy_settings
  custom_rules        = lookup(each.value, "custom_rules", null)
}

module "app_gateways" {
  source   = "./modules/app_gateway/v1.0.0.0"
  for_each = { for k, v in var.app_gateways : k => v if length(regexall("aea|espi", k)) == 0 }

  depends_on = [module.resource_group, module.waf_policies, module.user_managed_identities]

  # Required variables
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

  # Mandatory tags
  environment         = each.value.environment
  business_owner      = each.value.business_owner
  business_unit       = each.value.business_unit
  criticality         = each.value.criticality
  cost_center         = each.value.cost_center
  data_classification = each.value.data_classification
  compliance          = each.value.compliance

  # Optional parameters
  region          = lookup(each.value, "region", null)
  description     = lookup(each.value, "description", null)
  additional_tags = lookup(each.value, "additional_tags", {})

  # v1.0.0.0 specific tags
  app_name            = each.value.app_name
  type                = each.value.type
  budget_id           = each.value.budget_id
  status              = each.value.status
  tier                = each.value.tier
  compliance_required = each.value.compliance_required

  # Application Gateway specific parameters
  resource_group_name = module.resource_group[each.value.resource_group_key].name

  # Private Application Gateway with WAF_v2 - NO public IP
  create_public_ip      = false
  public_ip_resource_id = null

  managed_identities = {
    system_assigned            = try(each.value.managed_identities.system_assigned, false)
    user_assigned_resource_ids = [module.user_managed_identities[each.value.umi_key].resource_id]
  }

  # Gateway configuration - dedicated AppGW subnet resolved from the VNet module.
  gateway_ip_configuration = {
    subnet_id = module.identity_vnet[each.value.vnet_key].subnets[each.value.subnet_key].resource_id
  }

  frontend_ip_configuration_private = each.value.frontend_ip_configuration_private
  frontend_ports                    = each.value.frontend_ports
  backend_address_pools             = each.value.backend_address_pools
  backend_http_settings             = each.value.backend_http_settings
  http_listeners                    = each.value.http_listeners
  request_routing_rules             = each.value.request_routing_rules
  url_path_map_configurations       = lookup(each.value, "url_path_map_configurations", {})

  sku = each.value.sku

  # WAF policy linkage (separate policy resource).
  app_gateway_waf_policy_resource_id = each.value.waf_policy_key != null ? module.waf_policies[each.value.waf_policy_key].resource_id : null
  waf_configuration                  = null

  autoscale_configuration = lookup(each.value, "autoscale_configuration", null)
  zones                   = lookup(each.value, "zones", null)
  http2_enable            = lookup(each.value, "http2_enable", true)
  probe_configurations    = lookup(each.value, "probe_configurations", {})

  # SSL certificates deferred (HTTP-only) - no Key Vault certificate yet.
  ssl_certificates = {}

  rewrite_rule_set    = lookup(each.value, "rewrite_rule_sets", {})
  diagnostic_settings = {}
}

# =============================================================================
# Standalone private endpoints (Document Intelligence accounts).
# The Document Intelligence module does not create its own private endpoint, so
# these are provisioned separately. Private DNS zone integration is DEFERRED
# (NIC-only) until peering, so private_dns_zone_resource_ids stays empty.
# =============================================================================
module "private_endpoints" {
  source = "./modules/private_endpoint/v1.0.0.1"
  # Exclude the aea/espi app private endpoints (their target resources - e.g.
  # document_intelligence - are the disabled app workloads). Platform PEs
  # (foundry/kv/storage/cosmos/redis/search) are unaffected.
  for_each = { for k, v in var.private_endpoints : k => v if length(regexall("aea|espi", k)) == 0 }

  depends_on = [module.resource_group, module.document_intelligence, module.managed_redis, module.identity_vnet]

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
  resource_group_name    = module.resource_group[each.value.resource_group_key].name
  network_interface_name = each.value.network_interface_name
  subnet_resource_id     = module.identity_vnet[each.value.vnet_key].subnets[each.value.subnet_key].resource_id

  # Resolve the target resource by prefix:
  #   "di:<key>"    -> Document Intelligence account
  #   "redis:<key>" -> Managed Redis instance
  # any other value is treated as a literal resource id.
  private_connection_resource_id = (
    startswith(each.value.private_connection_resource_ref, "di:") ?
    module.document_intelligence[split(":", each.value.private_connection_resource_ref)[1]].id :
    startswith(each.value.private_connection_resource_ref, "redis:") ?
    module.managed_redis[split(":", each.value.private_connection_resource_ref)[1]].resource_id :
    each.value.private_connection_resource_ref
  )

  subresource_names = each.value.subresource_names

  # Private DNS zone registration: when the entry supplies `dns_zone_keys`,
  # resolve them against the shared private DNS zones in the network
  # subscription and register the endpoint. Otherwise the endpoint stays
  # NIC-only (no zone group).
  private_dns_zone_group_name   = length(lookup(each.value, "dns_zone_keys", [])) > 0 ? "default" : null
  private_dns_zone_resource_ids = [for k in lookup(each.value, "dns_zone_keys", []) : data.azurerm_private_dns_zone.existing_private_dns_zones[k].id]
}

# =============================================================================
# Backup platform (Recovery Services Vault + Backup Vault).
# Mirrors the AI Landing Zone dev reference (dev-ai/ai_base_infra). Both vaults
# are CMK-encrypted via a User Managed Identity + a Key Vault key, and the
# Recovery Services Vault private endpoint registers into the shared
# `backup_azure` private DNS zone (peering is available, so DNS is wired, not
# deferred). All driven off var.recovery_service_vaults / var.backup_vaults;
# empty by default so the stack is unchanged until tfvars populate them.
# =============================================================================
module "recovery_service_vaults" {
  source = "./modules/recovery_service_vault/v1.0.0.0"

  for_each = var.recovery_service_vaults

  depends_on = [module.resource_group, module.key_vault, module.user_managed_identities]

  # Required variables
  resource_group_name = module.resource_group[each.value.resource_group_key].name
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
      subnet_resource_id     = module.identity_vnet[pe_config.vnet_key].subnets[pe_config.subnet_key].resource_id
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
  resource_group_name = module.resource_group[each.value.resource_group_key].name
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

  depends_on = [module.resource_group, module.key_vault, module.user_managed_identities]
}

# Backup Vault CMK is enabled out-of-band via azapi after the vault's managed
# identity has been granted the Key Vault crypto role. The wait must start only
# AFTER that grant exists (module.role_assignments_cmk), otherwise the timer can
# elapse before the role assignment is created/propagated and the CMK patch
# fails. So depend on the grant module (and its own propagation wait) here.
resource "time_sleep" "wait_for_backup_vault_cmk_rbac" {
  create_duration = "180s"
  depends_on = [
    module.backup_vaults,
    module.role_assignments_cmk,
    time_sleep.rbac_wait_cmk
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
    module.role_assignments_cmk,
    module.user_managed_identities,
    time_sleep.wait_for_backup_vault_cmk_rbac
  ]
}

