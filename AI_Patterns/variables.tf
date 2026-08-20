variable "subscription_id" {
  description = "The subscription ID for the resources"
  type        = string
}

variable "resource_groups" {
  description = "Map of resource group definitions"
  type = map(object({
    env                = string
    org                = string
    region_code        = string
    base_name          = string
    additional_name    = optional(string, "")
    iterator           = string
    au                 = string
    app_code           = string
    bu                 = string
    owner              = string
    resource_type_code = string
    max_length         = optional(number, 90)
    no_dashes          = optional(bool, false)
    add_random         = optional(bool, false)
    rnd_length         = optional(number, 4)

    # Mandatory Tags
    environment         = string
    business_owner      = string
    business_unit       = string
    criticality         = string
    cost_center         = string
    data_classification = string
    compliance          = string
    app_name            = string
    budget_id           = string
    status              = string
    product_name        = string
    product_version     = string
    app_support         = string

    # Optional Tags
    region               = optional(string)
    description          = optional(string)
    notification_emails  = optional(list(string))
    automation_policy    = optional(string)
    review_required      = optional(string)
    backup_policy        = optional(string)
    disaster_recovery    = optional(string)
    cost_alert_threshold = optional(string)
    budget_limit         = optional(string)

    # Additional optional configurations
    lock             = optional(any)
    role_assignments = optional(any)
    additional_tags  = optional(map(string))
  }))
}

variable "virtual_networks" {
  description = "Map of virtual networks and their configuration"
  type        = any
  default     = {}
}

variable "network_security_groups" {
  description = "Map of Network Security Groups to create"
  type        = any
  default     = {}
}

variable "key_vaults" {
  description = "Map of Key Vaults to create"
  type        = any
  default     = {}
}

variable "route_tables" {
  description = "Map of Route Tables (UDRs) to create and associate with subnets"
  type        = any
  default     = {}
}

variable "user_managed_identities" {
  description = "Map of User Assigned Managed Identities to create"
  type        = any
  default     = {}
}

variable "storage_accounts" {
  description = "Map of Storage Accounts to create"
  type        = any
  default     = {}
}

variable "application_insights" {
  description = "Map of Application Insights instances to create"
  type        = any
  default     = {}
}

# -
# AI resources (Common AI layer)
# -
variable "internal_api_management" {
  description = "Map of internal API Management services to create"
  type        = any
  default     = {}
}

variable "ai_foundry_accounts" {
  description = "Map of AI Foundry (MS Foundry) accounts to create"
  type        = any
  default     = {}
}

variable "ai_foundry_projects" {
  description = "Map of AI Foundry projects to create under the account"
  type        = any
  default     = {}
}

variable "ai_foundry_deployments_01" {
  description = "Map of AI Foundry model (OpenAI) deployments"
  type        = any
  default     = {}
}

variable "ai_foundry_deployments_02" {
  description = "Map of AI Foundry model (OpenAI) deployments, created after deployment_01 (model creates on the same account must be sequential)"
  type        = any
  default     = {}
}

variable "ai_foundry_deployments_03" {
  description = "Map of AI Foundry model (OpenAI) deployments, created after deployment_02 (model creates on the same account must be sequential)"
  type        = any
  default     = {}
}

variable "ai_foundry_rai_policy" {
  description = "Map of Responsible-AI policies for AI Foundry accounts"
  type        = any
  default     = {}
}

variable "azure_container_registry" {
  description = "Map of Azure Container Registries to create"
  type        = any
  default     = {}
}

# -
# AI workload resources (Common / AEA / ESPI layers) ported from the AI LZ
# reference. All are simple `type = any` maps consumed by their for_each module
# blocks in main.tf.
# -
variable "managed_redis_instances" {
  description = "Map of Azure Managed Redis cache instances to create"
  type        = any
  default     = {}
}

variable "sql_servers" {
  description = "Map of Azure SQL Servers (and their databases) to create"
  type        = any
  default     = {}
}

variable "login_username" {
  description = "Display name of the Azure AD principal/group set as the SQL Server Azure AD administrator."
  type        = string
  default     = "REPLACE_ME"
}

