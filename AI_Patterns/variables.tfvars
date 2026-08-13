subscription_id = ""

# Related subscriptions referenced by this pattern. The central Log Analytics
# Workspace lives in the management subscription (law_sub).
subscriptions = {
  law_sub = {
    subscription_name = "{org}-plt-sub-mgmt-prd-{region_code}-01"
  }
  # Platform network subscription that owns the hub VNet + shared private DNS
  # zones (resolved by display name). Required for hub peering + DNS wiring.
  network_sub = {
    subscription_name = "{org}-plt-sub-network-prd-{region_code}-01"
  }
}

# Existing central Log Analytics Workspace that Application Insights connects to.
# Region-agnostic: the platform LAW is always prod ("pd"/"prd"), region-tokenized.
log_analytics_workspace_name    = "{org}-law-ops-pd-{region_code}-01"
log_analytics_workspace_rg_name = "{org}-rg-mgmt-pd-{region_code}-01"

# ---------------------------------------------------------------------------
# Hub network peering + shared private DNS zones (ACTIVE).
# The hub is the region's platform private-firewall VNet (region-tokenized):
# for SEA it resolves to the SEA firewall defined in Singapore/network. Only
# zones confirmed to exist in the hub RG are referenced below.
# ---------------------------------------------------------------------------
hub_virtual_networks = {
  "hub" = {
    name                = "{org}-vnet-pvt-network-pd-{region_code}-01"
    resource_group_name = "{org}-rg-private-network-pd-{region_code}-01"
  }
}

existing_private_dns_zones_rg_name = "{org}-rg-private-network-pd-{region_code}-01"

existing_private_dns_zones = {
  "vault_core"         = { name = "privatelink.vaultcore.azure.net" }
  "storage_blob"       = { name = "privatelink.blob.core.windows.net" }
  "cognitive_services" = { name = "privatelink.cognitiveservices.azure.com" }
  "openai"             = { name = "privatelink.openai.azure.com" }
  "ai_services"        = { name = "privatelink.services.ai.azure.com" }
  "azure_cr"           = { name = "privatelink.azurecr.io" }
  "cosmos_sql"         = { name = "privatelink.documents.azure.com" }
  "redis"              = { name = "privatelink.redis.azure.net" }
  "backup_azure"       = { name = "privatelink.{region_code}.backup.windowsazure.com" }
}

# ---------------------------------------------------------------------------
# Reference: original opt-in guidance for the hub peering + DNS scaffolding.
# ---------------------------------------------------------------------------
# Hub network peering + shared private DNS zones (OPT-IN, currently inactive).
#
# Everything below is dormant until uncommented: the `azurerm.network` provider
# falls back to the deployment subscription, hub_virtual_networks /
# existing_private_dns_zones default to {} (no data-source reads), and private
# endpoints stay NIC-only. Uncomment and fill in to bring the Data & AI pattern
# to AI Landing Zone parity (cross-subscription peering to the platform hub VNet
# + private DNS registration for the private endpoints).
#
# PREREQUISITES before activating (cannot be satisfied in Terraform alone):
#   1. The pipeline service principal needs Network Contributor on BOTH this
#      spoke VNet and the hub VNet `{org}-vnet-pvt-network-pd-{region_code}-01`
#      (in `{org}-plt-sub-network-prd-{region_code}-01`) for the peering + the
#      in-code reverse peering.
#   2. The SPN needs read on `{org}-rg-private-network-pd-{region_code}-01` and
#      Private DNS Zone Contributor to register the private endpoint A-records.
#   3. Confirm each private DNS zone below actually exists in that hub RG for
#      the target region before referencing it from a `dns_zone_keys`.
#
# Usage - register a private endpoint into a zone by adding `dns_zone_keys` to
# that endpoint entry in the resource blocks below, e.g. a Key Vault PE:
#   "pe" = {
#     name          = "{org}-pe-kv-aishared-{env}-{region_code}-{iterator}"
#     vnet_key      = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
#     subnet_key    = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
#     dns_zone_keys = ["vault_core"]
#   }
# ---------------------------------------------------------------------------

# # Add this entry inside the `subscriptions` map above to point the network
# # provider at the platform network subscription (resolved by display name):
# #   network_sub = {
# #     subscription_name = "{org}-plt-sub-network-prd-{region_code}-01"
# #   }

# # Hub VNet(s) this spoke peers to. A VNet peering's `hub_key` refers to a key
# # in this map.
# hub_virtual_networks = {
#   "hub" = {
#     name                = "{org}-vnet-pvt-network-pd-{region_code}-01"
#     resource_group_name = "{org}-rg-private-network-pd-{region_code}-01"
#   }
# }

# # Resource group (in the network subscription) that holds the shared private
# # DNS zones.
# existing_private_dns_zones_rg_name = "{org}-rg-private-network-pd-{region_code}-01"

# # Shared private DNS zones to register private endpoints into. Reference these
# # keys from a private endpoint's `dns_zone_keys`. Only include zones confirmed
# # to exist in the hub RG for the target region.
# existing_private_dns_zones = {
#   "vault_core"         = { name = "privatelink.vaultcore.azure.net" }
#   "storage_blob"       = { name = "privatelink.blob.core.windows.net" }
#   "storage_dfs"        = { name = "privatelink.dfs.core.windows.net" }
#   "storage_file"       = { name = "privatelink.file.core.windows.net" }
#   "storage_queue"      = { name = "privatelink.queue.core.windows.net" }
#   "storage_table"      = { name = "privatelink.table.core.windows.net" }
#   "cognitive_services" = { name = "privatelink.cognitiveservices.azure.com" }
#   "openai"             = { name = "privatelink.openai.azure.com" }
#   "ai_services"        = { name = "privatelink.services.ai.azure.com" }
#   "azure_cr"           = { name = "privatelink.azurecr.io" }
#   "search"             = { name = "privatelink.search.windows.net" }
#   "cosmos_sql"         = { name = "privatelink.documents.azure.com" }
#   "redis"              = { name = "privatelink.redis.cache.windows.net" }
#   "sites"              = { name = "privatelink.azurewebsites.net" }
# }

# ---------------------------------------------------------------------------
# Customer-Managed Key (CMK) encryption (OPT-IN, currently inactive).
#
# Everything below is dormant until uncommented: key_vault_keys and
# role_assignments_config_cmk default to {} (no Key Vault keys, no CMK RBAC,
# no rbac wait), and every resource's customer_managed_key / encryption block
# stays null (service-managed encryption), preserving current behaviour.
#
# Activation steps (all gated on these tfvars - no code change needed):
#   1. Add a `keys` map to the relevant entry in `key_vaults` below so the
#      Key Vault module creates the CMK key, e.g.:
#        keys = {
#          "cmk" = { name = "{org}-key-aishared-{env}-{region_code}-{iterator}", key_type = "RSA", key_size = 2048 }
#        }
#   2. Declare a User Managed Identity in `user_managed_identities` to be the
#      CMK identity (or reuse an existing one).
#   3. Add `key_vault_keys` (read by the AI Search / Redis / SQL TDE / Document
#      Intelligence / Cosmos / AI Foundry CMK blocks via data sources):
#        key_vault_keys = {
#          "cmk" = {
#            name                = "{org}-key-aishared-{env}-{region_code}-{iterator}"
#            key_vault_name      = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
#            resource_group_name = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
#          }
#        }
#   4. Grant the UMI the crypto role on the Key Vault via
#      `role_assignments_config_cmk` (scope_key = a `key_vaults` map key):
#        role_assignments_config_cmk = {
#          "cmk" = {
#            umi_key              = "{org}-id-aishared-{env}-{region_code}-{iterator}"
#            scope_key            = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
#            role_definition_name = "Key Vault Crypto Service Encryption User"
#          }
#        }
#   5. Add the per-resource CMK block to each resource entry that should be
#      encrypted with the CMK. `key_vault_key` / `tde_key_name` reference a
#      key in `key_vault_keys`; `umi_key` references `user_managed_identities`:
#        # Storage / ACR (key_vault_key resolves the Key Vault; key_name is the
#        # literal key name; key_version null => latest, auto-rotates):
#        customer_managed_key = {
#          key_vault_key             = "cmk"
#          key_name                  = "{org}-key-aishared-{env}-{region_code}-{iterator}"
#          user_assigned_identity_ref = "{org}-id-aishared-{env}-{region_code}-{iterator}"
#        }
#        # AI Search / Document Intelligence / Managed Redis (umi_key on the
#        # resource entry supplies the identity):
#        customer_managed_key = { key_vault_key = "cmk" }
#        # SQL Server TDE - set on the sql_servers entry (no block):
#        tde_key_name = "cmk"
#        # AI Foundry account - on the ai_foundry_accounts entry:
#        encryption = { key_vault_key = "cmk", umi_key = "{org}-id-aishared-{env}-{region_code}-{iterator}" }
#        # Cosmos DB - on the cosmosdb_accounts entry (umi_key already present):
#        customer_managed_key = { key_vault_key = "cmk" }
#
# PREREQUISITES before activating (cannot be satisfied in Terraform alone):
#   - The Key Vault must be reachable from the runner at key-creation time. The
#     module creates keys via the AzureServices bypass; if the Key Vault is
#     locked down, ensure the bypass / network_acls allow the create.
#   - The pipeline service principal needs Key Vault Crypto Officer (or Key
#     Vault Administrator) on the Key Vault to create the key material.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Customer-Managed Keys (CMK) - ACTIVE. All CMK keys are housed in the AI
# Shared Key Vault; each consuming resource references a logical key below.
# ---------------------------------------------------------------------------
key_vault_keys = {
  "sa-aishared-kv" = {
    name                = "{org}-cmk-sa-aishared-{env}-{region_code}-{iterator}"
    key_vault_name      = "{org}kvaishared{env}{region_code}{iterator}"
    resource_group_name = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
  }
  "sa-aifoundry-kv" = {
    name                = "{org}-cmk-sa-aifoundry-{env}-{region_code}-{iterator}"
    key_vault_name      = "{org}kvaishared{env}{region_code}{iterator}"
    resource_group_name = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
  }
  # AI Foundry ACCOUNT CMK - housed in the DEDICATED AI Foundry Key Vault
  # ({org}-kv-aifoundry), matching ex/dev-ai-latest (its account encryption.
  # key_vault_key = {org}-kv-aifoundry / cmk_key = {org}-cmk-aif-aifoundry). Kept
  # SEPARATE from the shared KV so the Foundry account's CMK setup is byte-parity
  # with the working MYW reference.
  "aif-aifoundry-kv" = {
    name                = "{org}-cmk-aif-aifoundry-{env}-{region_code}-{iterator}"
    key_vault_name      = "{org}kvaifoundry{env}{region_code}{iterator}"
    resource_group_name = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
  }
  "cosmos-aicommon-kv" = {
    name                = "{org}-cmk-cosmos-aicommon-{env}-{region_code}-{iterator}"
    key_vault_name      = "{org}kvaishared{env}{region_code}{iterator}"
    resource_group_name = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
  }
  "redis-aicommon-kv" = {
    name                = "{org}-cmk-redis-aicommon-{env}-{region_code}-{iterator}"
    key_vault_name      = "{org}kvaishared{env}{region_code}{iterator}"
    resource_group_name = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
  }
  "acr-aishared-kv" = {
    name                = "{org}-cmk-cr-aishared-{env}-{region_code}-{iterator}"
    key_vault_name      = "{org}kvaishared{env}{region_code}{iterator}"
    resource_group_name = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
  }
}

# Grant each consuming UMI the crypto role on the AI Shared Key Vault so the
# service can wrap/unwrap the CMK. scope_key is a `key_vaults` map key.
role_assignments_config_cmk = {
  "cmk-sa-aishared" = {
    umi_key              = "{org}-id-sa-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
  "cmk-sa-aifoundry" = {
    umi_key              = "{org}-id-sa-aifoundry-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
  # AI Foundry account UMI needs the crypto role on the DEDICATED Foundry KV
  # ({org}-kv-aifoundry) that now holds the account CMK key (parity move).
  "cmk-aif-aifoundry" = {
    umi_key              = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aifoundry-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
  # REQUIRED for gpt-5.1 / Foundry-agent content-safety validation on a
  # CMK-encrypted account: the account UMI must ALSO have "Key Vault Crypto User"
  # (broad key data-plane: encrypt/decrypt/sign/wrap/unwrap/get) on the CMK KV,
  # NOT just "Crypto Service Encryption User" (at-rest wrap/unwrap only). The
  # account CREATES + encrypts fine with the Encryption-User role, but the
  # gpt-5.1 model-deployment validation path performs a key data-plane operation
  # that needs Crypto User -> without it the deployment fails 400 "Failed to
  # validate policies for model gpt-5.1/2025-11-13". dev-ai-latest ai_rbac grants
  # BOTH roles to {org}-id-aif-aifoundry on the Foundry KV (comment there: "Required
  # for Foundry agent creation when the account uses a Customer Managed Key").
  "cmk-aif-aifoundry-crypto-user" = {
    umi_key              = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aifoundry-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto User"
  }
  "cmk-cosmos-aicommon" = {
    umi_key              = "{org}-id-cosmos-aicommon-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
  "cmk-redis-aicommon" = {
    umi_key              = "{org}-id-redis-aicommon-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
  "cmk-cr-aishared" = {
    umi_key              = "{org}-id-cr-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
  "cmk-rsv-aishared" = {
    umi_key              = "{org}-uami-rsv-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
  "cmk-bvault-aishared" = {
    umi_key              = "{org}-uami-bvault-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
  "cmk-bvault-aifoundry" = {
    umi_key              = "{org}-uami-bvault-aifoundry-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-aifoundry-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
}

# =============================================================================
# AI Foundry base RBAC (shared Foundry identity, control plane).
# Grants the shared AI Foundry identity ({org}-id-aif-aishared, used by the
# Foundry account and both projects) the control-plane roles it needs on the
# aishared / aicommon resource groups. Mirrors the AI Landing Zone reference
# (ai_rbac) for the shared Foundry identity; app-layer AEA/ESPI grants are
# intentionally excluded. The Cosmos data-plane grant is separate (see
# cosmosdb_sql_role_assignments below).
# =============================================================================
role_assignments_config_foundry = {
  "aif-aishared_on_aishared_rg_search" = {
    umi_key              = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Search Service Contributor"
  }
  "aif-aishared_on_aishared_rg_cosmos_operator" = {
    umi_key              = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Cosmos DB Operator"
  }
  "aif-aishared_on_aicommon_rg_cosmos_operator" = {
    umi_key              = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"
    role_definition_name = "Cosmos DB Operator"
  }
  "aif-aishared_on_aishared_rg_blob_contributor" = {
    umi_key              = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Storage Blob Data Contributor"
  }
  "aif-aishared_on_aishared_rg_blob_owner" = {
    umi_key              = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-rg-aishared-{env}-{region_code}-{iterator}"
    role_definition_name = "Storage Blob Data Owner"
  }
}

# =============================================================================
# Cosmos DB data-plane RBAC (shared Foundry identity).
# Grants the shared AI Foundry identity the Cosmos DB Built-in Data Contributor
# SQL role on the common Cosmos account so Foundry agents/threads can read and
# write data. Control-plane RBAC (above) alone does not grant data access.
# =============================================================================
cosmosdb_sql_role_assignments = {
  "aif-aishared_on_cosmos-aicommon" = {
    resource_group_key = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"
    account_key        = "{org}-cosmos-aicommon-{env}-{region_code}-{iterator}"
    umi_key            = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
  }
}

resource_groups = {
  "{org}-rg-aishared-{env}-{region_code}-{iterator}" = {
    # Naming variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_resource_group"
    product_version     = "1.0.0.0"
    app_support         = ""

    # Optional Tags
    description          = "Resource group for Data & AI patterns"
    notification_emails  = ["platform-alerts@example.com"]
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
  }

  "{org}-rg-aicommon-{env}-{region_code}-{iterator}" = {
    # Naming variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "aicommon"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_resource_group"
    product_version     = "1.0.0.0"
    app_support         = ""

    # Optional Tags
    description          = "Resource group for Data & AI patterns"
    notification_emails  = ["platform-alerts@example.com"]
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
  }

  # --- REMOVED FROM THIS DEPLOYMENT (AEA/ESPI resource groups) ---
  /*
  "{org}-rg-aea-{env}-{region_code}-{iterator}" = {
    # Naming variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "aea"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_resource_group"
    product_version     = "1.0.0.0"
    app_support         = ""

    # Optional Tags
    description          = "Resource group for Data & AI patterns"
    notification_emails  = ["platform-alerts@example.com"]
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
  }

  "{org}-rg-espi-{env}-{region_code}-{iterator}" = {
    # Naming variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "espi"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_resource_group"
    product_version     = "1.0.0.0"
    app_support         = ""

    # Optional Tags
    description          = "Resource group for Data & AI patterns"
    notification_emails  = ["platform-alerts@example.com"]
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
  }
  */
}

virtual_networks = {
  "{org}-vnet-aishared-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "vnet"
    max_length         = 63
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region              = ""
    description         = "VNET for Data & AI patterns"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-{region_code}-ID01-00001"
    auto_delete         = "No"
    delete_after        = "TBD"
    integration_id      = "TBD"
    retention           = "TBD"
    experiment_phase    = "TBD"
    sandbox_type        = "TBD"
    os                  = "TBD"
    patch_policy        = "Monthly-Standard"
    maintenance_window  = "Sun-02:00Z"
    last_vm_accessed    = "TBD"

    address_space      = []
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # VNet peering to the platform hub network. `hub_key` refers to a key in
    # `hub_virtual_networks`; the module resolves the remote VNet resource id
    # and creates the reverse peering in the hub.
    peerings = {
      "to-hub" = {
        name                                 = "{org}-peer-aishared-to-hub-{env}-{region_code}-{iterator}"
        hub_key                              = "hub"
        allow_forwarded_traffic              = true
        allow_virtual_network_access         = true
        create_reverse_peering               = true
        reverse_name                         = "{org}-peer-hub-to-aishared-{env}-{region_code}-{iterator}"
        reverse_allow_forwarded_traffic      = true
        reverse_allow_virtual_network_access = true
      }
    }

    # DNS forwarded to the SEA hub DNS Private Resolver inbound endpoint so the
    # spoke resolves the shared private DNS zones (vault_core, backup_azure, ...)
    # through the hub. Region-specific: SEA = 10.247.130.196 (MYW was 10.247.2.196).
    dns_servers = {
      dns_servers = ["10.247.130.196"]
    }

    subnets = {
      "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          id = "{org}-nsg-pe-aishared-{env}-{region_code}-{iterator}"
        }
      }
      "{org}-snet-agw-aishared-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-agw-aishared-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          id = "{org}-nsg-agw-aishared-{env}-{region_code}-{iterator}"
        }
      }
      "{org}-snet-apim-aishared-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-apim-aishared-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          id = "{org}-nsg-apim-aishared-{env}-{region_code}-{iterator}"
        }
      }
      "{org}-snet-vm-aishared-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-vm-aishared-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          id = "{org}-nsg-vm-aishared-{env}-{region_code}-{iterator}"
        }
        # delegation = [
        #   {
        #     name = "{org}-delg-vm-aishared-{env}-{region_code}-{iterator}"
        #     service_delegation = {
        #       name = "Microsoft.Web/serverFarms"
        #     }
        #   }
        # ]
      }
    }
  }

  # ---------------------------------------------------------------------------
  # Dedicated AI Foundry VNet (parity with ex/dev-ai-latest). Kept SEPARATE from
  # the aishared VNet so the network-injected Standard-Agent managed environment
  # uses AZURE-PROVIDED DNS (NO custom hub resolver) and resolves the account /
  # Search / Cosmos / Storage / Key Vault private endpoints via the private DNS
  # zones linked to this VNet (foundry_spoke_zones in main.tf), while resolving
  # public bootstrap endpoints via Azure DNS. It has its OWN hub peering so the
  # agent + PE subnets can reach the internal firewall, and its dedicated route
  # table ({org}-rt-aifoundry-...) forces 0.0.0.0/0 -> firewall so ALL agent egress
  # is filtered by the firewall FQDN/URL allow-list. The workflow injects the
  # SECOND (Class B) issue range into this VNet's address_space.
  # ---------------------------------------------------------------------------
  "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "aifoundry"
    bu                 = ""
    owner              = ""
    resource_type_code = "vnet"
    max_length         = 63
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region              = ""
    description         = "AI Foundry VNET (Standard-Agent network injection)"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-{region_code}-ID01-00001"
    auto_delete         = "No"
    delete_after        = "TBD"
    integration_id      = "TBD"
    retention           = "TBD"
    experiment_phase    = "TBD"
    sandbox_type        = "TBD"
    os                  = "TBD"
    patch_policy        = "Monthly-Standard"
    maintenance_window  = "Sun-02:00Z"
    last_vm_accessed    = "TBD"

    # Second (Class B) range from the issue is injected here by the workflow.
    address_space      = []
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Own hub peering (independent of the aishared VNet) so the Foundry agent /
    # PE subnets have a path to the internal firewall + hub-hosted private DNS
    # zones. Distinct peering names avoid collision with the aishared peering.
    peerings = {
      "to-hub" = {
        name                                 = "{org}-peer-aifoundry-to-hub-{env}-{region_code}-{iterator}"
        hub_key                              = "hub"
        allow_forwarded_traffic              = true
        allow_virtual_network_access         = true
        create_reverse_peering               = true
        reverse_name                         = "{org}-peer-hub-to-aifoundry-{env}-{region_code}-{iterator}"
        reverse_allow_forwarded_traffic      = true
        reverse_allow_virtual_network_access = true
      }
    }

    # NO dns_servers block => Azure-provided DNS (168.63.129.16). Mirrors
    # ex/dev-ai-latest: the Standard-Agent managed environment resolves the
    # account / Search / Cosmos / Storage / Key Vault private endpoints through
    # the private DNS zones linked to this VNet, and resolves public bootstrap
    # endpoints via Azure DNS.

    subnets = {
      "{org}-snet-agt-aifoundry-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-agt-aifoundry-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          id = "{org}-nsg-agt-aifoundry-{env}-{region_code}-{iterator}"
        }
        delegation = [
          {
            name = "{org}-delg-agt-aifoundry-{env}-{region_code}-{iterator}"
            service_delegation = {
              name = "Microsoft.App/environments"
            }
          }
        ]
      }
      "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          id = "{org}-nsg-pe-aifoundry-{env}-{region_code}-{iterator}"
        }
      }
    }
  }
}

