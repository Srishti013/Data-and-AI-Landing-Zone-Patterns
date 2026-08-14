# =============================================================================
# {org} Data Landing Zone - consolidated tfvars.
#
# Tokenisation (rewritten by .github/workflows/data-pattern.yml from the deploy
# issue BEFORE plan/apply):
#   - Fields set to "" (subscription_id, env, region_code, org, au, bu, owner,
#     iterator, environment, region, business_owner, business_unit, criticality,
#     cost_center, data_classification, compliance, app_name, budget_id, status,
#     app_support) are globally value-substituted from the issue selections.
#   - {env} / {region_code} tokens in map KEYS and resource NAME fields are
#     token-substituted (e.g. {env}->dev, {region_code}->sea).
#   - app_code / resource_type_code / service stay literal so resource NAMES
#     differ per resource (that is what makes each RG/VNet/... name unique).
#
# user_principal_name / object_id / log_analytics_* / existing_private_dns_zones_rg_name
# are NOT in the sed list and keep their literal values below.
# =============================================================================

subscription_id = ""

# Platform subscriptions (display names) for the aliased providers. These are
# shared, region/env-agnostic platform subs, so they are literal.
subscriptions = {
  pvt_dns_zones_sub = {
    subscription_name = "{org}-plt-sub-network-prd-{region_code}-01"
  }
  law_sub = {
    subscription_name = "{org}-plt-sub-mgmt-prd-{region_code}-01"
  }
}

# Central Log Analytics Workspace (platform management sub).
log_analytics_workspace_name    = "{org}-law-ops-pd-{region_code}-01"
log_analytics_workspace_rg_name = "{org}-rg-mgmt-pd-{region_code}-01"

# SQL Azure AD administrator - matches the latest dev-data reference: an
# individual user is set as the AD admin, assigned by object_id (module maps
# user_principal_name -> azuread_administrator.login_username). Update both
# lines (UPN + object_id) when replicating to another environment.
# SQL Azure AD administrator - DEMO: set to YOUR own AAD user (UPN + object_id).
user_principal_name = "REPLACE_ME@example.onmicrosoft.com"
object_id           = "00000000-0000-0000-0000-000000000000"

# Shared Private DNS Zones RG (platform network sub).
existing_private_dns_zones_rg_name = "{org}-rg-private-network-pd-{region_code}-01"

# Hub network this spoke peers to. The hub is the region's platform private
# firewall/DNS VNet (region-tokenized): for SEA it resolves to the SEA hub in
# {org}-plt-sub-network-prd-sea-01. `hub_key` in the VNet peering below refers to
# a key in this map. Required so private endpoints resolve via the central
# private DNS zones (CMK / KV / SQL / ADLS all depend on this).
hub_virtual_networks = {
  "hub" = {
    name                = "{org}-vnet-pvt-network-pd-{region_code}-01"
    resource_group_name = "{org}-rg-private-network-pd-{region_code}-01"
  }
}

existing_private_dns_zones = {
  "vault_core"    = { name = "privatelink.vaultcore.azure.net" }
  "sqlserver"     = { name = "privatelink.database.windows.net" }
  "storage_blob"  = { name = "privatelink.blob.core.windows.net" }
  "storage_dfs"   = { name = "privatelink.dfs.core.windows.net" }
  "storage_queue" = { name = "privatelink.queue.core.windows.net" }
  "adf"           = { name = "privatelink.datafactory.azure.net" }
  "adf_portal"    = { name = "privatelink.adf.azure.com" }
  "backup_azure"  = { name = "privatelink.{region_code}.backup.windowsazure.com" }
}

# =============================================================================
# Resource Groups (datashared / datastorage / dataingestion / dataanalytics)
# =============================================================================
data_resource_groups = {
  "{org}-rg-datashared-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "datashared"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
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
    product_name        = "{org}_resource_group"
    product_version     = "1.0.0.0"
    app_support         = ""

    region              = ""
    description         = "Data landing zone - shared infrastructure resource group."
    notification_emails = ["platform-alerts@example.com"]
    review_required     = "Yes"
  }
  "{org}-rg-datastorage-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "datastorage"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
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
    product_name        = "{org}_resource_group"
    product_version     = "1.0.0.0"
    app_support         = ""

    region              = ""
    description         = "Data landing zone - storage (ADLS) resource group."
    notification_emails = ["platform-alerts@example.com"]
    review_required     = "Yes"
  }
  "{org}-rg-dataingestion-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "dataingestion"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
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
    product_name        = "{org}_resource_group"
    product_version     = "1.0.0.0"
    app_support         = ""

    region              = ""
    description         = "Data landing zone - ingestion (ADF) resource group."
    notification_emails = ["platform-alerts@example.com"]
    review_required     = "Yes"
  }
  "{org}-rg-dataanalytics-{env}-{region_code}-{iterator}" = {
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    app_code           = "dataanalytics"
    bu                 = ""
    owner              = ""
    resource_type_code = "rg"
    max_length         = 90
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
    product_name        = "{org}_resource_group"
    product_version     = "1.0.0.0"
    app_support         = ""

    region              = ""
    description         = "Data landing zone - analytics (Fabric) resource group."
    notification_emails = ["platform-alerts@example.com"]
    review_required     = "Yes"
  }
}

