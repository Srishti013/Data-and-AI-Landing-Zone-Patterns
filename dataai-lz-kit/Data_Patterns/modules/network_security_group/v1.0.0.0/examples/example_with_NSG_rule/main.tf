terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  nsg_rules = {
    "rule01" = {
      name                       = "deny-outbound-80-88"
      access                     = "Deny"
      destination_address_prefix = "*"
      destination_port_range     = "80-88"
      direction                  = "Outbound"
      priority                   = 100
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
    "rule02" = {
      name                       = "allow-inbound-http-https"
      access                     = "Allow"
      destination_address_prefix = "*"
      destination_port_ranges    = ["80", "443"]
      direction                  = "Inbound"
      priority                   = 200
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
    }
  }
}

# Example - deploys an NSG with custom security rules.
module "nsg" {
  #checkov:skip=CKV_AZURE_160:Example code - HTTP access restriction not in scope
  source = "../../"

  # MBB Naming Module Variables (Required)
  env                = "dev"
  au                 = "0233985"
  owner              = "CloudOps"
  resource_type_code = "nsg"
  app_code           = "myapp"
  bu                 = "IT"

  # Resource Group (Required)
  resource_group_name = "rg-example-dev"

  # Mandatory Tags
  app_name             = "My NSG Application"
  app_support          = "support@company.com"
  environment          = "Development"
  business_owner       = "John Doe"
  business_unit        = "IT Operations"
  product_version      = "1.0.0"
  criticality          = "Medium"
  cost_center          = "CC1234"
  cost_allocation_unit = "Platform"
  data_classification  = "Internal"
  compliance           = "None"
  budget_id            = "BUD001"

  enable_telemetry = false
  security_rules   = local.nsg_rules
}
