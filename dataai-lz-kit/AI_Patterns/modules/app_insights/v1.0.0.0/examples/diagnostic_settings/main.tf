terraform {
  required_version = "~> 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.71, < 5.0.0"

    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  location                     = "southeastasia"
  resource_group_name          = "rg-ai-diagnostic"
  log_analytics_workspace_name = "law-ai-diagnostic"
  application_insights_name    = "appi-ai-diagnostic"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = local.location
  name     = local.resource_group_name
}


#Log Analytics Workspace for diagnostic settings. Required for workspace-based diagnostic settings.
resource "azurerm_log_analytics_workspace" "this" {
  location            = azurerm_resource_group.this.location
  name                = local.log_analytics_workspace_name
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
}


# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../.."

  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  location            = azurerm_resource_group.this.location
  name                = local.application_insights_name
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  enable_telemetry    = var.enable_telemetry # see variables.tf
}
