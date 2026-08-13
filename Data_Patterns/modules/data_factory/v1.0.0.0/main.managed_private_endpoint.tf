# Managed Private Endpoints for Data Factory - example for SQL, can be added for other linked service types as needed
resource "azurerm_data_factory_managed_private_endpoint" "this" {
  for_each           = var.managed_private_endpoints
  name               = each.value.name
  data_factory_id    = azurerm_data_factory.this.id
  target_resource_id = each.value.target_resource_id
  subresource_name   = each.value.subresource_name
}