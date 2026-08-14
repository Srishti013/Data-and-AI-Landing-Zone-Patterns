# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the Resource Group where the Managed Redis instance should exist. Changing this forces a new resource to be created."
  nullable    = false
}

# -
# Managed Redis Resource Variables
# -

variable "sku_name" {
  type        = string
  description = <<DESCRIPTION
(Required) The SKU of the Managed Redis instance. Possible values include:
- Balanced: Balanced_B0, Balanced_B1, Balanced_B3, Balanced_B5, Balanced_B10, Balanced_B20, Balanced_B50, Balanced_B100, Balanced_B150, Balanced_B250, Balanced_B350, Balanced_B500, Balanced_B700, Balanced_B1000
- ComputeOptimized: ComputeOptimized_X3, ComputeOptimized_X5, ComputeOptimized_X10, ComputeOptimized_X20, ComputeOptimized_X50, ComputeOptimized_X100, ComputeOptimized_X150, ComputeOptimized_X250, ComputeOptimized_X350, ComputeOptimized_X500, ComputeOptimized_X700
- FlashOptimized: FlashOptimized_A250, FlashOptimized_A500, FlashOptimized_A700, FlashOptimized_A1000, FlashOptimized_A1500, FlashOptimized_A2000, FlashOptimized_A4500
DESCRIPTION
  nullable    = false

  validation {
    condition = contains([
      "Balanced_B0", "Balanced_B1", "Balanced_B3", "Balanced_B5", "Balanced_B10",
      "Balanced_B20", "Balanced_B50", "Balanced_B100", "Balanced_B150", "Balanced_B250",
      "Balanced_B350", "Balanced_B500", "Balanced_B700", "Balanced_B1000",
      "ComputeOptimized_X3", "ComputeOptimized_X5", "ComputeOptimized_X10",
      "ComputeOptimized_X20", "ComputeOptimized_X50", "ComputeOptimized_X100",
      "ComputeOptimized_X150", "ComputeOptimized_X250", "ComputeOptimized_X350",
      "ComputeOptimized_X500", "ComputeOptimized_X700",
      "FlashOptimized_A250", "FlashOptimized_A500", "FlashOptimized_A700",
      "FlashOptimized_A1000", "FlashOptimized_A1500", "FlashOptimized_A2000",
      "FlashOptimized_A4500"
    ], var.sku_name)
    error_message = "The sku_name must be a valid Managed Redis SKU (e.g., Balanced_B3, ComputeOptimized_X5, FlashOptimized_A250)."
  }
}

variable "high_availability_enabled" {
  type        = bool
  default     = true
  description = "(Optional) Whether to enable high availability for the Managed Redis instance. Defaults to `true`. Changing this forces a new resource to be created."
}

variable "public_network_access" {
  type        = string
  default     = "Disabled"
  description = "(Optional) The public network access setting for the Managed Redis instance. Possible values are `Enabled` and `Disabled`. Defaults to `Disabled`."

  validation {
    condition     = contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "Value must be one of: Enabled, Disabled."
  }
}

variable "managed_redis_identity" {
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  default     = null
  description = <<-EOT
 - `type` - (Required) Specifies the type of Managed Service Identity. Possible values are `SystemAssigned`, `UserAssigned`, `SystemAssigned, UserAssigned`.
 - `identity_ids` - (Optional) Specifies a list of User Assigned Managed Identity IDs. Required when `type` is `UserAssigned` or `SystemAssigned, UserAssigned`.
EOT

  validation {
    condition = (
      var.managed_redis_identity == null ||
      !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.managed_redis_identity.type) ||
      try(length(var.managed_redis_identity.identity_ids), 0) > 0
    )
    error_message = "When managed_redis_identity.type is `UserAssigned` or `SystemAssigned, UserAssigned`, managed_redis_identity.identity_ids must be set and contain at least one ID."
  }
}