# =============================================================================
# Network Security Groups (PE / Data / Internal-Data subnets)
# =============================================================================
network_security_groups = {
  "{org}-nsg-pe-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    au                  = ""
    app_code            = "pe-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "nsg"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
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
    service             = "Bastion"
    region              = ""
    description         = "NSG for the data private-endpoint subnet."
    notification_emails = ["platform-alerts@example.com"]

    resource_group_key = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    security_rules = {
      Allow-Bastion-RDP-SSH = {
        name                       = "Allow-Bastion-RDP-SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["22", "3389"]
        source_address_prefix      = "" # AzureBastionSubnet CIDR in HUB (injected by workflow from BASTION_CIDR)
        destination_address_prefix = "*"
      }
    }
  }
  "{org}-nsg-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    au                  = ""
    app_code            = "data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "nsg"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
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
    service             = "Data"
    region              = ""
    description         = "NSG for the data services subnet."
    notification_emails = ["platform-alerts@example.com"]

    resource_group_key = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    security_rules     = {}
  }
  "{org}-nsg-int-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    au                  = ""
    app_code            = "int-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "nsg"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
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
    service             = "Data"
    region              = ""
    description         = "NSG for the internal data (compute) subnet."
    notification_emails = ["platform-alerts@example.com"]

    resource_group_key = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    security_rules     = {}
  }
  "{org}-nsg-consumption-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    au                  = ""
    app_code            = "consumption-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "nsg"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
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
    service             = "Data"
    region              = ""
    description         = "NSG for the consumption data subnet."
    notification_emails = ["platform-alerts@example.com"]

    resource_group_key = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    security_rules     = {}
  }
}

# =============================================================================
# Virtual Network + subnets. VNet address space and subnet prefixes are
# rewritten by the workflow from the deploy-issue network inputs.
# =============================================================================
virtual_networks = {
  "{org}-vnet-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    app_code            = "data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "vnet"
    max_length          = 63
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
    service             = "Networking"
    region              = ""
    description         = "Data landing zone virtual network."
    notification_emails = ["platform-alerts@example.com"]

    address_space      = []
    resource_group_key = "{org}-rg-datashared-{env}-{region_code}-{iterator}"

    # VNet peering to the platform hub network (cross-subscription). `hub_key`
    # refers to a key in `hub_virtual_networks`; the module resolves the remote
    # hub VNet resource id and creates the reverse peering in the hub. Required
    # for private DNS resolution (CMK / Key Vault / SQL / ADLS private endpoints)
    # and firewall egress.
    peerings = {
      "to-hub" = {
        name                                 = "{org}-peer-data-to-hub-{env}-{region_code}-{iterator}"
        hub_key                              = "hub"
        allow_forwarded_traffic              = true
        allow_virtual_network_access         = true
        create_reverse_peering               = true
        reverse_name                         = "{org}-peer-hub-to-data-{env}-{region_code}-{iterator}"
        reverse_allow_forwarded_traffic      = true
        reverse_allow_virtual_network_access = true
      }
    }

    # DNS forwarded to the hub DNS Private Resolver inbound endpoint so the
    # spoke resolves the shared private DNS zones (vault_core, backup_azure, ...)
    # through the hub. Injected by the workflow from the issue form's DNS Resolver IP.
    dns_servers = {
      dns_servers = [""]
    }

    subnets = {
      "{org}-snet-pe-data-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-pe-data-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          nsg_key = "{org}-nsg-pe-data-{env}-{region_code}-{iterator}"
        }
      }
      "{org}-snet-data-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-data-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          nsg_key = "{org}-nsg-data-{env}-{region_code}-{iterator}"
        }
      }
      "{org}-snet-int-data-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-int-data-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          nsg_key = "{org}-nsg-int-data-{env}-{region_code}-{iterator}"
        }
      }
      "{org}-snet-consumption-data-{env}-{region_code}-{iterator}" = {
        name           = "{org}-snet-consumption-data-{env}-{region_code}-{iterator}"
        address_prefix = ""
        network_security_group = {
          nsg_key = "{org}-nsg-consumption-data-{env}-{region_code}-{iterator}"
        }
      }
    }

    # Custom DNS (central resolver inbound endpoint) - region-specific. Hub
    # peering is now in place, so private DNS resolves via the hub. Uncomment and
    # set to the target region's resolver inbound IP only if the spoke must
    # resolve the central private DNS zones directly (resolver inbound endpoint:
    # 10.247.2.196 = MYW, 10.247.130.196 = SEA).
    # dns_servers = { dns_servers = ["10.247.2.196"] }
  }
}

