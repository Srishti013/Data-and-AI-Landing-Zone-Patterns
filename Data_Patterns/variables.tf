# =============================================================================
# Scalar variables. subscription_id is injected by the workflow (sed on the
# value in variables.tfvars) to the selected Data landing-zone subscription.
# =============================================================================
variable "subscription_id" {
  description = "Subscription ID of the Data landing zone where resources are created."
  type        = string
}

variable "user_principal_name" {
  description = "Azure AD administrator login (user principal name) for the SQL Server."
  type        = string
  default     = "REPLACE_ME@example.onmicrosoft.com"
}

variable "object_id" {
  description = "Azure AD administrator object id for the SQL Server."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

# tflint-ignore: terraform_unused_declarations # TEMP-DISABLED (demo 2026-07-21): unused while central LAW is disabled
variable "log_analytics_workspace_name" {
  description = "Central Log Analytics Workspace name (platform management sub)."
  type        = string
  default     = ""
}

# tflint-ignore: terraform_unused_declarations # TEMP-DISABLED (demo 2026-07-21): unused while central LAW is disabled
variable "log_analytics_workspace_rg_name" {
  description = "Resource group of the central Log Analytics Workspace."
  type        = string
  default     = ""
}

variable "existing_private_dns_zones_rg_name" {
  description = "Resource group (platform network sub) holding the shared Private DNS Zones."
  type        = string
  default     = ""
}

variable "hub_virtual_networks" {
  description = "Hub virtual networks (in the platform network subscription) that the data spoke VNet peers to, keyed by a logical hub key referenced from each peering's hub_key."
  type = map(object({
    name                = string
    resource_group_name = string
  }))
  default = {}
}

# =============================================================================
# Platform subscriptions referenced by the aliased providers, resolved from
# their display names. Keys: pvt_dns_zones_sub, law_sub.
# =============================================================================
variable "subscriptions" {
  description = "Platform subscriptions (display names) resolved for aliased providers."
  type        = any
  default     = {}
}

variable "existing_private_dns_zones" {
  description = "Existing shared Private DNS Zones to resolve for private endpoints."
  type        = any
  default     = {}
}

# =============================================================================
# Resource maps (type = any). Each mirrors the corresponding block in the
# standalone data_shared / data_storage / data_ingestion / data_analytics /
# data_rbac roots, consolidated into a single stack.
# =============================================================================
variable "data_resource_groups" {
  type    = any
  default = {}
}

variable "network_security_groups" {
  type    = any
  default = {}
}

variable "virtual_networks" {
  type    = any
  default = {}
}

variable "route_tables" {
  type    = any
  default = {}
}

variable "key_vaults" {
  type    = any
  default = {}
}

# tflint-ignore: terraform_unused_declarations # TEMP-DISABLED (demo 2026-07-21): App Insights disabled while central LAW is unavailable
variable "application_insights" {
  type    = any
  default = {}
}

variable "user_managed_identities" {
  type    = any
  default = {}
}

variable "role_assignments_config" {
  type    = any
  default = {}
}

variable "sql_server_secrets" {
  type    = any
  default = {}
}

variable "sql_servers" {
  type    = any
  default = {}
}

variable "storage_accounts" {
  type    = any
  default = {}
}

variable "recovery_service_vaults" {
  type    = any
  default = {}
}

variable "backup_vaults" {
  type    = any
  default = {}
}

variable "eventgrid_system_topics" {
  type    = any
  default = {}
}

variable "data_factories" {
  type    = any
  default = {}
}

variable "private_endpoints" {
  type    = any
  default = {}
}

variable "fabric_capacities" {
  type    = any
  default = {}
}

# Consolidated cross-resource RBAC (replaces the standalone data_rbac root).
variable "data_rbac_role_assignments" {
  type    = any
  default = {}
}
