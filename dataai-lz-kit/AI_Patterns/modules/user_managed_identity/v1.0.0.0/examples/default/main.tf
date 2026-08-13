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

resource "azurerm_resource_group" "this" {
  location = "southeastasia"
  name     = "rg-uami-example"
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  #checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash
  source = "../../"

  env                 = "dev"
  au                  = "0233985"
  owner               = "Infrastructure Team"
  app_code            = "infra"
  bu                  = "IT"
  app_name            = "Test Application"
  business_unit       = "Information Technology"
  business_owner      = "John Doe"
  budget_id           = "BUD-001"
  criticality         = "High"
  environment         = "Development"
  service             = "Infrastructure"
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry # see variables.tf
}
