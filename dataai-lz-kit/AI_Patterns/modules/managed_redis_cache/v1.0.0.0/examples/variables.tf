variable "sku_name" {
  type        = string
  description = "SKU name for the Managed Redis instance (e.g., Balanced_B3)."
  default     = "Balanced_B3"
}

variable "user_assigned_identity_ids" {
  type        = set(string)
  description = "Set of User Assigned Managed Identity IDs to assign to the Managed Redis instance."
  default     = []
}