network_security_groups = {
  "{org}-nsg-pe-aishared-{env}-{region_code}-{iterator}" = {
    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "pe-aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 80
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "Network Security and Connectivity"
    budget_id           = ""
    status              = ""
    service             = "Network Security Group"

    # Optional Tags
    region               = ""
    description          = "NSG for PE subnet in SIT network"
    notification_emails  = ["platform-alerts@example.com"]
    app_id               = "{org}-{region_code}-NET01-00001"
    auto_delete          = "No"
    delete_after         = "TBD"
    integration_id       = "TBD"
    retention            = "TBD"
    experiment_phase     = "TBD"
    sandbox_type         = "NA"
    os                   = "TBD"
    patch_policy         = "Monthly-Standard"
    maintenance_window   = "Sun-02:00Z"
    last_vm_accessed     = "TBD"
    auto_shutdown        = "TBD"
    tier                 = "TBD"
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
    cost_allocation_unit = "TBD"

    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    security_rules = {}
  }
  "{org}-nsg-agw-aishared-{env}-{region_code}-{iterator}" = {
    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "agw-aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 80
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "Network Security and Connectivity"
    budget_id           = ""
    status              = ""
    service             = "Network Security Group"

    # Optional Tags
    region               = ""
    description          = "NSG for Application Gateway subnet in SIT network"
    notification_emails  = ["platform-alerts@example.com"]
    app_id               = "{org}-{region_code}-NET01-00001"
    auto_delete          = "No"
    delete_after         = "TBD"
    integration_id       = "TBD"
    retention            = "TBD"
    experiment_phase     = "TBD"
    sandbox_type         = "NA"
    os                   = "TBD"
    patch_policy         = "Monthly-Standard"
    maintenance_window   = "Sun-02:00Z"
    last_vm_accessed     = "TBD"
    auto_shutdown        = "TBD"
    tier                 = "TBD"
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
    cost_allocation_unit = "TBD"

    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    security_rules = {
      allow_app_gateway_infrastructure = {
        name                       = "AllowAppGatewayInfrastructure"
        priority                   = 4000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "GatewayManager"
        destination_address_prefix = "*"
      }
    }
  }
  "{org}-nsg-apim-aishared-{env}-{region_code}-{iterator}" = {
    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "apim-aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 80
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "Network Security and Connectivity"
    budget_id           = ""
    status              = ""
    service             = "Network Security Group"

    # Optional Tags
    region               = ""
    description          = "NSG for APIM subnet in SIT network"
    notification_emails  = ["platform-alerts@example.com"]
    app_id               = "{org}-{region_code}-NET01-00001"
    auto_delete          = "No"
    delete_after         = "TBD"
    integration_id       = "TBD"
    retention            = "TBD"
    experiment_phase     = "TBD"
    sandbox_type         = "NA"
    os                   = "TBD"
    patch_policy         = "Monthly-Standard"
    maintenance_window   = "Sun-02:00Z"
    last_vm_accessed     = "TBD"
    auto_shutdown        = "TBD"
    tier                 = "TBD"
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
    cost_allocation_unit = "TBD"

    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    security_rules = {
      #Inbound rules for Azure Bastion
      allow_internal_https = {
        name                       = "allow-internal-https"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
      # ------------------------------------------------------------
      # OUTBOUND Ã¢â‚¬â€œ APIM Control Plane (MANDATORY)
      # ------------------------------------------------------------
      allow_apim_control_plane_outbound = {
        name                       = "allow-apim-control-plane-outbound"
        priority                   = 110
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "ApiManagement"
      }
      # ------------------------------------------------------------
      # OUTBOUND Ã¢â‚¬â€œ Azure Resource Manager (MANDATORY)
      # ------------------------------------------------------------
      allow_arm_outbound = {
        name                       = "allow-arm-outbound"
        priority                   = 120
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureResourceManager"
      }
      # ------------------------------------------------------------
      # OUTBOUND Ã¢â‚¬â€œ Azure Monitor / Log Analytics (MANDATORY)
      # ------------------------------------------------------------
      allow_monitoring_outbound = {
        name                       = "allow-monitoring-outbound"
        priority                   = 130
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "AzureMonitor"
      }
      # ------------------------------------------------------------
      # OUTBOUND Ã¢â‚¬â€œ Storage (MANDATORY Ã¢â‚¬â€œ APIM backend)
      # ------------------------------------------------------------
      allow_storage_outbound = {
        name                       = "allow-storage-outbound"
        priority                   = 140
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "Storage"
      }
      # ------------------------------------------------------------
      # INBOUND Ã¢â‚¬â€œ Allow APIM management from Azure control plane
      # ------------------------------------------------------------
      "allow_management_inbound" = {
        name                       = "allow_apim_management_inbound"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3443"
        source_address_prefix      = "ApiManagement" # Azure control plane
        destination_address_prefix = "*"
      }
      # ------------------------------------------------------------
      # OUTBOUND Ã¢â‚¬â€œ APIM Management endpoint (MANDATORY for Internal APIM)
      # ------------------------------------------------------------
      allow_management_outbound = {
        name                       = "allow-management-outbound"
        priority                   = 135
        direction                  = "Outbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3443"
        source_address_prefix      = "*"
        destination_address_prefix = "ApiManagement"
      }
      # ------------------------------------------------------------
      # INBOUND Ã¢â‚¬â€œ Azure Infrastructure Load Balancer (MANDATORY)
      # Required for Internal APIM health probes
      # ------------------------------------------------------------
      allow_azure_lb_inbound = {
        name                       = "allow-azure-load-balancer-inbound"
        priority                   = 105
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6390"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = "*"
      }
    }
  }
  "{org}-nsg-vm-aishared-{env}-{region_code}-{iterator}" = {
    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "vm-aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 80
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "Network Security and Connectivity"
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region               = ""
    description          = "NSG for VM subnet in production network"
    notification_emails  = ["platform-alerts@example.com"]
    app_id               = "{org}-{region_code}-NET01-00001"
    auto_delete          = "No"
    delete_after         = "TBD"
    integration_id       = "TBD"
    retention            = "TBD"
    experiment_phase     = "TBD"
    sandbox_type         = "NA"
    os                   = "TBD"
    patch_policy         = "Monthly-Standard"
    maintenance_window   = "Sun-02:00Z"
    last_vm_accessed     = "TBD"
    auto_shutdown        = "TBD"
    tier                 = "TBD"
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
    cost_allocation_unit = "TBD"

    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    security_rules = {
      Allow-Bastion-RDP-SSH = {
        name                       = "Allow-Bastion-RDP-SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "3389"]
        source_address_prefix      = "{bastion_cidr}" # region AzureBastionSubnet CIDR in HUB (injected by workflow)
        destination_address_prefix = "*"
      }
    }
  }
  "{org}-nsg-agt-aifoundry-{env}-{region_code}-{iterator}" = {
    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "agt-aifoundry"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 80
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = ""

    # Optional Tags
    region               = ""
    description          = "NSG for Foundry agent integration subnet in network"
    notification_emails  = ["platform-alerts@example.com"]
    app_id               = "{org}-{region_code}-NET01-00001"
    auto_delete          = "No"
    delete_after         = "TBD"
    integration_id       = "TBD"
    retention            = "TBD"
    experiment_phase     = "TBD"
    sandbox_type         = "NA"
    os                   = "TBD"
    patch_policy         = "Monthly-Standard"
    maintenance_window   = "Sun-02:00Z"
    last_vm_accessed     = "TBD"
    auto_shutdown        = "TBD"
    tier                 = "TBD"
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
    type                 = "Production"
    cost_allocation_unit = "TBD"
    resource_group_key   = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    security_rules = {}
  }
  "{org}-nsg-pe-aifoundry-{env}-{region_code}-{iterator}" = {
    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "pe-aifoundry"
    bu                 = ""
    owner              = ""
    resource_type_code = "nsg"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 80
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = ""
    # Optional Tags
    region               = ""
    description          = "NSG for  Foundry private endpoints subnet in network"
    notification_emails  = ["platform-alerts@example.com"]
    app_id               = "{org}-{region_code}-NET01-00001"
    auto_delete          = "No"
    delete_after         = "TBD"
    integration_id       = "TBD"
    retention            = "TBD"
    experiment_phase     = "TBD"
    sandbox_type         = "NA"
    os                   = "TBD"
    patch_policy         = "Monthly-Standard"
    maintenance_window   = "Sun-02:00Z"
    last_vm_accessed     = "TBD"
    auto_shutdown        = "TBD"
    tier                 = "TBD"
    automation_policy    = "NA"
    review_required      = "Yes"
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"
    type                 = "Production"
    cost_allocation_unit = "TBD"
    resource_group_key   = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    security_rules = {}
  }
}

key_vaults = {
  # Base Infra - AI Shared Key Vault (Premium, private endpoint only)
  "{org}-kv-aishared-{env}-{region_code}-{iterator}" = {
    # Naming module variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "kv"
    max_length         = 24
    no_dashes          = true
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "KeyVault"

    # Key Vault configuration
    sku_name                        = "premium"
    enable_rbac_authorization       = true
    purge_protection_enabled        = true
    soft_delete_retention_days      = 90
    enabled_for_disk_encryption     = true
    enabled_for_deployment          = false
    enabled_for_template_deployment = false
    public_network_access_enabled   = false

    network_acls = {
      bypass         = "AzureServices"
      default_action = "Deny"
    }

    # Customer-Managed Keys created in this Key Vault (consumed by storage,
    # AI Foundry, Cosmos DB and Managed Redis via `key_vault_keys`).
    keys = {
      "{org}-cmk-sa-aishared-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-sa-aishared-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-sa-aifoundry-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-sa-aifoundry-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-aif-aishared-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-aif-aishared-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-cosmos-aicommon-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-cosmos-aicommon-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-redis-aicommon-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-redis-aicommon-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-cr-aishared-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-cr-aishared-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-rsv-aishared-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-rsv-aishared-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-bvault-aishared-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-bvault-aishared-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
    }

    # Private endpoint placed in the AI Shared private-endpoint subnet
    private_endpoints = {
      pe = {
        name          = "{org}-pe-kv-aishared-{env}-{region_code}-{iterator}"
        vnet_key      = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key    = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        dns_zone_keys = ["vault_core"]
      }
    }

    # Optional Tags
    region              = ""
    description         = "AI Shared Base Infra Key Vault"
    notification_emails = ["platform-alerts@example.com"]

    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    additional_tags = {}
  }

  # Base Infra - AI Foundry Key Vault (Premium, private endpoint only)
  "{org}-kv-aifoundry-{env}-{region_code}-{iterator}" = {
    # Naming module variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    au                 = ""
    app_code           = "aifoundry"
    bu                 = ""
    owner              = ""
    resource_type_code = "kv"
    max_length         = 24
    no_dashes          = true
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "KeyVault"

    # Key Vault configuration
    sku_name                        = "premium"
    enable_rbac_authorization       = true
    purge_protection_enabled        = true
    soft_delete_retention_days      = 90
    enabled_for_disk_encryption     = true
    enabled_for_deployment          = false
    enabled_for_template_deployment = false
    public_network_access_enabled   = false

    network_acls = {
      bypass         = "AzureServices"
      default_action = "Deny"
    }

    # Customer-Managed Keys created in this Key Vault: the AI Foundry ACCOUNT CMK
    # ({org}-cmk-aif-aifoundry - dedicated Foundry KV, parity with ex/dev-ai-latest)
    # and the AI Foundry Backup Vault CMK.
    keys = {
      "{org}-cmk-aif-aifoundry-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-aif-aifoundry-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-bvault-aifoundry-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-bvault-aifoundry-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2035-12-31T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
    }

    # Private endpoint placed in the dedicated AI Foundry private-endpoint subnet
    private_endpoints = {
      pe = {
        name          = "{org}-pe-kv-aifoundry-{env}-{region_code}-{iterator}"
        vnet_key      = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
        subnet_key    = "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}"
        dns_zone_keys = ["vault_core"]
      }
    }

    # Optional Tags
    region              = ""
    description         = "AI Foundry Base Infra Key Vault"
    notification_emails = ["platform-alerts@example.com"]

    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    additional_tags = {}
  }
}

# -
# Route Tables (UDRs)
# -
# A single User Defined Route table is applied to all 7 AI Shared subnets,
# matching the inventory ({org}-rt-aishared-<env>-<region>-01). The AI Foundry
# subnets do NOT use this route table.
route_tables = {
  "{org}-rt-aishared-{env}-{region_code}-{iterator}" = {
    # Resource group (resolved from the resource_groups map in main.tf)
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables (env/au/bu/owner/region_code injected by workflow)
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "rt"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""

    # Mandatory Tags (injected by workflow)
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "RouteTable"

    # Route table behaviour. BGP propagation OFF (parity with ex/dev-ai + the
    # Foundry route table) so the EXPLICIT default route below wins - we no
    # longer rely on the hub BGP-advertised default.
    bgp_route_propagation_enabled = false

    # Route table (parity with ex/dev-ai {org}-rt-aishared): force ALL egress
    # from the AI Shared subnets through the internal firewall (like the Foundry
    # route table), WITH an ApiManagement exception so APIM's control-plane
    # (:3443) is not black-holed. next_hop_in_ip_address is rewritten to the
    # region firewall IP by the workflow (SEA = 10.247.130.4). The ApiManagement
    # service-tag route is more specific than 0.0.0.0/0, so APIM control-plane
    # still goes straight to the internet (fixes the "422 ManagementApiRequest
    # Failed" provisioning error); everything else is filtered by the firewall.
    routes = {
      "internet_traffic_to_firewall" = {
        name                   = "internet_traffic_to_firewall"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      }
      "apim_internet" = {
        name                   = "apim_internet"
        address_prefix         = "ApiManagement"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      }
    }

    # Associate the route table with all 7 AI Shared subnets
    subnet_associations = {
      "pe-aishared" = {
        vnet_key   = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
      }
      "agw-aishared" = {
        vnet_key   = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key = "{org}-snet-agw-aishared-{env}-{region_code}-{iterator}"
      }
      "apim-aishared" = {
        vnet_key   = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key = "{org}-snet-apim-aishared-{env}-{region_code}-{iterator}"
      }
      "vm-aishared" = {
        vnet_key   = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key = "{org}-snet-vm-aishared-{env}-{region_code}-{iterator}"
      }
    }

    # Optional Tags
    region              = ""
    description         = "Route table for AI Shared subnets"
    notification_emails = ["platform-alerts@example.com"]
  }

  # ---------------------------------------------------------------------------
  # Dedicated AI Foundry route table (parity with ex/dev-ai-latest
  # {org}-rt-aifoundry). Forces ALL Foundry agent + PE egress through the internal
  # firewall so the network-injected Standard-Agent managed environment is
  # filtered by the firewall FQDN/URL allow-list. bgp propagation OFF so the
  # explicit default route wins. next_hop_in_ip_address is rewritten to the
  # region firewall IP by the workflow (SEA = 10.247.130.4).
  # ---------------------------------------------------------------------------
  "{org}-rt-aifoundry-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    env                = ""
    au                 = ""
    app_code           = "aifoundry"
    bu                 = ""
    owner              = ""
    resource_type_code = "rt"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "RouteTable"

    bgp_route_propagation_enabled = false

    routes = {
      "internet_traffic_to_firewall" = {
        name                   = "internet_traffic_to_firewall"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      }
    }

    subnet_associations = {
      "agt-aifoundry" = {
        vnet_key   = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
        subnet_key = "{org}-snet-agt-aifoundry-{env}-{region_code}-{iterator}"
      }
      "pe-aifoundry" = {
        vnet_key   = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
        subnet_key = "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}"
      }
    }

    region              = ""
    description         = "Route table for AI Foundry subnets (egress via firewall)"
    notification_emails = ["platform-alerts@example.com"]
  }
}