variable "default_database" {
  type = object({
    access_keys_authentication_enabled = optional(bool, false)
    client_protocol                    = optional(string, "Encrypted")
    clustering_policy                  = optional(string, "OSSCluster")
    eviction_policy                    = optional(string, "VolatileLRU")
    geo_replication_group_name         = optional(string, null)
    persistence_aof_backup_frequency   = optional(string, null)
    persistence_rdb_backup_frequency   = optional(string, null)
    modules = optional(list(object({
      name = string
      args = optional(string, null)
    })), [])
  })
  nullable    = false
  description = <<DESCRIPTION
(Required when creating) The default database configuration for the Managed Redis instance:
- `access_keys_authentication_enabled` - (Optional) Whether access key authentication is enabled. Defaults to `false`.
- `client_protocol` - (Optional) Client connection protocol. Possible values: `Encrypted`, `Plaintext`. Defaults to `Encrypted`.
- `clustering_policy` - (Optional) Clustering policy. Possible values: `EnterpriseCluster`, `OSSCluster`, `NoCluster`. Defaults to `OSSCluster`. Changing forces recreation.
- `eviction_policy` - (Optional) Redis eviction policy. Possible values: `AllKeysLFU`, `AllKeysLRU`, `AllKeysRandom`, `VolatileLRU`, `VolatileLFU`, `VolatileTTL`, `VolatileRandom`, `NoEviction`. Defaults to `VolatileLRU`.
- `geo_replication_group_name` - (Optional) Name of the geo-replication group. Changing forces recreation.
- `persistence_aof_backup_frequency` - (Optional) AOF backup frequency. Only possible value: `1s`. Conflicts with `persistence_rdb_backup_frequency` and `geo_replication_group_name`.
- `persistence_rdb_backup_frequency` - (Optional) RDB backup frequency. Possible values: `1h`, `6h`, `12h`. Conflicts with `persistence_aof_backup_frequency` and `geo_replication_group_name`.
- `modules` - (Optional) A list of Redis modules to enable:
  - `name` - (Required) Module name. Possible values: `RedisBloom`, `RedisTimeSeries`, `RediSearch`, `RedisJSON`.
  - `args` - (Optional) Configuration options for the module.
DESCRIPTION
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<DESCRIPTION
 - `create` - (Defaults to 45 minutes) Used when creating the Managed Redis instance.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Managed Redis instance.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Managed Redis instance.
 - `update` - (Defaults to 30 minutes) Used when updating the Managed Redis instance.
DESCRIPTION
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "customer_managed_key" {
  type = object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  default     = null
  description = <<DESCRIPTION
An object describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.
DESCRIPTION  
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "diagnostic_settings" {
  type = map(object({
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
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Managed Redis instance. The map key is arbitrary and only used for resource addressing.
- `name` - (Optional) The name of the diagnostic setting. Defaults to `diag-<redis name>`.
- `log_categories` - (Optional) A set of individual log categories to enable. Defaults to `[]`.
- `log_groups` - (Optional) A set of log category groups to enable. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to enable. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for Log Analytics. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the Log Analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub to send logs and metrics to.
- `marketplace_partner_resource_id` - (Optional) The resource ID of the marketplace partner solution to send logs and metrics to.
DESCRIPTION

  validation {
    condition = alltrue([
      for _, v in var.diagnostic_settings :
      v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
    ])
    error_message = "At least one destination (workspace_resource_id, storage_account_resource_id, event_hub_authorization_rule_resource_id or marketplace_partner_resource_id) must be set for each diagnostic setting."
  }

  validation {
    condition = alltrue([
      for _, v in var.diagnostic_settings :
      contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)
    ])
    error_message = "log_analytics_destination_type must be either 'Dedicated' or 'AzureDiagnostics'."
  }
}

# -
# Mandatory Business Tags
# -
variable "app_name" {
  type        = string
  description = "(Required) Human readable name for the Application."
}

variable "app_support" {
  type        = string
  description = "(Required) Email address of the support team."
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.app_support))
    error_message = "Value for \"app_support\" must be a valid email address."
  }
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
  default     = "managed_redis_cache"
}

variable "product_version" {
  type        = string
  description = "(Required) Terraform Module version."
}

# -
# Mandatory Finance Tags
# -
variable "cost_center" {
  type        = string
  default     = ""
  description = "(Required) Cost center that should bear the costs."
}

variable "cost_allocation_unit" {
  type        = string
  description = "(Required) Logical bucket to split shared platform cost."
}

variable "budget_id" {
  type        = string
  description = "(Required) Budget or GL code used by Finance."
}

variable "budget_limit" {
  type        = string
  default     = ""
  description = "(Required) Maximum budget allocated."
}

variable "cost_alert_threshold" {
  type        = string
  default     = ""
  description = "(Required) Cost threshold for triggering alerts."
}

# -
# Mandatory Governance Tags
# -
variable "data_classification" {
  type        = string
  default     = ""
  description = "(Required) Data classification level."
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
# Optional Tags for Resources
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
  validation {
    condition     = var.auto_delete == "" || contains(["Yes", "No"], var.auto_delete)
    error_message = "Value must be Yes or No."
  }
  default = ""
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
  description = "(Optional) List of email addresses for notifications."
  default     = []
  validation {
    condition     = alltrue([for email in var.notification_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))])
    error_message = "All notification emails must be valid email addresses."
  }
}

