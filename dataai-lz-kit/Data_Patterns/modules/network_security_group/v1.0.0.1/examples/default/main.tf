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

# Example - deploys a basic NSG with no custom rules.
module "nsg" {
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
  app_name            = "My NSG Application"
  environment         = "Development"
  business_owner      = "John Doe"
  business_unit       = "IT Operations"
  criticality         = "Medium"
  cost_center         = "CC1234"
  data_classification = "Internal"
  compliance          = "None"
  budget_id           = "BUD001"

  enable_telemetry = false
}
