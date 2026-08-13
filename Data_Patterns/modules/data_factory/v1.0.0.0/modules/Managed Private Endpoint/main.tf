# Managed Private Endpoints for Data Factory - example for SQL, can be added for other linked service types as needed
resource "azurerm_data_factory_managed_private_endpoint" "this" {
  name               = var.name
  data_factory_id    = var.data_factory_id
  target_resource_id = var.target_resource_id
  subresource_name   = var.subresource_name
}