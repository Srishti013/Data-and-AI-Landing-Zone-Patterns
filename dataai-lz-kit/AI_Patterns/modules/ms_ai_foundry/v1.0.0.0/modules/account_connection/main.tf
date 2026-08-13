
########################################
## Account-Level Connections
## (Shared to all projects via isSharedToAll)
## For Standard Agent: Storage, Search, Cosmos
########################################
resource "azapi_resource" "account_connection" {
  for_each = var.account_connections != null ? var.account_connections : {}

  type                      = "Microsoft.CognitiveServices/accounts/connections@2025-06-01"
  name                      = each.value.name != null ? each.value.name : each.key
  parent_id                 = var.account_ids[each.value.account_key]
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
}

