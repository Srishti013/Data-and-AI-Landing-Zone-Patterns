variable "subscription_id" {
  type        = string
  description = "Target subscription: custom policy definitions are created here and all assignments are subscription-scoped."
}

variable "location" {
  type        = string
  description = "Location for policy-assignment managed identities (required for Modify / DeployIfNotExists remediation)."
  default     = "southeastasia"
}
