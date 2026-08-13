#################################
####Naming Conventions
#################################
module "module_foundry" {
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
      ProductName    = "ms_foundry"
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


########################
##MS Foundry
########################
resource "azapi_resource" "ai_foundry" {
  for_each = var.ai_foundry_accounts != null ? var.ai_foundry_accounts : {}

  type                      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name                      = module.module_foundry.name
  parent_id                 = each.value.parent_id
  location                  = module.module_foundry.location
  schema_validation_enabled = false

  body = {
    kind = "AIServices"


    sku = {
      name = each.value.sku_name
    }

    identity = merge(
      {
        type = each.value.identity_type
      },
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], each.value.identity_type) ? {
        userAssignedIdentities = {
          (each.value.identity_id) = {}
        }
      } : {}
    )

    properties = merge(
      {
        disableLocalAuth       = each.value.disableLocalAuth
        allowProjectManagement = each.value.allowProjectManagement
        customSubDomainName    = each.value.customSubDomainName
        publicNetworkAccess    = each.value.publicNetworkAccess

        # Managed VNet - Network Injection
        restrictOutboundNetworkAccess = each.value.restrict_outbound_network_access
      },

      each.value.encryption != null ? {
        encryption = {
          keySource = each.value.encryption.key_source

          keyVaultProperties = {
            keyVaultUri      = each.value.encryption.key_vault_uri
            keyName          = each.value.encryption.key_name
            keyVersion       = each.value.encryption.key_version
            identityClientId = each.value.encryption.identity_client_id
          }
        }
      } : {},

      # VNet injection for Standard Agents - only include useMicrosoftManagedNetwork if true
      each.value.network_injections != null && length(each.value.network_injections) > 0 ? {
        networkInjections = [
          for ni in each.value.network_injections : merge(
            {
              scenario    = ni.scenario
              subnetArmId = ni.subnet_arm_id
            },
            ni.use_microsoft_managed_network == true ? {
              useMicrosoftManagedNetwork = true
            } : {}
          )
        ]
      } : {},
      length(each.value.allowed_fqdn_list) > 0 ? {
        allowedFqdnList = each.value.allowed_fqdn_list
      } : {},
      each.value.network_acls != null ? {
        networkAcls = {
          bypass        = each.value.network_acls.bypass
          defaultAction = each.value.network_acls.default_action
          ipRules = [
            for rule in each.value.network_acls.ip_rules : {
              value = rule
            }
          ]
          virtualNetworkRules = [
            for rule in each.value.network_acls.virtual_network_rules : {
              id                               = rule
              ignoreMissingVnetServiceEndpoint = true
            }
          ]
        }
      } : {},
      length(each.value.user_owned_storage) > 0 ? {
        userOwnedStorage = [
          for uos in each.value.user_owned_storage : merge(
            { resourceId = uos.resource_id },
            uos.identity_client_id != null ? { identityClientId = uos.identity_client_id } : {}
          )
        ]
      } : {}
    )
  }
}

#################################
##MS Foundry Project
#################################
resource "azapi_resource" "ai_foundry_project" {
  for_each = var.ai_foundry_projects != null ? var.ai_foundry_projects : {}

  type                      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name                      = each.value.name != null ? each.value.name : each.key
  parent_id                 = each.value.account_key != null ? azapi_resource.ai_foundry[each.value.account_key].id : each.value.parent_id
  location                  = module.module_foundry.location
  schema_validation_enabled = false

  body = {
    sku = {
      name = each.value.sku_name
    }


    properties = {
      displayName = each.value.displayName
      description = each.value.description

    }

    identity = merge(
      {
        type = each.value.identity_type
      },
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], each.value.identity_type) ? {
        userAssignedIdentities = {
          (each.value.identity_id) = {}
        }
      } : {}
    )
  }

  response_export_values = [
    "identity.principalId",
    "properties.internalId"
  ]
}

#################################
##MS Foundry Project - Diagnostic Settings
#################################
locals {
  # Flatten projects x their diagnostic settings into a single map keyed by
  # "<project_key>.<diag_key>" so each setting becomes a discrete resource.
  ai_foundry_project_diagnostic_settings = merge([
    for proj_key, proj in(var.ai_foundry_projects != null ? var.ai_foundry_projects : {}) : {
      for diag_key, diag in proj.diagnostic_settings :
      "${proj_key}.${diag_key}" => {
        project_key = proj_key
        setting     = diag
      }
    }
  ]...)
}

