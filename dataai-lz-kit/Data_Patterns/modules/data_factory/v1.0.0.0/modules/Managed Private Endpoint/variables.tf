variable "name" {
  description = "Name of the Data Factory Managed Private Endpoint"
  type        = string
}

variable "data_factory_id" {
  description = "ID of the Azure Data Factory"
  type        = string
}

variable "target_resource_id" {
  description = "Target Azure resource ID for Managed Private Endpoint"
  type        = string
}

variable "subresource_name" {
  description = "Subresource name for the target resource"
  type        = string
}