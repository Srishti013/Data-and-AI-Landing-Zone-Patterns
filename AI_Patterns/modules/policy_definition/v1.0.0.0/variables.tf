# -
# Required Variables
# -
variable "name" {
  type        = string
  description = "(Required) The name of the custom policy definition."

  validation {
    condition     = length(var.name) <= 64
    error_message = "The policy definition name must not exceed 64 characters."
  }
}
variable "display_name" {
  type        = string
  description = "(Required) The display name shown in the compliance UI."
}
variable "policy_rule" {
  type        = any
  description = "(Required) The policyRule object (decoded), jsonencoded by this module."
}

# -
# Optional Variables
# -
variable "mode" {
  type        = string
  description = "(Optional) The policy definition mode. Defaults to All."
  default     = "All"
}
variable "description" {
  type        = string
  description = "(Optional) A description for the policy definition."
  default     = null
}
variable "parameters" {
  type        = any
  description = "(Optional) The parameters object (decoded), jsonencoded by this module when set."
  default     = null
}
variable "management_group_id" {
  type        = string
  description = "(Optional) The Management Group where this policy should be defined. If null, the definition is created at the subscription scope of the provider."
  default     = null
}