resource "azurerm_monitor_diagnostic_setting" "ai_foundry_project" {
  for_each = local.ai_foundry_project_diagnostic_settings

  name                           = each.value.setting.name != null ? each.value.setting.name : "diag-${each.value.project_key}"
  target_resource_id             = azapi_resource.ai_foundry_project[each.value.project_key].id
  log_analytics_workspace_id     = each.value.setting.workspace_resource_id
  log_analytics_destination_type = each.value.setting.workspace_resource_id != null ? each.value.setting.log_analytics_destination_type : null
  storage_account_id             = each.value.setting.storage_account_resource_id
  eventhub_authorization_rule_id = each.value.setting.event_hub_authorization_rule_resource_id
  eventhub_name                  = each.value.setting.event_hub_name
  partner_solution_id            = each.value.setting.marketplace_partner_resource_id

  # Log category groups (e.g. "allLogs", "audit")
  dynamic "enabled_log" {
    for_each = each.value.setting.log_groups

    content {
      category_group = enabled_log.value
    }
  }

  # Individual log categories (used when explicit categories are preferred)
  dynamic "enabled_log" {
    for_each = each.value.setting.log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = each.value.setting.metric_categories

    content {
      category = metric.value
    }
  }
}

###########################################
###Open AI Deployment Model
##########################################
resource "azapi_resource" "aifoundry_deployments" {
  for_each = var.ai_foundry_deployments != null ? var.ai_foundry_deployments : {}

  type                      = "Microsoft.CognitiveServices/accounts/deployments@2023-05-01"
  name                      = module.module_foundry.name
  parent_id                 = each.value.account_key != null ? azapi_resource.ai_foundry[each.value.account_key].id : each.value.parent_id
  schema_validation_enabled = false

  # Cognitive Services accounts serialize child-resource writes (deployments /
  # raiPolicies). When several deployments are created/updated in one apply the
  # account returns 409 RequestConflict ("Another operation is being performed
  # on the parent resource"). Retry with backoff so all deployments succeed in a
  # single apply instead of failing after the first one.
  retry = {
    error_message_regex  = ["RequestConflict", "Another operation is being performed", "Conflict"]
    interval_seconds     = 15
    max_interval_seconds = 120
  }

  body = {
    sku = {
      name     = each.value.sku_name
      capacity = each.value.capacity
    }

    properties = merge(
      {
        model = {
          format  = each.value.model_format
          name    = each.value.model_name
          version = each.value.model_version
        }
      },
      each.value.rai_policy_name != null ? {
        raiPolicyName = each.value.rai_policy_name
      } : {}
    )
  }
}

########################################
##RAI Policy
#######################################
# Managed via azapi (not azurerm) so that advanced content filters which have
# no severity threshold (Jailbreak, Indirect Attack, Protected Material Code/Text,
# Profanity, Spotlighting) can be expressed. azurerm_cognitive_account_rai_policy
# requires severity_threshold on every filter and therefore cannot model them.
resource "azapi_resource" "project_rai_policy" {
  for_each = var.ai_foundry_rai_policy != null ? var.ai_foundry_rai_policy : {}

  type                      = "Microsoft.CognitiveServices/accounts/raiPolicies@${try(each.value.api_version, "2024-10-01")}"
  name                      = module.module_foundry.name
  parent_id                 = each.value.account_key != null ? azapi_resource.ai_foundry[each.value.account_key].id : each.value.cognitive_account_id
  schema_validation_enabled = false

  body = {
    properties = {
      basePolicyName = each.value.base_policy_name
      mode           = try(each.value.mode, "Default")
      contentFilters = [
        for cf in try(each.value.content_filters, []) : merge(
          {
            name     = cf.name
            source   = cf.source
            enabled  = try(cf.filter_enabled, true)
            blocking = try(cf.block_enabled, true)
          },
          # severityThreshold is only valid for the four harm categories
          # (Hate/Sexual/Selfharm/Violence). Advanced filters must omit it.
          try(cf.severity_threshold, null) != null ? {
            severityThreshold = cf.severity_threshold
          } : {}
        )
      ]
    }
  }

  # Cognitive Services serializes child-resource writes; retry on the account
  # busy conflict so the policy applies in the same run as the deployments.
  retry = {
    error_message_regex  = ["RequestConflict", "Another operation is being performed", "Conflict"]
    interval_seconds     = 15
    max_interval_seconds = 120
  }

  depends_on = [
    azapi_resource.ai_foundry
  ]
}