# -
# User Assigned Managed Identities
# -
# One identity per Storage Account, used to grant the Storage Account access to
# its data plane / keys. env/au/bu/owner/region_code and all mandatory tags are
# injected by the workflow, so they are intentionally left blank here.
user_managed_identities = {
  # Backup platform identities (CMK for Recovery Services Vault + Backup Vault).
  "{org}-uami-rsv-aishared-{env}-{region_code}-{iterator}" = {
    # Resource group
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "rsv-aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "id"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    # Optional Tags
    region              = ""
    description         = "Managed Identity for Recovery Services Vault CMK"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-uami-bvault-aishared-{env}-{region_code}-{iterator}" = {
    # Resource group
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "bvault-aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "id"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    # Optional Tags
    region              = ""
    description         = "Managed Identity for Backup Vault CMK"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-uami-bvault-aifoundry-{env}-{region_code}-{iterator}" = {
    # Resource group
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "bvault-aifoundry"
    bu                 = ""
    owner              = ""
    resource_type_code = "id"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    # Optional Tags
    region              = ""
    description         = "Managed Identity for AI Foundry Backup Vault CMK"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-aishared-{env}-{region_code}-{iterator}" = {
    # Resource group
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "id-sa"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    # Optional Tags
    region              = ""
    description         = "Managed Identity for AI Shared Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-aifoundry-{env}-{region_code}-{iterator}" = {
    # Resource group
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aifoundry"
    bu                 = ""
    owner              = ""
    resource_type_code = "id-sa"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    # Optional Tags
    region              = ""
    description         = "Managed Identity for AI Foundry Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  # Identity for the AI Foundry (MS Foundry) account - UserAssigned
  "{org}-id-aif-aishared-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "id-aif"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    region              = ""
    description         = "Managed Identity for the AI Foundry account"
    notification_emails = ["platform-alerts@example.com"]
  }

  # Identity for the Azure Container Registry
  "{org}-id-cr-aishared-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "id-cr"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    region              = ""
    description         = "Managed Identity for the Azure Container Registry"
    notification_emails = ["platform-alerts@example.com"]
  }

  # Identity for the Managed Redis cache (AI Common)
  "{org}-id-redis-aicommon-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"

    env                = ""
    au                 = ""
    app_code           = "redis-aicommon"
    bu                 = ""
    owner              = ""
    resource_type_code = "id"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    region              = ""
    description         = "Managed Identity for the Managed Redis cache"
    notification_emails = ["platform-alerts@example.com"]
  }

  # --- REMOVED FROM THIS DEPLOYMENT (SQL Server identity - app use case) ---
  /*
  # Identity for the SQL Server (AI Common)
  "{org}-id-sql-aicommon-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"

    env                = ""
    au                 = ""
    app_code           = "sql-aicommon"
    bu                 = ""
    owner              = ""
    resource_type_code = "id"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    region              = ""
    description         = "Managed Identity for the SQL Server"
    notification_emails = ["platform-alerts@example.com"]
  }
  */

  # Identity for the Cosmos DB account (AI Common)
  "{org}-id-cosmos-aicommon-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"

    env                = ""
    au                 = ""
    app_code           = "cosmos-aicommon"
    bu                 = ""
    owner              = ""
    resource_type_code = "id"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    region              = ""
    description         = "Managed Identity for the Cosmos DB account"
    notification_emails = ["platform-alerts@example.com"]
  }

  # --- REMOVED FROM THIS DEPLOYMENT (all AEA/ESPI app-use-case identities) ---
  /*
  "{org}-id-di-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aea-{env}-{region_code}-{iterator}"

    env                = ""
    au                 = ""
    app_code           = "di-aea"
    bu                 = ""
    owner              = ""
    resource_type_code = "id"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    region              = ""
    description         = "Managed Identity for the Document Intelligence account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-srch-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-espi-{env}-{region_code}-{iterator}"

    env                = ""
    au                 = ""
    app_code           = "srch-espi"
    bu                 = ""
    owner              = ""
    resource_type_code = "id"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"

    region              = ""
    description         = "Managed Identity for the AI Search service"
    notification_emails = ["platform-alerts@example.com"]
  }

  # ---------------------------------------------------------------------------
  # Storage account identities (one per AEA/ESPI/EGST storage account)
  # ---------------------------------------------------------------------------
  "{org}-id-sa-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "sa-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the AEA Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-fmcp-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "sa-fmcp-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the AEA MCP Function Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-forch-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "sa-forch-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the AEA Orchestrator Function Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "sa-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-feval-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "sa-feval-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Eval Function Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-fing-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "sa-fing-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Ingestion Function Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-fmcp-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "sa-fmcp-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI MCP Function Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-forch-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "sa-forch-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Orchestrator Function Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-sa-egst-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "sa-egst"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the Event Grid system topic Storage Account"
    notification_emails = ["platform-alerts@example.com"]
  }

  # ---------------------------------------------------------------------------
  # Function App identities
  # ---------------------------------------------------------------------------
  "{org}-id-func-mcp-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "func-mcp-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the AEA MCP Function App"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-func-orch-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "func-orch-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the AEA Orchestrator Function App"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-func-eval-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "func-eval-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Eval Function App"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-func-ingestion-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "func-ingestion-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Ingestion Function App"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-func-mcp-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "func-mcp-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI MCP Function App"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-func-orch-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "func-orch-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Orchestrator Function App"
    notification_emails = ["platform-alerts@example.com"]
  }

  # ---------------------------------------------------------------------------
  # App Service identity (AEA web apps)
  # ---------------------------------------------------------------------------
  "{org}-id-app-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "app-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the AEA App Service web apps"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-app-aea-{env}-{region_code}-02" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "app-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the AEA App Service web apps"
    notification_emails = ["platform-alerts@example.com"]
  }

  # ---------------------------------------------------------------------------
  # Event Grid system topic identities
  # ---------------------------------------------------------------------------
  "{org}-id-egst-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "egst-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the AEA Event Grid system topic"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-egst-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "egst-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Event Grid system topic"
    notification_emails = ["platform-alerts@example.com"]
  }

  # ---------------------------------------------------------------------------
  # Document Intelligence (ESPI) and Cosmos DB (ESPI) identities
  # ---------------------------------------------------------------------------
  "{org}-id-di-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "di-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Document Intelligence account"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-cosmos-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "cosmos-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Cosmos DB account"
    notification_emails = ["platform-alerts@example.com"]
  }

  # ---------------------------------------------------------------------------
  # Application Gateway identities
  # ---------------------------------------------------------------------------
  "{org}-id-agw-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "agw-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the AEA Application Gateway"
    notification_emails = ["platform-alerts@example.com"]
  }

  "{org}-id-agw-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "agw-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 128
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ManagedIdentity"
    region              = ""
    description         = "Managed Identity for the ESPI Application Gateway"
    notification_emails = ["platform-alerts@example.com"]
  }
  */
}