# =============================================================================
# Route Table - default route to the platform firewall.
# =============================================================================
route_tables = {
  "{org}-rt-datashared-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "datashared"
    bu                  = ""
    owner               = ""
    resource_type_code  = "rt"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    app_name            = ""
    business_unit       = ""
    business_owner      = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    criticality         = ""
    environment         = ""
    status              = ""
    service             = "network-routing"
    budget_id           = ""
    region              = ""
    description         = "Routes default traffic to the platform firewall."
    notification_emails = ["platform-alerts@example.com"]

    bgp_route_propagation_enabled = true
    routes = {
      "internet_traffic_to_firewall" = {
        name                   = "internet_traffic_to_firewall"
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "Internet"
        next_hop_in_ip_address = null
      }
    }
    subnet_associations = {
      "pe"          = { vnet_key = "{org}-vnet-data-{env}-{region_code}-{iterator}", subnet_key = "{org}-snet-pe-data-{env}-{region_code}-{iterator}" }
      "data"        = { vnet_key = "{org}-vnet-data-{env}-{region_code}-{iterator}", subnet_key = "{org}-snet-data-{env}-{region_code}-{iterator}" }
      "int"         = { vnet_key = "{org}-vnet-data-{env}-{region_code}-{iterator}", subnet_key = "{org}-snet-int-data-{env}-{region_code}-{iterator}" }
      "consumption" = { vnet_key = "{org}-vnet-data-{env}-{region_code}-{iterator}", subnet_key = "{org}-snet-consumption-data-{env}-{region_code}-{iterator}" }
    }
  }
}

# =============================================================================
# Key Vault (Standard) with CMK keys (ADLS + SQL TDE) and a private endpoint.
# =============================================================================
key_vaults = {
  "{org}-kv-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    owner               = ""
    app_code            = "data"
    bu                  = ""
    resource_type_code  = "kv"
    max_length          = 24
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-{region_code}-NET01-00001"
    criticality         = ""
    environment         = ""
    status              = ""
    service             = "key_vault"
    budget_id           = ""

    resource_group_key            = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    sku_name                      = "standard"
    public_network_access_enabled = false

    description         = "Data landing zone Key Vault (CMK)."
    region              = ""
    notification_emails = ["platform-alerts@example.com"]

    role_assignments = {
      "cmk_crypto_user" = {
        role_definition_id_or_name = "Key Vault Crypto Service Encryption User"
        principal_id               = null
        umi_key                    = "{org}-uami-sql-data-{env}-{region_code}-{iterator}"
      }
      "cmk_crypto_user_rsv" = {
        role_definition_id_or_name = "Key Vault Crypto Service Encryption User"
        principal_id               = null
        umi_key                    = "{org}-uami-rsv-data-{env}-{region_code}-{iterator}"
      }
      "cmk_crypto_user_bvault" = {
        role_definition_id_or_name = "Key Vault Crypto Service Encryption User"
        principal_id               = null
        umi_key                    = "{org}-uami-bvault-data-{env}-{region_code}-{iterator}"
      }
    }
    additional_tags = {}
    network_acls = {
      bypass                     = "AzureServices"
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    keys = {
      "{org}-cmk-sa-adls-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-sa-adls-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 4096
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2027-03-30T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P365D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-sql-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-sql-{env}-{region_code}-{iterator}"
        key_type        = "RSA"
        key_size        = 2048
        key_opts        = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
        expiration_date = "2027-07-29T00:00:00Z"
        rotation_policy = {
          automatic            = { time_before_expiry = "P30D" }
          expire_after         = "P60D"
          notify_before_expiry = "P30D"
        }
      }
      "{org}-cmk-rsv-data-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-rsv-data-{env}-{region_code}-{iterator}"
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
      "{org}-cmk-bvault-data-{env}-{region_code}-{iterator}" = {
        name            = "{org}-cmk-bvault-data-{env}-{region_code}-{iterator}"
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

    private_endpoints = {
      "{org}-pe-kv-data-{env}-{region_code}-{iterator}" = {
        vnet_key     = "{org}-vnet-data-{env}-{region_code}-{iterator}"
        subnet_key   = "{org}-snet-pe-data-{env}-{region_code}-{iterator}"
        name         = "{org}-pe-kv-data-{env}-{region_code}-{iterator}"
        dns_zone_key = "vault_core"
      }
    }
  }
}

# =============================================================================
# Application Insights (wired to central LAW).
# =============================================================================
application_insights = {
  "{org}-appi-data-{env}-{region_code}-{iterator}" = {
    resource_group_key  = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    env                 = ""
    au                  = ""
    app_code            = "data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "appi"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
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
    service             = "Monitoring"
    region              = ""
    description         = "Application Insights for the data landing zone."
    notification_emails = ["platform-alerts@example.com"]

    application_type           = "web"
    internet_ingestion_enabled = false
    internet_query_enabled     = false
  }
}

# =============================================================================
# User Managed Identities (SQL TDE, ADLS CMK, ADF).
# (Event Grid delivery identity is included with the opt-in Event Grid block.)
# =============================================================================
user_managed_identities = {
  # Backup platform identities (CMK for Recovery Services Vault + Backup Vault).
  "{org}-uami-rsv-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    app_code            = "rsv-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
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
    service             = "Identity"
    region              = ""
    description         = "UMI for Recovery Services Vault (CMK)."
    notification_emails = ["platform-alerts@example.com"]
    resource_group_key  = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    enable_telemetry    = true
  }
  "{org}-uami-bvault-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    app_code            = "bvault-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
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
    service             = "Identity"
    region              = ""
    description         = "UMI for Backup Vault (CMK)."
    notification_emails = ["platform-alerts@example.com"]
    resource_group_key  = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    enable_telemetry    = true
  }
  "{org}-uami-sql-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    app_code            = "sql-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
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
    service             = "Identity"
    region              = ""
    description         = "UMI for SQL Server TDE (CMK)."
    notification_emails = ["platform-alerts@example.com"]
    resource_group_key  = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    enable_telemetry    = true
  }
  "{org}-uami-sa-adls-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    app_code            = "adls-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id-sa"
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
    service             = "Identity"
    region              = ""
    description         = "UMI for the ADLS storage account (CMK)."
    notification_emails = ["platform-alerts@example.com"]
    resource_group_key  = "{org}-rg-datastorage-{env}-{region_code}-{iterator}"
    enable_telemetry    = true
  }
  "{org}-uami-adf-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    app_code            = "adf-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
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
    service             = "Identity"
    region              = ""
    description         = "UMI for Azure Data Factory."
    notification_emails = ["platform-alerts@example.com"]
    resource_group_key  = "{org}-rg-dataingestion-{env}-{region_code}-{iterator}"
    enable_telemetry    = true
  }
  # Event Grid System Topic identity UMI - user-assigned identity for the topic.
  "{org}-uami-egst-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    app_code            = "egst-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "id"
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
    service             = "Identity"
    region              = ""
    description         = "UMI for the Event Grid System Topic."
    notification_emails = ["platform-alerts@example.com"]
    resource_group_key  = "{org}-rg-datastorage-{env}-{region_code}-{iterator}"
    enable_telemetry    = true
  }
}

