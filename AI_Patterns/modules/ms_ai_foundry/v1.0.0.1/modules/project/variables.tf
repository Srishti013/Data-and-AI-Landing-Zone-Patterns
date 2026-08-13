variable "location" {
  type        = string
  description = "Azure region for the projects (from the naming module)."
}

variable "account_ids" {
  type        = map(string)
  description = "Map of account_key => AI Foundry account ARM id (for same-stack parent resolution)."
  default     = {}
}

variable "ai_foundry_projects" {
  type        = any
  description = "Map of AI Foundry projects to create."
  default     = {}
}
