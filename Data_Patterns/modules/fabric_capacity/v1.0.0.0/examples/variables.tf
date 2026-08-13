variable "resource_group_name" {
  type        = string
  description = "Name of the RG"
}

variable "sku_name" {
  type        = string
  description = "SKU name for fabric capacity"
}

variable "administration_members" {
  type        = list(string)
  description = "List of administration members for the fabric capacity"
}