# -
# Storage Accounts
# -
# Two Base Infra storage accounts (AI Shared + AI Foundry). Both are Standard_ZRS
# with a private endpoint and public network access disabled. Each uses its
# dedicated user-assigned managed identity. env/au/bu/owner/region_code/region
# and all mandatory tags are injected by the workflow.
storage_accounts = {
  "{org}-sa-aishared-{env}-{region_code}-{iterator}" = {
    # Resource group
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "sa"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 24
    no_dashes       = true
    add_random      = false
    rnd_length      = 2

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"

    # Optional Tags
    region              = ""
    description         = "AI Shared Base Infra Storage Account"
    notification_emails = ["platform-alerts@example.com"]

    # Storage Account specific configuration
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    # Security settings
    https_traffic_only_enabled      = true
    public_network_access_enabled   = false
    allow_nested_items_to_be_public = false
    shared_access_key_enabled       = false
    default_to_oauth_authentication = true
    # Infrastructure (double) encryption. Must be set at creation time - it
    # cannot be enabled on an existing storage account without redeploying it
    # (policy: "Storage accounts should have infrastructure encryption").
    infrastructure_encryption_enabled = true

    # CMK encryption for the queue and table services so the customer key covers
    # ALL four storage services (blob + file are always CMK-covered).
    queue_encryption_key_type = "Account"
    table_encryption_key_type = "Account"

    # Customer-Managed Key encryption (CMK) - AI Shared storage.
    customer_managed_key = {
      key_vault_key              = "sa-aishared-kv"
      key_name                   = "{org}-cmk-sa-aishared-{env}-{region_code}-{iterator}"
      key_version                = null
      user_assigned_identity_ref = "{org}-id-sa-aishared-{env}-{region_code}-{iterator}"
    }

    # Identity - references the user_managed_identities map key
    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-aishared-{env}-{region_code}-{iterator}"
    }

    # Network rules
    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    # SAS expiration policy (compliance: SAS policies should be configured)
    sas_policy = {
      expiration_action = "Log"
      expiration_period = "90.00:00:00"
    }

    # Private endpoint in the AI Shared private-endpoint subnet
    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-aishared-{env}-{region_code}-{iterator}"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
        dns_zone_keys    = ["storage_blob"]
      }
    }
  }

  "{org}-sa-aifoundry-{env}-{region_code}-{iterator}" = {
    # Resource group
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aifoundry"
    bu                 = ""
    owner              = ""
    resource_type_code = "sa"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 24
    no_dashes       = true
    add_random      = false
    rnd_length      = 2

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"

    # Optional Tags
    region              = ""
    description         = "AI Foundry Base Infra Storage Account"
    notification_emails = ["platform-alerts@example.com"]

    # Storage Account specific configuration
    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    # Security settings
    https_traffic_only_enabled      = true
    public_network_access_enabled   = false
    allow_nested_items_to_be_public = false
    shared_access_key_enabled       = false
    default_to_oauth_authentication = true
    # Infrastructure (double) encryption. Must be set at creation time - it
    # cannot be enabled on an existing storage account without redeploying it
    # (policy: "Storage accounts should have infrastructure encryption").
    infrastructure_encryption_enabled = true

    # CMK encryption for the queue and table services so the customer key covers
    # ALL four storage services (blob + file are always CMK-covered).
    queue_encryption_key_type = "Account"
    table_encryption_key_type = "Account"

    # Customer-Managed Key encryption (CMK) - AI Foundry storage.
    customer_managed_key = {
      key_vault_key              = "sa-aifoundry-kv"
      key_name                   = "{org}-cmk-sa-aifoundry-{env}-{region_code}-{iterator}"
      key_version                = null
      user_assigned_identity_ref = "{org}-id-sa-aifoundry-{env}-{region_code}-{iterator}"
    }

    # Identity - references the user_managed_identities map key
    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-aifoundry-{env}-{region_code}-{iterator}"
    }

    # Network rules
    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    # SAS expiration policy (compliance: SAS policies should be configured)
    sas_policy = {
      expiration_action = "Log"
      expiration_period = "90.00:00:00"
    }

    # Private endpoint in the AI Foundry private-endpoint subnet
    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-aifoundry-{env}-{region_code}-{iterator}"
        vnet_key         = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
        dns_zone_keys    = ["storage_blob"]
      }
    }
  }

  # --- REMOVED FROM THIS DEPLOYMENT (AEA/ESPI + EGST storage accounts) ---
  /*
  # ===========================================================================
  # AEA / ESPI application storage accounts (Function App + general workload
  # storage) and the Event Grid system-topic storage account. All Standard_ZRS,
  # public network access disabled, private endpoints NIC-only (DNS deferred to
  # the peering stage). Each uses its own user-assigned managed identity.
  # ===========================================================================
  "{org}-sa-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "sa"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 24
    no_dashes           = true
    add_random          = false
    rnd_length          = 2
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"
    region              = ""
    description         = "AEA workload storage account"
    notification_emails = ["platform-alerts@example.com"]

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = true

    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-aea-{env}-{region_code}-{iterator}"
    }

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    sas_policy = {
      expiration_action = "Log"
      expiration_period = "07.00:00:00"
    }

    containers = {
      "{org}-blob-aea-{env}-{region_code}-{iterator}" = {
        name          = "{org}-blob-aea-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    queues = {
      "{org}-queue-aea-{env}-{region_code}-{iterator}" = {
        name          = "{org}-queue-aea-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
      "aea-manifest-blob-events" = {
        name          = "aea-manifest-blob-events"
        public_access = "None"
        metadata      = {}
      }
    }
    tables = {
      "{org}-table-aea-{env}-{region_code}-{iterator}" = {
        name               = "{org}tableaea{env}{region_code}{iterator}"
        signed_identifiers = []
        timeouts           = null
      }
    }

    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-aea-{env}-{region_code}-{iterator}-blob"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
      }
      "queue" = {
        name             = "{org}-pe-sa-aea-{env}-{region_code}-{iterator}-queue"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "queue"
      }
      "table" = {
        name             = "{org}-pe-sa-aea-{env}-{region_code}-{iterator}-table"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "table"
      }
    }
  }

  "{org}-sa-fmcp-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "fmcp-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "sa"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 24
    no_dashes           = true
    add_random          = false
    rnd_length          = 2
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"
    region              = ""
    description         = "AEA MCP Function App storage account"
    notification_emails = ["platform-alerts@example.com"]

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = true

    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-fmcp-aea-{env}-{region_code}-{iterator}"
    }

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    sas_policy = {
      expiration_action = "Log"
      expiration_period = "07.00:00:00"
    }

    containers = {
      "{org}-blob-fmcp-aea-{env}-{region_code}-{iterator}" = {
        name          = "{org}-blob-fmcp-aea-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    queues = {
      "{org}-queue-fmcp-aea-{env}-{region_code}-{iterator}" = {
        name          = "{org}-queue-fmcp-aea-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    tables = {
      "{org}-table-fmcp-aea-{env}-{region_code}-{iterator}" = {
        name               = "{org}tablefmcpaea{env}{region_code}{iterator}"
        signed_identifiers = []
        timeouts           = null
      }
    }

    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-fmcp-aea-{env}-{region_code}-{iterator}-blob"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
      }
      "queue" = {
        name             = "{org}-pe-sa-fmcp-aea-{env}-{region_code}-{iterator}-queue"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "queue"
      }
      "table" = {
        name             = "{org}-pe-sa-fmcp-aea-{env}-{region_code}-{iterator}-table"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "table"
      }
    }
  }

  "{org}-sa-forch-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "forch-aea"
    bu                  = ""
    owner               = ""
    resource_type_code  = "sa"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 24
    no_dashes           = true
    add_random          = false
    rnd_length          = 2
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"
    region              = ""
    description         = "AEA Orchestrator Function App storage account"
    notification_emails = ["platform-alerts@example.com"]

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = true

    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-forch-aea-{env}-{region_code}-{iterator}"
    }

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    sas_policy = {
      expiration_action = "Log"
      expiration_period = "07.00:00:00"
    }

    containers = {
      "{org}-blob-forch-aea-{env}-{region_code}-{iterator}" = {
        name          = "{org}-blob-forch-aea-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    queues = {
      "{org}-queue-forch-aea-{env}-{region_code}-{iterator}" = {
        name          = "{org}-queue-forch-aea-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    tables = {
      "{org}-table-forch-aea-{env}-{region_code}-{iterator}" = {
        name               = "{org}tableforchaea{env}{region_code}{iterator}"
        signed_identifiers = []
        timeouts           = null
      }
    }

    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-forch-aea-{env}-{region_code}-{iterator}-blob"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
      }
      "queue" = {
        name             = "{org}-pe-sa-forch-aea-{env}-{region_code}-{iterator}-queue"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "queue"
      }
      "table" = {
        name             = "{org}-pe-sa-forch-aea-{env}-{region_code}-{iterator}-table"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "table"
      }
    }
  }

  "{org}-sa-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "sa"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 24
    no_dashes           = true
    add_random          = false
    rnd_length          = 2
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"
    region              = ""
    description         = "ESPI workload storage account"
    notification_emails = ["platform-alerts@example.com"]

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = true

    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-espi-{env}-{region_code}-{iterator}"
    }

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    sas_policy = {
      expiration_action = "Log"
      expiration_period = "07.00:00:00"
    }

    containers = {
      "{org}-blob-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-blob-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    queues = {
      "{org}-queue-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-queue-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
      "evaluationdata-blob-events" = {
        name          = "evaluationdata-blob-events"
        public_access = "None"
        metadata      = {}
      }
    }
    tables = {
      "{org}-table-espi-{env}-{region_code}-{iterator}" = {
        name               = "{org}tableespi{env}{region_code}{iterator}"
        signed_identifiers = []
        timeouts           = null
      }
    }

    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-espi-{env}-{region_code}-{iterator}-blob"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
      }
      "queue" = {
        name             = "{org}-pe-sa-espi-{env}-{region_code}-{iterator}-queue"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "queue"
      }
      "table" = {
        name             = "{org}-pe-sa-espi-{env}-{region_code}-{iterator}-table"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "table"
      }
    }
  }

  "{org}-sa-feval-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "feval-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "sa"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 24
    no_dashes           = true
    add_random          = false
    rnd_length          = 2
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"
    region              = ""
    description         = "ESPI Eval Function App storage account"
    notification_emails = ["platform-alerts@example.com"]

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = true

    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-feval-espi-{env}-{region_code}-{iterator}"
    }

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    sas_policy = {
      expiration_action = "Log"
      expiration_period = "07.00:00:00"
    }

    containers = {
      "{org}-blob-feval-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-blob-feval-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    queues = {
      "{org}-queue-feval-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-queue-feval-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    tables = {
      "{org}-table-feval-espi-{env}-{region_code}-{iterator}" = {
        name               = "{org}tablefevalespi{env}{region_code}{iterator}"
        signed_identifiers = []
        timeouts           = null
      }
    }

    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-feval-espi-{env}-{region_code}-{iterator}-blob"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
      }
      "queue" = {
        name             = "{org}-pe-sa-feval-espi-{env}-{region_code}-{iterator}-queue"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "queue"
      }
      "table" = {
        name             = "{org}-pe-sa-feval-espi-{env}-{region_code}-{iterator}-table"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "table"
      }
    }
  }

  "{org}-sa-fing-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "fing-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "sa"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 24
    no_dashes           = true
    add_random          = false
    rnd_length          = 2
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"
    region              = ""
    description         = "ESPI Ingestion Function App storage account"
    notification_emails = ["platform-alerts@example.com"]

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = true

    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-fing-espi-{env}-{region_code}-{iterator}"
    }

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    sas_policy = {
      expiration_action = "Log"
      expiration_period = "07.00:00:00"
    }

    containers = {
      "{org}-blob-fing-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-blob-fing-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    queues = {
      "{org}-queue-fing-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-queue-fing-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    tables = {
      "{org}-table-fing-espi-{env}-{region_code}-{iterator}" = {
        name               = "{org}tablefingespi{env}{region_code}{iterator}"
        signed_identifiers = []
        timeouts           = null
      }
    }

    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-fing-espi-{env}-{region_code}-{iterator}-blob"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
      }
      "queue" = {
        name             = "{org}-pe-sa-fing-espi-{env}-{region_code}-{iterator}-queue"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "queue"
      }
      "table" = {
        name             = "{org}-pe-sa-fing-espi-{env}-{region_code}-{iterator}-table"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "table"
      }
    }
  }

  "{org}-sa-fmcp-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "fmcp-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "sa"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 24
    no_dashes           = true
    add_random          = false
    rnd_length          = 2
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"
    region              = ""
    description         = "ESPI MCP Function App storage account"
    notification_emails = ["platform-alerts@example.com"]

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = true

    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-fmcp-espi-{env}-{region_code}-{iterator}"
    }

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    sas_policy = {
      expiration_action = "Log"
      expiration_period = "07.00:00:00"
    }

    containers = {
      "{org}-blob-fmcp-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-blob-fmcp-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    queues = {
      "{org}-queue-fmcp-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-queue-fmcp-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    tables = {
      "{org}-table-fmcp-espi-{env}-{region_code}-{iterator}" = {
        name               = "{org}tablefmcpespi{env}{region_code}{iterator}"
        signed_identifiers = []
        timeouts           = null
      }
    }

    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-fmcp-espi-{env}-{region_code}-{iterator}-blob"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
      }
      "queue" = {
        name             = "{org}-pe-sa-fmcp-espi-{env}-{region_code}-{iterator}-queue"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "queue"
      }
      "table" = {
        name             = "{org}-pe-sa-fmcp-espi-{env}-{region_code}-{iterator}-table"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "table"
      }
    }
  }

  "{org}-sa-forch-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "forch-espi"
    bu                  = ""
    owner               = ""
    resource_type_code  = "sa"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 24
    no_dashes           = true
    add_random          = false
    rnd_length          = 2
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"
    region              = ""
    description         = "ESPI Orchestrator Function App storage account"
    notification_emails = ["platform-alerts@example.com"]

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = true

    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-forch-espi-{env}-{region_code}-{iterator}"
    }

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    sas_policy = {
      expiration_action = "Log"
      expiration_period = "07.00:00:00"
    }

    containers = {
      "{org}-blob-forch-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-blob-forch-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    queues = {
      "{org}-queue-forch-espi-{env}-{region_code}-{iterator}" = {
        name          = "{org}-queue-forch-espi-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }
    tables = {
      "{org}-table-forch-espi-{env}-{region_code}-{iterator}" = {
        name               = "{org}tableforchespi{env}{region_code}{iterator}"
        signed_identifiers = []
        timeouts           = null
      }
    }

    private_endpoints = {
      "blob" = {
        name             = "{org}-pe-sa-forch-espi-{env}-{region_code}-{iterator}-blob"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "blob"
      }
      "queue" = {
        name             = "{org}-pe-sa-forch-espi-{env}-{region_code}-{iterator}-queue"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "queue"
      }
      "table" = {
        name             = "{org}-pe-sa-forch-espi-{env}-{region_code}-{iterator}-table"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "table"
      }
    }
  }

  "{org}-sa-egst-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "egst"
    bu                  = ""
    owner               = ""
    resource_type_code  = "sa"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    max_length          = 24
    no_dashes           = true
    add_random          = false
    rnd_length          = 2
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Storage"
    region              = ""
    description         = "Event Grid system topic storage account"
    notification_emails = ["platform-alerts@example.com"]

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = true

    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-id-sa-egst-{env}-{region_code}-{iterator}"
    }

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    sas_policy = {
      expiration_action = "Log"
      expiration_period = "07.00:00:00"
    }

    queues = {
      "{org}-queue-egst-{env}-{region_code}-{iterator}" = {
        name          = "{org}-queue-egst-{env}-{region_code}-{iterator}"
        public_access = "None"
        metadata      = {}
      }
    }

    private_endpoints = {
      "queue" = {
        name             = "{org}-pe-sa-egst-{env}-{region_code}-{iterator}-queue"
        vnet_key         = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key       = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name = "queue"
      }
    }
  }
  */
}

# =============================================================================
# Application Insights
# Workspace-based; connected to the existing CENTRAL Log Analytics Workspace
# ({org}-law-ops-pd-myw-01 in the management subscription). The workspace is
# resolved via a data source - see subscriptions / log_analytics_workspace_*
# above and the azurerm.law provider.
# =============================================================================
application_insights = {
  "{org}-appi-aishared-{env}-{region_code}-{iterator}" = {
    # Resource group
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "appi"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ApplicationInsights"

    # Optional Tags
    region              = ""
    description         = "AI Shared Base Infra Application Insights"
    notification_emails = ["platform-alerts@example.com"]

    # Application Insights specific configuration
    application_type = "web"

    # Governance / security (non peering-dependent). internet_ingestion_enabled
    # and internet_query_enabled are intentionally left at their module defaults
    # (true) because disabling them requires the Azure Monitor Private Link
    # Scope, which depends on hub peering.
    local_authentication_disabled         = true
    retention_in_days                     = 90
    sampling_percentage                   = 100
    daily_data_cap_in_gb                  = 100
    daily_data_cap_notifications_disabled = false
  }
}

# =============================================================================
# Internal API Management (Common AI resource)
# Developer SKU, internal VNet integration against the APIM subnet. No private
# endpoint (build sheet marks APIM PE = No). named_values / APIs / products are
# not wired yet. APIM requires an explicit Azure location; region is fixed to
# "sea" so southeastasia is used.
# =============================================================================
internal_api_management = {
  "{org}-apim-aishared-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    location = "{location}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "apim"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 50
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ApiManagement"

    # SKU / publisher (Developer per build sheet)
    sku_name        = "Developer_1"
    publisher_name  = "{org}"
    publisher_email = "platform-alerts@example.com"

    # Internal VNet integration subnet
    vnet_key   = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key = "{org}-snet-apim-aishared-{env}-{region_code}-{iterator}"

    # Global API policy values. Placeholders for openid/jwt/issuer - replace with
    # the real identity-provider config. Module validations require:
    # jwt_failed_status_code = 401, jwt_scheme = "Bearer",
    # rate_limit_calls > 0 and quota_calls > 0.
    global_policy_vars = {
      jwt_header_name        = "Authorization"
      jwt_failed_status_code = 401
      jwt_failed_message     = "Unauthorized"
      jwt_require_expiry     = true
      jwt_scheme             = "Bearer"
      # Identity-provider config replicated from AI LZ (ailz sit-ai).
      # NOTE: the tenant GUID below is the ailz tenant - verify it matches the
      # platformlz AI subscription's tenant, and replace "api://your-audience"
      # with the real API App Registration audience before go-live.
      openid_config_url = "https://login.microsoftonline.com/{tenant}/v2.0/.well-known/openid-configuration"
      jwt_audience      = "api://your-audience"
      jwt_issuer        = "https://sts.windows.net/{tenant}/"

      rate_limit_calls       = 5
      rate_limit_period      = 60
      rate_limit_counter_key = "@(context.Subscription.Id)"

      quota_calls       = 1000
      quota_period      = 86400
      quota_counter_key = "@(context.Subscription.Id)"
    }
  }
}

# =============================================================================
# AI Foundry (MS Foundry) Account (Common AI resource)
# S0 account. The private endpoint sits in the dedicated AI Foundry
# private-endpoint subnet and is registered into the shared cognitive/openai/
# ai-services private DNS zones. Customer-managed key encryption and
# customer-owned storage are active from the initial deployment. Standard-Agent
# connections/capability hosts and network injection remain deferred (they
# depend on hub peering / cross-stack resources). publicNetworkAccess stays
# Enabled until DNS is fully layered in at the peering stage.
# =============================================================================
ai_foundry_accounts = {
  "{org}-aif-aishared-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "aif"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 64
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_ms_foundry"

    # Account configuration
    sku_name = "S0"
    # SystemAssigned ADDED (2026-07-24) to match the WORKING ex/dev-ai account.
    # gpt-5.1's content-safety / Responsible-AI policy VALIDATION uses the
    # account's SYSTEM-assigned managed identity; a UserAssigned-only account has
    # no system identity, so gpt-5.1 fails 400 "Failed to validate policies for
    # model gpt-5.1/2025-11-13" while older models (gpt-5-mini/embedding) validate
    # fine. disableLocalAuth=true also mirrors ex/dev-ai (was the last account diff).
    identity_type          = "SystemAssigned, UserAssigned"
    umi_key                = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    disableLocalAuth       = true
    allowProjectManagement = true
    customSubDomainName    = "{org}-aif-aishared-{env}-{region_code}-{iterator}"
    publicNetworkAccess    = "Disabled"

    # Allow TRUSTED Azure services (the model-deployment + RAI policy-validation
    # service) to reach the account. Governance policy forces
    # publicNetworkAccess=Disabled, so WITHOUT bypass="AzureServices" Azure's
    # gpt-5.1 policy-validation service is network-blocked and the model
    # deployment fails 400 "Failed to validate policies for model
    # gpt-5.1/2025-11-13" - persistently, even on warm re-runs. Mirrors ex/dev-ai
    # (its working account sets the same bypass).
    network_acls = {
      bypass         = "AzureServices"
      default_action = "Deny"
    }

    # REQUIRED for CMK (PROVEN 2026-07-27 by controlled born-account probe).
    # A network-locked (publicNetworkAccess=Disabled) Foundry account that is
    # CMK-encrypted FAILS gpt-5.1 with "Failed to validate policies" UNLESS it is
    # BORN with agent network injection AND is reachable via its own private
    # endpoint + resolvable private DNS (cognitive_services/openai/ai_services).
    # Bisection results: CMK + no-injection => FAIL; CMK + injection into a bare
    # VNet (no PE/DNS) => FAIL; CMK + injection + account PE + resolvable DNS =>
    # SUCCEEDS (matches the working MYW account, which is also born-injected).
    # This pattern already provides the account private endpoint (below) + custom
    # DNS = hub resolver + hub peering serving those zones, so the injected agent
    # path resolves the account. The agt subnet already has the Microsoft.App/
    # environments delegation + NSG. CAVEATS: injection is CREATE-ONLY (must be a
    # FRESH account - it cannot be added to the existing locked account), and the
    # target subscription needs the Microsoft.App + Microsoft.ContainerService
    # resource providers registered.
    network_injections = [
      {
        scenario   = "agent"
        vnet_key   = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
        subnet_key = "{org}-snet-agt-aifoundry-{env}-{region_code}-{iterator}"
      }
    ]

    # Customer-owned (user-owned) storage. Links the AI Foundry storage account
    # as the account's userOwnedStorage so the Cognitive Services / Foundry
    # account persists data in a customer-managed storage account. Must be set
    # at creation time (policy: "Cognitive Services accounts should use customer
    # owned storage" requires redeployment if added later). The account UMI
    # already holds Storage Blob Data Contributor/Owner on the aishared RG that
    # contains this storage account.
    storage_key = "{org}-sa-aifoundry-{env}-{region_code}-{iterator}"

    # Customer-Managed Key encryption (CMK) - AI Foundry account. CMK key housed
    # in the DEDICATED AI Foundry Key Vault ({org}-kv-aifoundry) for byte-parity
    # with the working ex/dev-ai-latest reference (was the shared KV).
    encryption = {
      key_vault_key = "aif-aifoundry-kv"
      umi_key       = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    }

    # Private endpoint placed in the dedicated AI Foundry private-endpoint
    # subnet, registered into the shared cognitive/openai/ai-services zones.
    private_endpoint = {
      name          = "{org}-pe-aif-aishared-{env}-{region_code}-{iterator}"
      vnet_key      = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
      subnet_key    = "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}"
      dns_zone_keys = ["cognitive_services", "openai", "ai_services"]
    }
  }
}

# =============================================================================
# AI Foundry Projects (Common AI resource)
# NOTE: EXCLUDED FROM SEA. The only projects ({org}-proj-aea / {org}-proj-espi)
# belong to the AEA/ESPI app tier, which is not deployed in SEA (base infra
# only). main.tf filters out any project key containing "aea"/"espi", so these
# entries are retained for reference/parity but are NOT created. A future
# non-AEA/ESPI project added here would be deployed.
# =============================================================================
ai_foundry_projects = {
  "{org}-proj-aea-{env}-{region_code}-{iterator}" = {
    foundry_key   = "{org}-aif-aishared-{env}-{region_code}-{iterator}"
    sku_name      = "S0"
    identity_type = "UserAssigned"
    umi_key       = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    displayName   = "{org}-proj-aea"
    description   = "AI Foundry project - AEA"
  }
  "{org}-proj-espi-{env}-{region_code}-{iterator}" = {
    foundry_key   = "{org}-aif-aishared-{env}-{region_code}-{iterator}"
    sku_name      = "S0"
    identity_type = "UserAssigned"
    umi_key       = "{org}-id-aif-aishared-{env}-{region_code}-{iterator}"
    displayName   = "{org}-proj-espi"
    description   = "AI Foundry project - ESPI"
  }
}

