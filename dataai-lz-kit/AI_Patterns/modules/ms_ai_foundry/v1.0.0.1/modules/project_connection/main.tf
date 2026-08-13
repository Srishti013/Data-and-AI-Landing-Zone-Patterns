
########################################
## AI Foundry Project Connections
## (Cosmos DB, AI Search, Storage, etc.)
########################################
resource "azapi_resource" "ai_foundry_project_connection" {
  for_each = var.ai_foundry_project_connections != null ? var.ai_foundry_project_connections : {}

  type                      = "Microsoft.CognitiveServices/accounts/projects/connections@2025-06-01"
  name                      = each.value.name
  parent_id                 = each.value.project_key != null ? var.project_ids[each.value.project_key] : each.value.parent_id
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
}