# =============================================================================
# Key Vault RBAC. (1) Runner identity -> KV Administrator (principal defaults to
# the authenticated client). (2) ADLS CMK UMI -> KV Crypto Service Encryption
# User (resolved by umi_key).
# =============================================================================
role_assignments_config = {
  runner_kv_admin = {
    key_vault_key        = "{org}-kv-data-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Administrator"
  }
  adls_umi_kv_crypto = {
    umi_key              = "{org}-uami-sa-adls-data-{env}-{region_code}-{iterator}"
    key_vault_key        = "{org}-kv-data-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Crypto Service Encryption User"
  }
}

# =============================================================================
# Key Vault secret - SQL admin password (value generated by random_password).
# =============================================================================
sql_server_secrets = {
  "admin_password" = {
    secret_name     = "{org}-kv-data-{env}-{region_code}-{iterator}-admin-password"
    key_vault_key   = "{org}-kv-data-{env}-{region_code}-{iterator}"
    content_type    = "sqlServerPassword"
    expiration_date = "2027-06-01T23:59:59Z"
  }
}

# =============================================================================
# SQL Server + database (TDE with the CMK SQL key) + private endpoint.
# =============================================================================
sql_servers = {
  "{org}-sql-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    owner               = ""
    app_code            = "data"
    bu                  = ""
    resource_type_code  = "sql"
    max_length          = 24
    no_dashes           = false
    add_random          = false
    rnd_length          = 4
    app_name            = ""
    app_support         = ""
    business_unit       = ""
    business_owner      = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    app_id              = "{org}-{region_code}-SQLS-001"
    criticality         = ""
    environment         = ""
    status              = ""
    service             = "sql_server"
    budget_id           = ""
    description         = "Data landing zone SQL Server."
    region              = ""
    notification_emails = ["platform-alerts@example.com"]
    additional_tags     = {}

    resource_group_key = "{org}-rg-datashared-{env}-{region_code}-{iterator}"
    umi_key            = "{org}-uami-sql-data-{env}-{region_code}-{iterator}"
    key_vault_key      = "{org}-kv-data-{env}-{region_code}-{iterator}"
    tde_key_name       = "{org}-cmk-sql-{env}-{region_code}-{iterator}"

    transparent_data_encryption_key_automatic_rotation_enabled = true
    server_version                                             = "12.0"
    administrator_login                                        = "sql_admin"
    enable_telemetry                                           = true
    express_vulnerability_assessment_enabled                   = true

    managed_identities = {
      system_assigned = false
      umi_key         = ["{org}-uami-sql-data-{env}-{region_code}-{iterator}"]
    }

    server_extended_auditing_policy = {
      enabled                 = true
      log_monitoring_enabled  = true
      retention_in_days       = 0
      diagnostic_setting_name = "{org}-diag-audit-master-sql-data-{env}-{region_code}-{iterator}"
    }

    diagnostic_settings = {
      sql_audit_to_law = {
        name                           = "{org}-diag-audit-sql-data-{env}-{region_code}-{iterator}"
        log_analytics_destination_type = "Dedicated"
        log_categories                 = []
        log_groups                     = []
        metric_categories              = ["AllMetrics"]
      }
    }

    databases = {
      "{org}-sqldb-data-{env}-{region_code}-{iterator}" = {
        name                        = "{org}-sqldb-data-{env}-{region_code}-{iterator}"
        create_mode                 = "Default"
        collation                   = "SQL_Latin1_General_CP1_CI_AS"
        license_type                = null
        max_size_gb                 = 50
        sku_name                    = "S0"
        min_capacity                = null
        auto_pause_delay_in_minutes = null
        zone_redundant              = false
        geo_backup_enabled          = true
        storage_account_type        = "Local"

        transparent_data_encryption_key_automatic_rotation_enabled = true

        long_term_retention_policy = {
          weekly_retention  = "P2W"
          monthly_retention = "PT0S"
          yearly_retention  = "PT0S"
          week_of_year      = 1
        }
      }
    }

    private_endpoints = {
      pe_sqlserver = {
        name                   = "{org}-pe-sqldb-data-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-data-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-data-{env}-{region_code}-{iterator}"
        subresource_name       = "sqlServer"
        dns_zone_key           = "sqlserver"
        network_interface_name = "{org}-pe-sqldb-data-{env}-{region_code}-{iterator}-nic"
      }
    }
  }
}

