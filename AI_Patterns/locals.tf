locals {
  # Azure location resolved from the issue-injected region_code (same mapping the
  # workflow uses: "Southeast Asia"->sea, "Malaysia West"->myw). Used where a raw
  # azurerm `location` string is required (e.g. private endpoints) instead of the
  # naming-module-derived location the MBB modules compute internally.
  location_by_region_code = {
    ea  = "eastasia"
    sea = "southeastasia"
    eu  = "eastus"
    myw = "malaysiawest"
    sg  = "southeastasia"
    idc = "indonesiacentral"
  }

  # Map all accessible subscriptions: display_name => subscription_id.
  # Group by display_name first (the tenant can contain several subscriptions
  # that share the same display name) and keep the first id for each name so
  # the comprehension never produces a duplicate-key error.
  subscription_map = {
    for name, ids in {
      for sub in data.azurerm_subscriptions.available.subscriptions :
      sub.display_name => sub.subscription_id...
    } : name => ids[0]
  }

  # Resolve the subscription id of the central Log Analytics Workspace from the
  # "law_sub" entry in var.subscriptions. Falls back to the deployment
  # subscription when not provided.
  law_subscription_name = try(var.subscriptions["law_sub"].subscription_name, null)
  law_subscription_id   = local.law_subscription_name != null ? lookup(local.subscription_map, local.law_subscription_name, var.subscription_id) : var.subscription_id

  # Resolve the subscription id of the platform network subscription (hub VNet +
  # shared private DNS zones) from the "network_sub" entry in var.subscriptions,
  # using the same display-name => id lookup as the LAW subscription. Falls back
  # to the deployment subscription when not provided so single-subscription
  # runs keep working.
  network_subscription_name = try(var.subscriptions["network_sub"].subscription_name, null)
  network_subscription_id   = local.network_subscription_name != null ? lookup(local.subscription_map, local.network_subscription_name, var.subscription_id) : var.subscription_id

  # Responsible-AI content filters applied to every AI Foundry RAI policy.
  # Field shape matches the ms_foundry `ai_foundry_rai_policy.content_filters`
  # object type exactly (name, source, severity_threshold + optional flags).
  # Content filters MUST match the Microsoft.DefaultV2 base policy (required by
  # gpt-5.x). Mirrors ex/dev-ai exactly: the four severity categories PLUS the
  # binary DefaultV2 filters (Profanity, Prompt Shields / Jailbreak + Indirect
  # Attack, Protected Material Text/Code). Missing any of these makes gpt-5.1
  # fail with "Failed to validate policies for model gpt-5.1/2025-11-13".
  # NOTE: category name is "Selfharm" (not "SelfHarm").
  rai_content_filters = [
    { name = "Hate", source = "Prompt", severity_threshold = "High" },
    { name = "Hate", source = "Completion", severity_threshold = "High" },
    { name = "Sexual", source = "Prompt", severity_threshold = "High" },
    { name = "Sexual", source = "Completion", severity_threshold = "High" },
    { name = "Violence", source = "Prompt", severity_threshold = "High" },
    { name = "Violence", source = "Completion", severity_threshold = "High" },
    { name = "Selfharm", source = "Prompt", severity_threshold = "High" },
    { name = "Selfharm", source = "Completion", severity_threshold = "High" },

    # Binary filters required by Microsoft.DefaultV2 (no severity_threshold).
    { name = "Profanity", source = "Prompt", filter_enabled = true, block_enabled = true },
    { name = "Profanity", source = "Completion", filter_enabled = true, block_enabled = true },
    { name = "Jailbreak", source = "Prompt", filter_enabled = true, block_enabled = true },
    { name = "Indirect Attack", source = "Prompt", filter_enabled = true, block_enabled = true },
    { name = "Indirect Attack Spotlighting", source = "Prompt", filter_enabled = true, block_enabled = true },
    { name = "Protected Material Text", source = "Completion", filter_enabled = true, block_enabled = true },
    { name = "Protected Material Code", source = "Completion", filter_enabled = true, block_enabled = true },
  ]

  # Cosmos DB CMK PATCH inputs - keyed by cosmos account, only includes accounts
  # that declare a `customer_managed_key` block in tfvars. Empty (no PATCH) by
  # default. Cosmos CMK cannot be set through the module, so it is enabled via a
  # two-step ARM PATCH (defaultIdentity, then keyVaultKeyUri); see the
  # azapi_resource_action resources in main.tf. The key uri is versionless so
  # Azure auto-rotates to the latest key version.
  cosmos_cmk_patch = {
    for k, v in var.cosmosdb_accounts : k => {
      cosmos_id = module.cosmosdb[k].id
      key_uri = format(
        "https://%s.vault.azure.net/keys/%s",
        var.key_vault_keys[v.customer_managed_key.key_vault_key].key_vault_name,
        var.key_vault_keys[v.customer_managed_key.key_vault_key].name,
      )
      umi_id = module.user_managed_identities[v.umi_key].resource_id
    }
    if try(v.customer_managed_key, null) != null
  }
}