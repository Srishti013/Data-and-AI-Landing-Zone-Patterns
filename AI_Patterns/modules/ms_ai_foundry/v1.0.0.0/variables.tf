##############################
##Foundry
##############################
variable "ai_foundry_accounts" {
  description = "Map of AI Foundry Cognitive Service accounts"

  type = map(object({
    name      = optional(string)
    parent_id = string
    location  = optional(string)

    sku_name = string

    identity_type = optional(string)
    identity_id   = optional(string)

    disableLocalAuth       = bool
    allowProjectManagement = bool
    customSubDomainName    = string
    publicNetworkAccess    = string

    # Managed VNet - Network Injection
    restrict_outbound_network_access = optional(bool, false)
    allowed_fqdn_list                = optional(list(string), [])

    encryption = optional(object({
      key_source         = optional(string, "Microsoft.KeyVault")
      key_vault_uri      = string
      key_name           = string
      key_version        = optional(string, null)
      identity_client_id = string
    }), null)

    # VNet injection for Standard Agents
    network_injections = optional(list(object({
      scenario                      = optional(string, "agent")
      subnet_arm_id                 = string
      use_microsoft_managed_network = optional(bool, false)
    })))

    # Network ACLs for inbound access control
    network_acls = optional(object({
      bypass                = optional(string, "AzureServices") # Allow trusted Azure services to bypass firewall
      default_action        = optional(string, "Deny")
      ip_rules              = optional(list(string), [])
      virtual_network_rules = optional(list(string), []) # Subnet resource IDs
    }))

    # Customer-owned storage for policy compliance
    user_owned_storage = optional(list(object({
      resource_id        = string
      identity_client_id = optional(string)
    })), [])

  }))
}

#######################################
###Foundry Project
######################################
variable "ai_foundry_projects" {
  type = map(object({
    name          = optional(string)
    account_key   = optional(string) # Key into ai_foundry_accounts to auto-resolve parent_id
    parent_id     = optional(string) # Direct account ID (alternative to account_key)
    location      = optional(string)
    sku_name      = string
    displayName   = optional(string)
    description   = optional(string)
    identity_type = string
    identity_id   = optional(string)

    # Diagnostic settings for the AI Foundry project. The map key is deliberately
    # arbitrary to avoid issues where map keys may be unknown at plan time.
    diagnostic_settings = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, proj in var.ai_foundry_projects : alltrue([
        for _, ds in proj.diagnostic_settings :
        ds.workspace_resource_id != null || ds.storage_account_resource_id != null || ds.event_hub_authorization_rule_resource_id != null || ds.marketplace_partner_resource_id != null
      ])
    ])
    error_message = "Each project diagnostic setting must set at least one of `workspace_resource_id`, `storage_account_resource_id`, `event_hub_authorization_rule_resource_id`, or `marketplace_partner_resource_id`."
  }

  validation {
    condition = alltrue([
      for _, proj in var.ai_foundry_projects : alltrue([
        for _, ds in proj.diagnostic_settings :
        contains(["Dedicated", "AzureDiagnostics"], ds.log_analytics_destination_type)
      ])
    ])
    error_message = "Project diagnostic setting `log_analytics_destination_type` must be one of: 'Dedicated', 'AzureDiagnostics'."
  }
}

######################################
###Open AI Deployment Model
######################################
variable "ai_foundry_deployments" {
  type = map(object({
    name            = optional(string)
    account_key     = optional(string) # Key into ai_foundry_accounts to auto-resolve parent_id
    parent_id       = optional(string) # Direct account ID (alternative to account_key)
    sku_name        = string
    capacity        = number
    model_format    = string
    model_name      = string
    model_version   = string
    rai_policy_name = optional(string) # Name of RAI policy to attach to this deployment
  }))
  default = {}
}

