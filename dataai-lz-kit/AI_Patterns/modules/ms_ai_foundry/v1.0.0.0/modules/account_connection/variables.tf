variable "account_ids" {
  type        = map(string)
  description = "Map of account_key => AI Foundry account ARM id."
  default     = {}
}

variable "account_connections" {
  type        = any
  description = "Map of account-level (shared) connections to create."
  default     = {}
}