# =============================================================================
# AI Foundry Model (OpenAI) Deployment (Common AI resource)
# Attached to the RAI policy defined below. Adjust model_name / model_version /
# capacity to the approved model for your environment.
# =============================================================================
ai_foundry_deployments_01 = {
  "{org}-opeai-aishared-{env}-{region_code}-01" = {
    foundry_key = "{org}-aif-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "opeai"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 64
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_ms_foundry"
    service             = "CognitiveServices"

    # Model deployment configuration - gpt-5.1 (GA GlobalStandard in SEA).
    # capacity 1000 matches the proven-working ex/dev-ai gpt-5.1 deployment
    # ({org}-openai-aifoundry-dev-sea-04) exactly. Quota limit is 30000, 0 used.
    sku_name      = "GlobalStandard"
    capacity      = 1000
    model_format  = "OpenAI"
    model_name    = "gpt-5.1"
    model_version = "2025-11-13"
    # RAI policy (2026-07-22): gpt-5.1 REQUIRES base_policy_name Microsoft.DefaultV2.
    # The earlier "drop RAI" was WRONG - ex/dev-ai deploys this SAME gpt-5.1/
    # 2025-11-13 successfully WITH this custom RAI (base = Microsoft.DefaultV2).
    # Dropping it fell back to Microsoft.Default (V1), which gpt-5.1 rejects.
    rai_policy_key = "{org}-raip-aishared-{env}-{region_code}-{iterator}"
  }
}

# =============================================================================
# AI Foundry Model (OpenAI) Deployment 02 - gpt-5-mini (Common AI resource)
# gpt-5.1-mini does not exist in Azure's SEA catalog; the general-purpose mini
# is gpt-5-mini (2025-08-07, GA GlobalStandard). Swap to gpt-5.4-mini if a newer
# mini is preferred.
# Created after deployment_01 (model creates on the same account must be
# sequential - Azure returns 409 on concurrent creates). Mirrors AI LZ.
# =============================================================================
ai_foundry_deployments_02 = {
  "{org}-opeai-aishared-{env}-{region_code}-02" = {
    foundry_key = "{org}-aif-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "opeai"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 64
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_ms_foundry"
    service             = "CognitiveServices"

    # Model deployment configuration.
    sku_name      = "GlobalStandard"
    capacity      = 250
    model_format  = "OpenAI"
    model_name    = "gpt-5-mini"
    model_version = "2025-08-07"
    # RAI policy re-enabled (base Microsoft.DefaultV2) - mirrors ex/dev-ai.
    rai_policy_key = "{org}-raip-aishared-{env}-{region_code}-{iterator}"
  }
}

# =============================================================================
# AI Foundry Model (OpenAI) Deployment 03 - text-embedding-3-large (Common AI)
# Chained after deployment_02 to keep model creation on the account sequential.
# Uses the Standard sku (embedding model). Mirrors AI LZ.
# =============================================================================
ai_foundry_deployments_03 = {
  "{org}-opeai-aishared-{env}-{region_code}-03" = {
    foundry_key = "{org}-aif-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "opeai"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 64
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_ms_foundry"
    service             = "CognitiveServices"

    # Model deployment configuration.
    sku_name      = "Standard"
    capacity      = 250
    model_format  = "OpenAI"
    model_name    = "text-embedding-3-large"
    model_version = "1"
    # RAI policy re-enabled (base Microsoft.DefaultV2) - mirrors ex/dev-ai.
    rai_policy_key = "{org}-raip-aishared-{env}-{region_code}-{iterator}"
  }
}

# =============================================================================
# RAI Policy for AI Foundry (Common AI resource)
# RE-ENABLED (2026-07-22): mirrors ex/dev-ai, which deploys the SAME gpt-5.1/
# 2025-11-13 with a custom RAI whose base is Microsoft.DefaultV2. gpt-5.1 REJECTS
# Microsoft.Default (V1); DefaultV2 is required. All 3 deployments reference this
# via rai_policy_key. content_filters come from local.rai_content_filters (main.tf).
# =============================================================================
ai_foundry_rai_policy = {
  "{org}-raip-aishared-{env}-{region_code}-{iterator}" = {
    # Naming module required variables
    env                = ""
    org                = "{org}"
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "raip"
    max_length         = 90
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_ms_foundry"
    service             = "foundry-service"

    # AI Foundry Responsible AI Policy specific variables. base = Microsoft.DefaultV2
    # (required by gpt-5.1); the foundry_key resolves the parent Cognitive account.
    foundry_key      = "{org}-aif-aishared-{env}-{region_code}-{iterator}"
    base_policy_name = "Microsoft.DefaultV2"
  }
}

# =============================================================================
# Azure Container Registry (Common AI resource)
# Premium SKU, uses a dedicated user-assigned identity. Customer-managed key is
# active from the initial deployment (ACR CMK is create-time only). The private
# endpoint ({org}-pe-cr-aishared-...) sits in the AI Shared PE subnet and is
# registered into the shared Azure Container Registry private DNS zone.
# =============================================================================
azure_container_registry = {
  "{org}-cr-aishared-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "cr"

    # Optional naming variables (ACR names are alphanumeric, no dashes)
    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    max_length      = 50
    no_dashes       = true
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "ContainerRegistry"

    # Optional Tags
    region              = ""
    description         = "Azure Container Registry for AI workloads"
    notification_emails = ["platform-alerts@example.com"]

    # Registry configuration
    sku = "Premium"

    managed_identities = {
      system_assigned = false
    }
    umi_key = "{org}-id-cr-aishared-{env}-{region_code}-{iterator}"

    # Customer-Managed Key encryption (CMK) - AI Shared ACR. Must be set at
    # creation time (ACR CMK cannot be enabled on an existing registry without
    # redeploying it), so this is active from the initial deployment.
    customer_managed_key = {
      key_vault_key              = "acr-aishared-kv"
      key_name                   = "{org}-cmk-cr-aishared-{env}-{region_code}-{iterator}"
      key_version                = null
      user_assigned_identity_ref = "{org}-id-cr-aishared-{env}-{region_code}-{iterator}"
    }

    # Private endpoint placed in the AI Shared private-endpoint subnet,
    # registered into the shared Azure Container Registry private DNS zone.
    private_endpoints = {
      pe = {
        name          = "{org}-pe-cr-aishared-{env}-{region_code}-{iterator}"
        vnet_key      = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key    = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        dns_zone_keys = ["azure_cr"]
      }
    }
  }
}

# =============================================================================
# Cosmos DB account (Common AI resource)
# UserAssigned identity; private endpoint in the AI Foundry PE subnet, registered
# into the shared Cosmos DB (Sql) private DNS zone. Customer-managed key is
# active (applied via azapi PATCH after the account is created).
# =============================================================================
cosmosdb_accounts = {
  "{org}-cosmos-aicommon-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aicommon"
    bu                 = ""
    owner              = ""
    resource_type_code = "cosmos"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = ""
    additional_name = ""
    iterator        = ""
    max_length      = 90
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_cosmos_db"
    product_version     = "1.0.0.0"
    app_support         = ""

    # Optional Tags
    region               = ""
    description          = "Cosmos DB for AI Common workloads"
    notification_emails  = ["platform-alerts@example.com"]
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"

    # Cosmos configuration
    # Azure no longer supports enabling Analytical Storage at account creation
    # (400 "Enabling Analytical Storage during account creation is no longer
    # supported"). Must be false at create; enable per-container instead if needed.
    analytical_storage_enabled = false
    automatic_failover_enabled = false

    capacity = {
      total_throughput_limit = 10000
    }

    consistency_policy = {
      consistency_level       = "Session"
      max_interval_in_seconds = 5
      max_staleness_prefix    = 100
    }

    identity = {
      type = "UserAssigned"
    }
    umi_key = "{org}-id-cosmos-aicommon-{env}-{region_code}-{iterator}"

    # Customer-Managed Key encryption (CMK) - Cosmos DB (applied via azapi PATCH).
    customer_managed_key = {
      key_vault_key = "cosmos-aicommon-kv"
    }

    capabilities                          = []
    ip_range_filter                       = []
    local_authentication_disabled         = true
    multiple_write_locations_enabled      = false
    network_acl_bypass_for_azure_services = true
    partition_merge_enabled               = false
    public_network_access_enabled         = false

    sql_databases = {}

    # Private endpoint in the AI Foundry PE subnet, registered into the shared
    # Cosmos DB (documents) private DNS zone.
    private_endpoints = {
      "pe" = {
        name                   = "{org}-pe-cosmos-aifoundry-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}"
        subresource_name       = "Sql"
        network_interface_name = "{org}-pe-cosmosdb-aifoundry-{env}-{region_code}-{iterator}-nic"
        dns_zone_keys          = ["cosmos_sql"]
      }
    }
  }

  # --- REMOVED FROM THIS DEPLOYMENT (Cosmos DB ESPI - app use case) ---
  /*
  # Cosmos DB account for ESPI workloads. UserAssigned identity; NIC-only
  # private endpoint in the AI Shared PE subnet (DNS deferred). CMK omitted.
  "{org}-cosmos-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-espi-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "espi"
    bu                 = ""
    owner              = ""
    resource_type_code = "cosmos"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = ""
    additional_name = ""
    iterator        = ""
    max_length      = 90
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    product_name        = "{org}_cosmos_db"
    product_version     = "1.0.0.0"
    app_support         = ""

    # Optional Tags
    region               = ""
    description          = "Cosmos DB for ESPI workloads"
    notification_emails  = ["platform-alerts@example.com"]
    backup_policy        = "VaultPolicy-Prod-Daily30"
    disaster_recovery    = "RP01-RT08"
    cost_alert_threshold = "80"
    budget_limit         = "10000"

    # Cosmos configuration
    analytical_storage_enabled = false
    automatic_failover_enabled = true

    capacity = {
      total_throughput_limit = -1
    }

    consistency_policy = {
      consistency_level       = "Session"
      max_interval_in_seconds = 300
      max_staleness_prefix    = 100001
    }

    identity = {
      type = "UserAssigned"
    }
    umi_key = "{org}-id-cosmos-espi-{env}-{region_code}-{iterator}"

    capabilities                          = []
    ip_range_filter                       = []
    local_authentication_disabled         = true
    multiple_write_locations_enabled      = false
    network_acl_bypass_for_azure_services = true
    partition_merge_enabled               = false
    public_network_access_enabled         = false

    sql_databases = {
      sql_db01 = {
        name = "{org}-cosmos-db-espi-{env}-{region_code}-{iterator}"
        containers = {
          container01 = {
            name                = "{org}-cosmos-container-espi-{env}-{region_code}-{iterator}"
            partition_key_paths = ["/sessionid"]
          }
        }
      }
    }

    # Private endpoint in the AI Shared PE subnet (NIC only; DNS deferred).
    private_endpoints = {
      "pe" = {
        name                   = "{org}-pe-cosmos-espi-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "Sql"
        network_interface_name = "{org}-pe-cosmosdb-espi-{env}-{region_code}-{iterator}-nic"
      }
    }
  }
  */
}

# =============================================================================
# SQL Server + database (Common AI resource)
# Azure AD-only authentication (azuread_authentication_only = true), so the
# SQL admin login/password are effectively unused - we still generate a random
# password to satisfy the provider but do NOT persist it to Key Vault (that
# write needs KV RBAC propagation and is unnecessary for AAD-only auth).
# Transparent Data Encryption uses the service-managed key until peering.
# Private endpoint in the AI Shared PE subnet (NIC only; DNS deferred).
# =============================================================================
# --- REMOVED FROM THIS DEPLOYMENT (SQL Server - app use case) ---
/*
sql_servers = {
  "{org}-sql-aicommon-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aicommon"
    bu                 = ""
    owner              = ""
    resource_type_code = "sql"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = ""
    additional_name = ""
    iterator        = ""
    max_length      = 60
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "sql_server"
    product_name        = "{org}_sql_server"
    product_version     = "1.0.0.0"
    app_support         = ""

    # Optional Tags
    region              = ""
    description         = "SQL Server for AI Common workloads"
    notification_emails = ["platform-alerts@example.com"]

    # SQL Server configuration
    umi_key                                  = "{org}-id-sql-aicommon-{env}-{region_code}-{iterator}"
    server_version                           = "12.0"
    administrator_login                      = "sql_admin"
    enable_telemetry                         = true
    express_vulnerability_assessment_enabled = true

    managed_identities = {
      system_assigned = false
    }

    databases = {
      "{org}-sqldb-aicommon-{env}-{region_code}-{iterator}" = {
        name                        = "{org}-sqldb-aicommon-{env}-{region_code}-{iterator}"
        create_mode                 = "Default"
        collation                   = "SQL_Latin1_General_CP1_CI_AS"
        license_type                = null
        max_size_gb                 = 50
        sku_name                    = "S0"
        min_capacity                = null
        auto_pause_delay_in_minutes = null
        geo_backup_enabled          = true
        storage_account_type        = "Local"
      }
    }

    # Private endpoint in the AI Shared PE subnet (NIC only; DNS deferred).
    private_endpoints = {
      "pe" = {
        name                   = "{org}-pe-sql-aicommon-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "sqlServer"
        network_interface_name = "{org}-pe-sql-aicommon-{env}-{region_code}-{iterator}-nic"
      }
    }
  }
}
*/

# =============================================================================
# Managed Redis Cache (Common AI resource)
# UserAssigned identity; public network access disabled. Customer-managed key
# is omitted (service-managed encryption) until the hub peering exists.
# =============================================================================
managed_redis_instances = {
  "{org}-redis-aicommon-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aicommon"
    bu                 = ""
    owner              = ""
    resource_type_code = "redis"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = ""
    additional_name = ""
    iterator        = ""
    max_length      = 60
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Business Tags
    app_name       = ""
    app_support    = ""
    business_unit  = ""
    business_owner = ""
    type           = "Infrastructure"

    # Mandatory DevOps Tags
    product_name    = "{org}_redis_cache"
    product_version = "1.0.0.0"

    # Mandatory Finance Tags
    cost_center          = ""
    cost_allocation_unit = "TBD"
    budget_id            = ""

    # Mandatory Governance Tags
    data_classification = ""
    compliance_required = "No"
    compliance          = ""

    # Mandatory Operation Tags
    criticality = ""
    environment = ""
    status      = ""

    # Optional Tags
    description         = "Managed Redis cache for AI Common workloads"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    # Redis configuration
    umi_key                   = "{org}-id-redis-aicommon-{env}-{region_code}-{iterator}"
    sku_name                  = "Balanced_B1"
    high_availability_enabled = true
    public_network_access     = "Disabled"

    # Customer-Managed Key encryption (CMK) - Managed Redis (Enterprise).
    customer_managed_key = {
      key_vault_key = "redis-aicommon-kv"
      key_name      = "{org}-cmk-redis-aicommon-{env}-{region_code}-{iterator}"
    }

    managed_redis_identity = {
      type = "UserAssigned"
    }

    default_database = {
      access_keys_authentication_enabled = false
      client_protocol                    = "Encrypted"
      clustering_policy                  = "OSSCluster"
      eviction_policy                    = "VolatileLRU"
    }
  }
}