###########################
##RAI Policy
###########################
variable "ai_foundry_rai_policy" {
  description = "Optional RAI policies for AI Foundry accounts"
  type = map(object({
    name                 = optional(string)
    base_policy_name     = optional(string)
    account_key          = optional(string) # Key into ai_foundry_accounts to auto-resolve cognitive_account_id
    cognitive_account_id = optional(string) # Direct account ID (alternative to account_key)
    mode                 = optional(string, "Default")
    api_version          = optional(string, "2024-10-01") # RAI policy REST API version (override for preview filters)
    tags                 = optional(map(string), {})

    content_filters = optional(list(object({
      name               = string
      severity_threshold = optional(string) # Only valid for harm categories (Hate/Sexual/Selfharm/Violence). Omit for advanced filters.
      source             = string
      filter_enabled     = optional(bool, true)
      block_enabled      = optional(bool, true)
    })), [])
  }))
  default = {}
}

# Naming Module Variables
# -################################
variable "env" {
  type        = string
  description = "(Required) Environment code. Example: `test`."
}

variable "au" {
  type        = string
  description = "(Required) Accounting Unit (AU) code. Example: `0233985`."
  validation {
    condition     = can(regex("^[[:digit:]]+$", var.au))
    error_message = "Value for \"au\" must be of numeric characters."
  }
}

variable "owner" {
  type        = string
  description = "(Required) Technology owner group."
}

variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation. Example: `kv`."
  default     = "kv"
}

variable "app_code" {
  type        = string
  description = "(Required) Application code. Example: network, mgmt, build"
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code. Example: IT or mbb."
}

# -
# Mandatory Business Tags
# -
variable "app_name" {
  type        = string
  description = "(Required) Human readable name for the Application."
}

variable "business_unit" {
  type        = string
  description = "(Required) Department that owns the resources."
}

variable "business_owner" {
  type        = string
  description = "(Required) Contact name of the application owner."
}

variable "type" {
  type        = string
  description = "(Required) Infrastructure or business service type."
  default     = "Infrastructure"
}

# -
# Mandatory DevOps Tags
# -
variable "product_name" {
  type        = string
  description = "(Required) Terraform Module name."
  default     = "key_vault"
}

# -
# Mandatory Finance Tags
# -
variable "cost_center" {
  type        = string
  description = "(Required) Cost center that should bear the costs."
  default     = ""
}

variable "cost_allocation_unit" {
  type        = string
  default     = ""
  description = "(Required) Logical bucket to split shared platform cost."
}

variable "budget_id" {
  type        = string
  description = "(Required) Budget or GL code used by Finance."
}

variable "budget_limit" {
  type        = string
  description = "(Required) Maximum budget allocated."
  default     = ""
}

variable "cost_alert_threshold" {
  type        = string
  description = "(Required) Cost threshold for triggering alerts."
  default     = ""
}

# -
# Mandatory Governance Tags
# -
variable "data_classification" {
  type        = string
  description = "(optional) Data classification level."
  default     = ""
}

variable "compliance_required" {
  type        = string
  description = "(Required) Does resource need to comply with standards?"
  validation {
    condition     = contains(["Yes", "No"], var.compliance_required)
    error_message = "Value must be Yes or No."
  }
  default = "No"
}

variable "compliance" {
  type        = string
  description = "(Required) Specific standard/regulation."
  default     = "None"
}

# -
# Mandatory Operation Tags
# -
variable "criticality" {
  type        = string
  description = "(Required) Workload SLA requirements."
}

variable "environment" {
  type        = string
  description = "(Required) Environment where the resource is located."
}

variable "status" {
  type        = string
  description = "(Required) Status of the resource."
  validation {
    condition     = contains(["Live", "Non-Operational", "Decommissioned"], var.status)
    error_message = "Value must be one of: Live, Non-Operational, Decommissioned."
  }
  default = "Live"
}

# -
# Optional Naming Variables
# -
variable "org" {
  type        = string
  description = "(Optional) Company/business unit code. Example: `mbb`."
  default     = "mbb"
}

variable "region_code" {
  type        = string
  description = "(Optional) Region code."
  validation {
    condition     = contains(["ea", "sea", "eu", "myw"], var.region_code)
    error_message = "Value of \"region_code\" must be one of: [ea,sea,eu,myw]."
  }
  default = "sea"
}

variable "additional_name" {
  type        = string
  description = "(Optional) Additional suffix to create resource uniqueness."
  default     = null
}

variable "iterator" {
  type        = string
  description = "(Optional) Iterator to create resource uniqueness."
  default     = null
}

