
########################################
## Private Endpoint for AI Foundry Account
########################################
resource "azurerm_private_endpoint" "ai_foundry" {
  count = var.private_endpoint_config != null ? 1 : 0

  name                = var.private_endpoint_config.name
  location            = var.private_endpoint_config.location
  resource_group_name = var.private_endpoint_config.resource_group_name
  subnet_id           = var.private_endpoint_config.subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.private_endpoint_config.name}-psc"
    private_connection_resource_id = var.account_ids[var.private_endpoint_config.account_key]
    is_manual_connection           = false
    subresource_names              = var.private_endpoint_config.subresource_names
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_endpoint_config.dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "ai-foundry-dns-zone-group"
      private_dns_zone_ids = var.private_endpoint_config.dns_zone_ids
    }
  }
}
