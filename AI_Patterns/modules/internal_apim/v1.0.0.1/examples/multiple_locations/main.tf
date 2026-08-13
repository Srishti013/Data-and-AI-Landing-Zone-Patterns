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
  additional_location = [{
    # location western europe
    location = "westeurope"
    capacity = 1
  }]
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
  publisher_name = "Apim Example Publisher"
  sku_name       = "Premium_3"
  # sku_name = "Developer_1"
  tags = {
    environment = "test"
    cost_center = "test"
  }
  zones = ["1", "2", "3"] # For compliance with WAF
}