########################################
## AI Foundry Project Connections
## (Cosmos DB, AI Search, Storage, etc.)
########################################
resource "azapi_resource" "ai_foundry_project_connection" {
  for_each = var.ai_foundry_project_connections != null ? var.ai_foundry_project_connections : {}

  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name                      = each.value.name
  parent_id                 = each.value.project_key != null ? azapi_resource.ai_foundry_project[each.value.project_key].id : each.value.parent_id
  schema_validation_enabled = false

  body = {
    properties = merge(
      {
        category = each.value.category
        target   = each.value.target
        authType = each.value.auth_type
      },
      each.value.auth_type == "ApiKey" && each.value.credentials_key != null ? {
        credentials = { key = each.value.credentials_key }
      } : {},
      each.value.auth_type == "AccountKey" && each.value.credentials_key != null ? {
        credentials = { accountKey = each.value.credentials_key }
      } : {},
      length(each.value.metadata) > 0 ? {
        metadata = each.value.metadata
      } : {}
    )
  }

  depends_on = [
    azapi_resource.ai_foundry_project
  ]
}

########################################
## Private Endpoint for AI Foundry Account
########################################
resource "azurerm_private_endpoint" "ai_foundry" {
  count = var.private_endpoint_config != null ? 1 : 0

  name                = var.private_endpoint_config.name
  location            = var.private_endpoint_config.location
  resource_group_name = var.private_endpoint_config.resource_group_name
  subnet_id           = var.private_endpoint_config.subnet_id
  tags                = module.module_foundry.tags

  private_service_connection {
    name                           = "${var.private_endpoint_config.name}-psc"
    private_connection_resource_id = azapi_resource.ai_foundry[var.private_endpoint_config.account_key].id
    is_manual_connection           = false
    subresource_names              = var.private_endpoint_config.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_endpoint_config.dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "ai-foundry-dns-zone-group"
      private_dns_zone_ids = var.private_endpoint_config.dns_zone_ids
    }
  }

  depends_on = [azapi_resource.ai_foundry]
}

########################################
## Account-Level Connections
## (Shared to all projects via isSharedToAll)
## For Standard Agent: Storage, Search, Cosmos
########################################
resource "azapi_resource" "account_connection" {
  for_each = var.account_connections != null ? var.account_connections : {}

  type                      = "Microsoft.CognitiveServices/accounts/connections@2025-06-01"
  name                      = each.value.name != null ? each.value.name : each.key
  parent_id                 = azapi_resource.ai_foundry[each.value.account_key].id
  schema_validation_enabled = false

  body = {
    properties = merge(
      {
        category      = each.value.category
        target        = each.value.target
        authType      = each.value.auth_type
        isSharedToAll = each.value.is_shared
      },
      length(each.value.credentials) > 0 ? {
        credentials = each.value.credentials
      } : {},
      length(each.value.metadata) > 0 ? {
        metadata = each.value.metadata
      } : {}
    )
  }

  depends_on = [azapi_resource.ai_foundry_project]
}

########################################
## Role Assignments
## (Account identity → Storage, Search, Cosmos)
########################################
resource "azurerm_role_assignment" "foundry_account" {
  for_each = var.role_assignments != null ? var.role_assignments : {}

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  description          = try(each.value.description, "")
}

########################################
## Cosmos DB SQL Role Assignments
## (Account identity - data plane access)
########################################
resource "azurerm_cosmosdb_sql_role_assignment" "foundry_account" {
  for_each = var.cosmos_role_assignments != null ? var.cosmos_role_assignments : {}

  resource_group_name = each.value.resource_group_name
  account_name        = each.value.cosmos_account_name
  role_definition_id  = each.value.role_definition_id
  principal_id        = each.value.principal_id
  scope               = each.value.scope
}

########################################
## Wait for Role Assignments to propagate
########################################
resource "time_sleep" "wait_for_rbac" {
  count = length(var.role_assignments) > 0 || length(var.cosmos_role_assignments) > 0 ? 1 : 0

  depends_on = [
    azurerm_role_assignment.foundry_account,
    azurerm_cosmosdb_sql_role_assignment.foundry_account,
    azurerm_private_endpoint.ai_foundry
  ]
  create_duration = var.wait_after_role_assignments
}

########################################
## Project Role Assignments
## (Project identity → Storage, Search, Cosmos
##  BEFORE capability host creation)
########################################
resource "azurerm_role_assignment" "project" {
  for_each = var.project_role_assignments != null ? var.project_role_assignments : {}

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  description          = try(each.value.description, "")
}

########################################
## Wait for Project Role Assignments
########################################
resource "time_sleep" "wait_for_project_rbac" {
  count = length(var.project_role_assignments) > 0 ? 1 : 0

  depends_on = [
    azurerm_role_assignment.project,
  ]
  create_duration = var.wait_after_role_assignments
}