variable "additional_tags" {
  description = "(Optional) Additional base tags."
  type        = map(string)
  default     = null
}

variable "base_name" {
  type        = string
  description = "(Optional) Application/Infrastructure base name."
  default     = null
}

variable "max_length" {
  type        = number
  description = "(Optional) Set the maximum length of the generated name."
  default     = 24
}

variable "no_dashes" {
  type        = bool
  description = "(Optional) When set to true, it will remove all '-' separators from the generated name."
  default     = true
}

variable "add_random" {
  type        = bool
  description = "(Optional) When set to true, it will add a random number at the name's end."
  default     = false
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Set the length of the random number generated."
  default     = 2
}

# -
# Optional Tags for Key Vault
# -
variable "delete_after" {
  type        = string
  description = "(Optional) Date after which resource should be deleted (MM/DD/YYYY)."
  default     = ""
}

variable "tier" {
  type        = string
  description = "(Optional) Network tier (VNet/subnet name)."
  default     = ""
}

variable "app_id" {
  type        = string
  description = "(Optional) Application ID from CMDB."
  default     = ""
}

variable "auto_delete" {
  type        = string
  description = "(Optional) Should resource be auto-deleted? (Yes/No)."
  default     = ""
}

variable "auto_shutdown" {
  type        = string
  description = "(Optional) Auto-shutdown configuration for cost optimization."
  default     = ""
}

variable "description" {
  type        = string
  description = "(Optional) Brief description of the resource purpose."
  default     = ""
}

variable "backup_policy" {
  type        = string
  description = "(Optional) Backup policy (Manual or Policy Based)."
  default     = ""
}

variable "disaster_recovery" {
  type        = string
  description = "(Optional) DR requirements."
  default     = ""
}

variable "notification_emails" {
  type        = list(string)
  description = "(Optional) List of emails for notifications."
  default     = [""]
}

variable "region" {
  type        = string
  description = "(Optional) Cloud region where resource is deployed."
  default     = ""
}

# -
# Additional Optional Tag Variables
# -
variable "service" {
  type        = string
  description = "(Required) Service name or identifier."
}

variable "integration_id" {
  type        = string
  description = "(Optional) Integration ID for the resource."
  default     = ""
}

variable "experiment_phase" {
  type        = string
  description = "(Optional) Experiment phase for sandbox environments."
  default     = ""
}

variable "os" {
  type        = string
  description = "(Optional) Operating System type."
  default     = ""
}

variable "last_vm_accessed" {
  type        = string
  description = "(Optional) Last VM access timestamp."
  default     = ""
}

variable "retention" {
  type        = string
  description = "(Optional) Data retention policy."
  default     = ""
}

variable "sandbox_type" {
  type        = string
  description = "(Optional) Type of sandbox environment."
  default     = ""
}

variable "patch_policy" {
  type        = string
  description = "(Optional) Patch policy configuration."
  default     = ""
}

variable "maintenance_window" {
  type        = string
  description = "(Optional) Maintenance window schedule."
  default     = ""
}

##############################
## AI Foundry Project Connections
##############################
variable "ai_foundry_project_connections" {
  description = "Map of connections from AI Foundry Project to external services (Cosmos DB, AI Search, Storage, etc.)"
  type = map(object({
    name        = string
    project_key = optional(string) # Key into ai_foundry_projects to auto-resolve parent_id
    parent_id   = optional(string) # Direct project ID (alternative to project_key)

    category = string # "CognitiveSearch", "CosmosDb", "AzureBlob", "AIServices", "AzureOpenAI"
    target   = string # Endpoint URL

    auth_type       = optional(string, "AAD") # "AAD", "ApiKey", "AccountKey", "ManagedIdentity"
    credentials_key = optional(string)        # API key or account key for non-AAD auth

    # Additional metadata (e.g., databaseName for CosmosDb, ContainerName for AzureBlob)
    metadata = optional(map(string), {})
  }))
  default = {}
}