# =============================================================================
# Storage Account - ADLS Gen2 (ZRS, HNS, CMK) with blob + dfs private endpoints.
# =============================================================================
storage_accounts = {
  "{org}-st-adls-data-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-datastorage-{env}-{region_code}-{iterator}"
    env                = ""
    au                 = ""
    app_code           = "adls-data"
    bu                 = ""
    owner              = ""
    resource_type_code = "sa"
    org                = ""
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    max_length         = 24
    no_dashes          = true
    add_random         = false
    rnd_length         = 2

    app_name            = ""
    business_unit       = ""
    business_owner      = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    criticality         = ""
    environment         = ""
    status              = ""
    service             = "network-storage"
    budget_id           = ""
    description         = "ADLS Gen2 storage for the data landing zone."
    region              = ""
    notification_emails = ["platform-alerts@example.com"]
    backup_policy       = "PolicyBased"

    account_kind             = "StorageV2"
    account_tier             = "Standard"
    account_replication_type = "ZRS"
    access_tier              = "Hot"
    min_tls_version          = "TLS1_2"
    is_hns_enabled           = true
    allowed_copy_scope       = "AAD"

    managed_identities = {
      system_assigned = true
      umi_key         = "{org}-uami-sa-adls-data-{env}-{region_code}-{iterator}"
    }

    https_traffic_only_enabled        = true
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = false
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = false

    # Microsoft Defender for Storage data-scanner network exception (added by
    # main.tf using the deploy subscription id). Set to false if the target
    # subscription does NOT have Defender for Storage enabled, otherwise the
    # apply fails referencing a non-existent StorageDataScanner resource.
    enable_defender_datascanner_access = true

    network_rules = {
      bypass                     = ["AzureServices"]
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }

    customer_managed_key = {
      key_vault_key              = "{org}-kv-data-{env}-{region_code}-{iterator}"
      key_name                   = "{org}-cmk-sa-adls-{env}-{region_code}-{iterator}"
      key_version                = null
      user_assigned_identity_ref = "{org}-uami-sa-adls-data-{env}-{region_code}-{iterator}"
    }

    sas_policy = {
      expiration_period = "07.00:00:00"
      expiration_action = "Log"
    }

    # Lifecycle management policy (data retention / tiering by medallion zone)
    # raw     : delete 45 days after last modification
    # bronze  : retain in Hot tier for 2 years, then delete (no tiering, delete at 730d)
    # archive : Cold 2y (0->730d) -> Archive 3y (730->1825d) -> delete at 5y (1825d)
    storage_management_policy_rule = {
      "raw-delete-45d" = {
        enabled = true
        name    = "raw-delete-45d"
        actions = {
          base_blob = {
            delete_after_days_since_modification_greater_than = 45
          }
        }
        filters = {
          blob_types = ["blockBlob"]
          prefix_match = [
            "raw/sharepoint/espi/sensitive/",
            "raw/sharepoint/espi/non-sensitive/",
            "raw/WebApp/AEA/"
          ]
        }
      }
      "archive-retention-5y" = {
        enabled = true
        name    = "archive-retention-5y"
        actions = {
          base_blob = {
            tier_to_cold_after_days_since_modification_greater_than = 0
            delete_after_days_since_modification_greater_than       = 1825
          }
        }
        filters = {
          blob_types = ["blockBlob"]
          prefix_match = [
            "archive/sharepoint/espi/sensitive/",
            "archive/sharepoint/espi/non-sensitive/",
            "archive/WebApp/AEA/"
          ]
        }
      }
    }

    # Containers. raw1 is managed as a data_lake_gen2_filesystem below (so its
    # root "/" ACL can be set declaratively); archive stays a plain container.
    containers = {
      "archive" = {
        name          = "archive"
        public_access = "None"
        metadata      = {}
      }
    }

    # ADLS Gen2 filesystem(s) with root ("/") POSIX ACLs. Managing raw1 here lets
    # Terraform set the filesystem-root ACL declaratively. --x = execute-only
    # traversal: CFS group members can pass THROUGH root to reach teradata/cfs
    # without listing root contents (no sibling data exposed).
    storage_data_lake_gen2_filesystems = {
      "raw1" = {
        name = "raw1"
        ace = [
          # Required POSIX entries
          { type = "user", permissions = "rwx" },
          { type = "group", permissions = "r-x" },
          { type = "other", permissions = "---" },
          # Add group traversal ACEs (--x) with YOUR own AAD group object ids if needed.
        ]
      }
    }

    # Storage queue (Event Grid system-topic delivery target). Created via the
    # storage module's azapi control-plane resource
    # (Microsoft.Storage/storageAccounts/queueServices/queues), so the runner's
    # Contributor role is sufficient - no data-plane Storage Queue role needed.
    # Apps connect to it privately via the queue private endpoint below.
    # NOTE: the module's `queues` schema is { name, metadata, role_assignments,
    # timeouts } - queues have no `public_access` (that is container-only).
    queues = {
      "eventgrid_system_topic_queue" = {
        name = "{org}-egst-queue-01"
      }
    }

    private_endpoints = {
      "blob_pe" = {
        name                   = "{org}-pe-st-adls-data-{env}-{region_code}-{iterator}-blob"
        vnet_key               = "{org}-vnet-data-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-data-{env}-{region_code}-{iterator}"
        subresource_name       = "blob"
        dns_zone_key           = "storage_blob"
        network_interface_name = null
      }
      "dfs_pe" = {
        name                   = "{org}-pe-st-adls-data-{env}-{region_code}-{iterator}-dfs"
        vnet_key               = "{org}-vnet-data-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-data-{env}-{region_code}-{iterator}"
        subresource_name       = "dfs"
        dns_zone_key           = "storage_dfs"
        network_interface_name = null
      }
      "queue_pe" = {
        name                   = "{org}-pe-st-adls-data-{env}-{region_code}-{iterator}-queue"
        vnet_key               = "{org}-vnet-data-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-data-{env}-{region_code}-{iterator}"
        subresource_name       = "queue"
        dns_zone_key           = "storage_queue"
        network_interface_name = null
      }
    }
  }
}