########################################
## Account-Level Capability Host
## (Sets up Agent runtime subnet)
########################################
resource "azapi_resource" "account_capability_host" {
  for_each = var.account_capability_hosts != null ? var.account_capability_hosts : {}

  type                      = "Microsoft.CognitiveServices/accounts/capabilityHosts@2025-04-01-preview"
  name                      = each.value.name
  parent_id                 = azapi_resource.ai_foundry[each.value.account_key].id
  schema_validation_enabled = false

  body = {
    properties = {
      capabilityHostKind = each.value.capability_host_kind
      customerSubnet     = each.value.subnet_id
    }
  }

  depends_on = [
    azapi_resource.account_connection,
    azapi_resource.ai_foundry_project,
    time_sleep.wait_for_rbac,
    time_sleep.wait_for_project_rbac
  ]
}

########################################
## Wait for Account Capability Host
## (When networkInjections is set, Azure auto-creates
##  the "default" account CH. This wait ensures it's
##  ready before project CH creation.)
########################################
resource "time_sleep" "wait_for_account_capability_host" {
  count = length(var.account_capability_hosts) == 0 && length(var.project_capability_hosts) > 0 ? 1 : 0

  depends_on = [
    azapi_resource.ai_foundry,
    azapi_resource.account_connection,
    time_sleep.wait_for_rbac,
    time_sleep.wait_for_project_rbac
  ]
  create_duration = var.wait_after_account_creation
}

########################################
## Project-Level Capability Host
## (Enables Standard Agent on each project)
########################################
resource "azapi_resource" "project_capability_host" {
  for_each = var.project_capability_hosts != null ? var.project_capability_hosts : {}

  type                      = "Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview"
  name                      = each.value.name
  parent_id                 = azapi_resource.ai_foundry_project[each.value.project_key].id
  schema_validation_enabled = false

  body = {
    properties = {
      capabilityHostKind       = each.value.capability_host_kind
      storageConnections       = each.value.storage_connections
      vectorStoreConnections   = each.value.vector_store_connections
      threadStorageConnections = each.value.thread_storage_connections
    }
  }

  timeouts {
    create = "45m"
    delete = "30m"
  }

  depends_on = [
    azapi_resource.account_capability_host,
    azapi_resource.account_connection,
    time_sleep.wait_for_rbac,
    time_sleep.wait_for_project_rbac,
    time_sleep.wait_for_account_capability_host
  ]
}

########################################
## Post Capability Host Role Assignments
## 1. Cosmos DB SQL Data Contributor
##    (data plane for thread storage)
## 2. Storage Blob Data Owner with ABAC
##    (scoped to project agent containers)
########################################
locals {
  # Convert project internalId to GUID format for ABAC condition
  project_id_guids = {
    for k, v in azapi_resource.ai_foundry_project : k =>
    try(
      "${substr(v.output.properties.internalId, 0, 8)}-${substr(v.output.properties.internalId, 8, 4)}-${substr(v.output.properties.internalId, 12, 4)}-${substr(v.output.properties.internalId, 16, 4)}-${substr(v.output.properties.internalId, 20, 12)}",
      ""
    )
  }
}

resource "azurerm_cosmosdb_sql_role_assignment" "project_post_ch" {
  for_each = var.project_cosmos_role_assignments != null ? var.project_cosmos_role_assignments : {}

  resource_group_name = each.value.resource_group_name
  account_name        = each.value.cosmos_account_name
  role_definition_id  = each.value.role_definition_id
  principal_id        = each.value.principal_id
  scope               = each.value.scope

  depends_on = [azapi_resource.project_capability_host]
}

resource "azurerm_role_assignment" "project_storage_blob_data_owner" {
  for_each = var.post_ch_storage_role_assignments != null ? var.post_ch_storage_role_assignments : {}

  scope                = each.value.scope
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = each.value.principal_id
  description          = "Project identity access to agent storage containers (post capability host)"
  condition_version    = "2.0"
  condition            = <<-EOT
  (
    (
      !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/read'})
      AND
      !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/filter/action'})
      AND
      !(ActionMatches{'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/tags/write'})
    )
    OR
    (
      @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringStartsWithIgnoreCase '${local.project_id_guids[each.value.project_key]}'
      AND
      @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringLikeIgnoreCase '*-azureml-agent'
    )
  )
  EOT

  depends_on = [azapi_resource.project_capability_host]
}
