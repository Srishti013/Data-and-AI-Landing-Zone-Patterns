variable "tags" {
  type        = map(string)
  description = "Tags for the private endpoint (from the naming module)."
  default     = {}
}

variable "account_ids" {
  type        = map(string)
  description = "Map of account_key => AI Foundry account ARM id."
  default     = {}
}

variable "private_endpoint_config" {
  type        = any
  description = "Private endpoint configuration object. null to skip."
  default     = null
}
