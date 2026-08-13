provider "azurerm" {
  features {}
}

terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.117"
    }
  }
}

# We need the tenant id for the key vault.
data "azurerm_client_config" "this" {}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "malaysiawest"
  name     = "rg-kv-tst-01"
}

# This is the module call
module "keyvault" {
  source = "../../"
  #checkov:skip=CKV_AZURE_109: Network ACLs are not configured in this default example
  #checkov:skip=CKV_AZURE_112: Key type is configurable via variable; HSM-backed keys require Premium SKU which is caller's responsibility

  # source              = "Azure/avm-res-keyvault-vault/azurerm"
  resource_group_name  = azurerm_resource_group.this.name
  tenant_id            = data.azurerm_client_config.this.tenant_id
  enable_telemetry     = var.enable_telemetry
  env                  = "test"
  au                   = "0000001"
  app_code             = "net"
  bu                   = "it"
  owner                = "CEAT"
  region_code          = "myw"
  resource_type_code   = "kv"
  business_unit        = "GTD-ISD"
  business_owner       = "Head of Cloud Engineering and Automation"
  app_name             = "Key Vault"
  app_support          = "mss_ceat@maybank.com"
  budget_id            = "83254"
  criticality          = "T1"
  environment          = "Test"
  product_version      = "1.0.0.0"
  cost_allocation_unit = "GTD-ISD"
}