# =============================================================================
# Azure Data Factory (managed VNet, system + user identities, Purview link,
# Azure + self-hosted IRs, managed private endpoints to the SQL Server + ADLS).
# =============================================================================
data_factories = {
  "{org}-adf-data-{env}-{region_code}-{iterator}" = {
    name               = "{org}-adf-data-{env}-{region_code}-{iterator}"
    resource_group_key = "{org}-rg-dataingestion-{env}-{region_code}-{iterator}"

    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    app_code            = "data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "adf"
    max_length          = 63
    no_dashes           = false
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
    service             = "DataPlatform"
    region              = ""
    description         = "Azure Data Factory for the data landing zone."
    notification_emails = ["platform-alerts@example.com"]
    additional_tags = {
      catalogUri = "https://api.purview-service.microsoft.com/catalog"
    }

    managed_identities = {
      system_assigned            = true
      user_assigned_resource_ids = []
    }
    umi_keys = ["{org}-uami-adf-data-{env}-{region_code}-{iterator}"]

    public_network_enabled          = false
    managed_virtual_network_enabled = true
    enable_telemetry                = true

    # Purview lineage/governance link - not used in the demo. Set to a Purview
    # account resource id in your environment to enable.
    purview_id = null

    managed_private_endpoints = {
      "sql_pe" = {
        subresource_name = "sqlServer"
        sql_server_key   = "{org}-sql-data-{env}-{region_code}-{iterator}"
      }
      "adls_sa_pe" = {
        subresource_name = "blob"
        adls_sa_key      = "{org}-st-adls-data-{env}-{region_code}-{iterator}"
      }
    }

    azure_integration_runtime_azure = {
      azure_ir_01 = {
        name     = "{org}-azure-ir-data-{env}-{region_code}-{iterator}"
        location = "auto"
      }
      azure_ir_02 = {
        name                    = "{org}-azure-ir-data-{env}-{region_code}-02"
        location                = "auto"
        virtual_network_enabled = true
        core_count              = 16
        time_to_live_min        = 30
      }
    }

    # Primary self-hosted IR - matches dev-data (created directly, NO
    # rbac_authorization/link; the SIT/UAT envs link to the dev primary, but we
    # replicate dev). The physical gateway node is registered out-of-band by ops
    # after the factory is created.
    integration_runtime_self_hosted = {
      self_hosted_ir_01 = {
        name     = "{org}-selfhosted-ir-data-{env}-{region_code}-{iterator}"
        location = "auto"
      }
    }
  }
}

