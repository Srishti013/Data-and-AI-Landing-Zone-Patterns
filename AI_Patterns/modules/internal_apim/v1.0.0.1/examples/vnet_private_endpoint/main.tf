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

# Create a virtual network for testing if needed
resource "azurerm_virtual_network" "this" {
  location            = azurerm_resource_group.this.location
  name                = "vnet-iapim-tst-01"
  resource_group_name = azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default_subnet" {
  #checkov:skip=CKV2_AZURE_31: NSG association is not required for this example subnet
  name                 = "default_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "pe_subnet" {
  #checkov:skip=CKV2_AZURE_31: NSG association is not required for private endpoint subnets in this example
  name                 = "pe_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Private DNS Zone for API Management
resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azure-api.net"
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "dnslink-azure-apim"
  resource_group_name   = azurerm_resource_group.this.name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = azurerm_virtual_network.this.id
}


# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "malaysiawest"
  name     = "rg-iapim-tst-01"
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
  enable_telemetry    = var.enable_telemetry
  env                 = "test"
  au                  = "0000001"
  app_code            = "apim"
  bu                  = "it"
  owner               = "CEAT"
  region_code         = "myw"
  service             = "apim"
  business_unit       = "GTD-ISD"
  business_owner      = "Head of Cloud Engineering and Automation"
  app_name            = "Internal APIM"
  budget_id           = "83254"
  criticality         = "T1"
  environment         = "Test"
  global_policy_vars = {
    jwt_header_name        = "Authorization"
    jwt_failed_status_code = 401
    jwt_failed_message     = "Unauthorized"
    jwt_require_expiry     = true
    jwt_scheme             = "Bearer"
    openid_config_url      = "https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration"
    jwt_audience           = "api://apim-tst"
    jwt_issuer             = "https://sts.windows.net/00000000-0000-0000-0000-000000000000/"
    rate_limit_calls       = 100
    rate_limit_period      = 60
    rate_limit_counter_key = "client-ip"
    quota_calls            = 1000
    quota_period           = 3600
    quota_counter_key      = "subscription-key"
  }
  # private endpoints
  # Add private endpoint configuration
  private_endpoints = {
    endpoint1 = {
      name               = "pe-apim-iapim-tst-01"
      subnet_resource_id = azurerm_subnet.pe_subnet.id

      # Link to the private DNS zone we created
      private_dns_zone_resource_ids = [
        azurerm_private_dns_zone.this.id
      ]

      tags = {
        environment = "test"
        service     = "apim"
      }
    }
  }
  publisher_name = "Apim Example Publisher"
  sku_name       = "Premium_3"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  zones = ["1", "2", "3"] # For compliance with WAF
}

