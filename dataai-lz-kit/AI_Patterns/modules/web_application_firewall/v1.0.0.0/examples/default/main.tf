terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.2"
    }
  }
}

provider "azurerm" {
  features {}
}

## End of section to provide a random Azure region for the resource group

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = "southeastasia"
  name     = "rg-example"
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"

  env            = "dev"
  au             = "0233985"
  owner          = "Infrastructure Team"
  app_code       = "infra"
  bu             = "IT"
  app_name       = "Test Application"
  business_unit  = "Information Technology"
  business_owner = "John Doe"
  budget_id      = "BUD-001"
  criticality    = "High"
  environment    = "Development"
  service        = "waf"

  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  # ...
  location = azurerm_resource_group.this.location
  managed_rules = {
    managed_rule_set = {
      owasp = {
        version = "3.2"
        type    = "OWASP"
      }
    }
  }
  name                = "fwpol-example"
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry # see variables.tf
  policy_settings = {
    enabled                                   = false
    file_upload_limit_in_mb                   = 100
    js_challenge_cookie_expiration_in_minutes = 30
    max_request_body_size_in_kb               = 128
    mode                                      = "Detection"
    request_body_check                        = true
    request_body_inspect_limit_in_kb          = 128
  }
}
