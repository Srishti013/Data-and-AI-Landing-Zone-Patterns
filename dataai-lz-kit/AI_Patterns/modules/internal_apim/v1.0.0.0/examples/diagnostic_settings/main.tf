terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
  }
}

provider "azurerm" {

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

  }
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "malaysiawest"
  name     = "rg-iapim-tst-01"
}

resource "azurerm_log_analytics_workspace" "diag" {
  location            = azurerm_resource_group.this.location
  name                = "law-iapim-diag-tst-01"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_log_analytics_workspace" "diag2" {
  location            = azurerm_resource_group.this.location
  name                = "law-iapim-diag2-tst-01"
  resource_group_name = azurerm_resource_group.this.name
}
# This is the module call
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"
  #checkov:skip=CKV_AZURE_174: Public access is controlled via virtual_network_type and private endpoint configuration
  location            = azurerm_resource_group.this.location
  name                = "apim-iapim-tst-01"
  publisher_email     = var.publisher_email
  resource_group_name = azurerm_resource_group.this.name
  diagnostic_settings = {
    diag = {
      name                  = "diag-apim-01"
      workspace_resource_id = azurerm_log_analytics_workspace.diag.id
    },
    diag2 = {
      name                  = "diag2-apim-01"
      workspace_resource_id = azurerm_log_analytics_workspace.diag2.id
      log_categories = [
        "GatewayLogs",             # Logs related to ApiManagement Gateway
        "WebSocketConnectionLogs", # Logs related to Websocket Connections
        "DeveloperPortalAuditLogs" # Logs related to Developer Portal usage
      ]
    }
  }
  enable_telemetry = var.enable_telemetry
  env              = "test"
  au               = "0000001"
  app_code         = "apim"
  bu               = "it"
  owner            = "CEAT"
  region_code      = "myw"
  service          = "apim"
  business_unit    = "GTD-ISD"
  business_owner   = "Head of Cloud Engineering and Automation"
  app_name         = "Internal APIM"
  budget_id        = "83254"
  criticality      = "T1"
  environment      = "Test"
  publisher_name   = "John Wick"
  sku_name         = "Premium_3"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  zones = ["1", "2", "3"] # For compliance with WAF
}