# =============================================================================
# REMOVED FROM THIS DEPLOYMENT - all AEA/ESPI app use cases below:
# Bing, Document Intelligence, AI Search, App Service Plans, App Services,
# Function Apps, EGST role assignments, Event Grid System Topics, WAF policies,
# Application Gateways. Restore by removing the /* ... */ wrapper.
# =============================================================================
/*
# =============================================================================
# Bing resource (Grounding Custom Search) - AEA. Always Global location.
# =============================================================================
bing_accounts = {
  "{org}-bing-aea-{env}-global-{iterator}" = {
    resource_group_key = "{org}-rg-aea-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aea"
    bu                 = ""
    owner              = ""
    resource_type_code = "bing"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = ""
    additional_name = ""
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "TBD"

    # Optional Tags
    region              = "global"
    description         = "Bing Grounding Custom Search"
    notification_emails = ["platform-alerts@example.com"]

    # Bing configuration (Bing resources are always Global)
    sku_name           = "G2"
    kind               = "Bing.GroundingCustomSearch"
    location           = "global"
    statistics_enabled = false
  }
}

# =============================================================================
# Document Intelligence (Form Recognizer) - AEA. UserAssigned identity, CMK
# deferred (service-managed key) until peering. Standalone private endpoint is
# added in the dedicated private-endpoint phase.
# =============================================================================
document_intelligence = {
  "{org}-di-aea-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aea-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "aea"
    bu                 = ""
    owner              = ""
    resource_type_code = "di"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = ""
    additional_name = ""
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "TBD"

    # Optional Tags
    region              = ""
    description         = "Document Intelligence (Form Recognizer)"
    notification_emails = ["platform-alerts@example.com"]

    # Document Intelligence configuration
    sku_name                      = "S0"
    kind                          = "FormRecognizer"
    umi_key                       = "{org}-id-di-aea-{env}-{region_code}-{iterator}"
    custom_subdomain_name         = "{org}-di-aea-{env}-{region_code}-{iterator}"
    local_auth_enabled            = true
    public_network_access_enabled = false

    identity = {
      type = "UserAssigned"
    }
  }

  # Document Intelligence (Form Recognizer) - ESPI. UserAssigned identity, CMK
  # deferred (service-managed key) until peering. Standalone private endpoint is
  # added in the dedicated private-endpoint phase.
  "{org}-di-espi-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-espi-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "espi"
    bu                 = ""
    owner              = ""
    resource_type_code = "di"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = ""
    additional_name = ""
    iterator        = ""
    max_length      = 128
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "TBD"

    # Optional Tags
    region              = ""
    description         = "Document Intelligence (Form Recognizer)"
    notification_emails = ["platform-alerts@example.com"]

    # Document Intelligence configuration
    sku_name                      = "S0"
    kind                          = "FormRecognizer"
    umi_key                       = "{org}-id-di-espi-{env}-{region_code}-{iterator}"
    custom_subdomain_name         = "{org}-di-espi-{env}-{region_code}-{iterator}"
    local_auth_enabled            = false
    public_network_access_enabled = false

    identity = {
      type = "UserAssigned"
    }
  }
}

# =============================================================================
# AI Search service - ESPI. UserAssigned identity, CMK enforcement disabled and
# CMK deferred (service-managed key) until peering. Public access disabled;
# standalone private endpoint added in the dedicated private-endpoint phase.
# Only one instance is kept (the MYW/SEA pair collapses to a single SEA name).
# =============================================================================
search_services = {
  # A single AI Search service pinned to Southeast Asia. The myw-pinned service
  # was dropped for now to keep the whole stack single-region (every run targets
  # one region, so its private endpoint stays in-region). `name`/`location` are
  # hardcoded (the workflow does not rewrite them); `{env}` stays a token so the
  # same definition works for every environment.
  "{org}-srch-espi-{env}-sea-{iterator}" = {
    resource_group_key = "{org}-rg-espi-{env}-{region_code}-{iterator}"

    # Region is pinned here (not taken from the issue template).
    name     = "{org}-srch-espi-{env}-sea-{iterator}"
    location = "{location}"

    # Naming module required variables
    env                = ""
    au                 = ""
    app_code           = "espi"
    bu                 = ""
    owner              = ""
    resource_type_code = "srch"

    # Optional naming variables
    org             = ""
    region_code     = ""
    base_name       = ""
    additional_name = ""
    iterator        = ""
    max_length      = 24
    no_dashes       = false
    add_random      = false
    rnd_length      = 4

    # Mandatory Business Tags
    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""

    # Mandatory DevOps Tags
    product_name    = "{org}_ai_search"
    product_version = "1.0.0.0"

    # Mandatory Finance Tags
    cost_allocation_unit = "TBD"
    budget_id            = ""

    # Mandatory Operation Tags
    criticality = ""
    environment = ""
    status      = ""
    service     = "ai-search-service"

    # Optional Tags
    description         = "AI Search service for ESPI workloads (Southeast Asia)"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    # AI Search configuration
    umi_key                       = "{org}-id-srch-espi-{env}-{region_code}-{iterator}"
    sku                           = "standard"
    public_network_access_enabled = false
    local_authentication_enabled  = false
    enable_telemetry              = true
    replica_count                 = 3
    allowed_ips                   = []

    managed_identities = {
      system_assigned = false
    }

    # NIC-only private endpoint (DNS integration deferred until peering).
    private_endpoints = {
      "pe-srch" = {
        name                   = "{org}-pe-srch-espi-{env}-sea-{iterator}"
        vnet_key               = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}"
        network_interface_name = "{org}-pe-srch-espi-{env}-sea-{iterator}-nic"
      }
    }
  }
}

# =============================================================================
# App Service Plans
# One Standard (S1) plan for the AEA web apps and six Flex Consumption (FC1)
# plans for the function apps (mcp/orch on the AEA side, eval/ing/mcp/orch on
# the ESPI side). os_type Linux, zone balancing disabled.
# =============================================================================
app_service_plans = {
  "{org}-asp-app-aea-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "app-aea"
    bu                 = ""
    resource_type_code = "asp"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Business Tags
    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-ASP-001"

    # Mandatory DevOps Tags
    product_name    = "{org}_app_service_plan"
    product_version = "1.0.0.0"

    # Mandatory Finance Tags
    cost_allocation_unit = "TBD"
    budget_id            = ""

    # Mandatory Operation Tags
    criticality = ""
    environment = ""
    status      = ""
    service     = "app_service_plan"

    # Optional Tags
    description         = "App Service Plan for AEA web apps"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    os_type                = "Linux"
    sku_name               = "S1"
    zone_balancing_enabled = false
    resource_group_key     = "{org}-rg-aea-{env}-{region_code}-{iterator}"
  }
  "{org}-asp-func-mcp-aea-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "func-mcp-aea"
    bu                 = ""
    resource_type_code = "asp"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-ASP-001"

    product_name    = "{org}_app_service_plan"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "app_service_plan"

    description         = "App Service Plan for AEA MCP function app"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    os_type                = "Linux"
    sku_name               = "FC1"
    zone_balancing_enabled = false
    resource_group_key     = "{org}-rg-aea-{env}-{region_code}-{iterator}"
  }
  "{org}-asp-func-orch-aea-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "func-orch-aea"
    bu                 = ""
    resource_type_code = "asp"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-ASP-001"

    product_name    = "{org}_app_service_plan"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "app_service_plan"

    description         = "App Service Plan for AEA orchestrator function app"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    os_type                = "Linux"
    sku_name               = "FC1"
    zone_balancing_enabled = false
    resource_group_key     = "{org}-rg-aea-{env}-{region_code}-{iterator}"
  }
  "{org}-asp-func-eval-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "func-eval-espi"
    bu                 = ""
    resource_type_code = "asp"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-ASP-001"

    product_name    = "{org}_app_service_plan"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "app_service_plan"

    description         = "App Service Plan for ESPI eval function app"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    os_type                = "Linux"
    sku_name               = "FC1"
    zone_balancing_enabled = false
    resource_group_key     = "{org}-rg-espi-{env}-{region_code}-{iterator}"
  }
  "{org}-asp-func-ing-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "func-ing-espi"
    bu                 = ""
    resource_type_code = "asp"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-ASP-001"

    product_name    = "{org}_app_service_plan"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "app_service_plan"

    description         = "App Service Plan for ESPI ingestion function app"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    os_type                = "Linux"
    sku_name               = "FC1"
    zone_balancing_enabled = false
    resource_group_key     = "{org}-rg-espi-{env}-{region_code}-{iterator}"
  }
  "{org}-asp-func-mcp-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "func-mcp-espi"
    bu                 = ""
    resource_type_code = "asp"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-ASP-001"

    product_name    = "{org}_app_service_plan"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "app_service_plan"

    description         = "App Service Plan for ESPI MCP function app"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    os_type                = "Linux"
    sku_name               = "FC1"
    zone_balancing_enabled = false
    resource_group_key     = "{org}-rg-espi-{env}-{region_code}-{iterator}"
  }
  "{org}-asp-func-orch-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "func-orch-espi"
    bu                 = ""
    resource_type_code = "asp"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-ASP-001"

    product_name    = "{org}_app_service_plan"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "app_service_plan"

    description         = "App Service Plan for ESPI orchestrator function app"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    os_type                = "Linux"
    sku_name               = "FC1"
    zone_balancing_enabled = false
    resource_group_key     = "{org}-rg-espi-{env}-{region_code}-{iterator}"
  }
}

# =============================================================================
# App Services (web apps)
# Two plain Linux web-app shells on the AEA side (no container image / app code
# deployed here - infrastructure only). VNet integrated into the dedicated web
# subnet; NIC-only private endpoints; shared user-assigned identity.
# =============================================================================
app_services = {
  "{org}-app-aea-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    iterator           = ""
    au                 = ""
    app_code           = "aea"
    bu                 = ""
    owner              = ""
    resource_type_code = "app"
    base_name          = ""
    additional_name    = ""
    max_length         = 128
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "appservice"
    app_support         = ""

    # Optional Tags
    region      = ""
    description = "Web App shell for AEA workloads"

    enable_telemetry   = true
    resource_group_key = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    service_plan_key   = "{org}-asp-app-aea-{env}-{region_code}-{iterator}"
    umi_key            = "{org}-id-app-aea-{env}-{region_code}-{iterator}"
    vnet_key           = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key         = "{org}-snet-web-aea-{env}-{region_code}-{iterator}"
    kind               = "webapp"
    os_type            = "Linux"

    managed_identities = {
      system_assigned = false
    }

    site_config = {
      always_on           = true
      ftps_state          = "FtpsOnly"
      http2_enabled       = true
      minimum_tls_version = "1.2"
    }

    enable_application_insights = false
    application_insights        = {}

    private_endpoints = {
      "pe-app" = {
        name                   = "{org}-pe-app-aea-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "sites"
        network_interface_name = "{org}-pe-app-aea-{env}-{region_code}-{iterator}-nic"
      }
    }
  }
  "{org}-app-aea-{env}-{region_code}-02" = {
    env                = ""
    org                = ""
    region_code        = ""
    iterator           = ""
    au                 = ""
    app_code           = "aea"
    bu                 = ""
    owner              = ""
    resource_type_code = "app"
    base_name          = ""
    additional_name    = ""
    max_length         = 128
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "appservice"
    app_support         = ""

    region      = ""
    description = "Web App shell for AEA workloads"

    enable_telemetry   = true
    resource_group_key = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    service_plan_key   = "{org}-asp-app-aea-{env}-{region_code}-{iterator}"
    umi_key            = "{org}-id-app-aea-{env}-{region_code}-02"
    vnet_key           = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key         = "{org}-snet-web-aea-{env}-{region_code}-{iterator}"
    kind               = "webapp"
    os_type            = "Linux"

    managed_identities = {
      system_assigned = false
    }

    site_config = {
      always_on           = true
      ftps_state          = "FtpsOnly"
      http2_enabled       = true
      minimum_tls_version = "1.2"
    }

    enable_application_insights = false
    application_insights        = {}

    private_endpoints = {
      "pe-app" = {
        name                   = "{org}-pe-app-aea-{env}-{region_code}-02"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "sites"
        network_interface_name = "{org}-pe-app-aea-{env}-{region_code}-02-nic"
      }
    }
  }
}

# =============================================================================
# Function Apps (Flex Consumption / FC1)
# Six Linux Python flex-consumption function shells: mcp/orch on the AEA side
# and eval/ing/mcp/orch on the ESPI side. Deployment container backed by the
# per-function storage account using user-assigned identity. App code deployed
# out-of-band; infrastructure only. NIC-only private endpoints.
# =============================================================================
function_app_flex = {
  "{org}-func-mcp-aea-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "mcp-aea"
    bu                 = ""
    resource_type_code = "func"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-NET01-00001"

    product_name    = "{org}_function_app"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "function_app"

    description         = "Flex Consumption function app shell for AEA MCP"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    service_plan_key            = "{org}-asp-func-mcp-aea-{env}-{region_code}-{iterator}"
    container_key               = "{org}-blob-fmcp-aea-{env}-{region_code}-{iterator}"
    umi_key                     = "{org}-id-func-mcp-aea-{env}-{region_code}-{iterator}"
    storage_key                 = "{org}-sa-fmcp-aea-{env}-{region_code}-{iterator}"
    resource_group_key          = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    app_insights_key            = "{org}-appi-aishared-{env}-{region_code}-{iterator}"
    vnet_key                    = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key                  = "{org}-snet-func-aea-{env}-{region_code}-{iterator}"
    enable_telemetry            = true
    fc1_runtime_name            = "python"
    fc1_runtime_version         = "3.13"
    function_app_uses_fc1       = true
    instance_memory_in_mb       = 2048
    kind                        = "functionapp"
    maximum_instance_count      = 100
    os_type                     = "Linux"
    storage_authentication_type = "UserAssignedIdentity"
    storage_container_type      = "blobContainer"
    enable_application_insights = false

    managed_identities = {
      system_assigned = false
    }

    private_endpoints = {
      "pe-func" = {
        name                   = "{org}-pe-func-mcp-aea-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "sites"
        network_interface_name = "{org}-pe-func-mcp-aea-{env}-{region_code}-{iterator}-nic"
      }
    }

    site_config = {
      ftps_state              = "Disabled"
      http2_enabled           = true
      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
    }
  }
  "{org}-func-orch-aea-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "orch-aea"
    bu                 = ""
    resource_type_code = "func"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-NET01-00001"

    product_name    = "{org}_function_app"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "function_app"

    description         = "Flex Consumption function app shell for AEA orchestrator"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    service_plan_key            = "{org}-asp-func-orch-aea-{env}-{region_code}-{iterator}"
    container_key               = "{org}-blob-forch-aea-{env}-{region_code}-{iterator}"
    umi_key                     = "{org}-id-func-orch-aea-{env}-{region_code}-{iterator}"
    storage_key                 = "{org}-sa-forch-aea-{env}-{region_code}-{iterator}"
    resource_group_key          = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    app_insights_key            = "{org}-appi-aishared-{env}-{region_code}-{iterator}"
    vnet_key                    = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key                  = "{org}-snet-func-aea-{env}-{region_code}-{iterator}"
    enable_telemetry            = true
    fc1_runtime_name            = "python"
    fc1_runtime_version         = "3.13"
    function_app_uses_fc1       = true
    instance_memory_in_mb       = 2048
    kind                        = "functionapp"
    maximum_instance_count      = 100
    os_type                     = "Linux"
    storage_authentication_type = "UserAssignedIdentity"
    storage_container_type      = "blobContainer"
    enable_application_insights = false

    managed_identities = {
      system_assigned = false
    }

    private_endpoints = {
      "pe-func" = {
        name                   = "{org}-pe-func-orch-aea-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "sites"
        network_interface_name = "{org}-pe-func-orch-aea-{env}-{region_code}-{iterator}-nic"
      }
    }

    site_config = {
      ftps_state              = "Disabled"
      http2_enabled           = true
      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
    }
  }
  "{org}-func-eval-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "eval-espi"
    bu                 = ""
    resource_type_code = "func"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-NET01-00001"

    product_name    = "{org}_function_app"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "function_app"

    description         = "Flex Consumption function app shell for ESPI eval"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    service_plan_key            = "{org}-asp-func-eval-espi-{env}-{region_code}-{iterator}"
    container_key               = "{org}-blob-feval-espi-{env}-{region_code}-{iterator}"
    umi_key                     = "{org}-id-func-eval-espi-{env}-{region_code}-{iterator}"
    storage_key                 = "{org}-sa-feval-espi-{env}-{region_code}-{iterator}"
    resource_group_key          = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    app_insights_key            = "{org}-appi-aishared-{env}-{region_code}-{iterator}"
    vnet_key                    = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key                  = "{org}-snet-func-espi-{env}-{region_code}-{iterator}"
    enable_telemetry            = true
    fc1_runtime_name            = "python"
    fc1_runtime_version         = "3.13"
    function_app_uses_fc1       = true
    instance_memory_in_mb       = 2048
    kind                        = "functionapp"
    maximum_instance_count      = 100
    os_type                     = "Linux"
    storage_authentication_type = "UserAssignedIdentity"
    storage_container_type      = "blobContainer"
    enable_application_insights = false

    managed_identities = {
      system_assigned = false
    }

    private_endpoints = {
      "pe-func" = {
        name                   = "{org}-pe-func-eval-espi-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "sites"
        network_interface_name = "{org}-pe-func-eval-espi-{env}-{region_code}-{iterator}-nic"
      }
    }

    site_config = {
      ftps_state              = "Disabled"
      http2_enabled           = true
      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
    }
  }
  "{org}-func-ing-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "ing-espi"
    bu                 = ""
    resource_type_code = "func"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-NET01-00001"

    product_name    = "{org}_function_app"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "function_app"

    description         = "Flex Consumption function app shell for ESPI ingestion"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    service_plan_key            = "{org}-asp-func-ing-espi-{env}-{region_code}-{iterator}"
    container_key               = "{org}-blob-fing-espi-{env}-{region_code}-{iterator}"
    umi_key                     = "{org}-id-func-ingestion-espi-{env}-{region_code}-{iterator}"
    storage_key                 = "{org}-sa-fing-espi-{env}-{region_code}-{iterator}"
    resource_group_key          = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    app_insights_key            = "{org}-appi-aishared-{env}-{region_code}-{iterator}"
    vnet_key                    = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key                  = "{org}-snet-func-espi-{env}-{region_code}-{iterator}"
    enable_telemetry            = true
    fc1_runtime_name            = "python"
    fc1_runtime_version         = "3.13"
    function_app_uses_fc1       = true
    instance_memory_in_mb       = 2048
    kind                        = "functionapp"
    maximum_instance_count      = 100
    os_type                     = "Linux"
    storage_authentication_type = "UserAssignedIdentity"
    storage_container_type      = "blobContainer"
    enable_application_insights = false

    managed_identities = {
      system_assigned = false
    }

    private_endpoints = {
      "pe-func" = {
        name                   = "{org}-pe-func-ing-espi-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "sites"
        network_interface_name = "{org}-pe-func-ing-espi-{env}-{region_code}-{iterator}-nic"
      }
    }

    site_config = {
      ftps_state              = "Disabled"
      http2_enabled           = true
      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
    }
  }
  "{org}-func-mcp-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "mcp-espi"
    bu                 = ""
    resource_type_code = "func"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-NET01-00001"

    product_name    = "{org}_function_app"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "function_app"

    description         = "Flex Consumption function app shell for ESPI MCP"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    service_plan_key            = "{org}-asp-func-mcp-espi-{env}-{region_code}-{iterator}"
    container_key               = "{org}-blob-fmcp-espi-{env}-{region_code}-{iterator}"
    umi_key                     = "{org}-id-func-mcp-espi-{env}-{region_code}-{iterator}"
    storage_key                 = "{org}-sa-fmcp-espi-{env}-{region_code}-{iterator}"
    resource_group_key          = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    app_insights_key            = "{org}-appi-aishared-{env}-{region_code}-{iterator}"
    vnet_key                    = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key                  = "{org}-snet-func-espi-{env}-{region_code}-{iterator}"
    enable_telemetry            = true
    fc1_runtime_name            = "python"
    fc1_runtime_version         = "3.13"
    function_app_uses_fc1       = true
    instance_memory_in_mb       = 2048
    kind                        = "functionapp"
    maximum_instance_count      = 100
    os_type                     = "Linux"
    storage_authentication_type = "UserAssignedIdentity"
    storage_container_type      = "blobContainer"
    enable_application_insights = false

    managed_identities = {
      system_assigned = false
    }

    private_endpoints = {
      "pe-func" = {
        name                   = "{org}-pe-func-mcp-espi-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "sites"
        network_interface_name = "{org}-pe-func-mcp-espi-{env}-{region_code}-{iterator}-nic"
      }
    }

    site_config = {
      ftps_state              = "Disabled"
      http2_enabled           = true
      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
    }
  }
  "{org}-func-orch-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "orch-espi"
    bu                 = ""
    resource_type_code = "func"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-MYW-NET01-00001"

    product_name    = "{org}_function_app"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "function_app"

    description         = "Flex Consumption function app shell for ESPI orchestrator"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    service_plan_key            = "{org}-asp-func-orch-espi-{env}-{region_code}-{iterator}"
    container_key               = "{org}-blob-forch-espi-{env}-{region_code}-{iterator}"
    umi_key                     = "{org}-id-func-orch-espi-{env}-{region_code}-{iterator}"
    storage_key                 = "{org}-sa-forch-espi-{env}-{region_code}-{iterator}"
    resource_group_key          = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    app_insights_key            = "{org}-appi-aishared-{env}-{region_code}-{iterator}"
    vnet_key                    = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key                  = "{org}-snet-func-espi-{env}-{region_code}-{iterator}"
    enable_telemetry            = true
    fc1_runtime_name            = "python"
    fc1_runtime_version         = "3.13"
    function_app_uses_fc1       = true
    instance_memory_in_mb       = 2048
    kind                        = "functionapp"
    maximum_instance_count      = 100
    os_type                     = "Linux"
    storage_authentication_type = "UserAssignedIdentity"
    storage_container_type      = "blobContainer"
    enable_application_insights = false

    managed_identities = {
      system_assigned = false
    }

    private_endpoints = {
      "pe-func" = {
        name                   = "{org}-pe-func-orch-espi-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "sites"
        network_interface_name = "{org}-pe-func-orch-espi-{env}-{region_code}-{iterator}-nic"
      }
    }

    site_config = {
      ftps_state              = "Disabled"
      http2_enabled           = true
      minimum_tls_version     = "1.2"
      scm_minimum_tls_version = "1.2"
    }
  }
}

# =============================================================================
# Event Grid System Topics + queue RBAC
# Two topics: one watching the AEA storage account (routes blob manifest events
# to the aea-manifest-blob-events queue) and one watching the ESPI storage
# account (routes evaluation xlsx blob events to the evaluationdata-blob-events
# queue). Each topic identity is first granted Storage Queue Data Message Sender
# on the source account via role_assignments_config_egst.
# =============================================================================
role_assignments_config_egst = {
  queue_role_on_ai_aea_storage = {
    umi_key              = "{org}-id-egst-aea-{env}-{region_code}-{iterator}"
    scope_source         = "ai_aea_storage"
    scope_key            = "{org}-sa-aea-{env}-{region_code}-{iterator}"
    role_definition_name = "Storage Queue Data Message Sender"
  }
  queue_role_on_ai_espi_storage = {
    umi_key              = "{org}-id-egst-espi-{env}-{region_code}-{iterator}"
    scope_source         = "ai_espi_storage"
    scope_key            = "{org}-sa-espi-{env}-{region_code}-{iterator}"
    role_definition_name = "Storage Queue Data Message Sender"
  }
}

eventgrid_system_topics = {
  "{org}-egst-aea-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "aea"
    bu                 = ""
    resource_type_code = "egst"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-SEA-NET01-00001"

    product_name    = "{org}_eventgrid_namespace"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "eventgrid_namespace"

    description         = "Event Grid system topic for AEA storage blob events"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    storage_account_key         = "{org}-sa-aea-{env}-{region_code}-{iterator}"
    umi_key                     = "{org}-id-egst-aea-{env}-{region_code}-{iterator}"
    resource_group_key          = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    eventgrid_system_topic_type = "Microsoft.Storage.StorageAccounts"

    eventgrid_system_topic_identity = {
      type = "UserAssigned"
    }

    event_subscriptions = {
      {org}-evgts-aea-01 = {
        eventgrid_system_topic_event_subscription_name                  = "{org}-evgts-aea-{env}-{region_code}-{iterator}"
        resource_group_key                                              = "{org}-rg-aea-{env}-{region_code}-{iterator}"
        eventgrid_system_topic_event_subscription_expiration_time_utc   = "2026-12-31T23:59:59Z"
        eventgrid_system_topic_event_subscription_event_delivery_schema = "EventGridSchema"

        eventgrid_system_topic_event_subscription_delivery_identity = {
          type                       = "UserAssigned"
          user_assigned_identity_key = "{org}-id-egst-aea-{env}-{region_code}-{iterator}"
        }

        eventgrid_system_topic_event_subscription_included_event_types = [
          "Microsoft.Storage.BlobCreated"
        ]
        subject_filter = {
          subject_begins_with = "/blobServices/default/containers/aea/blobs/jobs/"
          subject_ends_with   = "/input/manifest.json"
        }

        eventgrid_system_topic_event_subscription_storage_queue_endpoint = {
          storage_account_key                   = "{org}-sa-aea-{env}-{region_code}-{iterator}"
          queue_key                             = "aea-manifest-blob-events"
          queue_message_time_to_live_in_seconds = 3600
        }
      }
    }
  }
  "{org}-egst-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "espi"
    bu                 = ""
    resource_type_code = "egst"
    max_length         = 24
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    type                = "Infrastructure"
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-SEA-NET01-00001"

    product_name    = "{org}_eventgrid_namespace"
    product_version = "1.0.0.0"

    cost_allocation_unit = "TBD"
    budget_id            = ""

    criticality = ""
    environment = ""
    status      = ""
    service     = "eventgrid_namespace"

    description         = "Event Grid system topic for ESPI storage blob events"
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    storage_account_key         = "{org}-sa-espi-{env}-{region_code}-{iterator}"
    umi_key                     = "{org}-id-egst-espi-{env}-{region_code}-{iterator}"
    resource_group_key          = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    eventgrid_system_topic_type = "Microsoft.Storage.StorageAccounts"

    eventgrid_system_topic_identity = {
      type = "UserAssigned"
    }

    event_subscriptions = {
      {org}-evgts-espi-01 = {
        eventgrid_system_topic_event_subscription_name                  = "{org}-evgts-espi-{env}-{region_code}-{iterator}"
        resource_group_key                                              = "{org}-rg-espi-{env}-{region_code}-{iterator}"
        eventgrid_system_topic_event_subscription_expiration_time_utc   = "2026-12-31T23:59:59Z"
        eventgrid_system_topic_event_subscription_event_delivery_schema = "EventGridSchema"

        eventgrid_system_topic_event_subscription_delivery_identity = {
          type                       = "UserAssigned"
          user_assigned_identity_key = "{org}-id-egst-espi-{env}-{region_code}-{iterator}"
        }

        eventgrid_system_topic_event_subscription_included_event_types = [
          "Microsoft.Storage.BlobCreated"
        ]
        subject_filter = {
          subject_begins_with = "/blobServices/default/containers/espi-eval-input/blobs/"
          subject_ends_with   = ".xlsx"
        }

        eventgrid_system_topic_event_subscription_storage_queue_endpoint = {
          storage_account_key                   = "{org}-sa-espi-{env}-{region_code}-{iterator}"
          queue_key                             = "evaluationdata-blob-events"
          queue_message_time_to_live_in_seconds = 3600
        }
      }
    }
  }
}

# =============================================================================
# WAF policies (OWASP 3.2 + Bot Manager, Detection mode)
# =============================================================================
waf_policies = {
  "aea-waf-policy" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    au                 = ""
    app_code           = "aea"
    bu                 = ""
    owner              = ""
    resource_type_code = "waf"
    max_length         = 80
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""

    app_name             = "WAF Policy for AppGW"
    type                 = "Security"
    budget_id            = ""
    status               = ""
    service              = "Application Gateway"
    cost_allocation_unit = "Platform"
    compliance_required  = "No"

    name               = "{org}-waf-aea-{env}-{region_code}-{iterator}"
    resource_group_key = "{org}-rg-aea-{env}-{region_code}-{iterator}"

    managed_rules = {
      managed_rule_set = {
        owasp = {
          type    = "OWASP"
          version = "3.2"
        }
        bot-protection = {
          type    = "Microsoft_BotManagerRuleSet"
          version = "1.0"
        }
      }
    }

    policy_settings = {
      enabled                          = true
      mode                             = "Detection"
      request_body_check               = true
      max_request_body_size_in_kb      = 128
      file_upload_limit_in_mb          = 100
      request_body_enforcement         = true
      request_body_inspect_limit_in_kb = 128
    }

    custom_rules = null
  }
  "espi-waf-policy" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    au                 = ""
    app_code           = "espi"
    bu                 = ""
    owner              = ""
    resource_type_code = "waf"
    max_length         = 80
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""

    app_name             = "WAF Policy for AppGW"
    type                 = "Security"
    budget_id            = ""
    status               = ""
    service              = "Application Gateway"
    cost_allocation_unit = "Platform"
    compliance_required  = "No"

    name               = "{org}-waf-espi-{env}-{region_code}-{iterator}"
    resource_group_key = "{org}-rg-espi-{env}-{region_code}-{iterator}"

    managed_rules = {
      managed_rule_set = {
        owasp = {
          type    = "OWASP"
          version = "3.2"
        }
        bot-protection = {
          type    = "Microsoft_BotManagerRuleSet"
          version = "1.0"
        }
      }
    }

    policy_settings = {
      enabled                          = true
      mode                             = "Detection"
      request_body_check               = true
      max_request_body_size_in_kb      = 128
      file_upload_limit_in_mb          = 100
      request_body_enforcement         = true
      request_body_inspect_limit_in_kb = 128
    }

    custom_rules = null
  }
}

# =============================================================================
# Application Gateways (WAF_v2, private frontend, HTTP-only - TLS deferred)
# NOTE: private_ip_address values mirror the reference stack; they must sit
# within the {org}-snet-agw-aishared subnet range of the target region.
# =============================================================================
app_gateways = {
  "{org}-agw-aea-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    au                 = ""
    app_code           = "aea"
    bu                 = ""
    owner              = ""
    resource_type_code = "agw"
    max_length         = 80
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""

    region      = ""
    description = "Private Application Gateway for internal workloads (HTTP-only, no public IP)"

    app_name            = "Private AppGateway"
    type                = "LoadBalancer"
    status              = ""
    tier                = "WAF_v2"
    budget_id           = ""
    compliance_required = "No"

    resource_group_key = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    vnet_key           = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key         = "{org}-snet-agw-aishared-{env}-{region_code}-{iterator}"
    umi_key            = "{org}-id-agw-aea-{env}-{region_code}-{iterator}"
    waf_policy_key     = "aea-waf-policy"

    managed_identities = {
      system_assigned = false
    }

    frontend_ip_configuration_private = {
      name                          = "private-frontend-ip"
      private_ip_address            = "10.247.39.8"
      private_ip_address_allocation = "Static"
    }

    frontend_ports = {
      port-80 = {
        name = "port-80"
        port = 80
      }
    }

    backend_address_pools = {
      backend-pool-frontend = {
        name         = "backend-pool-frontend"
        ip_addresses = []
        fqdns        = ["{org}-app-aea-{env}-{region_code}-{iterator}.azurewebsites.net"]
      }
      backend-pool-backend-api = {
        name         = "backend-pool-backend-api"
        ip_addresses = []
        fqdns        = ["{org}-app-aea-{env}-{region_code}-02.azurewebsites.net"]
      }
    }

    backend_http_settings = {
      backend-setting-frontend = {
        name                                = "backend-setting-frontend"
        port                                = 80
        protocol                            = "Http"
        cookie_based_affinity               = "Disabled"
        request_timeout                     = 20
        pick_host_name_from_backend_address = true
        probe_name                          = "hp-frontend"
      }
      backend-settings-backend-api = {
        name                                = "backend-settings-backend-api"
        port                                = 80
        protocol                            = "Http"
        cookie_based_affinity               = "Disabled"
        request_timeout                     = 20
        pick_host_name_from_backend_address = true
        probe_name                          = "hp-backend-api"
      }
    }

    http_listeners = {
      http-listener-80 = {
        name                           = "http-listener-80"
        frontend_port_name             = "port-80"
        frontend_ip_configuration_name = "private-frontend-ip"
        protocol                       = "Http"
        require_sni                    = false
        host_names                     = []
      }
    }

    request_routing_rules = {
      rr-path-based = {
        name                       = "rr-path-based"
        rule_type                  = "PathBasedRouting"
        http_listener_name         = "http-listener-80"
        backend_address_pool_name  = "backend-pool-frontend"
        backend_http_settings_name = "backend-setting-frontend"
        priority                   = 100
        url_path_map_name          = "rr-path-based"
      }
    }

    url_path_map_configurations = {
      rr-path-based = {
        name                               = "rr-path-based"
        default_backend_address_pool_name  = "backend-pool-frontend"
        default_backend_http_settings_name = "backend-setting-frontend"
        path_rules = {
          api-paths = {
            name                       = "api-paths"
            paths                      = ["/api/*"]
            backend_address_pool_name  = "backend-pool-backend-api"
            backend_http_settings_name = "backend-settings-backend-api"
          }
        }
      }
    }

    sku = {
      name     = "WAF_v2"
      tier     = "WAF_v2"
      capacity = 0
    }

    autoscale_configuration = {
      min_capacity = 2
      max_capacity = 10
    }

    zones        = ["1", "2", "3"]
    http2_enable = true

    probe_configurations = {
      hp-backend-api = {
        name                                      = "hp-backend-api"
        protocol                                  = "Http"
        path                                      = "/health"
        interval                                  = 30
        minimum_servers                           = 0
        timeout                                   = 30
        unhealthy_threshold                       = 3
        host                                      = null
        port                                      = null
        pick_host_name_from_backend_http_settings = true
        match = {
          status_code = ["200-399"]
        }
      }
      hp-frontend = {
        name                                      = "hp-frontend"
        protocol                                  = "Http"
        path                                      = "/"
        interval                                  = 30
        minimum_servers                           = 0
        timeout                                   = 30
        unhealthy_threshold                       = 3
        host                                      = null
        port                                      = null
        pick_host_name_from_backend_http_settings = true
        match = {
          status_code = ["200-399"]
        }
      }
    }
  }
  "{org}-agw-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    au                 = ""
    app_code           = "espi"
    bu                 = ""
    owner              = ""
    resource_type_code = "agw"
    max_length         = 80
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""

    region      = ""
    description = "Private Application Gateway for ESPI workloads (HTTP-only, no public IP)"

    app_name            = "Private AppGateway"
    type                = "LoadBalancer"
    status              = ""
    tier                = "WAF_v2"
    budget_id           = ""
    compliance_required = "No"

    resource_group_key = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    vnet_key           = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key         = "{org}-snet-agw-aishared-{env}-{region_code}-{iterator}"
    umi_key            = "{org}-id-agw-espi-{env}-{region_code}-{iterator}"
    waf_policy_key     = "espi-waf-policy"

    managed_identities = {
      system_assigned = false
    }

    frontend_ip_configuration_private = {
      name                          = "private-frontend-ip"
      private_ip_address            = "10.247.39.5"
      private_ip_address_allocation = "Static"
    }

    frontend_ports = {
      port-80 = {
        name = "port-80"
        port = 80
      }
    }

    backend_address_pools = {
      backend-pool-1 = {
        name         = "backend-pool-1"
        ip_addresses = []
        fqdns        = ["{org}-apim-aishared-{env}-{region_code}-{iterator}.azure-api.net"]
      }
    }

    backend_http_settings = {
      http-setting-80 = {
        name                                = "backend-http-80"
        port                                = 80
        protocol                            = "Http"
        cookie_based_affinity               = "Disabled"
        request_timeout                     = 100
        pick_host_name_from_backend_address = true
        probe_name                          = "hp-http-80"
      }
    }

    http_listeners = {
      listener-80 = {
        name                           = "http-listener-80"
        frontend_port_name             = "port-80"
        frontend_ip_configuration_name = "private-frontend-ip"
        protocol                       = "Http"
        require_sni                    = false
        host_names                     = []
      }
    }

    request_routing_rules = {
      rule-1 = {
        name                       = "routing-rule-1"
        rule_type                  = "Basic"
        http_listener_name         = "http-listener-80"
        backend_address_pool_name  = "backend-pool-1"
        backend_http_settings_name = "backend-http-80"
        priority                   = 100
      }
    }

    sku = {
      name     = "WAF_v2"
      tier     = "WAF_v2"
      capacity = 0
    }

    autoscale_configuration = {
      min_capacity = 2
      max_capacity = 10
    }

    zones        = ["1", "2", "3"]
    http2_enable = true

    probe_configurations = {
      hp-http-80 = {
        name                                      = "hp-http-80"
        protocol                                  = "Http"
        path                                      = "/status"
        interval                                  = 30
        timeout                                   = 10
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = true
        match = {
          status_code = ["200-499"]
        }
      }
    }
  }
}
*/

