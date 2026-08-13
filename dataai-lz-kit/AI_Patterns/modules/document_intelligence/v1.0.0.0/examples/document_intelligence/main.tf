resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

module "document_intelligence" {
  source = "../../"

  name                = "name1"
  resource_group_name = azurerm_resource_group.example
  location            = azurerm_resource_group.example.location
  kind                = "FormRecognizer"
  sku_name            = "so"

  identity {
    type = "SystemAssigned"
  }
}