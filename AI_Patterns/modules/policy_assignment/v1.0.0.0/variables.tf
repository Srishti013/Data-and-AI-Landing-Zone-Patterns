# -
# Required Variables
# -

variable "name" {
  type        = string
  description = "(Required) The name which should be used for this Policy Assignment."

  validation {
    condition     = length(var.name) <= 128
    error_message = "The policy assignment name length must not exceed 128 characters."
  }
}
variable "policy_definition_id" {
  type        = string
  description = "(Required) The ID of the Policy Definition or Policy Definition Set."
}
variable "scope" {
  type        = string
  description = "(Required) The scope where this Policy Assignment should be created."
}

# -
# Optional Variables
# -
variable "description" {
  type        = string
  description = "(Optional) A description which should be used for this Policy Assignment."
  default     = null
}
variable "display_name" {
  type        = string
  description = "(Optional) The Display Name for this Policy Assignment."
  default     = null
}
variable "not_scopes" {
  type        = list(string)
  description = "(Optional) Specifies a list of Resource Scopes (for example a Subscription, or a Resource Group) within this Management Group which are excluded from this Policy."
  default     = null
}
variable "metadata" {
  type        = any
  description = "(Optional) A JSON mapping of any Metadata for this Policy."
  default     = null
}
variable "parameters" {
  type        = any
  description = "(Optional) A JSON mapping of any Parameters for this Policy."
  default     = null
}
variable "enforcement_mode" {
  type        = string
  description = "(Optional) Specifies if this Policy should be enforced or not?"
  default     = null

  validation {
    condition     = var.enforcement_mode == null ? true : contains(["Default", "DoNotEnforce"], var.enforcement_mode)
    error_message = "Enforcement mode must be either 'Default' or 'DoNotEnforce'."
  }
}
variable "location" {
  type        = string
  description = "(Optional) The Azure Region where the Policy Assignment should exist."
  default     = null
}
variable "assign_identity" {
  type        = bool
  description = "(Optional) Whether or not to assign System Assigned Identity to the Policy Assignment. It is required to enable this for enabling role assignments on Managed Identity."
  default     = false
}
variable "remediation_role_name" {
  type        = string
  description = "(Optional) Built-in role granted to the assignment's managed identity for remediation when assign_identity is true."
  default     = "Contributor"
}
variable "management_group_set_definition" {
  type        = string
  description = "(Optional) Name of management group from which policy set definition will be fetched. If not provided, will attempt to extract from policy_definition_id for custom initiatives."
  default     = null
}
variable "management_group_policy_definition" {
  type        = string
  description = "(Optional) Name of management group from which policy definition will be fetched. If not provided, will attempt to extract from policy definition IDs for custom policies."
  default     = null
}
variable "auto_detect_management_group" {
  type        = bool
  description = "(Optional) Whether to automatically detect management group from policy definition ID for custom policies. Defaults to true."
  default     = true
}

variable "manual_role_definition_ids" {
  type        = list(string)
  description = "(Optional) List of role definition IDs to assign to the policy assignment's managed identity. Use this for policy sets where automatic role extraction is not supported. Example: [\"/providers/Microsoft.Authorization/roleDefinitions/17d1049b-9a84-46fb-8f53-869881c3d3ab\"]"
  default     = []

  validation {
    condition = alltrue([
      for role_id in var.manual_role_definition_ids :
      can(regex("^/providers/Microsoft\\.Authorization/roleDefinitions/[a-fA-F0-9-]+$", role_id))
    ])
    error_message = "Role definition IDs must be in the format '/providers/Microsoft.Authorization/roleDefinitions/{guid}'."
  }
}