# =============================================================================
# Standalone private endpoints (Document Intelligence). NIC-only; private DNS
# zone integration deferred until peering.
# =============================================================================
private_endpoints = {
  # --- REMOVED FROM THIS DEPLOYMENT (Document Intelligence AEA/ESPI PEs) ---
  /*
  "{org}-pe-di-aea-{env}-{region_code}-{iterator}" = {
    env                = ""
    au                 = ""
    app_code           = "di-aea"
    bu                 = ""
    owner              = ""
    resource_type_code = "pe"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    no_dashes       = false

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "Network Security and Connectivity"
    budget_id           = ""
    status              = ""
    service             = "Bastion"

    region              = ""
    description         = "Private endpoint for AEA Document Intelligence"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-MYW-NET01-00001"
    auto_delete         = "No"
    delete_after        = "TBD"
    integration_id      = "TBD"
    retention           = "TBD"
    experiment_phase    = "TBD"
    sandbox_type        = "NA"
    os                  = "TBD"
    patch_policy        = "Monthly-Standard"
    maintenance_window  = "Sun-02:00Z"
    last_vm_accessed    = "TBD"

    resource_group_key              = "{org}-rg-aea-{env}-{region_code}-{iterator}"
    network_interface_name          = "{org}-pe-di-aea-{env}-{region_code}-{iterator}-nic"
    vnet_key                        = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
    subnet_key                      = "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}"
    private_connection_resource_ref = "di:{org}-di-aea-{env}-{region_code}-{iterator}"
    subresource_names               = ["account"]
  }
  "{org}-pe-di-espi-{env}-{region_code}-{iterator}" = {
    env                = ""
    au                 = ""
    app_code           = "di-espi"
    bu                 = ""
    owner              = ""
    resource_type_code = "pe"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    no_dashes       = false

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "Network Security and Connectivity"
    budget_id           = ""
    status              = ""
    service             = "Bastion"

    region              = ""
    description         = "Private endpoint for ESPI Document Intelligence"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-MYW-NET01-00001"
    auto_delete         = "No"
    delete_after        = "TBD"
    integration_id      = "TBD"
    retention           = "TBD"
    experiment_phase    = "TBD"
    sandbox_type        = "NA"
    os                  = "TBD"
    patch_policy        = "Monthly-Standard"
    maintenance_window  = "Sun-02:00Z"
    last_vm_accessed    = "TBD"

    resource_group_key              = "{org}-rg-espi-{env}-{region_code}-{iterator}"
    network_interface_name          = "{org}-pe-di-espi-{env}-{region_code}-{iterator}-nic"
    vnet_key                        = "{org}-vnet-aifoundry-{env}-{region_code}-{iterator}"
    subnet_key                      = "{org}-snet-pe-aifoundry-{env}-{region_code}-{iterator}"
    private_connection_resource_ref = "di:{org}-di-espi-{env}-{region_code}-{iterator}"
    subresource_names               = ["account"]
  }
  */
  "{org}-pe-redis-aicommon-{env}-{region_code}-{iterator}" = {
    env                = ""
    au                 = ""
    app_code           = "pe-redis"
    bu                 = ""
    owner              = ""
    resource_type_code = "pe"

    org             = ""
    region_code     = ""
    base_name       = null
    additional_name = null
    iterator        = ""
    no_dashes       = false

    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = "Network Security and Connectivity"
    budget_id           = ""
    status              = ""
    service             = "Bastion"

    region              = ""
    description         = "Private endpoint for AI Common Managed Redis"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-{region_code}-NET01-00001"
    auto_delete         = "No"
    delete_after        = "TBD"
    integration_id      = "TBD"
    retention           = "TBD"
    experiment_phase    = "TBD"
    sandbox_type        = "NA"
    os                  = "TBD"
    patch_policy        = "Monthly-Standard"
    maintenance_window  = "Sun-02:00Z"
    last_vm_accessed    = "TBD"

    resource_group_key              = "{org}-rg-aicommon-{env}-{region_code}-{iterator}"
    network_interface_name          = "{org}-pe-redis-aicommon-{env}-{region_code}-{iterator}-nic"
    vnet_key                        = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
    subnet_key                      = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
    private_connection_resource_ref = "redis:{org}-redis-aicommon-{env}-{region_code}-{iterator}"
    subresource_names               = ["redisEnterprise"]
    dns_zone_keys                   = ["redis"]
  }
}

