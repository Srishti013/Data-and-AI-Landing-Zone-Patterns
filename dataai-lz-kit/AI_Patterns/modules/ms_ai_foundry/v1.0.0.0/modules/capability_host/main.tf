########################################
## Account-Level Capability Host
## (Sets up Agent runtime subnet)
########################################
resource "azapi_resource" "account_capability_host" {
  for_each = var.account_capability_hosts != null ? var.account_capability_hosts : {}

  type                      = "Microsoft.CognitiveServices/accounts/capabilityHosts@2025-04-01-preview"
  name                      = each.value.name
  parent_id                 = var.account_ids[each.value.account_key]
  schema_validation_enabled = false

  body = {
    properties = {
      capabilityHostKind = each.value.capability_host_kind
      customerSubnet     = each.value.subnet_id
    }
  }
}

########################################
## Wait for Account Capability Host
## (When networkInjections is set, Azure auto-creates
##  the "default" account CH. This wait ensures it's
##  ready before project CH creation.)
########################################
resource "time_sleep" "wait_for_account_capability_host" {
  count = length(var.account_capability_hosts) == 0 && length(var.project_capability_hosts) > 0 ? 1 : 0

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
  parent_id                 = each.value.project_key != null ? var.project_ids[each.value.project_key] : each.value.parent_id
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
    for k, v in var.project_internal_ids : k =>
    try(
      "${substr(v, 0, 8)}-${substr(v, 8, 4)}-${substr(v, 12, 4)}-${substr(v, 16, 4)}-${substr(v, 20, 12)}",
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
