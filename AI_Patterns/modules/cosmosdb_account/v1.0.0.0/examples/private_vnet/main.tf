terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "cosmos_private" {
  source              = "../../"
  resource_group_name = "rg-data-dev"

  # Naming module inputs
  env                  = "dev"
  org                  = "mbb"
  region_code          = "sea"
  region               = "southeastasia"
  base_name            = "cosmos"
  au                   = "0233985"
  app_code             = "data"
  bu                   = "it"
  owner                = "platform"
  app_name             = "data-platform"
  app_support          = "data-platform@contoso.com"
  business_unit        = "data"
  business_owner       = "data-owner"
  product_name         = "cosmosdb_account"
  product_version      = "1.0.0.0"
  cost_center          = ""
  cost_allocation_unit = ""
  budget_id            = ""
  budget_limit         = ""
  cost_alert_threshold = ""
  data_classification  = ""
  compliance_required  = ""
  compliance           = "None"
  criticality          = "Medium"
  environment          = "dev"
  status               = "Live"
  country              = "th"

  public_network_access_enabled     = false
  is_virtual_network_filter_enabled = true

  virtual_network_rules = [
    {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-net-dev/providers/Microsoft.Network/virtualNetworks/vnet-dev/subnets/snet-data"
    }
  ]

  kind       = "GlobalDocumentDB"
  offer_type = "Standard"
}