# =============================================================================
# Backup platform - Recovery Services Vault (VM / file share backup).
# CMK-encrypted via {org}-uami-rsv-aishared + {org}-cmk-rsv-aishared; the private
# endpoint registers into the shared `backup_azure` private DNS zone.
# =============================================================================
recovery_service_vaults = {
  "{org}-rsv-aishared-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    au                 = ""
    app_code           = "aishared"
    bu                 = ""
    owner              = ""
    resource_type_code = "rsv"
    max_length         = 50
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Azure Backup"

    # Optional Tags
    region              = ""
    desc                = "Recovery Services Vault for AI backup"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-AISHARED-01-00001"
    auto_delete         = "No"
    delete_after        = "TBD"
    integration_id      = "TBD"
    retention           = "TBD"
    experiment_phase    = "TBD"
    sandbox_type        = "NA"
    os                  = "TBD"
    patch_policy        = "Monthly-Standard"
    maintenance_window  = "Sun-02:00Z"
    last_vm_accessed    = "TBD"

    # Recovery Service Vault specific configuration
    sku                                            = "Standard"
    public_network_access_enabled                  = false
    soft_delete_enabled                            = true
    storage_mode_type                              = "ZoneRedundant"
    cross_region_restore_enabled                   = false
    classic_vmware_replication_enabled             = false
    immutability                                   = "Disabled"
    alerts_for_all_job_failures_enabled            = true
    alerts_for_critical_operation_failures_enabled = true

    # Managed Identity for CMK encryption
    managed_identities = {
      system_assigned             = false
      user_assigned_identity_refs = ["{org}-uami-rsv-aishared-{env}-{region_code}-{iterator}"]
    }

    # Customer Managed Key encryption
    customer_managed_key = {
      key_vault_key              = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
      key_ref                    = "{org}-cmk-rsv-aishared-{env}-{region_code}-{iterator}"
      key_version                = null
      user_assigned_identity_ref = "{org}-uami-rsv-aishared-{env}-{region_code}-{iterator}"
    }

    # Private endpoint (registers into the shared backup private DNS zone)
    private_endpoints = {
      "pe_backup" = {
        name                   = "{org}-pe-rsv-aishared-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-aishared-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-aishared-{env}-{region_code}-{iterator}"
        subresource_name       = "AzureBackup"
        dns_zone_keys          = ["backup_azure"]
        network_interface_name = "{org}-pe-rsv-aishared-{env}-{region_code}-{iterator}-nic"
      }
    }

    # Backup policies
    # VM backup policy - name must match the governance assignment
    # (subscription-{org}-AI-sea) backupPolicyId. Schedule/retention/timezone
    # mirror the org-standard {org}-rsv-vm-backup-policy used by every other
    # landing zone (identity/management/network/security) and the MYW reference.
    vm_backup_policy = {
      "{org}-rsv-vm-backup-policy" = {
        name                           = "{org}-rsv-vm-backup-policy"
        timezone                       = "Pacific Standard Time"
        instant_restore_retention_days = 5
        policy_type                    = "V2"
        frequency                      = "Daily" # Hourly, Daily or Weekly

        instant_restore_resource_group = {
          ps = {
            prefix = "prefix-"
            suffix = null
          }
        }

        backup = {
          time          = "22:00"
          hour_interval = 6
          hour_duration = 12
          weekdays      = ["Tuesday", "Saturday"]
        }

        # Daily retention: 30 days
        retention_daily = 30

        # Weekly retention: 6 weeks
        retention_weekly = {
          count    = 6
          weekdays = ["Tuesday", "Saturday"]
        }

        # Yearly retention: 10 years
        retention_yearly = {
          count             = 10
          months            = ["January", "June"]
          weekdays          = ["Tuesday", "Saturday"]
          weeks             = ["First", "Third"]
          days              = [3, 10, 20]
          include_last_days = false
        }
      }
    }

    file_share_backup_policy = {
      "{org}-rsv-fileshare-backup-policy" = {
        name      = "{org}-rsv-fileshare-backup-policy"
        timezone  = "Pacific Standard Time"
        frequency = "Daily"
        backup = {
          time = "22:00"
        }
        retention_daily = 30
        retention_weekly = {
          count    = 6
          weekdays = ["Tuesday", "Saturday"]
        }
        retention_monthly = {
          count             = 5
          days              = [3, 10, 20]
          include_last_days = false
        }
        retention_yearly = {
          count    = 10
          months   = ["January", "June"]
          weekdays = ["Tuesday", "Saturday"]
          weeks    = ["First", "Third"]
        }
      }
    }

    # Optional variables
    enable_telemetry = true
    tags             = {}
  }
}

# =============================================================================
# Backup platform - Backup Vault (Microsoft.DataProtection).
# CMK enabled out-of-band via azapi after the vault identity is granted crypto
# access on the Key Vault (see azapi_update_resource.backup_vault_cmk).
# =============================================================================
backup_vaults = {
  "{org}-bvault-aishared-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "aishared"
    bu                 = ""
    resource_type_code = "bvault"
    max_length         = 50
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Azure Backup"

    # Optional Tags
    region              = ""
    desc                = "Backup Vault for AI backup"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-AISHARED-01-00001"
    auto_delete         = "No"
    delete_after        = "TBD"
    integration_id      = "TBD"
    retention           = "TBD"
    experiment_phase    = "TBD"
    sandbox_type        = "NA"
    os                  = "TBD"
    patch_policy        = "Monthly-Standard"
    maintenance_window  = "Sun-02:00Z"
    last_vm_accessed    = "TBD"

    # Backup Vault specific configuration
    datastore_type = "VaultStore"
    redundancy     = "ZoneRedundant"
    soft_delete    = "AlwaysOn"
    immutability   = "Disabled"

    # Managed Identity configuration
    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-uami-bvault-aishared-{env}-{region_code}-{iterator}"
    }

    # Customer Managed Key encryption (applied post-deploy via azapi)
    customer_managed_key = {
      key_vault_key              = "{org}-kv-aishared-{env}-{region_code}-{iterator}"
      key_name                   = "{org}-cmk-bvault-aishared-{env}-{region_code}-{iterator}"
      key_version                = null
      user_assigned_identity_ref = "{org}-uami-bvault-aishared-{env}-{region_code}-{iterator}"
    }

    # Backup Policies
    backup_policies = {
      "{org}-bvault-blob-backup-policy" = {
        type                                   = "blob"
        name                                   = "{org}-bvault-blob-backup-policy"
        backup_repeating_time_intervals        = ["R/2024-09-17T06:33:16+00:00/P1D"]
        operational_default_retention_duration = "P30D"
        vault_default_retention_duration       = "P90D"
        time_zone                              = "Central Standard Time"
        retention_rules = [
          {
            name     = "Daily"
            duration = "P30D"
            priority = 30
            criteria = [{
              absolute_criteria = "FirstOfDay"
            }]
            life_cycle = [{
              data_store_type = "VaultStore"
              duration        = "P30D"
            }]
          },
          {
            name     = "Weekly"
            duration = "P42D"
            priority = 20
            criteria = [{
              absolute_criteria = "FirstOfWeek"
            }]
            life_cycle = [{
              data_store_type = "VaultStore"
              duration        = "P30D"
            }]
          },
          {
            name     = "Yearly"
            duration = "P5475D"
            priority = 10
            criteria = [{
              absolute_criteria = "FirstOfYear"
            }]
            life_cycle = [{
              data_store_type = "VaultStore"
              duration        = "P30D"
            }]
          }
        ]
      },
      "{org}-bvault-disk-backup-policy" = {
        type                            = "disk"
        name                            = "{org}-bvault-disk-backup-policy"
        backup_repeating_time_intervals = ["R/2024-09-17T06:33:16+00:00/P1D"]
        default_retention_duration      = "P30D"
        time_zone                       = "Central Standard Time"
        retention_rules = [
          {
            name     = "Daily"
            priority = 25
            duration = "P30D"
            criteria = [{
              absolute_criteria = "FirstOfDay"
            }]
          },
          {
            name     = "Weekly"
            priority = 20
            duration = "P282D"
            criteria = [{
              absolute_criteria = "FirstOfWeek"
            }]
          }
        ]
      }
    }

    # Optional variables
    enable_telemetry = true
    tags             = {}
  }
  "{org}-bvault-aifoundry-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-aishared-{env}-{region_code}-{iterator}"

    # Naming module variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "aifoundry"
    bu                 = ""
    resource_type_code = "bvault"
    max_length         = 50
    no_dashes          = false
    add_random         = false
    rnd_length         = 4

    # Mandatory Tags
    environment         = ""
    business_owner      = ""
    business_unit       = ""
    criticality         = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_name            = ""
    budget_id           = ""
    status              = ""
    service             = "Azure Backup"

    # Optional Tags
    region              = ""
    desc                = "Backup Vault for AI Foundry backup"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-AIFOUNDRY-01-00001"
    auto_delete         = "No"
    delete_after        = "TBD"
    integration_id      = "TBD"
    retention           = "TBD"
    experiment_phase    = "TBD"
    sandbox_type        = "NA"
    os                  = "TBD"
    patch_policy        = "Monthly-Standard"
    maintenance_window  = "Sun-02:00Z"
    last_vm_accessed    = "TBD"

    # Backup Vault specific configuration
    datastore_type = "VaultStore"
    redundancy     = "ZoneRedundant"
    soft_delete    = "AlwaysOn"
    immutability   = "Disabled"

    # Managed Identity configuration
    managed_identities = {
      system_assigned = false
      umi_key         = "{org}-uami-bvault-aifoundry-{env}-{region_code}-{iterator}"
    }

    # Customer Managed Key encryption (applied post-deploy via azapi)
    customer_managed_key = {
      key_vault_key              = "{org}-kv-aifoundry-{env}-{region_code}-{iterator}"
      key_name                   = "{org}-cmk-bvault-aifoundry-{env}-{region_code}-{iterator}"
      key_version                = null
      user_assigned_identity_ref = "{org}-uami-bvault-aifoundry-{env}-{region_code}-{iterator}"
    }

    # Backup Policies
    backup_policies = {
      "{org}-bvault-blob-backup-policy" = {
        type                                   = "blob"
        name                                   = "{org}-bvault-blob-backup-policy"
        backup_repeating_time_intervals        = ["R/2024-09-17T06:33:16+00:00/P1D"]
        operational_default_retention_duration = "P30D"
        vault_default_retention_duration       = "P90D"
        time_zone                              = "Central Standard Time"
        retention_rules = [
          {
            name     = "Daily"
            duration = "P30D"
            priority = 30
            criteria = [{
              absolute_criteria = "FirstOfDay"
            }]
            life_cycle = [{
              data_store_type = "VaultStore"
              duration        = "P30D"
            }]
          },
          {
            name     = "Weekly"
            duration = "P42D"
            priority = 20
            criteria = [{
              absolute_criteria = "FirstOfWeek"
            }]
            life_cycle = [{
              data_store_type = "VaultStore"
              duration        = "P30D"
            }]
          },
          {
            name     = "Yearly"
            duration = "P5475D"
            priority = 10
            criteria = [{
              absolute_criteria = "FirstOfYear"
            }]
            life_cycle = [{
              data_store_type = "VaultStore"
              duration        = "P30D"
            }]
          }
        ]
      },
      "{org}-bvault-disk-backup-policy" = {
        type                            = "disk"
        name                            = "{org}-bvault-disk-backup-policy"
        backup_repeating_time_intervals = ["R/2024-09-17T06:33:16+00:00/P1D"]
        default_retention_duration      = "P30D"
        time_zone                       = "Central Standard Time"
        retention_rules = [
          {
            name     = "Daily"
            priority = 25
            duration = "P30D"
            criteria = [{
              absolute_criteria = "FirstOfDay"
            }]
          },
          {
            name     = "Weekly"
            priority = 20
            duration = "P282D"
            criteria = [{
              absolute_criteria = "FirstOfWeek"
            }]
          }
        ]
      }
    }

    # Optional variables
    enable_telemetry = true
    tags             = {}
  }
}