variable "region" {
  type        = string
  description = "(Optional) Cloud region where resource is deployed."
  default     = ""
}

variable "env" {
  type        = string
  description = "(Required) <CN> environment code. Example: `test`. <br></br>&#8226; Value of `env` must be one of: `[nonprod,prod,core,int,uat,stage,dev,test,p,d,u,sb,dv,pd,qa]`."
  validation {
    condition     = contains(["nonprod", "prod", "core", "int", "uat", "sit", "stage", "dev", "test", "p", "d", "u", "sb", "dv", "pd", "qa", "tst"], var.env)
    error_message = "Value of \"env\" must be one of: [nonprod,prod,core,int,uat,sit,stage,dev,test,p,d,u,sb,dv,pd,qa,tst]."
  }
}

variable "au" {
  type        = string
  description = "(Required) <CN> Accounting Unit (AU) code. Example: `0233985`. <br></br>&#8226; Value of `au` must be of numeric characters."
  validation {
    condition     = can(regex("^[[:digit:]]+$", var.au))
    error_message = "Value for \"au\" must be of numeric characters."
  }
}

variable "owner" {
  type        = string
  description = "(Required) <CN> technology owner group."
}

variable "resource_type_code" {
  type        = string
  description = "(Required) Azure resource type abbreviation (or `service` in <CN> Naming Standard). Example: `rg`, `vnet`, `st`, etc."
}

variable "app_code" {
  type        = string
  description = "(Required) Application code. Example: network, mgmt, build"
}

variable "bu" {
  type        = string
  description = "(Required) Business unit code. Example: `IT` or `{org}`."
}

# -
# Optional Variables
# -
variable "org" {
  type        = string
  description = "(Optional) <CN> company/business unit code. Example: `{org}`."
  default     = "{org}"
}

variable "country" {
  type        = string
  description = "(Optional) <CN> country code. Example: `th`."
  default     = "th"
}

variable "region_code" {
  type        = string
  description = "(Optional) {org} region code.<br></br>&#8226; Value of `region_code` must be one of: `[ea,sea,eu,myw,sg]`."
  validation {
    condition     = contains(["ea", "sea", "eu", "myw", "sg"], var.region_code)
    error_message = "Value of \"region_code\" must be one of: [ea,sea,eu,myw,sg]."
  }
  default = "sea"
}

variable "additional_name" {
  type        = string
  description = "(Optional) Additional suffix to create resource uniqueness. It will be separated by a `'-'` from the \"name's generated\" suffix. Example: `lan1`."
  default     = null
}

variable "iterator" {
  type        = string
  description = "(Optional) Iterator to create resource uniqueness. It will be separated by a `'-'` from the \"name's generated + additional_name\" concatenation. Example: `001`."
  default     = null
}

variable "additional_tags" {
  description = "(Optional) Additional base tags."
  type        = map(string)
  default     = null
}

variable "base_name" {
  type        = string
  description = "(optional) Application/Infrastructure \"base\" name. Example: `aks`."
  default     = null
}

# -
# Optional tuning switches & defaults
# -
variable "no_dashes" {
  type        = bool
  description = "(Optional) When set to `true`, it will remove all `'-'` separators from the generated name."
  default     = false
}

variable "add_random" {
  type        = bool
  description = "(Optional) When set to `true`, it will add a `rnd_length`'s long `random_number` at the name's end."
  default     = false
}

variable "max_length" {
  type        = number
  description = "(Optional) Set the maximum length of the generated name."
  default     = 63
}

variable "rnd_length" {
  type        = number
  description = "(Optional) Set the length of the `random_number` generated."
  default     = 2
}