variable "server_version" {
  type        = string
  description = "(Required) The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). Changing this forces a new resource to be created."
  nullable    = false
}

variable "administrator_login" {
  type        = string
  default     = null
  description = "(Optional) The administrator login name for the new server. Required unless `azuread_authentication_only` in the `azuread_administrator` block is `true`. When omitted, Azure will generate a default username which cannot be subsequently changed. Changing this forces a new resource to be created."
}

variable "administrator_login_password" {
  type        = string
  default     = null
  description = "(Optional) The password associated with the `administrator_login` user. Needs to comply with Azure's [Password Policy](https://msdn.microsoft.com/library/ms161959.aspx). Required unless `azuread_authentication_only` in the `azuread_administrator` block is `true`."
  sensitive   = true
}

variable "azuread_administrator" {
  type = object({
    azuread_authentication_only = optional(bool)
    login_username              = string
    object_id                   = string
    tenant_id                   = optional(string)
  })
  default     = null
  description = <<-EOT
 - `azuread_authentication_only` - (Optional) Specifies whether only AD Users and administrators (e.g. `azuread_administrator[0].login_username`) can be used to login, or also local database users (e.g. `administrator_login`). When `true`, the `administrator_login` and `administrator_login_password` properties can be omitted.
 - `login_username` - (Required) The login username of the Azure AD Administrator of this SQL Server.
 - `object_id` - (Required) The object id of the Azure AD Administrator of this SQL Server.
 - `tenant_id` - (Optional) The tenant id of the Azure AD Administrator of this SQL Server.
EOT
}

variable "connection_policy" {
  type        = string
  default     = null
  description = "(Optional) The connection policy the server will use. Possible values are `Default`, `Proxy`, and `Redirect`. Defaults to `Default`."
}

variable "express_vulnerability_assessment_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether the `Express Vulnerability Assessment` feature is enabled for this server. Defaults to `false`."
}

variable "outbound_network_restriction_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Whether outbound network traffic is restricted for this server. Defaults to `false`."
}

variable "primary_user_assigned_identity_id" {
  type        = string
  default     = null
  description = "(Optional) Specifies the primary user managed identity id. Required if `type` within the `identity` block is set to either `SystemAssigned, UserAssigned` or `UserAssigned` and should be set at same time as setting `identity_ids`."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether public network access is allowed for this server. Defaults to `false`."
}

variable "transparent_data_encryption_enabled" {
  type        = bool
  default     = false
  description = "(Optional) When `true`, a dedicated `azurerm_mssql_server_transparent_data_encryption` resource is created to manage the server `Transparent Data Encryption`(TDE) protector with the supplied `transparent_data_encryption_key_vault_key_id`. This flag gates resource creation with a plan-time-known value so `count` remains resolvable even when the referenced `Key Vault` `Key` is created or updated in the same run. Defaults to `false`."
}

variable "transparent_data_encryption_key_vault_key_id" {
  type        = string
  default     = null
  description = "(Optional) The `Key Vault` `Key` URL to be used as the `Customer Managed Key`(CMK/BYOK) for the server `Transparent Data Encryption`(TDE) layer. Provide a versionless URL (e.g. `https://<YourVaultName>.vault.azure.net/keys/<YourKeyName>`) when `transparent_data_encryption_key_automatic_rotation_enabled` is `true`, or a fully versioned URL otherwise. TDE is managed via the `azurerm_mssql_server_transparent_data_encryption` resource when `transparent_data_encryption_enabled` is `true`."
}

variable "transparent_data_encryption_key_automatic_rotation_enabled" {
  type        = bool
  default     = false
  description = "(Optional) When `true`, the server continuously checks the key vault for new versions of the TDE protector key and automatically rotates to the latest version within 60 minutes. Requires `transparent_data_encryption_key_vault_key_id` to be set (a versionless key URL is recommended). Defaults to `false`."
}

variable "server_extended_auditing_policy" {
  type = object({
    enabled                                 = optional(bool, true)
    log_monitoring_enabled                  = optional(bool, true)
    create_master_audit_diagnostic_setting  = optional(bool, true)
    retention_in_days                       = optional(number, 0)
    storage_endpoint                        = optional(string, null)
    storage_account_access_key              = optional(string, null)
    storage_account_access_key_is_secondary = optional(bool, null)
    storage_account_subscription_id         = optional(string, null)
    log_analytics_workspace_id              = optional(string, null)
    log_analytics_destination_type          = optional(string, "Dedicated")
    audit_log_categories                    = optional(list(string), ["SQLSecurityAuditEvents"])
    diagnostic_setting_name                 = optional(string, null)
  })
  default     = null
  description = <<-EOT
 (Optional) Manages a SQL Server (v12) Extended Auditing Policy to enable Azure SQL Auditing. When set, auditing is enabled on the server. Leave `null` to not manage auditing.

 - `enabled` - (Optional) Whether to create the extended auditing policy. Defaults to `true`.
 - `log_monitoring_enabled` - (Optional) Enable audit events to Azure Monitor (Log Analytics / Event Hub) via a diagnostic setting. Defaults to `true`.
 - `create_master_audit_diagnostic_setting` - (Optional) Whether Terraform should create the dedicated diagnostic setting on `<server>/databases/master` for audit events. Defaults to `true`. Set to `false` when Azure already creates and owns that sink to avoid duplicate `SQLSecurityAuditEvents` conflicts.
 - `retention_in_days` - (Optional) The number of days to retain logs in the storage account. Defaults to `0` (unlimited). Only applicable when `storage_endpoint` is set.
 - `storage_endpoint` - (Optional) The blob storage endpoint (e.g. `https://example.blob.core.windows.net`). When set, audit logs are written to this storage account.
 - `storage_account_access_key` - (Optional) The access key to use for the auditing storage account. Required if `storage_endpoint` is set and managed identity is not used.
 - `storage_account_access_key_is_secondary` - (Optional) Whether `storage_account_access_key` is the secondary key.
 - `storage_account_subscription_id` - (Optional) The subscription ID of the storage account.
 - `log_analytics_workspace_id` - (Optional) Log Analytics workspace resource ID to route audit events to. Azure SQL emits audit events (`SQLSecurityAuditEvents`) from the server's `master` database, so a diagnostic setting is created on `<server>/databases/master`. Required for the "Log Analytics" audit destination to appear enabled in the portal. When `null`, no audit diagnostic setting is created.
 - `log_analytics_destination_type` - (Optional) The Log Analytics destination type for the audit diagnostic setting. Defaults to `Dedicated`.
 - `audit_log_categories` - (Optional) The audit log categories to send to Log Analytics. Defaults to `["SQLSecurityAuditEvents"]`.
 - `diagnostic_setting_name` - (Optional) Name of the master-database audit diagnostic setting. Defaults to a generated name.
EOT
}
