variable "name" {
  type        = string
  description = "Base resource name (from the naming module)."
}

variable "account_ids" {
  type        = map(string)
  description = "Map of account_key => AI Foundry account ARM id."
  default     = {}
}

variable "ai_foundry_deployments" {
  type        = any
  description = "Map of model deployments to create."
  default     = {}
}