# =============================================================================
# Standalone Private Endpoints for the Data Factory (dataFactory + portal).
# =============================================================================
private_endpoints = {
  "{org}-pe-adf-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    au                  = ""
    app_code            = "adf-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "pe"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    no_dashes           = false
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
    service             = "ADF"
    region              = ""
    description         = "Private endpoint for Azure Data Factory."
    notification_emails = ["platform-alerts@example.com"]

    resource_group_key              = "{org}-rg-dataingestion-{env}-{region_code}-{iterator}"
    network_interface_name          = "{org}-pe-adf-data-{env}-{region_code}-{iterator}-nic"
    vnet_key                        = "{org}-vnet-data-{env}-{region_code}-{iterator}"
    subnet_key                      = "{org}-snet-pe-data-{env}-{region_code}-{iterator}"
    private_connection_resource_ref = "adf:{org}-adf-data-{env}-{region_code}-{iterator}"
    subresource_names               = ["dataFactory"]
    dns_zone_keys                   = ["adf"]
  }
  "{org}-pe-portal-adf-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    au                  = ""
    app_code            = "portal-adf-data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "pe"
    org                 = ""
    region_code         = ""
    base_name           = null
    additional_name     = null
    iterator            = ""
    no_dashes           = false
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
    service             = "ADF"
    region              = ""
    description         = "Private endpoint for the Azure Data Factory portal."
    notification_emails = ["platform-alerts@example.com"]

    resource_group_key              = "{org}-rg-dataingestion-{env}-{region_code}-{iterator}"
    network_interface_name          = "{org}-pe-portal-adf-data-{env}-{region_code}-{iterator}-nic"
    vnet_key                        = "{org}-vnet-data-{env}-{region_code}-{iterator}"
    subnet_key                      = "{org}-snet-pe-data-{env}-{region_code}-{iterator}"
    private_connection_resource_ref = "adf:{org}-adf-data-{env}-{region_code}-{iterator}"
    subresource_names               = ["portal"]
    dns_zone_keys                   = ["adf_portal"]
  }
}

# =============================================================================
# Microsoft Fabric Capacity (analytics).
# =============================================================================
fabric_capacities = {
  "{org}-fc-data-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-dataanalytics-{env}-{region_code}-{iterator}"
    sku_name           = "F4"
    administration_members = [
      "{fabric_admin}"
    ]

    env                 = ""
    au                  = ""
    app_code            = "data"
    bu                  = ""
    owner               = ""
    resource_type_code  = "fc"
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    max_length          = 80
    no_dashes           = true
    add_random          = false
    rnd_length          = 4
    app_name            = ""
    business_unit       = ""
    business_owner      = ""
    cost_center         = ""
    data_classification = ""
    compliance          = ""
    criticality         = ""
    environment         = ""
    status              = ""
    service             = "fabric_capacity"
    budget_id           = ""
    description         = "Fabric capacity for the data landing zone."
    region              = ""
  }
}

# =============================================================================
# Consolidated cross-resource RBAC (replaces the standalone data_rbac root).
# In-stack principals resolve from umi_key (ADF UMI) or system_identity_key (ADF
# system MI); external principals (Purview MSI) use a literal principal_id.
# Scope resolves to a resource created in this stack via scope_key.
# =============================================================================
data_rbac_role_assignments = {
  adf_umi_on_key_vault = {
    umi_key              = "{org}-uami-adf-data-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-data-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Secrets User"
  }
  adf_system_on_key_vault = {
    system_identity_key  = "{org}-adf-data-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-kv-data-{env}-{region_code}-{iterator}"
    role_definition_name = "Key Vault Secrets User"
  }
  adf_umi_on_adls = {
    umi_key              = "{org}-uami-adf-data-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-st-adls-data-{env}-{region_code}-{iterator}"
    role_definition_name = "Storage Blob Data Contributor"
  }
  adf_system_on_adls = {
    system_identity_key  = "{org}-adf-data-{env}-{region_code}-{iterator}"
    scope_key            = "{org}-st-adls-data-{env}-{region_code}-{iterator}"
    role_definition_name = "Storage Blob Data Contributor"
  }
  # External-principal grants (Purview MSI / Fabric SP) removed for portability -
  # re-add with your own principal ids to wire Purview/Fabric governance.
}