##############################
## Standard Agent - Private Endpoint
##############################
variable "private_endpoint_config" {
  description = "Private endpoint configuration for AI Foundry account"
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    subnet_id           = string
    account_key         = string # Key into ai_foundry_accounts
    subresource_names   = optional(list(string), ["account"])
    dns_zone_ids        = optional(list(string), [])
  })
  default = null
}

##############################
## Standard Agent - Account-Level Connections
##############################
variable "account_connections" {
  description = "Map of account-level connections (shared to all projects). For Standard Agent: Storage, Search, Cosmos."
  type = map(object({
    name        = optional(string)
    account_key = string # Key into ai_foundry_accounts
    category    = string # "AzureStorageAccount", "CognitiveSearch", "CosmosDb"
    target      = string # Resource endpoint URL
    auth_type   = optional(string, "AAD")
    is_shared   = optional(bool, true)
    credentials = optional(map(string), {})
    metadata    = optional(map(string), {})
  }))
  default = {}
}

##############################
## Standard Agent - Role Assignments (Account Identity)
##############################
variable "role_assignments" {
  description = "Map of role assignments for AI Foundry account identity (UMI) to access dependent resources"
  type = map(object({
    scope                = string
    role_definition_name = string
    principal_id         = string
    description          = optional(string, "")
  }))
  default = {}
}

##############################
## Standard Agent - Cosmos DB SQL Role Assignments (Account Identity)
##############################
variable "cosmos_role_assignments" {
  description = "Map of Cosmos DB SQL role assignments for account identity (data plane access)"
  type = map(object({
    cosmos_account_name = string
    resource_group_name = string
    role_definition_id  = string
    principal_id        = string
    scope               = string
  }))
  default = {}
}

##############################
## Standard Agent - Project Role Assignments (Before Capability Host)
##############################
variable "project_role_assignments" {
  description = "Map of role assignments for project identities (UMI) to access resources BEFORE capability host creation"
  type = map(object({
    scope                = string
    role_definition_name = string
    principal_id         = string
    description          = optional(string, "")
  }))
  default = {}
}

##############################
## Standard Agent - Account Capability Host
##############################
variable "account_capability_hosts" {
  description = "Map of account-level capability hosts (sets up Agent runtime subnet)"
  type = map(object({
    name                 = optional(string, "default")
    account_key          = string # Key into ai_foundry_accounts
    capability_host_kind = optional(string, "Agents")
    subnet_id            = string # Agent subnet ARM ID
  }))
  default = {}
}

##############################
## Standard Agent - Project Capability Hosts
##############################
variable "project_capability_hosts" {
  description = "Map of project-level capability hosts (enables Standard Agent per project)"
  type = map(object({
    name                       = optional(string, "default")
    project_key                = optional(string) # Key into ai_foundry_projects (same-stack projects)
    parent_id                  = optional(string) # Existing project ARM id (cross-stack; alternative to project_key)
    capability_host_kind       = optional(string, "Agents")
    storage_connections        = list(string) # Connection names for storage
    thread_storage_connections = list(string) # Connection names for Cosmos DB
    vector_store_connections   = optional(list(string), [])
  }))
  default = {}
}

##############################
## Standard Agent - Post-CH Cosmos Role Assignments
##############################
variable "project_cosmos_role_assignments" {
  description = "Map of Cosmos DB SQL role assignments for project identities (AFTER capability host)"
  type = map(object({
    project_key         = string
    cosmos_account_name = string
    resource_group_name = string
    role_definition_id  = string
    principal_id        = string
    scope               = string
  }))
  default = {}
}

##############################
## Standard Agent - Post-CH Storage ABAC Role Assignments
##############################
variable "post_ch_storage_role_assignments" {
  description = "Map of Storage Blob Data Owner assignments with ABAC condition (AFTER capability host)"
  type = map(object({
    project_key  = string # Key into ai_foundry_projects (for internalId ABAC)
    principal_id = string
    scope        = string # Storage account resource ID
  }))
  default = {}
}

##############################
## Timing
##############################
variable "wait_after_role_assignments" {
  description = "Duration to wait after role assignments for RBAC propagation"
  type        = string
  default     = "60s"
}

variable "wait_after_account_creation" {
  description = "Duration to wait after account creation for auto-created account capability host to be ready"
  type        = string
  default     = "120s"
}
