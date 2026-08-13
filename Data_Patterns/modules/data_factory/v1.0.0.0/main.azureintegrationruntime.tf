resource "azurerm_data_factory_integration_runtime_azure" "this" {
  for_each = var.azure_integration_runtime_azure

  name            = each.value.name
  data_factory_id = azurerm_data_factory.this.id
  location        = each.value.location

  description             = try(each.value.description, null)
  cleanup_enabled         = try(each.value.cleanup_enabled, null)
  compute_type            = try(each.value.compute_type, null)
  core_count              = try(each.value.core_count, null)
  time_to_live_min        = try(each.value.time_to_live_min, null)
  virtual_network_enabled = try(each.value.virtual_network_enabled, null)
}