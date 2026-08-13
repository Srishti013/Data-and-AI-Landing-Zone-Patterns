locals {
  # Map all available subscriptions: display_name -> [subscription_id...]
  # (grouped to tolerate duplicate display names across tenants).
  subscription_map = {
    for sub in data.azurerm_subscriptions.available.subscriptions :
    sub.display_name => sub.subscription_id...
  }

  # Flatten to display_name -> first subscription_id.
  subscription_lookup = {
    for display_name, subscription_ids in local.subscription_map :
    display_name => subscription_ids[0]
  }

  # Resolve the platform (network / management) subscriptions referenced by the
  # aliased providers from their display names in var.subscriptions.
  filtered_subscriptions = {
    for key, value in var.subscriptions :
    key => {
      subscription_guid = local.subscription_lookup[value.subscription_name]
      subscription_id   = "/subscriptions/${local.subscription_lookup[value.subscription_name]}"
      subscription_name = value.subscription_name
    }
    if contains(keys(local.subscription_lookup), value.subscription_name)
  }

  # Region-code -> Azure location. Mirrors the AI landing-zone pattern so the
  # single stack can be deployed to either region by selecting it in the issue.
  location_by_region_code = {
    ea  = "eastasia"
    sea = "southeastasia"
    eu  = "eastus"
    myw = "malaysiawest"
    sg  = "southeastasia"
    idc = "indonesiacentral"
  }

  # Data-plane RBAC scope resolution for the consolidated role_assignments
  # block. Each scope_key resolves to a resource created earlier in THIS stack
  # (Key Vault / Storage / Data Factory / SQL Server), replacing the per-folder
  # data sources used by the standalone data_rbac root.
  resource_scope_map = merge(
    { for k, v in module.key_vault : k => v.resource_id },
    { for k, v in module.storage_accounts : k => v.resource_id },
    { for k, v in module.data_factories : k => v.resource_id },
    { for k, v in module.data_sql_server : k => v.resource_id },
  )

  # System-assigned principal ids of the Data Factories, keyed by tfvars key,
  # so RBAC can grant the ADF managed identity access to KV / Storage. Resolved
  # from a data source on the created ADF (identity[0].principal_id) - matches
  # the standalone data_rbac root's approach.
  system_assigned_principal_ids = {
    for key, adf in data.azurerm_data_factory.adf_system :
    key => try(adf.identity[0].principal_id, null)
  }
}