variable "sql_admin_object_id" {
  description = "Object ID of the Azure AD principal/group set as the SQL Server Azure AD administrator."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "cosmosdb_accounts" {
  description = "Map of Azure Cosmos DB accounts to create"
  type        = any
  default     = {}
}

variable "app_service_plans" {
  description = "Map of App Service Plans to create"
  type        = any
  default     = {}
}

variable "app_services" {
  description = "Map of App Services (web apps) to create"
  type        = any
  default     = {}
}

variable "function_app_flex" {
  description = "Map of Flex Consumption Function Apps to create"
  type        = any
  default     = {}
}

variable "search_services" {
  description = "Map of Azure AI Search services to create"
  type        = any
  default     = {}
}

variable "bing_accounts" {
  description = "Map of Bing (Grounding) resources to create"
  type        = any
  default     = {}
}

variable "document_intelligence" {
  description = "Map of Document Intelligence (Form Recognizer) accounts to create"
  type        = any
  default     = {}
}

variable "eventgrid_system_topics" {
  description = "Map of Event Grid System Topics to create"
  type        = any
  default     = {}
}

variable "waf_policies" {
  description = "Map of Application Gateway Web Application Firewall policies to create"
  type        = any
  default     = {}
}

variable "app_gateways" {
  description = "Map of Application Gateways to create"
  type        = any
  default     = {}
}

variable "azure_openai_accounts" {
  description = "Dedicated Azure OpenAI (kind=OpenAI) cognitive accounts to create, each reached via a locked-down private endpoint."
  type        = any
  default     = {}
}

variable "private_endpoints" {
  description = "Map of standalone Private Endpoints to create (for resources whose module does not create its own PE)"
  type        = any
  default     = {}
}

variable "role_assignments_config_egst" {
  description = "Map of role assignments granting Event Grid System Topic identities access to their target storage queues"
  type        = any
  default     = {}
}

# Related subscriptions referenced by this pattern (display name -> resolved id).
# Used to connect Application Insights to the central Log Analytics Workspace,
# which lives in the management subscription.
variable "subscriptions" {
  description = "Map of related subscriptions referenced by this pattern, keyed by a logical name (e.g. law_sub)"
  type = map(object({
    subscription_name = string
  }))
  default = {}
}

variable "log_analytics_workspace_name" {
  description = "Name of the existing central Log Analytics Workspace that Application Insights is connected to"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_rg_name" {
  description = "Resource group name of the existing central Log Analytics Workspace"
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Cross-subscription hub network: VNet peering + shared private DNS zones.
# All optional / opt-in. When the maps below are left empty (the defaults) no
# peering is created and private endpoints stay NIC-only, preserving the
# current behaviour. Populate them in tfvars once the hub peering / private DNS
# path is in place to match the AI Landing Zone reference.
# ---------------------------------------------------------------------------

variable "hub_virtual_networks" {
  description = "Map of hub virtual networks (in the platform network subscription) that spoke VNets peer to, keyed by a logical hub key referenced from each peering's hub_key."
  type = map(object({
    name                = string
    resource_group_name = string
  }))
  default = {}
}

variable "existing_private_dns_zones_rg_name" {
  description = "Resource group name (in the platform network subscription) that holds the shared private DNS zones the private endpoints register into."
  type        = string
  default     = ""
}

variable "existing_private_dns_zones" {
  description = "Map of existing shared private DNS zones to read from the platform network subscription, keyed by a logical zone key referenced from each private endpoint's dns_zone_keys."
  type = map(object({
    name = string
  }))
  default = {}
}

variable "recovery_service_vaults" {
  description = "Map of Recovery Services Vaults to create (VM / file share backup). Empty by default so the stack is unchanged until tfvars populate them."
  type        = any
  default     = {}
}

variable "backup_vaults" {
  description = "Map of Backup Vaults (Microsoft.DataProtection) to create. Empty by default so the stack is unchanged until tfvars populate them."
  type        = any
  default     = {}
}

# ---------------------------------------------------------------------------
# Customer-Managed Key (CMK) encryption. All optional / opt-in. When the maps
# below are empty (the defaults) no Key Vault keys, no CMK role assignments and
# no per-resource CMK blocks are produced, so every resource keeps the current
# service-managed encryption behaviour. Populate them - together with each
# resource's `customer_managed_key` / `encryption` block in tfvars - to enable
# CMK, matching the AI Landing Zone reference.
# ---------------------------------------------------------------------------

variable "key_vault_keys" {
  description = "Map of Key Vault keys (and their parent Key Vault) that the resource CMK blocks read via data sources, keyed by a logical key referenced from each resource's customer_managed_key.key_vault_key. Empty by default (no CMK)."
  type = map(object({
    name                = string
    key_vault_name      = string
    resource_group_name = string
  }))
  default = {}
}

variable "role_assignments_config_cmk" {
  description = "Map of CMK role assignments granting a User Managed Identity (umi_key) the Key Vault crypto role on a Key Vault (scope_key resolves to a module.key_vault entry). Empty by default (no CMK RBAC, no rbac wait)."
  type = map(object({
    umi_key              = string
    scope_key            = string
    role_definition_name = string
  }))
  default = {}
}

# ---------------------------------------------------------------------------
# AI Foundry base RBAC. Grants the shared AI Foundry identity (umi_key) the
# control-plane roles it needs on the aishared / aicommon resource groups
# (scope_key resolves to a module.resource_group entry): Cosmos DB Operator,
# Storage Blob Data Contributor/Owner, Search Service Contributor, etc. Empty
# by default (no extra RBAC).
# ---------------------------------------------------------------------------
variable "role_assignments_config_foundry" {
  description = "Map of AI Foundry base role assignments granting a User Managed Identity (umi_key) a control-plane role on a resource group (scope_key resolves to a module.resource_group entry)."
  type = map(object({
    umi_key              = string
    scope_key            = string
    role_definition_name = string
  }))
  default = {}
}

# ---------------------------------------------------------------------------
# Cosmos DB data-plane RBAC. Grants a User Managed Identity (umi_key) the Cosmos
# DB Built-in Data Contributor SQL role on a Cosmos account (account_key /
# resource_group_key resolve to module.cosmosdb / module.resource_group
# entries). Empty by default (no data-plane RBAC).
# ---------------------------------------------------------------------------
variable "cosmosdb_sql_role_assignments" {
  description = "Map of Cosmos DB data-plane (SQL) role assignments granting a User Managed Identity (umi_key) the built-in Data Contributor role on a Cosmos account (account_key) in a resource group (resource_group_key)."
  type = map(object({
    resource_group_key = string
    account_key        = string
    umi_key            = string
  }))
  default = {}
}
