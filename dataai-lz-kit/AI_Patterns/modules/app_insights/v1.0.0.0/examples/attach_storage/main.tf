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
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  location                     = "southeastasia"
  resource_group_name          = "rg-ai-attach-storage"
  log_analytics_workspace_name = "law-ai-attach-storage"
  storage_account_name         = "staiexattach01"
  application_insights_name    = "appi-ai-attach-storage"
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

# This is the storage account for the profiler.
resource "azurerm_storage_account" "this" {
  # checkov:skip=CKV2_AZURE_1: Not in scope for this example - customer-managed key encryption is not required for testing
  # checkov:skip=CKV2_AZURE_38: Not in scope for this example - soft delete configuration is not required for testing
  # checkov:skip=CKV2_AZURE_40: Not in scope for this example - Shared Key authorization not restricted for testing
  # checkov:skip=CKV2_AZURE_47: Not in scope for this example - blob anonymous access restriction not required for testing
  # checkov:skip=CKV2_AZURE_41: Not in scope for this example - SAS expiration policy not required for testing
  # checkov:skip=CKV2_AZURE_33: Not in scope for this example - private endpoint is not required for testing
  # checkov:skip=CKV_AZURE_44: Not in scope for this example - TLS version set via min_tls_version where applicable
  # checkov:skip=CKV_AZURE_43: Not in scope for this example - storage account naming follows module convention
  # checkov:skip=CKV_AZURE_35: Not in scope for this example - default deny network rule not required for testing
  # checkov:skip=CKV_AZURE_59: Not in scope for this example - public access restriction not required for testing
  # checkov:skip=CKV_AZURE_33: Not in scope for this example - Storage Queue logging not required for testing
  # checkov:skip=CKV_AZURE_206: Not in scope for this example - ZRS replication is sufficient for testing
  # checkov:skip=CKV_AZURE_190: Not in scope for this example - blob public access restriction not required for testing
  account_replication_type = "ZRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.this.location
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  min_tls_version          = "TLS1_2"
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  location                            = azurerm_resource_group.this.location
  name                                = local.application_insights_name
  resource_group_name                 = azurerm_resource_group.this.name
  workspace_id                        = azurerm_log_analytics_workspace.this.id
  enable_telemetry                    = var.enable_telemetry # see variables.tf
  force_customer_storage_for_profiler = true
  linked_storage_account = {
    profiler = {
      resource_id = azurerm_storage_account.this.id
    }
  }
}
