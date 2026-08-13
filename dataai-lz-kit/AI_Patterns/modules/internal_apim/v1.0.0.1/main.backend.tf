# API Management Backends
# This file implements backend configurations for routing API requests to target services

resource "azurerm_api_management_backend" "this" {
  for_each = var.backends

  api_management_name = azurerm_api_management.this.name
  name                = each.key
  protocol            = each.value.protocol
  resource_group_name = azurerm_api_management.this.resource_group_name
  url                 = each.value.url
  description         = each.value.description
  title               = each.value.title
  resource_id         = each.value.resource_id

  dynamic "tls" {
    for_each = each.value.tls != null ? [each.value.tls] : []

    content {
      validate_certificate_chain = tls.value.validate_certificate_chain
      validate_certificate_name  = tls.value.validate_certificate_name
    }
  }

  dynamic "credentials" {
    for_each = each.value.credentials != null ? [each.value.credentials] : []

    content {
      certificate = credentials.value.certificate
      header      = credentials.value.header
      query       = credentials.value.query

      dynamic "authorization" {
        for_each = credentials.value.authorization != null ? [credentials.value.authorization] : []

        content {
          parameter = authorization.value.parameter
          scheme    = authorization.value.scheme
        }
      }
    }
  }

  depends_on = [azurerm_api_management.this]
}