# =============================================================================
# Event Grid System Topic (BARE - no event subscriptions). Declared directly in
# main.tf with source_arm_resource_id (valid on azurerm < 4.37, the version this
# stack is pinned to via the {org}_fabric_capacity module). App teams add delivery
# subscriptions later.
# =============================================================================
eventgrid_system_topics = {
  "{org}-egst-data-{env}-{region_code}-{iterator}" = {
    env                 = ""
    org                 = ""
    region_code         = ""
    base_name           = ""
    additional_name     = ""
    iterator            = ""
    au                  = ""
    owner               = ""
    app_code            = "data"
    bu                  = ""
    resource_type_code  = "egst"
    max_length          = 24
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
    service             = "eventgrid_namespace"
    region              = ""
    description         = "Event Grid System Topic for ADLS blob events."
    notification_emails = ["platform-alerts@example.com"]

    storage_account_key         = "{org}-st-adls-data-{env}-{region_code}-{iterator}"
    umi_key                     = "{org}-uami-egst-data-{env}-{region_code}-{iterator}"
    resource_group_key          = "{org}-rg-datastorage-{env}-{region_code}-{iterator}"
    eventgrid_system_topic_type = "Microsoft.Storage.StorageAccounts"

    eventgrid_system_topic_identity = {
      type = "UserAssigned"
    }

    event_subscriptions = {}
  }
}

# =============================================================================
# Backup platform - Recovery Services Vault (VM / file share backup).
# CMK-encrypted via {org}-uami-rsv-data + {org}-cmk-rsv-data; the private endpoint
# registers into the shared `backup_azure` private DNS zone.
# =============================================================================
recovery_service_vaults = {
  "{org}-rsv-datashared-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-datashared-{env}-{region_code}-{iterator}"

    # Naming module required variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = null
    additional_name    = null
    iterator           = ""
    au                 = ""
    app_code           = "datashared"
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
    desc                = "Recovery Services Vault for data backup"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-DATA-01-00001"
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
      user_assigned_identity_refs = ["{org}-uami-rsv-data-{env}-{region_code}-{iterator}"]
    }

    # Customer Managed Key encryption
    customer_managed_key = {
      key_vault_key              = "{org}-kv-data-{env}-{region_code}-{iterator}"
      key_ref                    = "{org}-cmk-rsv-data-{env}-{region_code}-{iterator}"
      key_version                = null
      user_assigned_identity_ref = "{org}-uami-rsv-data-{env}-{region_code}-{iterator}"
    }

    # Private endpoint (registers into the shared backup private DNS zone)
    private_endpoints = {
      "pe_backup" = {
        name                   = "{org}-pe-rsv-datashared-{env}-{region_code}-{iterator}"
        vnet_key               = "{org}-vnet-data-{env}-{region_code}-{iterator}"
        subnet_key             = "{org}-snet-pe-data-{env}-{region_code}-{iterator}"
        subresource_name       = "AzureBackup"
        dns_zone_keys          = ["backup_azure"]
        network_interface_name = "{org}-pe-rsv-datashared-{env}-{region_code}-{iterator}-nic"
      }
    }

    # Backup policies
    # VM backup policy - name must match the governance VM-backup assignment's
    # backupPolicyId. Schedule/retention/timezone mirror the org-standard
    # {org}-rsv-vm-backup-policy used by every other landing zone
    # (identity/management/network/security) and the MYW reference.
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
  "{org}-bvault-datashared-{env}-{region_code}-{iterator}" = {
    resource_group_key = "{org}-rg-datashared-{env}-{region_code}-{iterator}"

    # Naming module variables
    env                = ""
    org                = ""
    region_code        = ""
    base_name          = ""
    additional_name    = ""
    iterator           = ""
    au                 = ""
    owner              = ""
    app_code           = "datashared"
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
    desc                = "Backup Vault for data backup"
    notification_emails = ["platform-alerts@example.com"]
    app_id              = "{org}-DATA-01-00001"
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
      umi_key         = "{org}-uami-bvault-data-{env}-{region_code}-{iterator}"
    }

    # Customer Managed Key encryption (applied post-deploy via azapi)
    customer_managed_key = {
      key_vault_key              = "{org}-kv-data-{env}-{region_code}-{iterator}"
      key_name                   = "{org}-cmk-bvault-data-{env}-{region_code}-{iterator}"
      key_version                = null
      user_assigned_identity_ref = "{org}-uami-bvault-data-{env}-{region_code}-{iterator}"
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
