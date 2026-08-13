variable "name" {
  type        = string
  description = "Base resource name (from the naming module)."
}

variable "account_ids" {
  type        = map(string)
  description = "Map of account_key => AI Foundry account ARM id."
  default     = {}
}

variable "ai_foundry_rai_policy" {
  type        = any
  description = "Map of RAI policies to create."
  default     = {}
}
