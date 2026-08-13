terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  # skip_provider_registration = true
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "resource_group" {
  source = "../../"

  # MBB Naming Module Variables (Required)
  env                = "dev"
  au                 = "0233985"
  owner              = "CloudOps"
  resource_type_code = "rg"
  app_code           = "myapp"
  bu                 = "IT"

  # Mandatory Tags (Required)
  app_name            = "My Resource Group"
  app_support         = "support@company.com"
  business_unit       = "IT Operations"
  business_owner      = "John Doe"
  product_version     = "1.0.0"
  cost_center         = "CC1234"
  budget_id           = "BUD001"
  data_classification = "Internal"
  criticality         = "Medium"
  environment         = "Development"
}

output "name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

# Module owners should include the full resource via a 'resource' output
# https://confluence.ei.leidos.com/display/ECM/Terraform+ECM+Style+Guide#TerraformECMStyleGuide-TFFR2-Category:Outputs-AdditionalTerraformOutputs
output "resource" {
  description = "This is the full output for the resource group."
  value       = module.resource_group
}

output "resource_id" {
  description = "The resource Id of the resource group"
  value       = module.resource_group.resource_id
}
