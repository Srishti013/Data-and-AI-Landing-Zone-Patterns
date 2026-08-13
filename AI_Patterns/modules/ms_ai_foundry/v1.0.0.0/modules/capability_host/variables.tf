variable "account_ids" {
  type        = map(string)
  description = "Map of account_key => AI Foundry account ARM id."
  default     = {}
}

variable "project_ids" {
  type        = map(string)
  description = "Map of project_key => project ARM id (same-stack)."
  default     = {}
}

variable "project_internal_ids" {
  type        = map(string)
  description = "Map of project_key => project internalId (for ABAC conditions)."
  default     = {}
}

variable "account_capability_hosts" {
  type        = any
  description = "Map of account-level capability hosts."
  default     = {}
}

variable "project_capability_hosts" {
  type        = any
  description = "Map of project-level capability hosts."
  default     = {}
}

variable "project_cosmos_role_assignments" {
  type        = any
  description = "Post-capability-host Cosmos DB SQL role assignments."
  default     = {}
}

variable "post_ch_storage_role_assignments" {
  type        = any
  description = "Post-capability-host Storage Blob Data Owner (ABAC) assignments."
  default     = {}
}

variable "wait_after_account_creation" {
  type        = string
  description = "Duration to wait for the auto-created account capability host before project hosts."
  default     = "120s"
}
