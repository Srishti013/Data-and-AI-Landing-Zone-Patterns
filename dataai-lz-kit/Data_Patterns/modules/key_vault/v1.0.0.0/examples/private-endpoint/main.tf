terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.117"
    }
  }
}

provider "azurerm" {
  features {}
}

# We need the tenant id for the key vault.
data "azurerm_client_config" "this" {}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "malaysiawest"
  name     = "rg-kv-tst-01"
}

# A vnet is required for the private endpoint.
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = "vnet-kv-tst-01"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "this" {
  #checkov:skip=CKV2_AZURE_31: NSG association is not required for private endpoint subnets in this example
  address_prefixes     = ["192.168.0.0/24"]
  name                 = "snet-kv-tst-01"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.this.name
}

# This is the module call
module "keyvault" {
  source = "../../"
  #checkov:skip=CKV_AZURE_109: Network ACLs are not required in this private endpoint example as public access is disabled
  #checkov:skip=CKV_AZURE_112: Key type is configurable via variable; HSM-backed keys require Premium SKU which is caller's responsibility

  # source             = "Azure/avm-res-keyvault-vault/azurerm"
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
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.this.id]
      subnet_resource_id            = azurerm_subnet.this.id
    }
  }
  public_network_access_enabled = false
}
